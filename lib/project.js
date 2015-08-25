"use babel";

import fs from "fs";
import path from "path";
import {File, Emitter}  from "atom";

const packageDir = atom.packages.resolvePackagePath("latex-plus");
const projectsDir = path.join(packageDir, "projects");

export default class Project extends File {
  // TODO: ensure that atomProject is a directory
  constructor(atomProject) {
    filePath = path.join(projectsDir, `${path.basename(atomProject)}.json`);
    super(filePath);
  }

  onDidLoad(callback) {
    this.emitter.on("did-load-project", callback);
  }

  async load() {
    exists = await this.exists();
    if (!exists) {
      try {
        await this._new();
      } catch (e) {

      }
    }

    if (this.subscription) {
      this.subscription.dispose()
    }

    this.subscription = this.onDidChange(() => {
      this._set();
    });

    try {
      await this._set();
    } catch (e) {

    }

    this.emitter.emit("did-load-project");
  }

  _set() {
    return this.read().then((data) => {
      project = JSON.parse(data);

      this.projectPath = project.projectPath;
      this.texTitle = project.title;

      this.texRoot = path.join(this.projectPath, project.root);
      // FIXME: make this async
      if (!fs.existsSync(this.texRoot)) {
        atom.notifications.addError(`Root does not exist: ${this.texRoot}`);
        reject();
      }

      switch (project.program) {
        case "pdflatex":
          this.texProgram = "pdflatex";
          break;
        case "xelatex":
          this.texProgram = "-xelatex";
          break;
        case "lualatex":
          this.texProgram = "-lualatex";
          break;
        default:
          atom.notifications.addError(`Program ${project.program} is invalid.`);
          reject();
      }

      this.texOutput = path.join(this.projectPath, project.output);
      if (project.output == "") {
        atom.notifications.addError(`An output must be specified`);
      }

      this.texLog = path.join(this.texOutput, path.basename(this.texRoot).split(".")[0] + ".log");
      this.item = path.join(this.texOutput, path.basename(this.texRoot).split(".")[0] + ".pdf");

      resolve();
    });
  }

  async _new() {
    const contents =
`{
  "projectPath": "${atomProject}",
  "title": "LaTeX-Plus Project",
  "root": "main.tex",
  "program": "pdflatex",
  "output": ".latex"
}`

    try {
      await this.create();
      await this.write(contents);
    } catch (e) {

    }
  }

  edit() {
    atom.workspace.open(this.getPath());
  }
}
