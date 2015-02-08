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
  * Fixed issue with 'pdflatex' as the program used to compile tex files.
