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

        this.status.updateStatusBarMode("compiling");
        this.compiler.latex_build("latexmk", this.environment.options, this.project);
      },
      "latex-plus:sync": () => {
        this.openOutput();
        target = path.join(this.project.projectPath, path.basename(this.project.item));
        viewer = null;
        for (item of atom.workspace.getPaneItems()) {
          if (path.basename(item.filePath) === path.basename(target)) {
            viewer = item;
            break;
          }
        }
        if (!viewer) {
          return;
        }
        this.synctex.syncView(atom.workspace.getActivePaneItem(), viewer, this.environment.options);
      },
      "latex-plus:edit": () => {
        this.project.edit();
      },
      "latex-plus:clean": () => {
        if (this.project.error) {
          return;
        }

        this.status.updateStatusBarMode("cleaning");
        this.compiler.latex_clean("latexmk", this.environment.options, this.project);
      }
    });

    configChangedEvent = new Disposable(atom.config.onDidChange(() => {
      this.environment = new Environment();
    }));

    cleanSuccessEvent = new Disposable(
      this.compiler.onDidCleanSuccess(() => {
        this.status.updateStatusBarTitle(this.project.texTitle)
        this.status.updateStatusBarMode("ready")
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
        throw e;
      });
    }));

    this.configSubscriptions = new CompositeDisposable(configChangedEvent);
    this.compilerSubscriptions = new CompositeDisposable(cleanSuccessEvent,
                                                         compileSuccessEvent,
                                                         compileErrorEvent);
  },

  deactivate() {
    // TODO: clean up any projects that no longer exist
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

    this.project = new Project(atomProject);

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

  copyOverFile(source, target, callback) {
    fs.exists(target, (exist) => {
      if (exists) {
        fs.unlink(target, () => {
          read = fs.createReadStream(source);
          read.on("error", (e) => {
            throw e;
          });

          write = fs.createWriteStream(target);
          write.on("error", (e) => {
            throw e;
          });
          write.on("finish", callback);

          read.pipe(write);
        });
      }
    });
  },

  openOutput() {
    // copy and open the output upon successful compilation
    target = path.join(this.project.projectPath, path.basename(this.project.item));
    source = this.project.item;

    copySyncTeX = (callback) => {
      this.copyOverFile(
        this.project.texSyncTeX,
        path.join(this.project.projectPath, path.basename(this.project.texSyncTeX)),
        callback);
    };

    copySyncTeX(() => {
      this.copyOverFile(source, target, (ex) => {
        if (!atom.config.get("latex-plus.openOutputEnabled")) {
          return;
        }

        alreadyOpen = false;
        for (pane of atom.workspace.getPaneItems()) {
          if (path.basename(pane.filePath) === path.basename(target)) {
            alreadyOpen = true;
            break;
          }
        }

        if (!alreadyOpen) {
          pane = atom.workspace.getActivePane();
          outputPane = pane.splitRight();
          atom.workspace.open(target, outputPane);
        }
      });
    });
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
