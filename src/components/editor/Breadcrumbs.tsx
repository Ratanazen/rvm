import React from 'react';
import { useIDE } from '../../context/IDEContext';
import { ChevronRight, FileCode, Folder } from 'lucide-react';

export const Breadcrumbs: React.FC = () => {
  const { openTabs, activeTabId } = useIDE();
  const activeTab = openTabs.find(t => t.id === activeTabId);

  if (!activeTab) return null;

  const parts = activeTab.path.split('/');

  return (
    <div className="flex items-center space-x-1 px-4 py-1 bg-[#1e1e1e] border-b border-[#252526] text-[11px] text-gray-400 select-none">
      {parts.map((part, idx) => {
        const isLast = idx === parts.length - 1;
        return (
          <React.Fragment key={idx}>
            {idx > 0 && <ChevronRight className="w-3 h-3 text-gray-600 flex-shrink-0" />}
            <div className={`flex items-center space-x-1 ${isLast ? 'text-gray-200 font-medium' : 'hover:text-gray-300'}`}>
              {isLast ? (
                <FileCode className="w-3.5 h-3.5 text-sky-400" />
              ) : (
                <Folder className="w-3.5 h-3.5 text-amber-500/80" />
              )}
              <span>{part}</span>
            </div>
          </React.Fragment>
        );
      })}
    </div>
  );
};
