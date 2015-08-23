"use babel";

import fs from "fs";
import path from "path";
import {MessagePanelView, LineMessageView, PlainMessageView} from "atom-message-panel";

const ContentsByMode = {
  'load': ["status-bar-latex-plus-mode-load", "Loaded"],
  'ready': ["status-bar-latex-plus-mode-ready", "Ready"],
  'compile': ["status-bar-latex-plus-mode-compile", "Compiling ..."],
  'error': ["status-bar-latex-plus-mode-error", "Error"]
}

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

    this.messagepanel = new MessagePanelView({title: 'Latex-Plus'});
    this.markers = [];
  }

  initialize(statusBar) {
    this.statusBar = statusBar;
  }

  addErrors(errors) {
    this.updateMessagePanel(errors);
    this.updateGutter(errors);
    this.updateStatusBar("error");
  }

  destroyErrors() {
    this.messagepanel.clear()
    this.messagepanel.close();

    for (marker of this.markers) {
      marker.destroy()
    }

    this.updateStatusBar("ready");
  }

  updateStatusBar(mode, title) {
    if (title !== undefined) {
      this.titleElement.textContent = `${title}: `;
    }

    if (newContents = ContentsByMode[mode]) {
      [klass, status] = newContents;
      this.statusElement.className = klass;
      this.statusElement.textContent = `${status}`;
    }
  }

  updateMessagePanel(errors) {
    editors =  atom.workspace.getTextEditors()
    for (var e of errors) {
      this.messagepanel.add(
          new LineMessageView({
          file: e.file ,
          line: e.line,
          character: 0,
          message: e.message
        })
      );
    }

    this.messagepanel.attach();
  }

  updateGutter(errors) {
    editors =  atom.workspace.getTextEditors()
    for (var e of errors) {
      for (editor of editors) {
        let errorFile = path.basename(e.file);
        if (errorFile == path.basename(editor.getPath())) {
          let row = parseInt(e.line) - 1;
          let column = editor.buffer.lineLengthForRow(row);
          let range = [[row, 0], [row, column]];
          let marker = editor.markBufferRange(range, {invalidate: 'touch'});
          let decoration = editor.decorateMarker(marker, {type: 'line-number', class: 'gutter-red'});
          this.markers.push(marker);
        }
      }
    }
  }

  attach() {
    this.tile = this.statusBar.addLeftTile({item: this.container, priority: 20});
  }

  detach() {
    this.tile.destroy()
  }

  destroy() {
    // this.element?.remove()
    this.element = null
    // this.container?.remove()
    this.container = null
    // this.messagepanel?.remove()
    this.messagepanel = null
  }
}
