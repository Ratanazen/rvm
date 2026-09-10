import { VFSItem } from '../types/vfs';

export const getLanguageFromPath = (filename: string): string => {
  const ext = filename.split('.').pop()?.toLowerCase() || '';
  switch (ext) {
    case 'html': return 'html';
    case 'css': return 'css';
    case 'js':
    case 'jsx': return 'javascript';
    case 'ts':
    case 'tsx': return 'typescript';
    case 'json': return 'json';
    case 'py': return 'python';
    case 'md': return 'markdown';
    case 'sql': return 'sql';
    case 'sh':
    case 'bash': return 'shell';
    case 'rs': return 'rust';
    case 'go': return 'go';
    case 'cpp':
    case 'c': return 'cpp';
    case 'yaml':
    case 'yml': return 'yaml';
    case 'svg': return 'xml';
    default: return 'plaintext';
  }
};

export const INITIAL_VFS: VFSItem = {
  id: 'root-1',
  name: 'my-web-app',
  path: 'my-web-app',
  type: 'directory',
  isOpen: true,
  children: [
    {
      id: 'dir-public',
      name: 'public',
      path: 'my-web-app/public',
      type: 'directory',
      isOpen: false,
      children: [
        {
          id: 'file-favicon',
          name: 'favicon.svg',
          path: 'my-web-app/public/favicon.svg',
          type: 'file',
          language: 'xml',
          content: `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
  <circle cx="50" cy="50" r="45" fill="#007acc"/>
  <path d="M30 30 L55 50 L30 70 M60 70 L75 70" stroke="white" stroke-width="8" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
</svg>`
        }
      ]
    },
    {
      id: 'dir-src',
      name: 'src',
      path: 'my-web-app/src',
      type: 'directory',
      isOpen: true,
      children: [
        {
          id: 'file-app',
          name: 'App.tsx',
          path: 'my-web-app/src/App.tsx',
          type: 'file',
          language: 'typescript',
          content: `import React, { useState } from 'react';
import Header from './components/Header';
import { calculateStats } from './utils';

export default function App() {
  const [count, setCount] = useState<number>(0);
  const stats = calculateStats(count);

  return (
    <div className="min-h-screen bg-slate-900 text-white p-8 font-sans">
      <Header title="RVM Desktop Web IDE" />
      <main className="max-w-4xl mx-auto mt-8 p-6 bg-slate-800 rounded-xl shadow-2xl border border-slate-700">
        <h2 className="text-2xl font-bold text-sky-400">RVM Interactive Counter & Python Runner</h2>
        <p className="mt-2 text-slate-300">
          Welcome to <strong className="text-emerald-400">RVM</strong> — fast code editor with 40 built-in themes and integrated CLI!
        </p>

        <div className="mt-6 flex items-center space-x-4">
          <button
            onClick={() => setCount((c) => c + 1)}
            className="px-6 py-3 bg-sky-500 hover:bg-sky-600 font-semibold rounded-lg transition-all transform active:scale-95 shadow-lg"
          >
            Count: {count}
          </button>
          <button
            onClick={() => setCount(0)}
            className="px-4 py-3 bg-slate-700 hover:bg-slate-600 text-slate-300 font-medium rounded-lg"
          >
            Reset
          </button>
        </div>

        <div className="mt-8 grid grid-cols-3 gap-4">
          <div className="p-4 bg-slate-900/60 rounded-lg border border-slate-700">
            <span className="text-sm text-slate-400">Square Value</span>
            <p className="text-2xl font-mono text-emerald-400">{stats.square}</p>
          </div>
          <div className="p-4 bg-slate-900/60 rounded-lg border border-slate-700">
            <span className="text-sm text-slate-400">Doubled</span>
            <p className="text-2xl font-mono text-amber-400">{stats.doubled}</p>
          </div>
          <div className="p-4 bg-slate-900/60 rounded-lg border border-slate-700">
            <span className="text-sm text-slate-400">Is Even?</span>
            <p className="text-2xl font-mono text-purple-400">{stats.isEven ? 'YES' : 'NO'}</p>
          </div>
        </div>
      </main>
    </div>
  );
}`
        },
        {
          id: 'file-main-py',
          name: 'main.py',
          path: 'my-web-app/src/main.py',
          type: 'file',
          language: 'python',
          content: `# RVM Python Pipeline Script
import sys
import time

def run_rvm_analytics(dataset):
    print(f"[{time.strftime('%H:%M:%S')}] RVM Python engine processing {len(dataset)} items...")
    processed = [x ** 2 for x in dataset if x % 2 == 0]
    print(f"Filtered even squares: {processed}")
    return sum(processed)

if __name__ == "__main__":
    data = list(range(1, 11))
    total = run_rvm_analytics(data)
    print(f"✅ Analytics completed! Total result: {total}")
`
        },
        {
          id: 'file-main',
          name: 'main.tsx',
          path: 'my-web-app/src/main.tsx',
          type: 'file',
          language: 'typescript',
          content: `import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';
import './index.css';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);`
        },
        {
          id: 'file-css',
          name: 'index.css',
          path: 'my-web-app/src/index.css',
          type: 'file',
          language: 'css',
          content: `@tailwind base;
@tailwind components;
@tailwind utilities;

body {
  margin: 0;
  font-family: 'Inter', system-ui, sans-serif;
  background-color: #0f172a;
  color: #f8fafc;
}`
        },
        {
          id: 'file-utils',
          name: 'utils.ts',
          path: 'my-web-app/src/utils.ts',
          type: 'file',
          language: 'typescript',
          content: `export interface AppStats {
  square: number;
  doubled: number;
  isEven: boolean;
}

export function calculateStats(num: number): AppStats {
  return {
    square: num * num,
    doubled: num * 2,
    isEven: num % 2 === 0,
  };
}`
        },
        {
          id: 'file-query',
          name: 'query.sql',
          path: 'my-web-app/src/query.sql',
          type: 'file',
          language: 'sql',
          content: `-- RVM SQL Query Execution
SELECT 
    id, 
    username, 
    email, 
    theme_preference,
    created_at
FROM rvm_users
WHERE status = 'active'
ORDER BY created_at DESC
LIMIT 50;`
        }
      ]
    },
    {
      id: 'file-package',
      name: 'package.json',
      path: 'my-web-app/package.json',
      type: 'file',
      language: 'json',
      content: `{
  "name": "my-web-app",
  "private": true,
  "version": "0.1.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^18.3.1",
    "react-dom": "^18.3.1"
  },
  "devDependencies": {
    "@types/react": "^18.3.18",
    "@types/react-dom": "^18.3.5",
    "@vitejs/plugin-react": "^4.3.4",
    "typescript": "^5.7.3",
    "vite": "^6.1.0"
  }
}`
    },
    {
      id: 'file-readme',
      name: 'README.md',
      path: 'my-web-app/README.md',
      type: 'file',
      language: 'markdown',
      content: `# My Web App 🚀

Welcome to your project inside **RVM**!

## Features
- ⚡ Fast Vite + React + TypeScript + Python engine
- 🎨 40 built-in themes & full file type icons
- 💻 Integrated CLI with \`rvm\` command support

## CLI Commands in Terminal
Try running:
- \`rvm .\`
- \`rvm main.py\`
- \`npm run dev\`
- \`python src/main.py\`
- \`git status\`
`
    },
    {
      id: 'file-html',
      name: 'index.html',
      path: 'my-web-app/index.html',
      type: 'file',
      language: 'html',
      content: `<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/public/favicon.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>My Web App - RVM</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>`
    }
  ]
};
