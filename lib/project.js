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
    this.atomProject = atomProject
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
        throw e
      }
    }

    if (this.subscription) {
      this.subscription.dispose()
    }

    set = async () => {
      try {
        await this._set();
        this.error = null;
        this.emitter.emit("did-load-project");
      } catch (e) {
        this.error = e;
        this.emitter.emit("did-load-error-project");
        throw e
      }
    }

    this.subscription = this.onDidChange(async () => {
      await set();
    });

    await set();
  }

  _set() {
    return this.read().then((data) => {
      project = JSON.parse(data);

      // FIXME: make this async
      texRoot =  path.join(project.projectPath, project.root)
      if (!fs.existsSync(texRoot)) {
        throw new Error(`Invalid root: ${texRoot}`);
      }

      switch (project.program) {
        case "pdflatex":
          break;
        case "xelatex":
        case "lualatex":
          project.texProgram = `-${project.program}`;
          break;
        default:
          throw new Error(`Invalid program: ${project.program}`);
      }

      texOutput = path.join(project.projectPath, project.output);
      if (path.resolve(texOutput) == path.resolve(this.atomProject)) {
        throw new Error(`Invalid output: ${texOutput}`);
      }

      this.projectPath = project.projectPath;
      this.texTitle = project.title;
      this.texRoot = texRoot;
      this.texProgram = project.texProgram;
      this.texOutput = texOutput;
      this.texLog = path.join(this.texOutput, path.basename(this.texRoot).split(".")[0] + ".log");
      this.item = path.join(this.texOutput, path.basename(this.texRoot).split(".")[0] + ".pdf");
    });
  }

  async _new() {
    const contents =
`{
  "projectPath": "${this.atomProject}",
  "title": "LaTeX-Plus Project",
  "root": "main.tex",
  "program": "pdflatex",
  "output": ".latex"
}`

    try {
      await this.create();
      await this.write(contents);
    } catch (e) {
      throw e;
    }
  }

  edit() {
    atom.workspace.open(this.getPath());
  }
}
