"use babel";

import path from "path";

export default class Environment {
  constructor() {
    this.texBin = atom.config.get("latex-plus.texBin");
    // FIXME: package should exit if this is true
    if (this.texBin === "") {
      atom.notifications.addError("A LaTeX installation must be specified in the LaTeX-Plus settings.");
    }

    switch (process.platform) {
      case "darwin":
      case "linux":
        this.delim = ":";
        this.PATH = process.env.PATH;
        break;
      case "win32":
        this.delim = ";";
        this.PATH = process.env.Path;
        break;
      default:
    }

    this.ghostscriptBin = atom.config.get("latex-plus.ghostscriptBin");

    // #TODO: resolve texBin automatically
    this.options = process.env;
    this.options.timeout = 60000;
    this.options.PATH = this.texBin + this.delim + this.ghostscriptBin + this.delim + this.PATH;

    this.texInputs = atom.config.get("latex-plus.texInputs");
    if (this.texInputs !== "") {
      // TEXINPUTS seems to only be available on *nix operating systems
      if (process.platform !== "win32") {
        this.options.TEXINPUTS = this.texInputs + this.delim;
      }
    }

    this.advancedEnabled = atom.config.get("latex-plus.advancedEnabled");
    this.outputPath = atom.config.get("latex-plus.projectDefaults.outputPath");
    this.postCompileAction = atom.config.get("latex-plus.projectDefaults.postCompileAction");
    this.postCompileActionPath = atom.config.get("latex-plus.projectDefaults.postCompileActionPath");
  }
}
