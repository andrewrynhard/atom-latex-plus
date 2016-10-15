# Changelog
## 0.2.0
  * Complete rewrite of code.
  * Improved error handling.
  * Improved `watch` feature.
  * Improved UI.
  * Fixed scrolling when viewing the log file.
  * Magic comments.
  * Can now toggle view of toggle log file.

## 0.2.1
  * Fixed package description

## 0.2.2
  * Improved `watch` feature. Now saves and compiles automatically.
  * Improved magic comments. Now supports `program`.
  * Fixed changelog.
  * Added `Watch Delay` option to package settings.

## 0.2.3
  * Fixed watch delay implementation. Previously the `watch` feature depended on
    the buffer's `stoppedChangingDelay` value. Setting this explicitly was a
    hack and effected other packages that might depend on this value. The new
    implementation mimics `onDidStopChanging` and allows an adjustable delay
    time.

## 0.2.4
  * Fixed an error caused by the wrong log file name when using magic comments.
  * Changed keymaps that conflicted with Atom's keymaps.

## 0.2.5
  * Modified `watch` to run `compile` when invoked for the first time.

## 0.2.6
  * Fixed changelog.

## 0.2.7
  * Fixed atom engine semver.

## 0.2.8
  * Fixed issue with `pdflatex` as the program used to compile tex files.

## 0.3.0
  * Added error indication in gutter.
  * Added `stop` command.
  * Added user notifications.
  * Improved the functionality of the `watch` command.
  * Changed log button to refresh when showing.
  * Changed synctex to optional.
  * Fixed autosave.
  * Various bug fixes.

## 0.3.1
  * Fixed bug in `stop` command.

## 0.3.2
  * Fixed bad reference to watched file.

## 0.3.3
  * Fixed a bug caused by whitespace in the project path.

## 0.3.4
  * Improved `watch` feature. `watch` no longer fails on compile when the active
    file is not the watched file.

## 0.3.5
  * Fixed changelog.
  Optimize code

## 0.3.6
  * Optimized code.
  * Watch now switches files instead of prompting to stop first.
  * Errors are now displayed with a message.
  * Gutters are now updated across all currently opened editors.
  * Code was modified to be more modular.
  * Removed log view in favor of displaying errors. A future release will
    provide a keymapping that will open the log file upon invoking.

## 0.3.7
  * Fixed Windows crossplatform compatibility.

## 0.3.8
  * Fixed Linux crossplatform compatibility.

## 0.4.0
  Add features and fix bugs

  * Added BibTex support.
  * Multiple project root support.
  * Move PDF to project root.
  * Bug fixes.

## 0.4.1
  * Changed release to minor.
  * Fixed changelog.

## 0.4.2
  * Merged pull request #12 from mglont/develop
  * Merged pull request #9 from dkerzig/develop

## 0.4.3
  * Moved all of the indicators the `status-bar`.
  * Removed the `watch` command until a better implementation can be written.
  * Fixed #11, and #13.
  * Fixed an issue caused by using synchronous reading of the log file.

## 0.4.4
  * Fixed an error that caused the error view to not display.

## 0.5.0
  * Added `tex.json` config file.
  * Removed `synctex` option.
  * Improved error messages.
  * Added `travis.yml`.

## 0.5.1
  * Fixed travis-ci build.

## 0.5.2
  * Now uses status-bar and message-panel.

## 0.5.3
  * Bug fixes.

## 0.5.4
  * Bug fixes.

## 0.5.5
  * Merged #17.

## 0.5.6
  * Fixed #18
  * Allow multiple projects to be open at once.

## 0.5.7
  * Fixed project switching.

## 0.5.8
  * Fixed message panel file link.

## 0.5.9
  * Removed missing async module

## 0.5.10
  * Removed missing readdirp module

## 0.5.11
  * Fixed an error caused by a missing configuration file.

## 0.5.12
  * Renamed package

## 0.6.0
  * Fixed changelog.

## 0.6.1
  * Pushed to fix apm publish error.

## 0.6.2
  * Fixed demo gif.

## 0.7.0
  * Rewritten with babel for es6/es7 features

    LaTeX-Plus now uses project configuration files generated automatically based on
    the directory name of the Atom project. An option to edit the file manually is
    also available in case the default values are not desired. In addition to
    this change the following features were improved upon:

      * Project management.
      * LaTeX error handling.
      * Status indication.

## 0.7.1
  * Bug fixes.
  * Changed the 'path' key in the project configuration to 'projectPath.'

## 0.7.2
  * Pushed to fix apm publish error.

## 0.7.3
  * Improved error handling.

## 0.7.4
  * Fixed a missing dependency.

## 0.7.5
  * Fixed an error that caused the message view to fail on stderr messages.

## 0.7.6
  * Changed how latexmk stderr is displayed.

## 0.7.7
  * Updated README with warning about beta status.
  * Fixed the message type of latexmk errors.

## 0.7.8
  * Added option to enable/disable automatically opening the output.

## 0.8.0
  * Merged #27 Synctex support.
  * Merged #30 Per project latexmk settings.

## 0.8.1
  * Merged #32 Use latexmk for cleaning.

## 0.8.2
  * Fixed a bug that stopped the status bar message from being updated.

## 0.8.3
  * Pushed to fix apm publish error.

## 0.8.4
  * Fixed #23 and #28.

## 0.8.5
 * Merge #37, #39, #41, #43, #44

## 0.8.6
 * Merge #45

## 0.8.7
* Added [pdf-view](https://github.com/izuzak/atom-pdf-view) as a dependency.

## 0.9.0
* Merge #71
  * Global and project level  settings
  * Configurable output path
  * Copy and symlink options for output
* Project settings are now saved in the root of the project
* Fixes an issue caused by unescaped windows paths

# Contributors
* svkurowski
* shouya
* dpo
* mungerd
* Muffinpirate
* swhgoon
* uliska
* mglont
* dkerzig
* izuzak
* dn0sar
