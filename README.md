# TeXlicious

Productivity tools for pdfLaTeX, LuaLaTeX, and XeLaTeX flavors of LaTeX.

## Installing
Atom package manager or `apm install texlicious`.

## Usage
  * To compile the current TeX file once, invoke the `compile` command.
  * To select a different flavor of TeX such as `pdfLaTeX`, `XeLaTeX`, or `LuaLaTeX`, choose the desired `program` in the package settings.
  * To include custom packages with `usepackage`, such as `cls`, `sty`, or `tex` files, specify a path in texlicious' settings option `Tex Inputs`.
  * Use magic comments common to other popular editors.

## Note
TeXlicious depends on latexmk which in turn depends on perl. Please ensure you have a working installation of perl before using TeXlicous.
