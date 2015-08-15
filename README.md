# TeXlicious
[![Build Status](https://travis-ci.org/andrewrynhard/atom-texlicious.svg?branch=master)](https://travis-ci.org/andrewrynhard/atom-texlicious)
[![Plugin installs!](https://img.shields.io/apm/dm/texlicious.svg?style=flat-square)](https://atom.io/packages/texlicious)
[![Package version!](https://img.shields.io/apm/v/texlicious.svg?style=flat-square)](https://atom.io/packages/texlicious)

Productivity tools for pdfLaTeX, LuaLaTeX, and XeLaTeX flavors of LaTeX.

## Installing
Atom package manager or `apm install texlicious`.

## Usage
  * Define a project configuration file, `tex.json`, in the root of you latex project.
  * Compile the project with `ˆ⇧C`.

## Project Configuration Example
```` json
{
  "project": "Example TeXlicious Project",
  "root": "main.tex",
  "program": "xelatex",
  "output": ".texlicious"
}
````

## Demo
![Alt text](/demo.gif?raw=true)
