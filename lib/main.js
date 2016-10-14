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
    require('atom-package-deps').install('latex-plus').then(() => {

    }).catch((e) => {
      console.log(e)
    })

    // Read again the environment here because some values might be
    // undefined if read before activation
    this.environment = new Environment();

    this.commands = atom.commands.add("atom-workspace", {
      // transact() suppresses calls to atom.config.onDidChange since it can delete this.project
      "latex-plus:compile": async () => { atom.config.transact(async () => {
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
      })},
      "latex-plus:compile-and-sync": async () => { atom.config.transact(async () => {
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
      })},
      "latex-plus:sync": async () => { atom.config.transact(async () => {
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
      })},
      "latex-plus:edit": async () => { atom.config.transact(async () => {
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
      })},
      "latex-plus:clean": async () => { atom.config.transact(async () => {
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
      })},
    });

    configChangedEvent = new Disposable(atom.config.onDidChange("latex-plus.projectDefaults", () => {
      this.environment = new Environment();
      // Force the reload of the project, since now it might depend on some
      // environment variables
      delete this.project;
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

    this.project = new Project(atomProject, relativeToAtomProject, this.environment);

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
    if (this.project.postAction == "none") {
      return;
    }
    let createDirIfNotExists = function(path) {
      return new Promise(function(resolve, reject) {
        fs.stat(path, function(err, stat) {
          if (err && err.code === "ENOENT") {
            // Path does not exists, so make it with the same mode as the project root
            fs.stat(this.project.projectPath, function (err, stat) {
              if (err) {
                reject(err); // This should not happen
              }
              // TODO: make it create non existent intermediate dirs as well
              fs.mkdir(path, stat.mode, function(err) {
                if (err) {
                  reject(err);
                } else {
                  resolve(true);
                }
              });
            });
          } else if (err) {
            reject(err);
          } else {
            // Check that the path is a directory
            resolve(stat.isDirectory());
          }
        });
      });
    };
    // link and open the output upon successful compilation
    let deleteFile = function(path) {
      return new Promise(function(resolve, reject) {
        fs.stat(path, function(err, stat) {
          if (err && err.code === "ENOENT") {
            // No need to remove because there no file at the path
            resolve(true);
          } else if (err) {
            reject(err);
          } else {
            if (stat.isFile()) {
              // Remove
              fs.unlink(path, function(err) {
                if (err) {
                  reject(err);
                }
                resolve(true);
              });
            } else {
              // Not a file
              resolve(false);
            }
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
    let copy = function(origin, dest) {
      return new Promise(function(resolve, reject) {
        fs.readFile(origin,
          function(err, data) {
            if (err) {
              reject(err);
            }
            fs.writeFile(dest, data, function(err) {
              if (err) {
                reject(err);
              }
              resolve();
            });
        });
      });
    };
    let showError = function(str, err) {
      atom.notifications.addError(
        str,
        {detail: err.toString()}
      );
    }
    let errorCallback = function(op, target, path, err) {
      showError("Error while " + op + " " + path + " to " + target, err);
    };
    let postPath = this.project.postPath;
    let postPathOk = true;
    let syncTexPath = path.join(postPath, path.basename(this.project.texSyncTeX));
    let syncTexCompilationPath = this.project.texSyncTeX;
    let itemPath = path.join(postPath, path.basename(this.project.item));
    let itemCompilationPath = this.project.item;
    await createDirIfNotExists(postPath)
      .catch(function(err) {
        showError("Unable to create post compile action path directory", err);
        postPathOk = false;
      });
    if (!postPathOk) {
      return;
    }
    await deleteFile(syncTexPath)
      .then(async function(res) { if (res) { await symlink(syncTexCompilationPath, syncTexPath); }})
      .catch(errorCallback.bind(this, "symlinking", syncTexCompilationPath, syncTexPath));
    if (this.project.postAction == "link") {
      await deleteFile(itemPath)
        .then(async function(res) { if (res) {await symlink(itemCompilationPath, itemPath); }})
        .catch(errorCallback.bind(this, "symlinking", itemCompilationPath, itemPath));
    } else {
      await deleteFile(itemPath)
        .then(async function(res) { if (res) {await copy(itemCompilationPath, itemPath); }})
        .catch(errorCallback.bind(this, "copying", itemCompilationPath, itemPath));
    }

    if (!this.project.openOutput) {
      return;
    }

    const previousActivePane = atom.workspace.getActivePane();
    const options = { split: 'right', searchAllPanes: true };
    this.viewer = await atom.workspace.open(itemPath, options);
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
