"use babel";

import {exec} from "child_process";
import fs from "fs";
import path from "path";
import {Emitter} from "atom";

export default class Compiler {
  constructor() {
    this.emitter = new Emitter;
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

  latex_build(cmd, options, project) {
    args = this.build_args(project);
    command = `${cmd} ${args.join(" ")}`;
    console.log(command)
    proc = exec(command, options, (err, stdout, stderr) => {
      this.pid = proc.pid;
      this.err = err;
      this.stdout = stdout;
      this.stderr = stderr;
      if (err) {
        this.emitter.emit("did-compile-error");
      } else {
        this.emitter.emit("did-compile-success");
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

    args.push("-interaction=nonstopmode -f -cd -pdf -file-line-error");

    if (atom.config.get("latex-plus.bibtexEnabled")) {
      args.push("-bibtex");
    }

    if (atom.config.get("latex-plus.shellEscapeEnabled")) {
      args.push("-shell-escape");
    }

    if (project.texProgram != "pdflatex") {
      args.push(project.texProgram)
    }

    args.push(`-outdir=\"${project.texOutput}\"`);
    args.push(`\"${project.texRoot}\"`);

    return args
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
      console.log("No pid to kill.")
    } else {
      try {
        process.kill(this.pid, "SIGINT")
      } catch (e) {
        if (e.code == "ESRCH") {
          throw new Error(`Process ${this.pid} has already been killed.`)
        } else {
          throw (e)
        }
      }
    }
  }
}
