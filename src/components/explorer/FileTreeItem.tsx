import React, { useState } from 'react';
import { VFSItem } from '../../types/vfs';
import { useIDE } from '../../context/IDEContext';
import {
  ChevronRight,
  ChevronDown,
  FileCode2,
  FileJson,
  FileText,
  FileSpreadsheet,
  File,
  Folder,
  FolderOpen,
  Plus,
  FolderPlus,
  Trash2,
  Edit2,
  Code,
  Terminal,
  Database,
  Layers,
  Settings,
  Cpu,
  Flame,
  FileSearch
} from 'lucide-react';

interface FileTreeItemProps {
  item: VFSItem;
  level: number;
}

export const FileTreeItem: React.FC<FileTreeItemProps> = ({ item, level }) => {
  const {
    openFile,
    toggleFolder,
    activeTabId,
    openTabs,
    createFile,
    createFolder,
    deleteItem,
    renameItem
  } = useIDE();

  const [isCreatingFile, setIsCreatingFile] = useState(false);
  const [isCreatingFolder, setIsCreatingFolder] = useState(false);
  const [isRenaming, setIsRenaming] = useState(false);
  const [inputName, setInputName] = useState('');

  const activeTab = openTabs.find(t => t.id === activeTabId);
  const isSelected = activeTab?.path === item.path;

  const handleItemClick = (e: React.MouseEvent) => {
    e.stopPropagation();
    if (item.type === 'directory') {
      toggleFolder(item.path);
    } else {
      openFile(item.path);
    }
  };

  const handleCreateSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!inputName.trim()) return;
    if (isCreatingFile) {
      createFile(item.path, inputName.trim());
      setIsCreatingFile(false);
    } else if (isCreatingFolder) {
      createFolder(item.path, inputName.trim());
      setIsCreatingFolder(false);
    } else if (isRenaming) {
      renameItem(item.path, inputName.trim());
      setIsRenaming(false);
    }
    setInputName('');
  };

  // Helper to return distinct colored icon per file extension
  const renderFileIcon = () => {
    if (item.type === 'directory') {
      return item.isOpen ? (
        <FolderOpen className="w-4 h-4 text-amber-400 flex-shrink-0" />
      ) : (
        <Folder className="w-4 h-4 text-amber-400 flex-shrink-0" />
      );
    }

    if (item.name === 'package.json') {
      return <Layers className="w-4 h-4 text-emerald-400 flex-shrink-0" />;
    }
    if (item.name === 'Dockerfile') {
      return <Cpu className="w-4 h-4 text-sky-400 flex-shrink-0" />;
    }
    if (item.name.startsWith('.env')) {
      return <Settings className="w-4 h-4 text-amber-500 flex-shrink-0" />;
    }

    const ext = item.name.split('.').pop()?.toLowerCase();
    switch (ext) {
      case 'py':
        return <FileCode2 className="w-4 h-4 text-emerald-400 flex-shrink-0" />;
      case 'html':
      case 'htm':
        return <Code className="w-4 h-4 text-orange-500 flex-shrink-0" />;
      case 'css':
      case 'scss':
        return <FileCode2 className="w-4 h-4 text-sky-400 flex-shrink-0" />;
      case 'tsx':
      case 'jsx':
        return <FileCode2 className="w-4 h-4 text-cyan-400 flex-shrink-0" />;
      case 'ts':
      case 'js':
        return <Code className="w-4 h-4 text-amber-300 flex-shrink-0" />;
      case 'json':
        return <FileJson className="w-4 h-4 text-yellow-300 flex-shrink-0" />;
      case 'sql':
        return <Database className="w-4 h-4 text-purple-400 flex-shrink-0" />;
      case 'sh':
      case 'bash':
        return <Terminal className="w-4 h-4 text-emerald-300 flex-shrink-0" />;
      case 'md':
        return <FileText className="w-4 h-4 text-blue-300 flex-shrink-0" />;
      case 'rs':
        return <Flame className="w-4 h-4 text-orange-400 flex-shrink-0" />;
      case 'go':
        return <Cpu className="w-4 h-4 text-teal-300 flex-shrink-0" />;
      case 'yaml':
      case 'yml':
        return <FileSearch className="w-4 h-4 text-rose-400 flex-shrink-0" />;
      case 'svg':
        return <FileSpreadsheet className="w-4 h-4 text-purple-400 flex-shrink-0" />;
      default:
        return <File className="w-4 h-4 text-gray-400 flex-shrink-0" />;
    }
  };

  return (
    <div className="select-none text-xs">
      <div
        onClick={handleItemClick}
        style={{ paddingLeft: `${level * 12 + 8}px` }}
        className={`group flex items-center justify-between py-1 pr-2 cursor-pointer transition-colors ${
          isSelected
            ? 'bg-[#37373d] text-white font-medium border-l-2 border-sky-500'
            : 'text-gray-300 hover:bg-[#2a2d2e] hover:text-white'
        }`}
      >
        <div className="flex items-center space-x-1.5 min-w-0 flex-1">
          {item.type === 'directory' ? (
            <span className="text-gray-400">
              {item.isOpen ? (
                <ChevronDown className="w-3.5 h-3.5" />
              ) : (
                <ChevronRight className="w-3.5 h-3.5" />
              )}
            </span>
          ) : (
            <span className="w-3.5" />
          )}

          {renderFileIcon()}

          {isRenaming ? (
            <form onSubmit={handleCreateSubmit} onClick={(e) => e.stopPropagation()} className="flex-1">
              <input
                type="text"
                autoFocus
                value={inputName}
                onChange={(e) => setInputName(e.target.value)}
                onBlur={() => setIsRenaming(false)}
                className="bg-[#3c3c3c] border border-sky-500 text-white text-xs px-1 rounded outline-none w-full"
              />
            </form>
          ) : (
            <span className="truncate">{item.name}</span>
          )}

          {item.gitStatus && (
            <span
              className={`text-[10px] font-mono px-1 rounded ${
                item.gitStatus === 'modified'
                  ? 'text-amber-400'
                  : item.gitStatus === 'untracked'
                  ? 'text-emerald-400'
                  : 'text-gray-400'
              }`}
            >
              {item.gitStatus === 'modified' ? 'M' : item.gitStatus === 'untracked' ? 'U' : ''}
            </span>
          )}
        </div>

        {/* Hover Quick Action Buttons */}
        <div className="hidden group-hover:flex items-center space-x-1">
          {item.type === 'directory' && (
            <>
              <button
                onClick={(e) => {
                  e.stopPropagation();
                  setIsCreatingFile(true);
                  setInputName('');
                }}
                title="New File"
                className="p-0.5 hover:bg-[#454545] rounded text-gray-400 hover:text-white"
              >
                <Plus className="w-3 h-3" />
              </button>
              <button
                onClick={(e) => {
                  e.stopPropagation();
                  setIsCreatingFolder(true);
                  setInputName('');
                }}
                title="New Folder"
                className="p-0.5 hover:bg-[#454545] rounded text-gray-400 hover:text-white"
              >
                <FolderPlus className="w-3 h-3" />
              </button>
            </>
          )}
          <button
            onClick={(e) => {
              e.stopPropagation();
              setIsRenaming(true);
              setInputName(item.name);
            }}
            title="Rename"
            className="p-0.5 hover:bg-[#454545] rounded text-gray-400 hover:text-white"
          >
            <Edit2 className="w-3 h-3" />
          </button>
          <button
            onClick={(e) => {
              e.stopPropagation();
              deleteItem(item.path);
            }}
            title="Delete"
            className="p-0.5 hover:bg-red-800/80 rounded text-gray-400 hover:text-red-300"
          >
            <Trash2 className="w-3 h-3" />
          </button>
        </div>
      </div>

      {/* Inline Create Input for Directory */}
      {(isCreatingFile || isCreatingFolder) && (
        <div style={{ paddingLeft: `${(level + 1) * 12 + 20}px` }} className="py-1 pr-2">
          <form onSubmit={handleCreateSubmit} className="flex items-center space-x-1">
            {isCreatingFolder ? (
              <Folder className="w-3.5 h-3.5 text-amber-400" />
            ) : (
              <File className="w-3.5 h-3.5 text-gray-400" />
            )}
            <input
              type="text"
              autoFocus
              placeholder={isCreatingFolder ? 'Folder name' : 'File name'}
              value={inputName}
              onChange={(e) => setInputName(e.target.value)}
              onBlur={() => {
                setIsCreatingFile(false);
                setIsCreatingFolder(false);
              }}
              className="bg-[#3c3c3c] border border-sky-500 text-white text-xs px-1 rounded outline-none w-full"
            />
          </form>
        </div>
      )}

      {/* Children Directory Render */}
      {item.type === 'directory' && item.isOpen && item.children && (
        <div>
          {item.children.map((child) => (
            <FileTreeItem key={child.id} item={child} level={level + 1} />
          ))}
        </div>
      )}
    </div>
  );
};
