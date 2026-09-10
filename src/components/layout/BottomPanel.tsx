import React, { useState } from 'react';
import { useIDE } from '../../context/IDEContext';
import { BottomPanelTab } from '../../types/vfs';
import { IntegratedTerminal } from '../terminal/IntegratedTerminal';
import { X, Minus, ChevronUp, AlertCircle, AlertTriangle, Info, Terminal as TermIcon, Play, Bug } from 'lucide-react';

export const BottomPanel: React.FC = () => {
  const {
    activeBottomTab,
    setBottomTab,
    isBottomPanelOpen,
    toggleBottomPanel,
    bottomPanelHeight,
    setBottomPanelHeight,
    problems,
    openFile
  } = useIDE();

  const [debugInput, setDebugInput] = useState('');
  const [debugLogs, setDebugLogs] = useState<string[]>([
    'RVM JS Debug REPL ready.',
    'Type any JavaScript expression (e.g., 2 + 2 or Math.PI) to evaluate.'
  ]);

  if (!isBottomPanelOpen) return null;

  const handleMouseDown = (e: React.MouseEvent) => {
    e.preventDefault();
    const startY = e.clientY;
    const startHeight = bottomPanelHeight;

    const onMouseMove = (moveEvent: MouseEvent) => {
      const newHeight = Math.max(120, Math.min(600, startHeight - (moveEvent.clientY - startY)));
      setBottomPanelHeight(newHeight);
    };

    const onMouseUp = () => {
      document.removeEventListener('mousemove', onMouseMove);
      document.removeEventListener('mouseup', onMouseUp);
    };

    document.addEventListener('mousemove', onMouseMove);
    document.addEventListener('mouseup', onMouseUp);
  };

  const handleDebugSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!debugInput.trim()) return;
    try {
      // Evaluate expression
      const result = eval(debugInput);
      setDebugLogs(prev => [...prev, `> ${debugInput}`, `< ${String(result)}`]);
    } catch (err: any) {
      setDebugLogs(prev => [...prev, `> ${debugInput}`, `Error: ${err.message}`]);
    }
    setDebugInput('');
  };

  const tabs: { id: BottomPanelTab; label: string; badge?: number }[] = [
    { id: 'problems', label: 'PROBLEMS', badge: problems.length },
    { id: 'output', label: 'OUTPUT' },
    { id: 'debug', label: 'DEBUG CONSOLE' },
    { id: 'terminal', label: 'TERMINAL' }
  ];

  return (
    <div
      style={{ height: `${bottomPanelHeight}px` }}
      className="bg-[#1e1e1e] border-t border-[#2d2d2d] flex flex-col flex-shrink-0 relative select-none z-20"
    >
      {/* Vertical Resizer Handle */}
      <div
        onMouseDown={handleMouseDown}
        className="resizer-v absolute top-0 left-0 right-0 hover:bg-sky-500 active:bg-sky-500 cursor-row-resize"
      />

      {/* Panel Tab Header Bar */}
      <div className="flex items-center justify-between bg-[#252526] h-8 px-3 border-b border-[#1e1e1e] text-xs">
        <div className="flex items-center space-x-4">
          {tabs.map((tab) => {
            const isActive = activeBottomTab === tab.id;
            return (
              <button
                key={tab.id}
                onClick={() => setBottomTab(tab.id)}
                className={`flex items-center space-x-1 py-1.5 border-b-2 font-medium transition-colors ${
                  isActive
                    ? 'border-sky-500 text-white font-bold'
                    : 'border-transparent text-gray-400 hover:text-gray-200'
                }`}
              >
                <span>{tab.label}</span>
                {tab.badge !== undefined && tab.badge > 0 && (
                  <span className="bg-sky-700 text-white text-[10px] px-1.5 py-0.2 rounded-full font-mono">
                    {tab.badge}
                  </span>
                )}
              </button>
            );
          })}
        </div>

        <div className="flex items-center space-x-2 text-gray-400">
          <button
            onClick={toggleBottomPanel}
            title="Minimize Panel"
            className="p-1 hover:bg-[#3c3c3c] rounded hover:text-white"
          >
            <Minus className="w-3.5 h-3.5" />
          </button>
          <button
            onClick={toggleBottomPanel}
            title="Close Panel"
            className="p-1 hover:bg-[#3c3c3c] rounded hover:text-white"
          >
            <X className="w-3.5 h-3.5" />
          </button>
        </div>
      </div>

      {/* Tab Body Content */}
      <div className="flex-1 overflow-hidden">
        {activeBottomTab === 'terminal' && <IntegratedTerminal />}

        {activeBottomTab === 'problems' && (
          <div className="p-3 overflow-y-auto h-full space-y-2 text-xs">
            {problems.map((prob) => (
              <div
                key={prob.id}
                onClick={() => openFile(prob.file)}
                className="flex items-start space-x-2 bg-[#2d2d2d] border border-[#3c3c3c] p-2 rounded hover:bg-[#37373d] cursor-pointer"
              >
                {prob.severity === 'error' ? (
                  <AlertCircle className="w-4 h-4 text-red-400 flex-shrink-0 mt-0.5" />
                ) : prob.severity === 'warning' ? (
                  <AlertTriangle className="w-4 h-4 text-amber-400 flex-shrink-0 mt-0.5" />
                ) : (
                  <Info className="w-4 h-4 text-sky-400 flex-shrink-0 mt-0.5" />
                )}

                <div className="flex-1">
                  <div className="flex justify-between font-mono text-sky-300 text-[11px]">
                    <span>{prob.file} [{prob.line}:{prob.col}]</span>
                    {prob.code && <span className="text-gray-500">{prob.code}</span>}
                  </div>
                  <p className="text-gray-200 mt-0.5">{prob.message}</p>
                </div>
              </div>
            ))}
          </div>
        )}

        {activeBottomTab === 'output' && (
          <div className="p-3 overflow-y-auto h-full font-mono text-xs text-gray-300 space-y-1 bg-[#1e1e1e]">
            <div className="text-sky-400 font-bold">[RVM Task Output Channel]</div>
            <div className="text-gray-400">[13:40:02] Initialized Virtual File System watcher for my-web-app.</div>
            <div className="text-gray-400">[13:40:05] TypeScript Language Server v5.7.3 active.</div>
            <div className="text-emerald-400">[13:40:08] Vite dev server process standard output ready.</div>
            <div className="text-gray-500">Watching for file updates in /my-web-app/src/...</div>
          </div>
        )}

        {activeBottomTab === 'debug' && (
          <div className="flex flex-col h-full bg-[#1e1e1e] p-2 font-mono text-xs">
            <div className="flex-1 overflow-y-auto space-y-1 p-2 text-gray-300">
              {debugLogs.map((log, i) => (
                <div key={i} className={log.startsWith('>') ? 'text-sky-400 font-semibold' : 'text-gray-200'}>
                  {log}
                </div>
              ))}
            </div>

            <form onSubmit={handleDebugSubmit} className="flex items-center space-x-2 border-t border-[#3c3c3c] pt-2">
              <span className="text-sky-400 font-bold">&gt;</span>
              <input
                type="text"
                placeholder="Evaluate expression..."
                value={debugInput}
                onChange={(e) => setDebugInput(e.target.value)}
                className="flex-1 bg-[#2d2d2d] border border-[#444444] focus:border-sky-500 rounded px-2 py-1 text-white text-xs outline-none"
              />
            </form>
          </div>
        )}
      </div>
    </div>
  );
};
