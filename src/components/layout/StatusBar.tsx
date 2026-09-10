import React from 'react';
import { useIDE } from '../../context/IDEContext';
import { GitBranch, AlertCircle, AlertTriangle, Terminal, RefreshCw, Check, Bell } from 'lucide-react';

export const StatusBar: React.FC = () => {
  const {
    openTabs,
    activeTabId,
    toggleBottomPanel,
    isBottomPanelOpen,
    problems,
    vfs
  } = useIDE();

  const activeTab = openTabs.find(t => t.id === activeTabId);
  const errorCount = problems.filter(p => p.severity === 'error').length;
  const warningCount = problems.filter(p => p.severity === 'warning').length;

  return (
    <footer className="h-6 bg-[#007acc] text-white flex items-center justify-between px-3 text-[11px] select-none font-sans z-30 flex-shrink-0">
      {/* Left Status Bar Items */}
      <div className="flex items-center space-x-3">
        <button
          onClick={() => {}}
          className="flex items-center space-x-1 hover:bg-[#1f8ad2] px-1.5 py-0.5 rounded transition-colors"
        >
          <GitBranch className="w-3.5 h-3.5" />
          <span>main*</span>
        </button>

        <button className="flex items-center space-x-1 hover:bg-[#1f8ad2] px-1.5 py-0.5 rounded">
          <RefreshCw className="w-3 h-3" />
        </button>

        <div className="flex items-center space-x-2">
          <span className="flex items-center space-x-0.5 hover:bg-[#1f8ad2] px-1 py-0.5 rounded">
            <AlertCircle className="w-3 h-3" />
            <span>{errorCount}</span>
          </span>
          <span className="flex items-center space-x-0.5 hover:bg-[#1f8ad2] px-1 py-0.5 rounded">
            <AlertTriangle className="w-3 h-3" />
            <span>{warningCount}</span>
          </span>
        </div>
      </div>

      {/* Right Status Bar Items */}
      <div className="flex items-center space-x-3">
        <span className="hover:bg-[#1f8ad2] px-1.5 py-0.5 rounded">
          Ln 14, Col 22
        </span>

        <span className="hover:bg-[#1f8ad2] px-1.5 py-0.5 rounded">
          Spaces: 2
        </span>

        <span className="hover:bg-[#1f8ad2] px-1.5 py-0.5 rounded">
          UTF-8
        </span>

        <span className="hover:bg-[#1f8ad2] px-1.5 py-0.5 rounded font-medium">
          {activeTab ? activeTab.language.toUpperCase() : 'TYPESCRIPT REACT'}
        </span>

        <button
          onClick={toggleBottomPanel}
          title="Toggle Terminal Panel"
          className={`flex items-center space-x-1 px-1.5 py-0.5 rounded transition-colors ${
            isBottomPanelOpen ? 'bg-[#1f8ad2]' : 'hover:bg-[#1f8ad2]'
          }`}
        >
          <Terminal className="w-3.5 h-3.5" />
        </button>

        <button className="hover:bg-[#1f8ad2] p-1 rounded">
          <Bell className="w-3.5 h-3.5" />
        </button>
      </div>
    </footer>
  );
};
