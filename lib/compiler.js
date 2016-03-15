"use babel";

import {exec} from "child_process";
import fs from "fs";
import path from "path";
import {Emitter} from "atom";

export default class Compiler {
  constructor() {
    this.emitter = new Emitter();
  }

  onDidCleanSuccess(callback) {
    this.emitter.on("did-clean-success", callback);
  }

  onDidCompileSuccess(callback) {
    this.emitter.on("did-compile-success", callback);
  }

  onDidCompileError(callback) {
    this.emitter.on("did-compile-error", callback);
  }

  destroy() {
    this.emitter.dispose();
  }

  latex_build(cmd, options, project, userData) {
    args = this.build_args(project);
    command = `${cmd} ${args.join(" ")}`;
    console.log(command);
    proc = exec(command, options, (err, stdout, stderr) => {
      this.pid = proc.pid;
      this.err = err;
      this.stdout = stdout;
      this.stderr = stderr;
      if (err) {
        this.emitter.emit("did-compile-error", userData);
      }
      else {
        this.emitter.emit("did-compile-success", userData);
      }
    });
  }

  latex_clean(cmd, options, project) {
    args = this.clean_args(project);
    command = `${cmd} ${args.join(" ")}`;
    console.log(command)
    proc = exec(command, options, (err, stdout, stderr) => {
      this.pid = proc.pid;
      this.err = err;
      this.stdout = stdout;
      this.stderr = stderr;
      this.emitter.emit("did-clean-success");
    });
  }

  build_args(project) {
    args = [];

    latexmk_common = "-interaction=nonstopmode -f -cd -file-line-error -synctex=1";
    latexmk_defaults = "-bibtex -pdf -shell-escape";
    args.push(latexmk_common);
    if (atom.config.get("latex-plus.advancedEnabled")) {
      // Filter out unwanted options.
      latexmk_options = project.latexmkOptions;
      unwanted = ["-cd-", "-f-", "-h", "-help", "--help", "-xelatex", "-lualatex"];
      let nUnwanted = unwanted.length;
      for (let opt = 0; opt < nUnwanted; opt++) {
        latexmk_options = latexmk_options.replace(new RegExp(unwanted[opt], "g"), "");
      }
      args.push(latexmk_options);
    }
    else {
      args.push(latexmk_defaults);
    }

    if (project.texProgram !== "pdflatex") {
      args.push(project.texProgram);
    }

    args.push(`-outdir=\"${project.texOutput}\"`);
    args.push(`\"${project.texRoot}\"`);

    return args;
  }

  clean_args(project) {
    args = [];
    args.push("-C -cd");
    args.push(`-outdir=\"${project.texOutput}\"`);
    args.push(`\"${project.texRoot}\"`);
    return args;
  }

  kill(pid) {
    if (!this.pid) {
      console.log("No pid to kill.");
    }
    else {
      try {
        process.kill(this.pid, "SIGINT");
      }
      catch (e) {
        if (e.code === "ESRCH") {
          throw new Error(`Process ${this.pid} has already been killed.`);
        }
        else {
          throw (e);
        }
      }
    }
  }
}
