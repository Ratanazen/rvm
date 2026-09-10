import React, { useState } from 'react';
import { useIDE } from '../../context/IDEContext';
import { Blocks, Search, Star, Download, Check } from 'lucide-react';

export const ExtensionsView: React.FC = () => {
  const { extensions, toggleExtension } = useIDE();
  const [filter, setFilter] = useState('');

  const filtered = extensions.filter(ext =>
    ext.name.toLowerCase().includes(filter.toLowerCase()) ||
    ext.description.toLowerCase().includes(filter.toLowerCase())
  );

  return (
    <div className="flex flex-col h-full bg-[#252526] text-[#cccccc] select-none text-xs p-2">
      <div className="font-semibold text-gray-300 uppercase tracking-wider text-[11px] mb-2 px-1">
        EXTENSIONS
      </div>

      <div className="relative flex items-center mb-3">
        <input
          type="text"
          placeholder="Search Extensions in Marketplace..."
          value={filter}
          onChange={(e) => setFilter(e.target.value)}
          className="w-full bg-[#3c3c3c] border border-[#555555] focus:border-sky-500 rounded px-2 py-1 text-white text-xs outline-none pr-6"
        />
        <Search className="w-3.5 h-3.5 text-gray-400 absolute right-2" />
      </div>

      <div className="flex-1 overflow-y-auto space-y-2 pr-1">
        {filtered.map((ext) => (
          <div
            key={ext.id}
            className="bg-[#2d2d2d] border border-[#3c3c3c] rounded p-2 hover:border-[#555555] transition-colors"
          >
            <div className="flex items-start justify-between">
              <div className="flex items-center space-x-2">
                <div className="w-8 h-8 rounded bg-sky-900/60 border border-sky-600 flex items-center justify-center font-bold text-sky-300 text-sm">
                  {ext.name.charAt(0)}
                </div>
                <div>
                  <h4 className="font-semibold text-white truncate max-w-[140px]">{ext.name}</h4>
                  <p className="text-[10px] text-gray-400">{ext.publisher}</p>
                </div>
              </div>

              <button
                onClick={() => toggleExtension(ext.id)}
                className={`px-2 py-0.5 rounded text-[11px] font-medium flex items-center space-x-1 ${
                  ext.installed
                    ? 'bg-[#3a3a3a] text-gray-300 hover:bg-red-900/60 hover:text-red-300'
                    : 'bg-[#0e639c] hover:bg-[#1177bb] text-white'
                }`}
              >
                {ext.installed ? (
                  <>
                    <Check className="w-3 h-3 text-emerald-400" />
                    <span>Installed</span>
                  </>
                ) : (
                  <span>Install</span>
                )}
              </button>
            </div>

            <p className="text-[11px] text-gray-300 mt-2 line-clamp-2">{ext.description}</p>

            <div className="flex items-center space-x-3 mt-2 text-[10px] text-gray-400">
              <span className="flex items-center space-x-0.5">
                <Download className="w-3 h-3" />
                <span>{ext.downloads}</span>
              </span>
              <span className="flex items-center space-x-0.5 text-amber-400">
                <Star className="w-3 h-3 fill-amber-400" />
                <span>{ext.rating}</span>
              </span>
              <span className="bg-[#3c3c3c] px-1 rounded">{ext.category}</span>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};
