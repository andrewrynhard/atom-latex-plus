# LaTeX-Plus

[![Plugin installs!](https://img.shields.io/apm/dm/latex-plus.svg?style=flat-square)](https://atom.io/packages/latex-plus)
[![Package version!](https://img.shields.io/apm/v/latex-plus.svg?style=flat-square)](https://atom.io/packages/latex-plus)

LaTeX for Atom.

## Status
This package is a beta release. For the newest features install the `develop` branch:
```` bash
mkdir ~/repos
cd ~/repos
git clone https://github.com/andrewrynhard/atom-latex-plus.git
cd atom-latex-plus
apm install
apm link
````

| Master Branch | Develop Branch|
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
  1. Configure `TeX Bin` in the package settings.
  1. Open a tex file within the directory containing your LaTeX project.
  2. Compile to activate LaTeX-Plus.

#### Project Configuration
LaTeX-Plus keeps metadata on projects using a `JSON` formatted file that is
easily configurable. Simply invoke the `edit` command to customize to your
liking.

###### Default Settings
  * `title: LaTeX-Plus Project`
  * `root: main.tex`
  * `program: pdflatex`
  * `output: .latex`

###### Caveat
Due to the beta status of this package, project configuration files will be overwritten upon upgrading. Once the project configuration API has stablized a more permanent solution will exist.

#### Keymaps

###### OS X
* compile project: `cmd-;`
* sync project: `alt-cmd-;`
* edit project: `cmd-'`
* clean project: `alt-cmd-'`

###### Linux and Windows
* compile project: `ctrl-;`
* sync project `ctrl-alt-;`
* edit project: `ctrl-'`
* clean project: `ctrl-alt-'`

## Screencasts
#### Compiling:
![screencast](https://raw.githubusercontent.com/andrewrynhard/atom-latex-plus/resources/gif/compile.gif)

#### Error Detection:
![screencast](https://raw.githubusercontent.com/andrewrynhard/atom-latex-plus/resources/gif/errors.gif)
