'use strict';

var _FlowSingleProjectLanguageService = require('flow-language-server/lib/pkg/nuclide-flow-rpc/lib/FlowSingleProjectLanguageService');

var _diagnosticsParser = require('flow-language-server/lib/pkg/nuclide-flow-rpc/lib/diagnosticsParser');

var _log4js = require('log4js');

const logger = (0, _log4js.getLogger)('nuclide-flow-rpc-patch');

async function getDiagnostics(filePath, buffer) {
  await this._forceRecheck(filePath);

  const options = {};

  const args = ['status', '--json', filePath];

  let result;

  try {
    // Don't log errors if the command returns a nonzero exit code, because status returns nonzero
    // if it is reporting any issues, even when it succeeds.
    result = await this._process.execFlow(args, options,
    /* waitForServer */true);
    if (!result) {
      return null;
    }
  } catch (e) {
    // This codepath will be exercised when Flow finds type errors as the
    // exit code will be non-zero. Note this codepath could also be exercised
    // due to a logical error in Nuclide, so we try to differentiate.
    if (e.exitCode !== undefined) {
      result = e;
    } else {
      logger.error(e);
      return null;
    }
  }

  let json;
  try {
    json = JSON.parse(result.stdout);
  } catch (e) {
    return null;
  }

  const diagnostics = (0, _diagnosticsParser.flowStatusOutputToDiagnostics)(json);

  const filePathToMessages = new Map();

  for (const diagnostic of diagnostics) {
    const path = diagnostic.filePath;
    let diagnosticArray = filePathToMessages.get(path);
    if (!diagnosticArray) {
      diagnosticArray = [];
      filePathToMessages.set(path, diagnosticArray);
    }
    diagnosticArray.push(diagnostic);
  }

  const lastDiagnosticsFilePath = Array.from(filePathToMessages.keys());

  if (this._lastDiagnosticsFilePath) {
    this._lastDiagnosticsFilePath.forEach(key => {
      if (!filePathToMessages.has(key)) {
        filePathToMessages.set(key, []);
      }
    });
  }

  this._lastDiagnosticsFilePath = lastDiagnosticsFilePath;

  return {
    filePathToMessages
  };
}

_FlowSingleProjectLanguageService.FlowSingleProjectLanguageService.prototype.getDiagnostics = getDiagnostics;