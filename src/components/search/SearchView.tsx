import React, { useState } from 'react';
import { useIDE } from '../../context/IDEContext';
import { VFSItem } from '../../types/vfs';
import { Search as SearchIcon, Replace, ChevronRight, ChevronDown, FileText } from 'lucide-react';

interface SearchResult {
  file: VFSItem;
  matches: { line: number; text: string }[];
}

export const SearchView: React.FC = () => {
  const { vfs, openFile, updateFileContent } = useIDE();
  const [query, setQuery] = useState('');
  const [replaceQuery, setReplaceQuery] = useState('');
  const [showReplace, setShowReplace] = useState(false);

  // Search through all VFS files recursively
  const searchVFS = (node: VFSItem, q: string, results: SearchResult[]) => {
    if (!q.trim()) return;
    if (node.type === 'file' && node.content) {
      const lines = node.content.split('\n');
      const matches: { line: number; text: string }[] = [];
      lines.forEach((lineText, idx) => {
        if (lineText.toLowerCase().includes(q.toLowerCase())) {
          matches.push({ line: idx + 1, text: lineText.trim() });
        }
      });
      if (matches.length > 0) {
        results.push({ file: node, matches });
      }
    }
    if (node.children) {
      node.children.forEach(c => searchVFS(c, q, results));
    }
  };

  const results: SearchResult[] = [];
  searchVFS(vfs, query, results);
  const totalMatches = results.reduce((acc, r) => acc + r.matches.length, 0);

  const handleReplaceAll = () => {
    if (!query || !replaceQuery) return;
    results.forEach(res => {
      if (res.file.content) {
        const regex = new RegExp(query, 'gi');
        const newContent = res.file.content.replace(regex, replaceQuery);
        updateFileContent(res.file.path, newContent);
      }
    });
  };

  return (
    <div className="flex flex-col h-full bg-[#252526] text-[#cccccc] select-none text-xs p-2">
      <div className="font-semibold text-gray-300 uppercase tracking-wider text-[11px] mb-2 px-1">
        SEARCH
      </div>

      <div className="space-y-2 mb-3">
        <div className="relative flex items-center">
          <input
            type="text"
            placeholder="Search files..."
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            className="w-full bg-[#3c3c3c] border border-[#555555] focus:border-sky-500 rounded px-2 py-1 text-white text-xs outline-none pr-6"
          />
          <SearchIcon className="w-3.5 h-3.5 text-gray-400 absolute right-2" />
        </div>

        <div className="flex items-center space-x-1">
          <button
            onClick={() => setShowReplace(!showReplace)}
            className="text-[10px] text-sky-400 hover:underline flex items-center space-x-1"
          >
            <Replace className="w-3 h-3" />
            <span>{showReplace ? 'Hide Replace' : 'Toggle Replace'}</span>
          </button>
        </div>

        {showReplace && (
          <div className="space-y-1 animate-fade-in">
            <input
              type="text"
              placeholder="Replace with..."
              value={replaceQuery}
              onChange={(e) => setReplaceQuery(e.target.value)}
              className="w-full bg-[#3c3c3c] border border-[#555555] focus:border-sky-500 rounded px-2 py-1 text-white text-xs outline-none"
            />
            <button
              onClick={handleReplaceAll}
              className="w-full bg-[#0e639c] hover:bg-[#1177bb] text-white py-1 rounded text-xs font-medium"
            >
              Replace All in {results.length} files
            </button>
          </div>
        )}
      </div>

      {query && (
        <div className="text-[11px] text-gray-400 mb-2 px-1">
          {totalMatches} results in {results.length} files
        </div>
      )}

      {/* Results List */}
      <div className="flex-1 overflow-y-auto space-y-2 pr-1">
        {results.map((res) => (
          <div key={res.file.id} className="bg-[#2d2d2d] rounded p-1.5 border border-[#3c3c3c]">
            <div
              onClick={() => openFile(res.file.path)}
              className="flex items-center space-x-1 font-semibold text-sky-400 cursor-pointer hover:underline mb-1"
            >
              <FileText className="w-3.5 h-3.5" />
              <span>{res.file.name}</span>
              <span className="text-[10px] text-gray-500">({res.matches.length})</span>
            </div>

            <div className="space-y-1 pl-2">
              {res.matches.map((m, idx) => (
                <div
                  key={idx}
                  onClick={() => openFile(res.file.path)}
                  className="flex items-center space-x-2 text-[11px] text-gray-300 hover:bg-[#383838] p-0.5 rounded cursor-pointer truncate"
                >
                  <span className="text-gray-500 font-mono w-6 text-right flex-shrink-0">{m.line}:</span>
                  <span className="truncate">{m.text}</span>
                </div>
              ))}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};
