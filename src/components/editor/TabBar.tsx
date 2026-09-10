import React from 'react';
import { useIDE } from '../../context/IDEContext';
import { X, Columns2, Play, Globe } from 'lucide-react';

interface TabBarProps {
  showWebPreview: boolean;
  setShowWebPreview: (val: boolean) => void;
}

export const TabBar: React.FC<TabBarProps> = ({ showWebPreview, setShowWebPreview }) => {
  const {
    openTabs,
    activeTabId,
    setActiveTabId,
    closeTab,
    splitEditor,
    toggleSplitEditor
  } = useIDE();

  return (
    <div className="flex items-center justify-between bg-[#252526] border-b border-[#1e1e1e] h-9 select-none overflow-x-auto overflow-y-hidden">
      {/* File Tabs List */}
      <div className="flex items-center space-x-0.5 h-full overflow-x-auto">
        {openTabs.map((tab) => {
          const isActive = tab.id === activeTabId && !showWebPreview;
          return (
            <div
              key={tab.id}
              onClick={() => {
                setActiveTabId(tab.id);
                setShowWebPreview(false);
              }}
              className={`group flex items-center space-x-2 px-3 h-full cursor-pointer text-xs border-r border-[#1e1e1e] transition-colors relative ${
                isActive
                  ? 'bg-[#1e1e1e] text-white font-medium border-t-2 border-t-sky-500'
                  : 'bg-[#2d2d2d] text-gray-400 hover:bg-[#2a2d2e] hover:text-gray-200'
              }`}
            >
              <span className="truncate max-w-[150px]">{tab.name}</span>

              {tab.isDirty ? (
                <span className="w-2 h-2 rounded-full bg-white group-hover:hidden" />
              ) : null}

              <button
                onClick={(e) => {
                  e.stopPropagation();
                  closeTab(tab.id);
                }}
                className={`p-0.5 rounded hover:bg-[#454545] text-gray-400 hover:text-white ${
                  tab.isDirty ? 'hidden group-hover:block' : ''
                }`}
              >
                <X className="w-3 h-3" />
              </button>
            </div>
          );
        })}
      </div>

      {/* Editor Action Buttons */}
      <div className="flex items-center space-x-1 px-2 border-l border-[#1e1e1e]">
        <button
          onClick={() => setShowWebPreview(!showWebPreview)}
          title="Toggle Live Web App Preview"
          className={`p-1.5 rounded flex items-center space-x-1 text-xs transition-colors ${
            showWebPreview
              ? 'bg-sky-600 text-white font-medium'
              : 'hover:bg-[#3c3c3c] text-gray-300'
          }`}
        >
          <Globe className="w-3.5 h-3.5" />
          <span className="hidden sm:inline">Preview</span>
        </button>

        <button
          onClick={toggleSplitEditor}
          title="Toggle Split Editor"
          className={`p-1.5 rounded text-gray-400 hover:text-white hover:bg-[#3c3c3c] ${
            splitEditor ? 'text-sky-400' : ''
          }`}
        >
          <Columns2 className="w-3.5 h-3.5" />
        </button>
      </div>
    </div>
  );
};
