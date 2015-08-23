# LaTeX-Plus

[![Plugin installs!](https://img.shields.io/apm/dm/latex-plus.svg?style=flat-square)](https://atom.io/packages/latex-plus)
[![Package version!](https://img.shields.io/apm/v/latex-plus.svg?style=flat-square)](https://atom.io/packages/latex-plus)

LaTeX for Atom.

## Status
| Master | Develop |
|:-----------|:------------|
| [![Build Status](https://travis-ci.org/andrewrynhard/atom-latex-plus.svg?branch=master)](https://travis-ci.org/andrewrynhard/atom-latex-plus)       |        [![Build Status](https://travis-ci.org/andrewrynhard/atom-latex-plus.svg?branch=develop)](https://travis-ci.org/andrewrynhard/atom-latex-plus)

## About
  A `latexmk` wrapper developed for [Atom](https://atom.io).
#### Features
  * Project management
  * Error detection
  * TEXINPUTS

## Usage
#### Quick Start
  1. Open a tex file within the directory containing your LaTeX project.
  2. Compile.

#### Project Configuration
LaTeX-Plus keeps metadata on projects using a `JSON` formatted file that is
easily configurable. Simply invoke the `edit` command to customize to your
liking.

###### Default Settings
  * `title: LaTeX-Plus Project`
  * `root: main.tex`
  * `program: pdflatex`
  * `output: .latex`

#### Ergomonic Keymaps

###### OS X
* compile project: `cmd-;`
* edit project: `cmd-'`

###### Linux and Windows
* compile project: `ctrl-;`
* edit project: `ctrl-'`

#####  NOTE:
After installing LaTeX-Plus a TeX bin path must be specified in the package settings.

## Screencasts
#### Compiling:
![screencast](https://raw.githubusercontent.com/andrewrynhard/atom-latex-plus/resources/gif/compile.gif)

#### Error Detection:
![screencast](https://raw.githubusercontent.com/andrewrynhard/atom-latex-plus/resources/gif/errors.gif)
