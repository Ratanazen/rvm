import React, { useState } from 'react';
import { useIDE } from '../../context/IDEContext';
import { VFSItem } from '../../types/vfs';
import { GitBranch, Check, Plus, Minus, FileCode2, RefreshCw } from 'lucide-react';

export const SourceControlView: React.FC = () => {
  const { vfs, openFile, executeCLICommand } = useIDE();
  const [commitMessage, setCommitMessage] = useState('');
  const [committedNotice, setCommittedNotice] = useState('');

  // Collect modified & untracked items
  const collectChanges = (node: VFSItem, list: VFSItem[]) => {
    if (node.type === 'file') {
      if (node.isModified || node.gitStatus === 'modified' || node.gitStatus === 'untracked') {
        list.push(node);
      }
    }
    if (node.children) {
      node.children.forEach(c => collectChanges(c, list));
    }
  };

  const changes: VFSItem[] = [];
  collectChanges(vfs, changes);

  const handleCommit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!commitMessage.trim()) return;
    executeCLICommand(`git commit -m "${commitMessage.trim()}"`);
    setCommittedNotice(`Committed: "${commitMessage.trim()}"`);
    setCommitMessage('');
    setTimeout(() => setCommittedNotice(''), 3000);
  };

  return (
    <div className="flex flex-col h-full bg-[#252526] text-[#cccccc] select-none text-xs p-2">
      <div className="flex items-center justify-between font-semibold text-gray-300 uppercase tracking-wider text-[11px] mb-2 px-1">
        <span>SOURCE CONTROL</span>
        <button
          onClick={() => executeCLICommand('git status')}
          title="Refresh Git Status"
          className="p-1 hover:bg-[#37373d] rounded text-gray-400 hover:text-white"
        >
          <RefreshCw className="w-3.5 h-3.5" />
        </button>
      </div>

      {/* Branch Header */}
      <div className="flex items-center space-x-2 bg-[#2d2d2d] px-2 py-1.5 rounded mb-3 border border-[#3c3c3c]">
        <GitBranch className="w-4 h-4 text-sky-400" />
        <span className="font-semibold text-white">main</span>
        <span className="text-[10px] text-gray-400">origin/main</span>
      </div>

      {/* Commit Input Box */}
      <form onSubmit={handleCommit} className="space-y-2 mb-3">
        <textarea
          rows={2}
          placeholder="Message (Ctrl+Enter to commit)"
          value={commitMessage}
          onChange={(e) => setCommitMessage(e.target.value)}
          className="w-full bg-[#3c3c3c] border border-[#555555] focus:border-sky-500 rounded p-2 text-white text-xs outline-none resize-none"
        />
        <button
          type="submit"
          disabled={changes.length === 0 || !commitMessage.trim()}
          className={`w-full py-1.5 rounded text-xs font-semibold flex items-center justify-center space-x-1.5 transition-colors ${
            changes.length > 0 && commitMessage.trim()
              ? 'bg-[#0e639c] hover:bg-[#1177bb] text-white'
              : 'bg-[#3a3a3a] text-gray-500 cursor-not-allowed'
          }`}
        >
          <Check className="w-3.5 h-3.5" />
          <span>Commit</span>
        </button>
      </form>

      {committedNotice && (
        <div className="bg-emerald-900/60 border border-emerald-600 text-emerald-300 p-2 rounded mb-2 text-xs animate-fade-in">
          {committedNotice}
        </div>
      )}

      {/* Changes Header */}
      <div className="flex items-center justify-between font-bold text-gray-300 text-[11px] mb-2 px-1">
        <span>CHANGES</span>
        <span className="bg-[#3c3c3c] px-1.5 py-0.5 rounded text-[10px]">{changes.length}</span>
      </div>

      {/* Changes List */}
      <div className="flex-1 overflow-y-auto space-y-1">
        {changes.length === 0 ? (
          <div className="text-gray-500 text-[11px] italic p-2 text-center">
            No pending git changes
          </div>
        ) : (
          changes.map((item) => (
            <div
              key={item.id}
              onClick={() => openFile(item.path)}
              className="flex items-center justify-between p-1.5 hover:bg-[#2a2d2e] rounded cursor-pointer group"
            >
              <div className="flex items-center space-x-2 min-w-0">
                <FileCode2 className="w-3.5 h-3.5 text-gray-400 flex-shrink-0" />
                <span className="truncate text-gray-200">{item.name}</span>
                <span className="text-[10px] text-gray-500 truncate">{item.path}</span>
              </div>
              <span className="font-mono text-[11px] font-bold text-amber-400">
                {item.gitStatus === 'untracked' ? 'U' : 'M'}
              </span>
            </div>
          ))
        )}
      </div>
    </div>
  );
};
