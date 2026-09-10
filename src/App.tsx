import React from 'react';
import { IDEProvider } from './context/IDEContext';
import { TitleBar } from './components/layout/TitleBar';
import { ActivityBar } from './components/layout/ActivityBar';
import { Sidebar } from './components/layout/Sidebar';
import { MonacoEditorArea } from './components/editor/MonacoEditorArea';
import { BottomPanel } from './components/layout/BottomPanel';
import { StatusBar } from './components/layout/StatusBar';
import { CommandPalette } from './components/layout/CommandPalette';

const MainLayout: React.FC = () => {
  return (
    <div className="flex flex-col h-screen w-screen bg-[#1e1e1e] overflow-hidden select-none font-sans">
      {/* Top Title Bar */}
      <TitleBar />

      {/* Main Workbench Area */}
      <div className="flex-1 flex overflow-hidden relative">
        {/* Left Activity Bar */}
        <ActivityBar />

        {/* Primary Sidebar (Explorer, Search, Git, Debug, Extensions) */}
        <Sidebar />

        {/* Main Work Area (Monaco Editor & Bottom Panel) */}
        <div className="flex-1 flex flex-col h-full overflow-hidden relative">
          <MonacoEditorArea />
          <BottomPanel />
        </div>
      </div>

      {/* Bottom Status Bar */}
      <StatusBar />

      {/* Global Command Palette Modal */}
      <CommandPalette />
    </div>
  );
};

export default function App() {
  return (
    <IDEProvider>
      <MainLayout />
    </IDEProvider>
  );
}
