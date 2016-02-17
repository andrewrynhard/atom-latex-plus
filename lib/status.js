"use babel";

import fs from "fs";
import path from "path";
import {MessagePanelView, LineMessageView, PlainMessageView} from "atom-message-panel";

const ContentsByMode = {
  "compile": ["status-bar-latex-plus-mode-action", "Compiling"],
  "sync": ["status-bar-latex-plus-mode-action", "Syncing"],
  "edit": ["status-bar-latex-plus-mode-action", "Editing"],
  "clean": ["status-bar-latex-plus-mode-action", "Cleaning"],
  "load": ["status-bar-latex-plus-mode-good", "Loaded"],
  "ready": ["status-bar-latex-plus-mode-good", "Ready"],
  "invalid": ["status-bar-latex-plus-mode-error", "Invalid"],
  "error": ["status-bar-latex-plus-mode-error", "Error"],
};

export default class Status {
  constructor() {
    this.container = document.createElement("div");
    this.container.className = "inline-block";
    this.titleElement = document.createElement("span");
    this.titleElement.id = "status-bar-latex-plus-title";
    this.statusElement = document.createElement("span");
    this.statusElement.id = "status-bar-latex-plus-mode";

    this.container.appendChild(this.titleElement);
    this.container.appendChild(this.statusElement);

    this.messagepanel = new MessagePanelView({title: "LaTeX-Plus"});
    this.markers = [];
  }

  initialize(statusBar) {
    this.statusBar = statusBar;
  }

  showLogErrors(errors) {
    this.updateMessagePanel(errors);
    this.updateGutter(errors);
  }

  updateStatusBarTitle(title) {
    if (title) {
      this.titleElement.textContent = `${title}: `;
    }
  }

  updateStatusBarMode(mode) {
    if (newContents = ContentsByMode[mode]) {
      [klass, status] = newContents;
      this.statusElement.className = klass;
      this.statusElement.textContent = `${status}`;
    }
  }

  updateMessagePanel(errors) {
    editors =  atom.workspace.getTextEditors();
    for (let e of errors) {
      this.messagepanel.add(
        new LineMessageView({
          file: e.file ,
          line: e.line,
          character: 0,
          message: e.message,
        }));
    }

    this.messagepanel.attach();
  }

  updateGutter(errors) {
    editors =  atom.workspace.getTextEditors();
    for (let e of errors) {
      for (editor of editors) {
        errorFile = path.basename(e.file);
        if (errorFile === path.basename(editor.getPath())) {
          row = parseInt(e.line) - 1;
          column = editor.buffer.lineLengthForRow(row);
          range = [[row, 0], [row, column]];
          marker = editor.markBufferRange(range, {invalidate: "touch"});
          decoration = editor.decorateMarker(marker, {type: "line-number", class: "gutter-red"});
          this.markers.push(marker);
        }
      }
    }
  }

  clear() {
    this.messagepanel.clear();
    this.messagepanel.close();

    for (marker of this.markers) {
      marker.destroy();
    }
  }

  attach() {
    this.tile = this.statusBar.addLeftTile({item: this.container, priority: 20});
  }

  detach() {
    this.tile.destroy();
  }

  destroy() {
    if (this.element) {
      this.element.remove();
      this.element = null;
    }

    if (this.container) {
      this.container.remove();
      this.container = null;
    }

    if (this.messagepanel) {
      this.messagepanel.remove();
      this.messagepanel = null;
    }
  }
}
