"use babel";

import {exec} from "child_process";
import {Emitter} from "atom";

export default class SyncTeX {

  constructor(environment) {
    this.emitter = new Emitter();
  }

  onDidSyncSuccess(callback) {
    this.emitter.on("did-sync-success", callback);
  }

  destroy() {
  }

  execute(source, pos, output, environment, callback) {
    synctexPath = atom.config.get("pdf-view.syncTeXPath") || "synctex";
    synctexCmd = `${synctexPath} view -i ${pos.row}:${pos.column}:"${source}" -o "${output}"`;
    proc = exec(synctexCmd, environment, (err, stdout, stderr) => {
      if (err) {
        atom.notifications.addError("SyncTeX Error:", {
          detail: stderr,
          dismissable: true,
        });
        return;
      }
      ret = {};
      for (line of stdout.split("\n")) {
        m = line.match(/^([a-zA-Z]*):\s*(.*)\s*$/);
        if (m) {
          x = parseFloat(m[2]);
          if (isNaN(x)) {
            x = m[2];
          }
          ret[m[1]] = x;
        }
      }
      callback(ret);
    });
  }

  syncView(sourceFile, cursorPosition, viewer, environment) {
    this.execute(
      sourceFile,
      cursorPosition,
      viewer.file.path,
      environment,
      (syncData) => {
        if (!syncData.Page && syncData.Page > viewer.currentPageNumber) {
          return;
        }
        y = viewer.pageHeights.slice(0, syncData.Page - 1).reduce((a,b) => { return a + b; }, 0) + (syncData.Page - 1) * 20;
        if (syncData.y) {
          y += (syncData.y - syncData.H) * viewer.currentScale;
        }
        y -= atom.config.get("latex-plus.synctexVertAlign") * viewer.innerHeight();
        viewer.scrollTop(y);
        this.emitter.emit("did-sync-success");
      });
  }
}
