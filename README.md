# LaTeX-Plus

[![Travis branch](https://img.shields.io/travis/andrewrynhard/atom-latex-plus/master.svg?style=flat-square)]()
[![Plugin installs!](https://img.shields.io/apm/dm/latex-plus.svg?style=flat-square)](https://atom.io/packages/latex-plus)
[![Package version!](https://img.shields.io/apm/v/latex-plus.svg?style=flat-square)](https://atom.io/packages/latex-plus)

LaTeX for Atom.

## About
  A `latexmk` wrapper developed for [Atom](https://atom.io).
#### Features
  * SyncTeX
  * Project management
  * Error detection
  * `TEXINPUTS`

## Usage
#### Quick Start
  1. Ensure a latex distribution is installed, and that `latexmk` and `synctex` is in your `PATH`.
  2. Configure `TeX Bin` in the package settings to the location of your latex distribution's installation location.
  3. Ensure that the `language-latex` package for Atom is installed.
  4. Open a tex file within the directory containing your LaTeX project.
  5. `compile` the project.

#### Project Configuration
LaTeX-Plus keeps metadata on projects using a `JSON` formatted file that is
easily configurable. Simply invoke the `edit` command to customize to your
liking.

#### Keymaps

###### OS X
* compile and sync project: `cmd-;`
* compile project: `alt-cmd-:`
* sync project: `alt-cmd-;`
* edit project: `cmd-'`
* clean project: `alt-cmd-'`

###### Linux and Windows
* compile and sync project: `ctrl-;`
* compile project: `alt-ctrl-:`
* sync project `ctrl-alt-;`
* edit project: `ctrl-'`
* clean project: `ctrl-alt-'`

![screencast](https://raw.githubusercontent.com/andrewrynhard/atom-latex-plus/resources/gif/compile.gif)

![screencast](https://raw.githubusercontent.com/andrewrynhard/atom-latex-plus/resources/gif/errors.gif)
