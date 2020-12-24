'use strict';

var _vscode = require('vscode');

var _vscode2 = _interopRequireDefault(_vscode);

var _vscodeLanguageclient = require('vscode-languageclient');

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

// this method is called when your extension is activated
// your extension is activated the very first time the command is executed
function activate(context) {
  const serverModule = context.asAbsolutePath('lib/server.js');
  const debugOptions = { execArgv: ['--nolazy', '--debug=6009'] };
  const serverOptions = {
    run: { module: serverModule, transport: _vscodeLanguageclient.TransportKind.ipc },
    debug: {
      module: serverModule,
      transport: _vscodeLanguageclient.TransportKind.ipc,
      options: debugOptions
    }
  };
  const clientOptions = {
    // Register the server for js documents
    documentSelector: [{ scheme: 'file', language: 'javascript' }, { scheme: 'file', language: 'javascriptreact' }],
    synchronize: {
      // Synchronize the setting section 'lspSample' to the server
      configurationSection: 'flow',
      fileEvents: _vscode2.default.workspace.createFileSystemWatcher('**/.flowconfig')
    }
  };

  let flowDisposable = new _vscodeLanguageclient.LanguageClient('flow', 'Flow', serverOptions, clientOptions).start();

  context.subscriptions.push(flowDisposable);
}
exports.activate = activate;

// this method is called when your extension is deactivated
function deactivate() {}
exports.deactivate = deactivate;