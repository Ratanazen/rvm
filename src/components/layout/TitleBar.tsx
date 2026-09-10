import React, { useState } from 'react';
import { useIDE } from '../../context/IDEContext';
import { Code2, Minus, Square, X, Play, Terminal as TerminalIcon, Search } from 'lucide-react';

interface MenuItem {
  label: string;
  shortcut?: string;
  action?: () => void;
}

interface Menu {
  name: string;
  items: MenuItem[];
}

export const TitleBar: React.FC = () => {
  const { openTabs, activeTabId, toggleCommandPalette, toggleBottomPanel, executeCLICommand } = useIDE();
  const activeTab = openTabs.find(t => t.id === activeTabId);
  const [activeMenu, setActiveMenu] = useState<string | null>(null);

  const menus: Menu[] = [
    {
      name: 'File',
      items: [
        { label: 'New File', shortcut: 'Ctrl+N', action: () => toggleCommandPalette() },
        { label: 'Save', shortcut: 'Ctrl+S', action: () => {} },
        { label: 'Close Tab', shortcut: 'Ctrl+W', action: () => {} },
      ]
    },
    {
      name: 'Edit',
      items: [
        { label: 'Undo', shortcut: 'Ctrl+Z' },
        { label: 'Redo', shortcut: 'Ctrl+Y' },
        { label: 'Find in Files', shortcut: 'Ctrl+Shift+F' },
      ]
    },
    {
      name: 'View',
      items: [
        { label: 'Command Palette...', shortcut: 'Ctrl+Shift+P', action: () => toggleCommandPalette() },
        { label: 'Toggle Terminal', shortcut: 'Ctrl+`', action: () => toggleBottomPanel() },
      ]
    },
    {
      name: 'Run',
      items: [
        { label: 'Run Without Debugging', shortcut: 'Ctrl+F5', action: () => executeCLICommand('npm run dev') },
      ]
    },
    {
      name: 'Terminal',
      items: [
        { label: 'New Terminal', action: () => toggleBottomPanel() },
        { label: 'Run Task...', action: () => executeCLICommand('npm run dev') },
      ]
    },
    {
      name: 'Help',
      items: [
        { label: 'Documentation', action: () => window.open('https://vitejs.dev', '_blank') },
        { label: 'About RVM', action: () => alert('RVM IDE v1.0.0\nReact + Monaco Editor + xterm.js') }
      ]
    }
  ];

  return (
    <header className="h-9 bg-[#3c3c3c] border-b border-[#2d2d2d] flex items-center justify-between text-xs text-[#cccccc] px-2 select-none relative z-40">
      {/* Left Menu */}
      <div className="flex items-center space-x-1">
        <div className="flex items-center space-x-1.5 px-2 font-bold text-sky-400">
          <Code2 className="w-4 h-4 text-sky-400" />
          <span>RVM</span>
        </div>

        <div className="flex items-center space-x-0.5 ml-2">
          {menus.map((menu) => (
            <div key={menu.name} className="relative">
              <button
                onClick={() => setActiveMenu(activeMenu === menu.name ? null : menu.name)}
                className={`px-2 py-1 rounded hover:bg-[#505050] transition-colors ${
                  activeMenu === menu.name ? 'bg-[#505050] text-white' : ''
                }`}
              >
                {menu.name}
              </button>

              {activeMenu === menu.name && (
                <>
                  <div
                    className="fixed inset-0 z-40"
                    onClick={() => setActiveMenu(null)}
                  />
                  <div className="absolute left-0 top-full mt-0.5 w-48 bg-[#252526] border border-[#454545] rounded shadow-2xl py-1 z-50 animate-fade-in">
                    {menu.items.map((item, idx) => (
                      <button
                        key={idx}
                        onClick={() => {
                          item.action?.();
                          setActiveMenu(null);
                        }}
                        className="w-full text-left px-3 py-1.5 hover:bg-[#04395e] hover:text-white flex justify-between items-center text-xs"
                      >
                        <span>{item.label}</span>
                        {item.shortcut && (
                          <span className="text-[10px] text-gray-400">{item.shortcut}</span>
                        )}
                      </button>
                    ))}
                  </div>
                </>
              )}
            </div>
          ))}
        </div>
      </div>

      {/* Middle Bar: Active File Search / Quick Switch */}
      <button
        onClick={toggleCommandPalette}
        className="flex items-center space-x-2 bg-[#2d2d2d] hover:bg-[#343434] px-4 py-1 rounded-md border border-[#454545] text-gray-300 w-80 justify-between transition-all"
      >
        <div className="flex items-center space-x-2 truncate">
          <Search className="w-3.5 h-3.5 text-gray-400" />
          <span className="truncate">{activeTab ? activeTab.path : 'my-web-app - RVM'}</span>
        </div>
        <span className="text-[10px] bg-[#3c3c3c] px-1.5 py-0.5 rounded text-gray-400 font-mono">Ctrl+P</span>
      </button>

      {/* Right Window Controls */}
      <div className="flex items-center space-x-1">
        <button
          onClick={() => toggleBottomPanel()}
          title="Toggle Terminal (Ctrl+`)"
          className="p-1.5 hover:bg-[#505050] rounded text-gray-300"
        >
          <TerminalIcon className="w-3.5 h-3.5" />
        </button>
        <button
          onClick={() => executeCLICommand('npm run dev')}
          title="Run Dev Server"
          className="p-1.5 hover:bg-emerald-700/60 rounded text-emerald-400"
        >
          <Play className="w-3.5 h-3.5 fill-emerald-400" />
        </button>
        <div className="h-4 w-px bg-gray-600 mx-1" />
        <button className="p-1.5 hover:bg-[#505050] text-gray-400">
          <Minus className="w-3.5 h-3.5" />
        </button>
        <button className="p-1.5 hover:bg-[#505050] text-gray-400">
          <Square className="w-3 h-3" />
        </button>
        <button className="p-1.5 hover:bg-red-600 text-gray-400 hover:text-white transition-colors">
          <X className="w-3.5 h-3.5" />
        </button>
      </div>
    </header>
  );
};
