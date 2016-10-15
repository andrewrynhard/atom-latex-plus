"use babel";

export default {
  texBin: {
    title: "TeX Bin",
    description: "Location of your TeX installation bin.",
    type: "string",
    default: "",
    order: 1,
  },

  ghostscriptBin: {
    title: "Ghostscript conversion utilities",
    description: "Path to ps2pdf and dvipdf",
    type: "string",
    default: "",
    order: 2,
  },

  texInputs: {
    title: "TeX Packages",
    description: "Location of your custom TeX packages directory.",
    type: "string",
    default: "",
    order: 3,
  },

  advancedEnabled: {
    title: "Enable advanced LaTeXmk Options",
    type: "boolean",
    default: false,
    order: 4,
  },

  synctexVertAlign: {
    title: "SyncTeX Vertical Alignment",
    description: "A number between 0 (top) and 1 (bottom), e.g., 0.5 for vertical centering.",
    type: "number",
    default: 0.0,
    minimum: 0.0,
    maximum: 1.0,
    order: 5,
  },

  projectDefaults: {
    type: "object",
    title: "Default Project Settings",
    properties: {
      outputPath: {
        title: "Output Path",
        description: "The path relative to a project root where the compilation \
                      output will be saved.",
        type: "string",
        default: ".latex",
      },

      postCompileAction: {
        title: "Post Compile Action",
        description: "Action to be performed after the compilation. Note that, if \
                      `link` or `copy` is chosen, any file at `Post Compile Action \
                      Path` whose name clashes with `'texroot'.pdf` will be overwritten. \
                      Invoke the `edit` command to chek a project `texroot`.",
        type: "string",
        default: "link",
        enum: [
          "none",
          "link",
          "copy"
        ],
      },

      postCompileActionPath: {
        title: "Post Compile Action Path",
        description: "The path relative to a project root where the pdf is symlinked/copied to.",
        type: "string",
        default: "",
      },
    },
    order: 6,
  },
};
