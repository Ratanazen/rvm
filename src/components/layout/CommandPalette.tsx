import React, { useState, useEffect } from 'react';
import { useIDE } from '../../context/IDEContext';
import { Search, Terminal, FilePlus, FolderPlus, Play, Columns2, Settings, Trash2 } from 'lucide-react';

export const CommandPalette: React.FC = () => {
  const {
    commandPaletteOpen,
    toggleCommandPalette,
    toggleBottomPanel,
    executeCLICommand,
    toggleSplitEditor,
    setSidebarView,
    createFile
  } = useIDE();

  const [query, setQuery] = useState('');

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if ((e.ctrlKey || e.metaKey) && e.shiftKey && e.key.toLowerCase() === 'p') {
        e.preventDefault();
        toggleCommandPalette();
      } else if (e.key === 'Escape' && commandPaletteOpen) {
        toggleCommandPalette();
      }
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [commandPaletteOpen]);

  if (!commandPaletteOpen) return null;

  const commands = [
    {
      id: 'cmd-term',
      label: 'Terminal: Toggle Integrated Terminal',
      icon: <Terminal className="w-4 h-4 text-sky-400" />,
      action: () => toggleBottomPanel()
    },
    {
      id: 'cmd-dev',
      label: 'Tasks: Run Dev Server (npm run dev)',
      icon: <Play className="w-4 h-4 text-emerald-400" />,
      action: () => executeCLICommand('npm run dev')
    },
    {
      id: 'cmd-newfile',
      label: 'File: New File in Root',
      icon: <FilePlus className="w-4 h-4 text-amber-400" />,
      action: () => createFile('my-web-app', 'untitled.ts')
    },
    {
      id: 'cmd-split',
      label: 'View: Toggle Split Editor',
      icon: <Columns2 className="w-4 h-4 text-purple-400" />,
      action: () => toggleSplitEditor()
    },
    {
      id: 'cmd-settings',
      label: 'Preferences: Open User Settings',
      icon: <Settings className="w-4 h-4 text-gray-400" />,
      action: () => setSidebarView('settings')
    },
    {
      id: 'cmd-clear',
      label: 'Terminal: Clear Terminal Output',
      icon: <Trash2 className="w-4 h-4 text-red-400" />,
      action: () => executeCLICommand('clear')
    }
  ];

  const filtered = commands.filter(c => c.label.toLowerCase().includes(query.toLowerCase()));

  return (
    <div className="fixed inset-0 bg-black/60 backdrop-blur-xs z-50 flex items-start justify-center pt-12 select-none">
      <div
        className="fixed inset-0"
        onClick={toggleCommandPalette}
      />
      <div className="relative w-full max-w-xl bg-[#252526] border border-[#454545] rounded-lg shadow-2xl overflow-hidden z-10 animate-fade-in text-xs">
        <div className="flex items-center px-3 py-2 border-b border-[#3c3c3c]">
          <Search className="w-4 h-4 text-gray-400 mr-2" />
          <input
            type="text"
            autoFocus
            placeholder="Type a command or search..."
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            className="w-full bg-transparent text-white text-sm outline-none placeholder-gray-500 font-sans"
          />
        </div>

        <div className="max-h-72 overflow-y-auto py-1">
          {filtered.length === 0 ? (
            <div className="p-4 text-gray-500 text-center">No matching commands found</div>
          ) : (
            filtered.map((cmd) => (
              <div
                key={cmd.id}
                onClick={() => {
                  cmd.action();
                  toggleCommandPalette();
                }}
                className="flex items-center space-x-3 px-4 py-2 hover:bg-[#04395e] hover:text-white text-gray-300 cursor-pointer transition-colors"
              >
                {cmd.icon}
                <span className="truncate flex-1 font-medium">{cmd.label}</span>
              </div>
            ))
          )}
        </div>
      </div>
    </div>
  );
};
