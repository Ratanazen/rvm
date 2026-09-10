import React from 'react';
import { useIDE } from '../../context/IDEContext';
import { SidebarView } from '../../types/vfs';
import {
  Files,
  Search,
  GitBranch,
  Bug,
  Blocks,
  Settings,
  Terminal,
  Globe
} from 'lucide-react';

export const ActivityBar: React.FC = () => {
  const {
    activeSidebarView,
    setSidebarView,
    isSidebarOpen,
    problems,
    vfs
  } = useIDE();

  // Count modified files
  const countModifiedFiles = (node: any): number => {
    let count = 0;
    if (node.isModified || node.gitStatus === 'modified' || node.gitStatus === 'untracked') {
      count++;
    }
    if (node.children) {
      node.children.forEach((c: any) => {
        count += countModifiedFiles(c);
      });
    }
    return count;
  };
  const modifiedCount = countModifiedFiles(vfs);

  const topItems: { view: SidebarView; label: string; icon: React.ReactNode; badge?: number }[] = [
    {
      view: 'explorer',
      label: 'Explorer (Ctrl+Shift+E)',
      icon: <Files className="w-6 h-6" />
    },
    {
      view: 'search',
      label: 'Search (Ctrl+Shift+F)',
      icon: <Search className="w-6 h-6" />
    },
    {
      view: 'git',
      label: 'Source Control (Ctrl+Shift+G)',
      icon: <GitBranch className="w-6 h-6" />,
      badge: modifiedCount
    },
    {
      view: 'debug',
      label: 'Run and Debug (Ctrl+Shift+D)',
      icon: <Bug className="w-6 h-6" />
    },
    {
      view: 'extensions',
      label: 'Extensions (Ctrl+Shift+X)',
      icon: <Blocks className="w-6 h-6" />
    }
  ];

  return (
    <aside className="w-12 bg-[#333333] border-r border-[#1e1e1e] flex flex-col justify-between items-center py-2 select-none z-30 flex-shrink-0">
      {/* Top Activity Group */}
      <div className="flex flex-col items-center space-y-3 w-full">
        {topItems.map((item) => {
          const isActive = isSidebarOpen && activeSidebarView === item.view;
          return (
            <button
              key={item.view}
              onClick={() => setSidebarView(item.view)}
              title={item.label}
              className={`w-full py-2 flex items-center justify-center relative transition-colors ${
                isActive
                  ? 'text-white border-l-2 border-sky-500 bg-[#252526]'
                  : 'text-gray-400 hover:text-white hover:bg-[#3d3d3d]'
              }`}
            >
              {item.icon}
              {item.badge && item.badge > 0 ? (
                <span className="absolute top-1.5 right-1.5 bg-sky-600 text-white text-[9px] font-bold px-1 rounded-full min-w-[14px] text-center leading-3">
                  {item.badge}
                </span>
              ) : null}
            </button>
          );
        })}
      </div>

      {/* Bottom Activity Group */}
      <div className="flex flex-col items-center space-y-3 w-full">
        <button
          onClick={() => setSidebarView('settings')}
          title="Settings"
          className={`w-full py-2 flex items-center justify-center transition-colors ${
            isSidebarOpen && activeSidebarView === 'settings'
              ? 'text-white border-l-2 border-sky-500 bg-[#252526]'
              : 'text-gray-400 hover:text-white hover:bg-[#3d3d3d]'
          }`}
        >
          <Settings className="w-6 h-6" />
        </button>
      </div>
    </aside>
  );
};
