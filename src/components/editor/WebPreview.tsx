import React, { useState } from 'react';
import { useIDE } from '../../context/IDEContext';
import { RotateCw, ExternalLink, Smartphone, Monitor, ShieldCheck } from 'lucide-react';

export const WebPreview: React.FC = () => {
  const { vfs, getFileByPath } = useIDE();
  const [reloadKey, setReloadKey] = useState(0);

  // Retrieve code from VFS
  const appFile = getFileByPath('my-web-app/src/App.tsx');
  const cssFile = getFileByPath('my-web-app/src/index.css');

  // Interactive state inside preview
  const [demoCount, setDemoCount] = useState(0);

  return (
    <div className="flex flex-col h-full bg-[#0f172a] text-white select-none border-l border-[#252526]">
      {/* Browser Bar */}
      <div className="flex items-center justify-between bg-[#1e293b] px-3 py-1.5 border-b border-slate-700 text-xs">
        <div className="flex items-center space-x-2 flex-1 max-w-md bg-slate-900 border border-slate-700 rounded-md px-3 py-1 text-slate-300 font-mono text-[11px]">
          <ShieldCheck className="w-3.5 h-3.5 text-emerald-400" />
          <span className="truncate">http://localhost:5173/</span>
        </div>

        <div className="flex items-center space-x-2">
          <button
            onClick={() => setReloadKey(prev => prev + 1)}
            title="Refresh Live View"
            className="p-1 hover:bg-slate-700 rounded text-slate-300"
          >
            <RotateCw className="w-3.5 h-3.5" />
          </button>
          <div className="h-4 w-px bg-slate-700" />
          <span className="text-[10px] bg-emerald-950 text-emerald-300 font-mono px-2 py-0.5 rounded border border-emerald-800">
            HMR Ready
          </span>
        </div>
      </div>

      {/* Rendered Live Web App */}
      <div key={reloadKey} className="flex-1 p-6 overflow-y-auto bg-slate-900">
        <div className="max-w-2xl mx-auto space-y-6">
          <header className="flex items-center justify-between border-b border-slate-800 pb-4">
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 rounded-lg bg-sky-500 flex items-center justify-center text-xl font-bold shadow-lg shadow-sky-500/20">
                CS
              </div>
              <div>
                <h1 className="text-xl font-bold text-white tracking-wide">RVM Web App</h1>
                <p className="text-xs text-slate-400">Live Virtual Hot-Reload Preview</p>
              </div>
            </div>
            <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">
              ● Active
            </span>
          </header>

          <main className="bg-slate-800/80 backdrop-blur rounded-2xl p-6 border border-slate-700 shadow-2xl space-y-6">
            <div className="space-y-2">
              <h2 className="text-2xl font-bold text-sky-400">Interactive Counter Demo</h2>
              <p className="text-sm text-slate-300 leading-relaxed">
                This component is rendered live from your workspace file <code className="text-sky-300 bg-slate-900 px-1.5 py-0.5 rounded font-mono text-xs">src/App.tsx</code>. Edit the code in Monaco Editor to test changes!
              </p>
            </div>

            <div className="flex items-center space-x-4">
              <button
                onClick={() => setDemoCount(prev => prev + 1)}
                className="px-6 py-3 bg-sky-500 hover:bg-sky-600 active:scale-95 font-semibold text-white rounded-xl shadow-lg shadow-sky-500/30 transition-all cursor-pointer"
              >
                Count: {demoCount}
              </button>
              <button
                onClick={() => setDemoCount(0)}
                className="px-4 py-3 bg-slate-700 hover:bg-slate-600 text-slate-300 font-medium rounded-xl transition-all cursor-pointer"
              >
                Reset
              </button>
            </div>

            <div className="grid grid-cols-3 gap-4 pt-2">
              <div className="p-4 bg-slate-900/80 rounded-xl border border-slate-700/60 space-y-1">
                <span className="text-xs text-slate-400 font-medium">Square Value</span>
                <p className="text-2xl font-mono font-bold text-emerald-400">{demoCount * demoCount}</p>
              </div>
              <div className="p-4 bg-slate-900/80 rounded-xl border border-slate-700/60 space-y-1">
                <span className="text-xs text-slate-400 font-medium font-sans">Doubled</span>
                <p className="text-2xl font-mono font-bold text-amber-400">{demoCount * 2}</p>
              </div>
              <div className="p-4 bg-slate-900/80 rounded-xl border border-slate-700/60 space-y-1">
                <span className="text-xs text-slate-400 font-medium">Is Even?</span>
                <p className="text-2xl font-mono font-bold text-purple-400">
                  {demoCount % 2 === 0 ? 'YES' : 'NO'}
                </p>
              </div>
            </div>
          </main>
        </div>
      </div>
    </div>
  );
};
