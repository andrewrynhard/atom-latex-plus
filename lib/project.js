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

  onDidLoadError(callback) {
    this.emitter.on("did-load-error-project", callback);
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

    this.subscription = this.onDidChange(async () => {
      try {
        await this._set();
        this.error = null;
      } catch (e) {
        this.error = e;
        this.emitter.emit("did-load-error-project");
      }
    });

    try {
      await this._set();
      this.emitter.emit("did-load-project");
      this.error = null;
    } catch (e) {
      this.error = e;
      this.emitter.emit("did-load-error-project");
    }
  }

  _set() {
    return this.read().then((data) => {
      project = JSON.parse(data);

      // FIXME: make this async
      texRoot =  path.join(project.projectPath, project.root)
      if (!fs.existsSync(texRoot)) {
        throw new Error("Root invalid.");
      }

      switch (project.program) {
        case "pdflatex":
          break;
        case "xelatex":
        case "lualatex":
          project.texProgram = `-${project.texProgram}`;
          break;
        default:
          throw new Error("Program invalid.");
      }

      if (project.output == "" || project.output == "." || project.output == "./") {
        throw new Error("Output invalid.");
      }

      this.projectPath = project.projectPath;
      this.texTitle = project.title;
      this.texRoot = texRoot;
      this.texOutput = path.join(this.projectPath, project.output);
      this.texLog = path.join(this.texOutput, path.basename(this.texRoot).split(".")[0] + ".log");
      this.item = path.join(this.texOutput, path.basename(this.texRoot).split(".")[0] + ".pdf");
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
