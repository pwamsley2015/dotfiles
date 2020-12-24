'use strict';

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.createServer = createServer;

var _nuclideUri = require('nuclide-commons/nuclideUri');

var _nuclideUri2 = _interopRequireDefault(_nuclideUri);

var _UniversalDisposable = require('nuclide-commons/UniversalDisposable');

var _UniversalDisposable2 = _interopRequireDefault(_UniversalDisposable);

var _path = require('path');

var _path2 = _interopRequireDefault(_path);

var _vscodeLanguageserver = require('vscode-languageserver');

var _Completion = require('flow-language-server/lib/Completion');

var _Completion2 = _interopRequireDefault(_Completion);

var _Definition = require('flow-language-server/lib/Definition');

var _Definition2 = _interopRequireDefault(_Definition);

var _Diagnostics = require('flow-language-server/lib/Diagnostics');

var _Diagnostics2 = _interopRequireDefault(_Diagnostics);

var _Hover = require('flow-language-server/lib/Hover');

var _Hover2 = _interopRequireDefault(_Hover);

var _Symbol = require('flow-language-server/lib/Symbol');

var _Symbol2 = _interopRequireDefault(_Symbol);

var _TextDocuments = require('flow-language-server/lib/TextDocuments');

var _TextDocuments2 = _interopRequireDefault(_TextDocuments);

var _FlowExecInfoContainer = require('flow-language-server/lib/pkg/nuclide-flow-rpc/lib/FlowExecInfoContainer');

var _FlowSingleProjectLanguageService = require('flow-language-server/lib/pkg/nuclide-flow-rpc/lib/FlowSingleProjectLanguageService');

var _log4js = require('log4js');

var _flowBinForRoot = require('flow-language-server/lib/flow-versions/flowBinForRoot');

var _githubSemverDownloader = require('flow-language-server/lib/flow-versions/githubSemverDownloader');

var _utils = require('flow-language-server/lib/flow-versions/utils');

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

const SUPPORTS_PERSISTENT_CONNECTION = process.platform !== 'win32'; /**
                                                                      * Copyright (c) 2017-present, Facebook, Inc.
                                                                      * All rights reserved.
                                                                      *
                                                                      * This source code is licensed under the BSD-style license found in the
                                                                      * LICENSE file in the root directory of this source tree. An additional grant
                                                                      * of patent rights can be found in the PATENTS file in the same directory.
                                                                      *
                                                                      * 
                                                                      * @format
                                                                      */

function createServer(connection, initialFlowOptions) {
  const logger = (0, _log4js.getLogger)('index');
  const disposable = new _UniversalDisposable2.default();
  const documents = new _TextDocuments2.default();

  disposable.add(documents);

  connection.onShutdown(() => {
    logger.debug('LSP server connection shutting down');
    disposable.dispose();
  });

  connection.onInitialize(async ({ capabilities, rootPath }) => {
    // Flow trips on trailing slashes in root on Windows, `path.resolve` gets
    // rid of it.
    const root = _path2.default.resolve(rootPath || process.cwd());

    logger.debug('LSP connection initialized. Connecting to flow...');

    const flowVersionInfo = await getFlowVersionInfo(root, connection, initialFlowOptions);
    if (!flowVersionInfo) {
      return { capabilities: {} };
    }
    const flowContainer = new _FlowExecInfoContainer.FlowExecInfoContainer(flowVersionInfo);
    const flow = new _FlowSingleProjectLanguageService.FlowSingleProjectLanguageService(root, flowContainer);

    disposable.add(flow, flow.getServerStatusUpdates().distinctUntilChanged().subscribe(statusType => {
      connection.console.info(`Flow status: ${statusType}`);
    }));

    const diagnostics = new _Diagnostics2.default({ flow });

    if (SUPPORTS_PERSISTENT_CONNECTION) {
      disposable.add(diagnostics.observe().subscribe(diagnosticItems => diagnosticItems.forEach(connection.sendDiagnostics)));
    } else {
      // Flow doesn't support its persistent connection well on Windows,
      // so fall back to monitoring open and save events to offer diagnostics
      let lastDiagnostics;
      const diagnoseAndSend = async function ({ document }) {
        const diagnosticItems = await diagnostics.diagnoseOne(document);
        logger.debug(`New Diagnostics: ${JSON.stringify(diagnosticItems, null, 2)}`);
        diagnosticItems.forEach(connection.sendDiagnostics);
      };

      documents.onDidSave(diagnoseAndSend);
      documents.onDidOpen(diagnoseAndSend);
    }

    const completion = new _Completion2.default({
      clientCapabilities: capabilities,
      documents,
      flow
    });
    connection.onCompletion(docParams => {
      logger.debug(`completion requested for document ${docParams.textDocument.uri}`);
      return completion.provideCompletionItems(docParams);
    });

    connection.onCompletionResolve(() => {
      // for now, noop as we can't/don't need to provide any additional
      // information on resolve, but need to respond to implement completion
    });

    const definition = new _Definition2.default({ documents, flow });
    connection.onDefinition(docParams => {
      logger.debug(`definition requested for document ${docParams.textDocument.uri}`);
      return definition.provideDefinition(docParams);
    });

    const hover = new _Hover2.default({ documents, flow });
    connection.onHover(docParams => {
      return hover.provideHover(docParams);
    });

    const symbols = new _Symbol2.default({ documents, flow });
    connection.onDocumentSymbol(symbolParams => {
      logger.debug(`symbols requested for document ${symbolParams.textDocument.uri}`);
      return symbols.provideDocumentSymbol(symbolParams);
    });

    logger.info('Flow language server started');

    return {
      capabilities: {
        textDocumentSync: documents.syncKind,
        definitionProvider: true,
        documentSymbolProvider: true,
        completionProvider: {
          resolveProvider: true,
          triggerCharacters: ['.']
        },
        hoverProvider: true
      }
    };
  });

  return {
    listen() {
      documents.listen(connection);
      connection.listen();
    }
  };
}

async function getFlowVersionInfo(rootPath, connection, flowOptions) {
  const versionLogger = (0, _log4js.getLogger)('flow-versions');

  if (flowOptions.flowPath != null) {
    connection.window.showInformationMessage('path to flow ' + flowOptions.flowPath);
    if (!_nuclideUri2.default.isAbsolute(flowOptions.flowPath)) {
      connection.window.showErrorMessage('Supplied path to flow was not absolute. Specify a complete path to ' + 'the flow binary or leave the option empty for Flow to be managed ' + 'for you.');
      return null;
    }

    const flowVersionInfo = await (0, _utils.versionInfoForPath)(rootPath, flowOptions.flowPath);
    if (!flowVersionInfo) {
      connection.window.showErrorMessage('Invalid path to flow binary.');
    }
    versionLogger.info(`Using the provided path to flow binary at ${flowOptions.flowPath}`);

    return flowVersionInfo;
  }

  const downloadManagerLogger = {
    error: connection.window.showErrorMessage.bind(connection.window),
    info: versionLogger.info.bind(versionLogger),
    warn: versionLogger.warn.bind(versionLogger)
  };

  const versionInfo = await (0, _flowBinForRoot.flowBinForPath)(rootPath, {
    autoDownloadFlow: flowOptions.autoDownloadFlow,
    reporter: downloadManagerLogger,
    semverDownloader: _githubSemverDownloader.downloadSemverFromGitHub,
    tryFlowBin: flowOptions.tryFlowBin
  });

  if (!versionInfo) {
    versionLogger.error('There was a problem obtaining the appropriate version of flow for ' + 'your project. Please check the extension logs.');
  }

  return versionInfo;
}