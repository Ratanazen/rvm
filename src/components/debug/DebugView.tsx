import React from 'react';
import { useIDE } from '../../context/IDEContext';
import { Play, Pause, RotateCw, Bug, PlaySquare } from 'lucide-react';

export const DebugView: React.FC = () => {
  const { executeCLICommand } = useIDE();

  return (
    <div className="flex flex-col h-full bg-[#252526] text-[#cccccc] select-none text-xs p-2">
      <div className="font-semibold text-gray-300 uppercase tracking-wider text-[11px] mb-3 px-1">
        RUN AND DEBUG
      </div>

      <div className="bg-[#2d2d2d] border border-[#3c3c3c] rounded p-3 space-y-3 mb-4">
        <div className="flex items-center justify-between">
          <span className="font-semibold text-white">Launch Program</span>
          <span className="text-[10px] bg-sky-950 text-sky-300 px-1.5 py-0.5 rounded font-mono">Vite Dev Server</span>
        </div>

        <button
          onClick={() => executeCLICommand('npm run dev')}
          className="w-full bg-[#0e639c] hover:bg-[#1177bb] text-white py-1.5 rounded flex items-center justify-center space-x-2 font-semibold"
        >
          <Play className="w-4 h-4 fill-white" />
          <span>Start Debugging (F5)</span>
        </button>
      </div>

      {/* Variables Section */}
      <div className="border-t border-[#3c3c3c] pt-2 mb-3">
        <span className="font-bold text-gray-400 uppercase text-[10px] block mb-1">VARIABLES</span>
        <div className="bg-[#1e1e1e] p-2 rounded text-[11px] font-mono text-gray-300 space-y-1">
          <div><span className="text-purple-400">process.env.NODE_ENV</span>: <span className="text-amber-300">"development"</span></div>
          <div><span className="text-purple-400">port</span>: <span className="text-cyan-400">5173</span></div>
          <div><span className="text-purple-400">hotReload</span>: <span className="text-emerald-400">true</span></div>
        </div>
      </div>

      {/* Call Stack Section */}
      <div className="border-t border-[#3c3c3c] pt-2">
        <span className="font-bold text-gray-400 uppercase text-[10px] block mb-1">CALL STACK</span>
        <div className="text-[11px] text-gray-400 space-y-1">
          <div className="flex justify-between hover:bg-[#2d2d2d] p-1 rounded">
            <span className="text-sky-400">App (App.tsx:8)</span>
            <span>my-web-app</span>
          </div>
          <div className="flex justify-between hover:bg-[#2d2d2d] p-1 rounded">
            <span>main (main.tsx:5)</span>
            <span>my-web-app</span>
          </div>
        </div>
      </div>
    </div>
  );
};
