"use babel";

import fs from "fs";
import path from "path";

import {Disposable, CompositeDisposable} from "atom";
import Config from "./config";
import Project from "./project";
import Environment from "./environment";
import Compiler from "./compiler";
import Parser from "./parser";
import Status from "./status";
import SyncTeX from "./synctex";


export default {
  config: Config,
  status: new Status(),
  environment: new Environment(),
  compiler: new Compiler(),
  parser: new Parser(),
  synctex: new SyncTeX(),
  disposables: new CompositeDisposable(),

  async activate() {
    this.commands = atom.commands.add("atom-workspace", {
      "latex-plus:compile": async () => {
        this.saveAll();
        try {
          await this.setProject();
        }
        catch (e) {
          console.log(e);
          return;
        }

        this.status.updateStatusBarMode("compile");
        this.compiler.latex_build("latexmk", this.environment.options, this.project);
      },
      "latex-plus:compile-and-sync": async () => {
        this.saveAll();
        try {
          await this.setProject();
        }
        catch (e) {
          console.log(e);
          return;
        }

        const editor = atom.workspace.getActivePaneItem();
        const syncOptions = {
          filePath: editor.buffer.file.path,
          cursorPosition: editor.getCursorBufferPosition()
        };

        this.status.updateStatusBarMode("compile");
        this.compiler.latex_build(
          "latexmk",
          this.environment.options,
          this.project,
          syncOptions
        );
      },
      "latex-plus:sync": async () => {
        if (! this.project) {
          try {
            await this.setProject();
          }
          catch (e) {
            console.log(e);
            return;
          }
        }

        editor = atom.workspace.getActivePaneItem();
        await this.openOutput();

        this.status.updateStatusBarMode("sync");
        this.synctex.syncView(
          editor.buffer.file.path,
          editor.getCursorBufferPosition(),
          this.viewer,
          this.environment.options
        );
      },
      "latex-plus:edit": async () => {
        if (! this.project) {
          try {
            await this.setProject();
          }
          catch (e) {
            console.log(e);
            return;
          }
        }

        this.status.updateStatusBarMode("edit");
        this.project.edit();
      },
      "latex-plus:clean": async () => {
        if (! this.project) {
          try {
            await this.setProject();
          }
          catch (e) {
            console.log(e);
            return;
          }
        }

        if (this.project.error) {
          return;
        }

        this.status.updateStatusBarMode("clean");
        this.compiler.latex_clean("latexmk", this.environment.options, this.project);
      },
    });

    configChangedEvent = new Disposable(atom.config.onDidChange(() => {
      this.environment = new Environment();
    }));

    syncSuccessEvent = new Disposable(
      this.synctex.onDidSyncSuccess(() => {
        this.status.updateStatusBarTitle(this.project.texTitle);
        this.status.updateStatusBarMode("ready");
        this.status.clear();
      }
    ));

    cleanSuccessEvent = new Disposable(
      this.compiler.onDidCleanSuccess(() => {
        this.status.updateStatusBarTitle(this.project.texTitle);
        this.status.updateStatusBarMode("ready");
        this.status.clear();
      }
    ));

    compileSuccessEvent = new Disposable(
      this.compiler.onDidCompileSuccess(async (syncOptions) => {
        this.status.updateStatusBarTitle(this.project.texTitle);
        if (syncOptions !== undefined) {
          this.status.updateStatusBarMode("sync");
          await this.openOutput();
          this.synctex.syncView(
            syncOptions.filePath,
            syncOptions.cursorPosition,
            this.viewer,
            this.environment.options
          );
        }
        else {
          this.status.updateStatusBarMode("ready");
          this.status.clear();
          this.openOutput();
        }
      }
    ));

    compileErrorEvent = new Disposable(this.compiler.onDidCompileError(() => {
      this.status.updateStatusBarMode("error");
      this.parser.parse(this.getRootPath(), this.project.texLog)
      .then((errors) => {
        if (errors.length === 0) {
          atom.notifications.addError("LaTeXmk Error:", {
            detail: this.compiler.stderr,
            dismissable: true,
          });
        }
        else {
          this.status.showLogErrors(errors);
        }
      }, (e) => {
        console.log("YEAH");
        atom.notifications.addError("Parsing Error:", {
          detail: e,
          dismissable: true,
        });
      });
    }));

    this.configSubscriptions = new CompositeDisposable(configChangedEvent);
    this.synctexSubscriptions = new CompositeDisposable(syncSuccessEvent);
    this.compilerSubscriptions = new CompositeDisposable(cleanSuccessEvent,
                                                         compileSuccessEvent,
                                                         compileErrorEvent);
  },

  deactivate() {
    // TODO: clean up any projects that no longer exist
    this.configSubscriptions.destroy();
    this.synctexSubscriptions.destroy();
    this.compilerSubscriptions.destroy();
  },

  async setProject() {
    filePath = atom.workspace.getActiveTextEditor().getPath();
    [atomProject, relativeToAtomProject] = atom.project.relativizePath(filePath);

    // check if the current latex project contains the active file
    if (this.project && this.project.projectPath === atomProject) {
      return;
    }

    if (!atom.project.contains(filePath)) {
      atom.notifications.addError(`The file ${path.basename(filePath)} must exist in an Atom project.`);
      return;
    }

    this.project = new Project(atomProject, relativeToAtomProject);

    projectChangedEvent = new Disposable(this.project.onDidChange(() => {
      this.status.updateStatusBarTitle(this.project.texTitle);
    }));

    projectLoadedEvent = new Disposable(this.project.onDidLoad(() => {
      this.status.updateStatusBarMode("load");
      atom.notifications.addSuccess(`${this.project.texTitle} loaded.`);
    }));

    projectErrorEvent = new Disposable(this.project.onDidLoadError(() => {
      this.status.updateStatusBarMode("invalid");
      atom.notifications.addError("Configuration Error: Invalid parameter", {
        detail: this.project.error.message,
      });
    }));

    if (this.projectSubscriptions) {
      this.projectSubscriptions.dispose();
    }

    this.projectSubscriptions = new CompositeDisposable(projectLoadedEvent,
                                                        projectChangedEvent,
                                                        projectErrorEvent);

    try {
      await this.project.load();
    }
    catch (e) {
      throw e;
    }
  },

  async openOutput() {
    // link and open the output upon successful compilation
    let unlinkSymlink = function(target, path) {
      return new Promise(function(resolve, reject) {
        fs.readlink(path, function(err, linkString) {
          if (err && err.code === "ENOENT") {
            // No need to remove because there exists no entry at the path
            resolve(true);
          }
          else if (err) {
            reject(err);
          }
          else if (linkString === target) {
            // No need to remove because symlink at path points to target
            resolve(false);
          }
          else {
            fs.unlink(path, function(err) {
              if (err) {
                reject(err);
              }
              resolve(true);
            });
          }
        });
      });
    };
    let symlink = function(target, path) {
      return new Promise(function(resolve, reject) {
        fs.symlink(target, path,
          function (err) {
            if (err) {
              reject(err);
            }
            resolve();
          }
        );
      });
    };
    let errorCallback = function(target, path, err) {
      atom.notifications.addError(
        "Error while symlinking " + path + " to " + target,
        {detail: err.toString()}
      );
    };
    let syncTexPath = path.join(this.project.projectPath, path.basename(this.project.texSyncTeX));
    let syncTexTargetPath = this.project.texSyncTeX;
    let itemPath = path.join(this.project.projectPath, path.basename(this.project.item));
    let itemTargetPath = this.project.item;
    await unlinkSymlink(syncTexTargetPath, syncTexPath)
      .then(function(res) { if (res) { symlink(syncTexTargetPath, syncTexPath); }})
      .catch(errorCallback.bind(this, syncTexTargetPath, syncTexPath));
    await unlinkSymlink(itemTargetPath, itemPath)
      .then(function(res) { if (res) { symlink(itemTargetPath, itemPath); }})
      .catch(errorCallback.bind(this, itemTargetPath, itemPath));

    if (!atom.config.get("latex-plus.openOutputEnabled")) {
      return;
    }

    const previousActivePane = atom.workspace.getActivePane();
    const options = { split: 'right', searchAllPanes: true };
    this.viewer = await atom.workspace.open(path.basename(this.project.item), options);
    previousActivePane.activate();
  },

  getRootPath() {
    [atomProject, relativeToAtomProject] = atom.project.relativizePath(this.project.texRoot);
    return path.join(atomProject, path.dirname(relativeToAtomProject));
  },

  saveAll() {
    // TODO: save only latex associated files
    for (pane of atom.workspace.getPanes()) {
      pane.saveItems();
    }
  },

  consumeStatusBar(status) {
    this.status.initialize(status);
    this.status.attach();
    this.disposables.add(new Disposable(() => {
      this.status.detach();
    }));
  },
};
