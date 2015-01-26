# atom-texlicious

A package that provides productivity tools for multiple flavors of TeX.

## Installing
Use the Atom package manager and search for "texlicious", or run `apm install texlicious`
from the terminal.

## Usage
  * To build the current TeX file once, invoke the `build` command with `ctrl-alt-b`.
  * To watch the current TeX file and build continuously, invoke the `watch` command with `ctrl-alt-w`.
  * To select the flavor of TeX such as `pdfLaTeX`, `XeLaTeX`, or `LuaLaTeX`, change the `engine` in the package settings.
  * To include custom packages with `usepackage`, such as `cls`, `sty`, or `tex` files, specify a path to the directory containing the packages in texlicious' settings option `Tex Inputs`.


## Notes

  * When watching a TeX file, changes to it or any that it depend on, invokes the `build` command automatically. It is recommended to use [pdf-view](https://atom.io/packages/pdf-view) to view the output PDF in a split pane. Currently the `watch` command opens the Preview app in OS X but this will be changed in future releases.
  * When `Tex Inputs` is specified, subdirectories of the path containing packages are automatically resolved with `usepackage`.
