module.exports =
  texPath:
    title: 'TeX Path'
    description: "The full path to your TeX distribution's bin directory."
    type: 'string'
    default: ''
    order: 1
  engine:
    title: 'TeX Flavor'
    description: 'Engine used to compile a TeX file.'
    type: 'string'
    default: 'pdflatex'
    enum: ['pdflatex', 'lualatex', 'xelatex']
    order: 2
  texInputs:
    title: 'TeX Inputs'
    description: "The full path to your custom TeX packages directory."
    type: 'string'
    default: ''
    order: 3
  outputDirectory:
    title: 'Output Directory'
    description: 'All files generated during a build will be redirected here.
      Leave blank if you want the build output to be stored in the same
      directory as the TeX document.'
    type: 'string'
    default: ''
    order: 4
  enableShellEscape:
    title: 'Shell Escape Flag for latexmk'
    type: 'boolean'
    default: false
    order: 5
  useHardwareAcceleration:
    type: 'boolean'
    default: true
    description: 'Disabling will improve editor font rendering but reduce
      scrolling performance.'
    order: 99
