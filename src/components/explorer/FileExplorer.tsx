import React, { useState } from 'react';
import { useIDE } from '../../context/IDEContext';
import { FileTreeItem } from './FileTreeItem';
import { Plus, FolderPlus, RotateCw, ChevronRight, ChevronDown, MoreHorizontal } from 'lucide-react';

export const FileExplorer: React.FC = () => {
  const { vfs, createFile, createFolder } = useIDE();
  const [isSectionOpen, setIsSectionOpen] = useState(true);
  const [isCreatingFileRoot, setIsCreatingFileRoot] = useState(false);
  const [isCreatingFolderRoot, setIsCreatingFolderRoot] = useState(false);
  const [rootInput, setRootInput] = useState('');

  const handleRootSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!rootInput.trim()) return;
    if (isCreatingFileRoot) {
      createFile('my-web-app', rootInput.trim());
      setIsCreatingFileRoot(false);
    } else if (isCreatingFolderRoot) {
      createFolder('my-web-app', rootInput.trim());
      setIsCreatingFolderRoot(false);
    }
    setRootInput('');
  };

  return (
    <div className="flex flex-col h-full bg-[#252526] text-[#cccccc] select-none text-xs">
      {/* Header Bar */}
      <div className="flex items-center justify-between px-4 py-2 border-b border-[#1e1e1e] font-semibold text-gray-300 tracking-wider text-[11px] uppercase">
        <span>Explorer</span>
        <button className="p-1 hover:bg-[#37373d] rounded">
          <MoreHorizontal className="w-4 h-4 text-gray-400" />
        </button>
      </div>

      {/* Accordion Header for Workspace */}
      <div className="flex-1 overflow-y-auto">
        <div className="flex items-center justify-between px-2 py-1 bg-[#2a2d2e] font-bold text-gray-200 border-b border-[#1e1e1e]">
          <div
            onClick={() => setIsSectionOpen(!isSectionOpen)}
            className="flex items-center space-x-1 cursor-pointer truncate"
          >
            {isSectionOpen ? (
              <ChevronDown className="w-3.5 h-3.5 text-gray-400" />
            ) : (
              <ChevronRight className="w-3.5 h-3.5 text-gray-400" />
            )}
            <span className="truncate uppercase font-extrabold text-[11px]">MY-WEB-APP</span>
          </div>

          <div className="flex items-center space-x-1">
            <button
              onClick={() => {
                setIsCreatingFileRoot(true);
                setRootInput('');
              }}
              title="New File in Root"
              className="p-1 hover:bg-[#3d3d3d] rounded text-gray-400 hover:text-white"
            >
              <Plus className="w-3.5 h-3.5" />
            </button>
            <button
              onClick={() => {
                setIsCreatingFolderRoot(true);
                setRootInput('');
              }}
              title="New Folder in Root"
              className="p-1 hover:bg-[#3d3d3d] rounded text-gray-400 hover:text-white"
            >
              <FolderPlus className="w-3.5 h-3.5" />
            </button>
          </div>
        </div>

        {/* Root Inline Create Form */}
        {(isCreatingFileRoot || isCreatingFolderRoot) && (
          <div className="px-4 py-1">
            <form onSubmit={handleRootSubmit}>
              <input
                type="text"
                autoFocus
                placeholder={isCreatingFolderRoot ? 'Folder name in root' : 'File name in root'}
                value={rootInput}
                onChange={(e) => setRootInput(e.target.value)}
                onBlur={() => {
                  setIsCreatingFileRoot(false);
                  setIsCreatingFolderRoot(false);
                }}
                className="bg-[#3c3c3c] border border-sky-500 text-white text-xs px-1 py-0.5 rounded outline-none w-full"
              />
            </form>
          </div>
        )}

        {/* Tree List */}
        {isSectionOpen && vfs.children && (
          <div className="py-1">
            {vfs.children.map((child) => (
              <FileTreeItem key={child.id} item={child} level={0} />
            ))}
          </div>
        )}
      </div>
    </div>
  );
};
