"use babel";

import fs from "fs";
import path from "path";

import {Disposable, CompositeDisposable} from 'atom';
import Config from "./config";
import Project from "./project";
import Environment from "./environment";
import Compiler from "./compiler";
import Parser from "./parser";
import Status from "./status";


export default {
  config: Config,
  status: new Status(),
  environment: new Environment(),
  compiler: new Compiler(),
  parser: new Parser(),
  disposables: new CompositeDisposable,

  async activate() {
    this.commands = atom.commands.add("atom-workspace", {
      "latex-plus:compile": async () => {
        this.saveAll();
        await this.setProject();
        this.status.updateStatusBarMode("compile");
        this.compiler.execute("latexmk", this.environment.options, this.project);
      },
      "latex-plus:edit": () => {
        this.project.edit()
      }
    });

    configChangedEvent = new Disposable(atom.config.onDidChange(() => {
        this.environment = new Environment();
      })
    )

    compileSuccessEvent = new Disposable(
      this.compiler.onDidCompileSuccess(() => {
        this.status.updateStatusBarTitle(this.project.texTitle)
        this.status.updateStatusBarMode("ready")
        this.status.clear();
        this.openOutput();
      }
    ));

    compileErrorEvent = new Disposable(this.compiler.onDidCompileError(() => {
      this.status.updateStatusBarMode("error");
      this.parser.parse(this.getRootPath(), this.project.texLog)
      .then((errors) => {
          if (errors.length == 0) {
            this.status.showStderr(this.compiler.stderr);
          } else {
            this.status.showLogErrors(errors);
          }
        }, (err) => {
          console.log(err);
        }
      );
    }));

    this.configSubscriptions = new CompositeDisposable(configChangedEvent);
    this.compilerSubscriptions = new CompositeDisposable(compileSuccessEvent,
                                                         compileErrorEvent);
  },

  deactivate() {
    // TODO: clean up any projects that no longer exist
  },

  async setProject() {
    filePath = atom.workspace.getActiveTextEditor().getPath();
    [atomProject, relativeToAtomProject] = atom.project.relativizePath(filePath);
    // check if the current latex project contains the active file
    if (this.project && this.project.projectPath == atomProject) {
      return;
    }

    if (!atom.project.contains(filePath)) {
      atom.notifications.addError(`The file ${path.basename(filePath)} must exist in an Atom project.`);
      return;
    }

    this.project = new Project(atomProject);
    await this.project.load();

    projectChangedEvent = new Disposable(this.project.onDidChange(() => {
        this.status.updateStatusBarTitle(this.project.texTitle)
      })
    )

    projectLoadedEvent = new Disposable(this.project.onDidLoad(() => {
        this.status.updateStatusBarMode("load")
      })
    )

    this.projectSubscriptions = new CompositeDisposable(projectLoadedEvent);

    atom.notifications.addSuccess(`${this.project.texTitle} loaded.`);
  },

  openOutput() {
    // copy and open the output upon successful compilation
    target = path.join(this.project.projectPath, path.basename(this.project.item));
    source = this.project.item;
    fs.exists(target, (exist) => {
      if (exists) {
        fs.unlink(target, () => {
          read = fs.createReadStream(source);
          read.on("error", (err) => {
            console.log(err);
          });

          write = fs.createWriteStream(target);
          write.on("error", (err) => {
            console.log(err);
          });

          write.on("finish", (ex) => {
            for (pane of atom.workspace.getPaneItems()) {
              if (pane.filePath === source) {
                return;
              }
            }

            pane = atom.workspace.getActivePane();
            outputPane = pane.splitRight();
            atom.workspace.open(source, outputPane);
          });

          read.pipe(write);
        });
      }
    })
  },

  getRootPath() {
    [atomProject, relativeToAtomProject] = atom.project.relativizePath(this.project.texRoot);
    return path.join(atomProject, path.dirname(relativeToAtomProject));
  },

  saveAll() {
    // TODO: save only latex associated files
    for (pane of atom.workspace.getPanes()) {
      pane.saveItems()
    }
  },

  consumeStatusBar(status) {
    this.status.initialize(status)
    this.status.attach()
    this.disposables.add(new Disposable(() => {
      this.status.detach()
    }));
  }
}
