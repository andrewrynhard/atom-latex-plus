"use babel";

export default {
  texBin: {
    title: 'TeX Bin',
    description: "Location of your TeX installation bin.",
    type: 'string',
    default: '',
    order: 1
  },

  texInputs: {
    title: 'TeX Packages',
    description: "Location of your custom TeX packages directory.",
    type: 'string',
    default: '',
    order: 3
  },

  bibtexEnabled: {
    title: 'Enable BibTeX',
    type: 'boolean',
    default: false,
    order: 5
  },

  shellEscapeEnabled: {
    title: 'Enable Shell Escape',
    type: 'boolean',
    default: false,
    order: 6
  },

  openOutputEnabled: {
    title: 'Open Output',
    description: 'Open the output file after successful compilation.',
    type: 'boolean',
    default: true,
    order: 7
  },

  ps2pdfBin: {
    title: 'ps2pdf Bin',
    description: "Path to ps2pdf and dvipdf.",
    type: 'string',
    default: '',
    order: 8
  }
}
