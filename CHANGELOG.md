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
