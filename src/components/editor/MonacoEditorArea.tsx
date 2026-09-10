import React, { useState } from 'react';
import Editor from '@monaco-editor/react';
import { useIDE } from '../../context/IDEContext';
import { TabBar } from './TabBar';
import { Breadcrumbs } from './Breadcrumbs';
import { WebPreview } from './WebPreview';
import { Code2, Terminal, Search, Files, Keyboard } from 'lucide-react';

export const MonacoEditorArea: React.FC = () => {
  const {
    openTabs,
    activeTabId,
    updateFileContent,
    saveFile,
    splitEditor,
    toggleCommandPalette
  } = useIDE();

  const [showWebPreview, setShowWebPreview] = useState(false);
  const activeTab = openTabs.find(t => t.id === activeTabId);

  const handleEditorChange = (value: string | undefined) => {
    if (activeTab && value !== undefined) {
      updateFileContent(activeTab.path, value);
    }
  };

  const handleEditorMount = (editor: any, monaco: any) => {
    // Add Ctrl+S save shortcut
    editor.addCommand(monaco.KeyMod.CtrlCmd | monaco.KeyCode.KeyS, () => {
      if (activeTab) {
        saveFile(activeTab.path);
      }
    });
  };

  return (
    <div className="flex-1 flex flex-col h-full bg-[#1e1e1e] overflow-hidden relative">
      {/* Tab Header Bar */}
      <TabBar showWebPreview={showWebPreview} setShowWebPreview={setShowWebPreview} />

      {/* Path Breadcrumbs */}
      {!showWebPreview && <Breadcrumbs />}

      {/* Editor Body */}
      <div className="flex-1 flex h-full overflow-hidden relative">
        {showWebPreview ? (
          <WebPreview />
        ) : activeTab ? (
          <div className="flex-1 flex h-full overflow-hidden">
            {/* Primary Monaco Editor */}
            <div className="flex-1 h-full relative">
              <Editor
                height="100%"
                language={activeTab.language}
                value={activeTab.content}
                theme="vs-dark"
                onChange={handleEditorChange}
                onMount={handleEditorMount}
                options={{
                  fontSize: 13,
                  fontFamily: '"JetBrains Mono", "Fira Code", Consolas, monospace',
                  minimap: { enabled: true, renderCharacters: true },
                  scrollBeyondLastLine: false,
                  automaticLayout: true,
                  smoothScrolling: true,
                  cursorBlinking: 'smooth',
                  cursorSmoothCaretAnimation: 'on',
                  bracketPairColorization: { enabled: true },
                  lineNumbers: 'on',
                  tabSize: 2,
                  wordWrap: 'on',
                  padding: { top: 10 }
                }}
              />
            </div>

            {/* Split Editor (If Toggled) */}
            {splitEditor && (
              <div className="flex-1 h-full border-l border-[#252526] relative">
                <div className="bg-[#2d2d2d] px-3 py-1 text-xs text-gray-400 font-mono border-b border-[#1e1e1e]">
                  Split View — Read Only Reference
                </div>
                <Editor
                  height="100%"
                  language={activeTab.language}
                  value={activeTab.content}
                  theme="vs-dark"
                  options={{
                    fontSize: 13,
                    fontFamily: '"JetBrains Mono", "Fira Code", Consolas, monospace',
                    minimap: { enabled: false },
                    readOnly: true,
                    scrollBeyondLastLine: false,
                    automaticLayout: true,
                    lineNumbers: 'on',
                    tabSize: 2,
                    wordWrap: 'on',
                  }}
                />
              </div>
            )}
          </div>
        ) : (
          /* Empty Watermark Screen */
          <div className="flex-1 flex flex-col items-center justify-center text-gray-500 select-none p-6 space-y-6">
            <Code2 className="w-16 h-16 text-sky-500/40 animate-pulse" />
            <h2 className="text-xl font-bold text-gray-400">RVM Desktop IDE</h2>

            <div className="space-y-3 max-w-sm text-xs font-mono text-gray-400">
              <div className="flex justify-between items-center bg-[#252526] px-4 py-2 rounded-lg border border-[#333333]">
                <span>Show All Commands</span>
                <span className="bg-[#3c3c3c] text-white px-2 py-0.5 rounded text-[11px]">Ctrl+Shift+P</span>
              </div>

              <div className="flex justify-between items-center bg-[#252526] px-4 py-2 rounded-lg border border-[#333333]">
                <span>Go to File</span>
                <span className="bg-[#3c3c3c] text-white px-2 py-0.5 rounded text-[11px]">Ctrl+P</span>
              </div>

              <div className="flex justify-between items-center bg-[#252526] px-4 py-2 rounded-lg border border-[#333333]">
                <span>Toggle Terminal</span>
                <span className="bg-[#3c3c3c] text-white px-2 py-0.5 rounded text-[11px]">Ctrl+`</span>
              </div>
            </div>

            <button
              onClick={toggleCommandPalette}
              className="px-4 py-2 bg-sky-600 hover:bg-sky-500 text-white rounded-md text-xs font-medium transition-colors"
            >
              Open Command Palette
            </button>
          </div>
        )}
      </div>
    </div>
  );
};
