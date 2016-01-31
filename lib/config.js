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
    order: 2
  },

  advancedEnabled: {
    title: 'Enable advanced LaTeXmk Options',
    type: 'boolean',
    default: false,
    order: 3
  },

  openOutputEnabled: {
    title: 'Open Output',
    description: 'Open the output file after successful compilation.',
    type: 'boolean',
    default: true,
    order: 4
  },

  ghostscriptBin: {
    title: 'Ghostscript conversion utilities',
    description: 'Path to ps2pdf and dvipdf',
    type: 'string',
    default: '',
    order: 5
  }
}
