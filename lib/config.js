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

  synctexEnabled: {
    title: 'Enable SyncTeX',
    type: 'boolean',
    default: false,
    order: 8
  },

  synctexVertAlign: {
    title: 'SyncTeX Vertical Alignment',
    description: "A number between 0 (top) and 1 (bottom), e.g., 0.5 for vertical centering.",
    type: 'number',
    default: 0.0,
    minimum: 0.0,
    maximum: 1.0,
    order: 9
  }
}
