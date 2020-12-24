'use strict';

require('./patchGetDiagnostics');

require('./patchURIToPath');

var _vscodeJsonrpc = require('vscode-jsonrpc');

var _vscodeLanguageserver = require('vscode-languageserver');

var _flowLanguageServer = require('flow-language-server');

const connection = (0, _vscodeLanguageserver.createConnection)(new _vscodeJsonrpc.IPCMessageReader(process), new _vscodeJsonrpc.IPCMessageWriter(process)); // import log4js from 'log4js';
// log4js.configure({
//   appenders: [
//     {
//       type: 'logLevelFilter',
//       level: 'DEBUG',
//       appender: {
//         type: 'console'
//       }
//     }
//   ]
// });

const flowOptions = {
  tryFlowBin: true,
  autoDownloadFlow: false
};

(0, _flowLanguageServer.createServer)(connection, flowOptions).listen();