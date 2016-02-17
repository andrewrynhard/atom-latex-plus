"use babel";

import fs from "fs";
import path from "path";

const errorPattern = new RegExp("^.\/(|[A-D:])(.*\\.tex):(\\d*):\\s(.*)");

export default class Parser {
  parse(projectPath, log) {
    errors = [];
    promise = new Promise((resolve, reject) => {
      fs.exists(log, (exists) => {
        if (exists) {
          fs.readFile(log, (err, data) => {
            if(err) {
              reject(err);
              return;
            }

            bufferString = data.toString().split("\n").forEach((line) => {
              e = line.match(errorPattern);

              if (e === null) {
                return;
              }

              error = {
                // normalize to an absolute path so that the message panel links work
                // properly
                file:     path.join(projectPath, path.normalize(e[2])),
                line:     e[3],
                message:  e[4],
              };

              errors.push(error);
            });

            resolve(errors);
          });
        }
      });
    });

    return promise;
  }
}
