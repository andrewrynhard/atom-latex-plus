"use babel";

import fs from "fs";
import path from "path";
import {File, Emitter}  from "atom";

const packageDir = atom.packages.resolvePackagePath("latex-plus");
const projectsDir = path.join(packageDir, "projects");

export default class Project {
  constructor() {
    this.emitter = new Emitter;
  }

  onDidLoad(callback) {
    this.emitter.on("did-load-project", callback);
  }

  async load(atomProject) {
    filePath = path.join(projectsDir, `${path.basename(atomProject)}.json`);
    file = new File(filePath);

    if (this.file != undefined && this.file.getPath() == file.getPath()) {
      return;
    }

    exists = await file.exists();
    if (!exists) {
      try {
        await this.new(file);
      } catch (e) {

      }
    }

    this.file = file;

    if (this.subscriptions) {
      this.subscriptions.dispose()
    }

    this.subscriptions = file.onDidChange(() => {
      this.set(this.file);
      this.emitter.emit("did-load-project");
    });

    try {
      await this.set(this.file);
    } catch (e) {

    }

    this.emitter.emit("did-load-project");
    atom.notifications.addSuccess(`Project loaded: ${this.texTitle}`)
  }

  set(file) {
    return file.read().then((data) => {
      project = JSON.parse(data);

      this.path = project.path
      this.texTitle = project.title;

      this.texRoot = path.join(project.path, project.root);
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
          atom.notifications.addError(`Invalid program: ${project.project}`);
          reject();
      }

      this.texOutput = path.join(project.path, project.output);
      this.texLog = path.join(this.texOutput, path.basename(this.texRoot).split(".")[0] + ".log");

      resolve();
    });
  }

  async new(file) {
    const contents =
`{
  "path": "${atomProject}",
  "title": "LaTeX-Plus Project",
  "root": "main.tex",
  "program": "pdflatex",
  "output": ".latex"
}`

    try {
      await file.create();
      await file.write(contents);
    } catch (e) {

    }
  }

  edit() {
    atom.workspace.open(this.file.getPath());
  }
}
