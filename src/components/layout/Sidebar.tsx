import React from 'react';
import { useIDE } from '../../context/IDEContext';
import { FileExplorer } from '../explorer/FileExplorer';
import { SearchView } from '../search/SearchView';
import { SourceControlView } from '../git/SourceControlView';
import { DebugView } from '../debug/DebugView';
import { ExtensionsView } from '../extensions/ExtensionsView';

export const Sidebar: React.FC = () => {
  const {
    activeSidebarView,
    isSidebarOpen,
    sidebarWidth,
    setSidebarWidth
  } = useIDE();

  if (!isSidebarOpen) return null;

  const handleMouseDown = (e: React.MouseEvent) => {
    e.preventDefault();
    const startX = e.clientX;
    const startWidth = sidebarWidth;

    const onMouseMove = (moveEvent: MouseEvent) => {
      const newWidth = Math.max(180, Math.min(500, startWidth + (moveEvent.clientX - startX)));
      setSidebarWidth(newWidth);
    };

    const onMouseUp = () => {
      document.removeEventListener('mousemove', onMouseMove);
      document.removeEventListener('mouseup', onMouseUp);
    };

    document.addEventListener('mousemove', onMouseMove);
    document.addEventListener('mouseup', onMouseUp);
  };

  const renderContent = () => {
    switch (activeSidebarView) {
      case 'explorer':
        return <FileExplorer />;
      case 'search':
        return <SearchView />;
      case 'git':
        return <SourceControlView />;
      case 'debug':
        return <DebugView />;
      case 'extensions':
        return <ExtensionsView />;
      case 'settings':
        return (
          <div className="p-3 text-xs text-gray-300">
            <h3 className="font-semibold text-white uppercase mb-2">Settings</h3>
            <div className="space-y-3">
              <div>
                <label className="block text-[11px] text-gray-400 mb-1">Editor Theme</label>
                <select className="bg-[#3c3c3c] text-white p-1 rounded w-full border border-gray-600">
                  <option>VS Code Dark+ (Default)</option>
                  <option>GitHub Dark</option>
                  <option>Monokai Pro</option>
                </select>
              </div>
              <div>
                <label className="block text-[11px] text-gray-400 mb-1">Font Size</label>
                <input type="number" defaultValue={14} className="bg-[#3c3c3c] text-white p-1 rounded w-full border border-gray-600" />
              </div>
              <div>
                <label className="flex items-center space-x-2">
                  <input type="checkbox" defaultChecked className="rounded bg-[#3c3c3c]" />
                  <span>Enable Minimap</span>
                </label>
              </div>
              <div>
                <label className="flex items-center space-x-2">
                  <input type="checkbox" defaultChecked className="rounded bg-[#3c3c3c]" />
                  <span>Auto Save on Blur</span>
                </label>
              </div>
            </div>
          </div>
        );
      default:
        return <FileExplorer />;
    }
  };

  return (
    <div
      style={{ width: `${sidebarWidth}px` }}
      className="bg-[#252526] border-r border-[#1e1e1e] flex-shrink-0 flex relative h-full overflow-hidden"
    >
      <div className="flex-1 h-full overflow-hidden">
        {renderContent()}
      </div>

      {/* Resize Handle */}
      <div
        onMouseDown={handleMouseDown}
        className="resizer-h absolute right-0 top-0 bottom-0 hover:bg-sky-500 active:bg-sky-500 cursor-col-resize"
      />
    </div>
  );
};
