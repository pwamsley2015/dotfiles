'use strict';

const URI = require('vscode-uri').default;
const utilsHack = require('flow-language-server/lib/utils/util');

function fileURIToPath(fileUri) {
  const uri = URI.parse(fileUri).fsPath;
  return uri;
}
utilsHack.fileURIToPath = fileURIToPath;