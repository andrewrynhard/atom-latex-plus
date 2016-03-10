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
        this.synctex.syncView(editor, this.viewer, this.environment.options);
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
      this.compiler.onDidCompileSuccess(() => {
        this.status.updateStatusBarTitle(this.project.texTitle);
        this.status.updateStatusBarMode("ready");
        this.status.clear();
        this.openOutput();
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
    await fs.symlink(
            this.project.texSyncTeX,
            path.join(this.project.projectPath, path.basename(this.project.texSyncTeX)),
            function (err) {
              console.log("cannot link " + path.basename(this.project.texSyncTeX) + " : " + err);
            });
    await fs.symlink(
            this.project.item,
            path.join(this.project.projectPath, path.basename(this.project.item)),
            function (err) {
              console.log("cannot link " + path.basename(this.project.item) + " : " + err);
            });

    if (!atom.config.get("latex-plus.openOutputEnabled")) {
      return;
    }

    alreadyOpen = false;
    for (pane of atom.workspace.getPaneItems()) {
      if (path.basename(pane.filePath) === path.basename(this.project.item)) {
        alreadyOpen = true;
        break;
      }
    }

    if (!alreadyOpen) {
      pane = atom.workspace.getActivePane();
      outputPane = pane.splitRight();
      await atom.workspace.open(path.basename(this.project.item), outputPane);
      this.viewer = atom.workspace.getActivePaneItem();
    }
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
