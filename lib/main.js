"use babel";

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
  project: new Project(),
  environment: new Environment(),
  compiler: new Compiler(),
  parser: new Parser(),
  status: new Status(),
  subscriptions: new CompositeDisposable,
  disposables: new CompositeDisposable,

  activate() {
    this.commands = atom.commands.add("atom-workspace", {
      "latex-plus:compile": async () => {
        for (pane of atom.workspace.getPanes()) {
          pane.saveItems()
        }

        filePath = atom.workspace.getActiveTextEditor().getPath();
        fileBasename = path.basename(filePath);
        fileDirname = path.dirname(filePath);

        if (!atom.project.contains(filePath)) {
          atom.notifications.addError(`Error: ${fileBasename} does not exist in the atom workspace.`);
          return;
        }

        // check if the current latex project contains the active file
        [atomProject, relativeToAtomProject] = atom.project.relativizePath(filePath);
        this.status.updateStatusBar("compile")
        if (this.project.path != atomProject) {
          await this.project.load(atomProject)
          this.compiler.execute("latexmk", this.environment.options, this.project);
        } else {
          this.compiler.execute("latexmk", this.environment.options, this.project);
        }
      },
      "latex-plus:edit": () => {
        this.project.edit()
      }
    });

    atom.config.observe('latex-plus.texBin', (newValue) => {
      this.environement = new Environment();
    });

    atom.config.observe('latex-plus.texInputs', (newValue) => {
      this.environement = new Environment();
    });

    this.subscriptions.add(this.project.onDidLoad(() => {
        this.status.updateStatusBar("load", this.project.texTitle)
      })
    );

    this.subscriptions.add(this.compiler.onDidCompileSuccess(() => {
        this.status.destroyErrors();
      })
    );

    this.subscriptions.add(this.compiler.onDidCompileError(() => {
        parse = this.parser.parse(this.project.path, this.project.texLog);
        parse.then((errors) => {
          this.status.addErrors(errors);
        });
      })
    );
  },

  consumeStatusBar(status) {
    this.status.initialize(status)
    this.status.attach()
    this.disposables.add(new Disposable(() => {
      this.status.detach()
    }));
  }
}
