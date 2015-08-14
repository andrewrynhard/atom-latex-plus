# TeXlicious

Productivity tools for pdfLaTeX, LuaLaTeX, and XeLaTeX flavors of LaTeX.

## Installing
Atom package manager or `apm install texlicious`.

## Usage
  * Define a project configuration file, `tex.json`, in the root of you latex project.
  * Compile the project with `ˆ⇧C`.

##### Example `tex.json`:
```` json
{
  "project": "Example TeXlicious Project",
  "root": "main.tex",
  "program": "xelatex",
  "output": ".texlicious"
}
````
