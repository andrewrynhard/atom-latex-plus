module.exports =
  useHardwareAcceleration:
    type: 'boolean'
    default: true
    description: 'Disabling will improve editor font rendering but reduce scrolling performance.'
  enableShellEscape:
    type: 'boolean'
    default: false
  outputDirectory:
    description: 'All files generated during a build will be redirected here.
      Leave blank if you want the build output to be stored in the same
      directory as the TeX document.'
    type: 'string'
    default: ''
  texPath:
    title: 'TeX Path'
    description: "The full path to your TeX distribution's bin directory."
    type: 'string'
    default: ''
  texInputs:
    title: 'TeX Inputs'
    description: "The full path to your custom TeX packages directory."
    type: 'string'
    default: ''
  engine:
    description: 'TeX engine'
    type: 'string'
    default: 'pdflatex'
    enum: ['pdflatex', 'lualatex', 'xelatex']
  customEngine:
    description: 'Enter command for custom TeX engine. Overrides Engine.'
    type: 'string'
    default: ''
