import React, { createContext, useContext, useState, useEffect } from 'react';
import { VFSItem, OpenTab, SidebarView, BottomPanelTab, ProblemItem, ExtensionItem } from '../types/vfs';
import { INITIAL_VFS, getLanguageFromPath } from '../utils/defaultVFS';
import { parseAndExecuteCLI, CLIResult } from '../utils/cliParser';

interface IDEContextType {
  vfs: VFSItem;
  cwd: string;
  setCwd: (path: string) => void;
  openTabs: OpenTab[];
  activeTabId: string | null;
  activeSidebarView: SidebarView;
  activeBottomTab: BottomPanelTab;
  isSidebarOpen: boolean;
  isBottomPanelOpen: boolean;
  sidebarWidth: number;
  setSidebarWidth: (width: number) => void;
  bottomPanelHeight: number;
  setBottomPanelHeight: (height: number) => void;
  devServerRunning: boolean;
  setDevServerRunning: (running: boolean) => void;
  problems: ProblemItem[];
  extensions: ExtensionItem[];
  commandPaletteOpen: boolean;
  splitEditor: boolean;
  
  // Actions
  openFile: (path: string) => void;
  closeTab: (id: string) => void;
  setActiveTabId: (id: string) => void;
  updateFileContent: (path: string, content: string) => void;
  saveFile: (path: string) => void;
  createFile: (parentPath: string, name: string) => void;
  createFolder: (parentPath: string, name: string) => void;
  deleteItem: (path: string) => void;
  renameItem: (path: string, newName: string) => void;
  toggleFolder: (path: string) => void;
  setSidebarView: (view: SidebarView) => void;
  setBottomTab: (tab: BottomPanelTab) => void;
  toggleSidebar: () => void;
  toggleBottomPanel: () => void;
  toggleCommandPalette: () => void;
  toggleSplitEditor: () => void;
  executeCLICommand: (cmd: string) => CLIResult;
  toggleExtension: (id: string) => void;
  
  // Helpers
  getFileByPath: (path: string) => VFSItem | null;
}

const INITIAL_PROBLEMS: ProblemItem[] = [
  {
    id: 'prob-1',
    file: 'my-web-app/src/App.tsx',
    line: 12,
    col: 24,
    message: "'calculateStats' is imported but can be enhanced with memoization.",
    severity: 'info',
    code: 'TS6133'
  },
  {
    id: 'prob-2',
    file: 'my-web-app/package.json',
    line: 18,
    col: 5,
    message: "Consider updating Vite to v6.2.0 for security enhancements.",
    severity: 'warning',
    code: 'NPM001'
  }
];

const INITIAL_EXTENSIONS: ExtensionItem[] = [
  {
    id: 'ext-prettier',
    name: 'Prettier - Code formatter',
    publisher: 'esbenp',
    description: 'Code formatter using prettier',
    version: '10.4.0',
    downloads: '45.2M',
    rating: 4.8,
    installed: true,
    category: 'Formatters'
  },
  {
    id: 'ext-eslint',
    name: 'ESLint',
    publisher: 'dbaeumer',
    description: 'Integrates ESLint JavaScript into VS Code.',
    version: '3.0.10',
    downloads: '32.1M',
    rating: 4.6,
    installed: true,
    category: 'Linters'
  },
  {
    id: 'ext-python',
    name: 'Python',
    publisher: 'ms-python',
    description: 'IntelliSense, Linting, Debugging, Code formatting for Python',
    version: '2024.1.0',
    downloads: '112M',
    rating: 4.9,
    installed: false,
    category: 'Languages'
  },
  {
    id: 'ext-tailwind',
    name: 'Tailwind CSS IntelliSense',
    publisher: 'bradlc',
    description: 'Intelligent Tailwind CSS tooling for VS Code',
    version: '0.12.0',
    downloads: '14.8M',
    rating: 4.9,
    installed: true,
    category: 'Snippets'
  },
  {
    id: 'ext-gitlens',
    name: 'GitLens — Git supercharged',
    publisher: 'eamodio',
    description: 'Supercharge Git within VS Code — Visualize code authorship',
    version: '15.0.1',
    downloads: '31.4M',
    rating: 4.7,
    installed: false,
    category: 'Git'
  }
];

const IDEContext = createContext<IDEContextType | undefined>(undefined);

export const IDEProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [vfs, setVfs] = useState<VFSItem>(INITIAL_VFS);
  const [cwd, setCwd] = useState<string>('my-web-app');
  const [openTabs, setOpenTabs] = useState<OpenTab[]>([]);
  const [activeTabId, setActiveTabId] = useState<string | null>(null);
  
  const [activeSidebarView, setActiveSidebarView] = useState<SidebarView>('explorer');
  const [activeBottomTab, setActiveBottomTab] = useState<BottomPanelTab>('terminal');
  const [isSidebarOpen, setIsSidebarOpen] = useState<boolean>(true);
  const [isBottomPanelOpen, setIsBottomPanelOpen] = useState<boolean>(true);
  
  const [sidebarWidth, setSidebarWidth] = useState<number>(260);
  const [bottomPanelHeight, setBottomPanelHeight] = useState<number>(240);
  
  const [devServerRunning, setDevServerRunning] = useState<boolean>(false);
  const [problems, setProblems] = useState<ProblemItem[]>(INITIAL_PROBLEMS);
  const [extensions, setExtensions] = useState<ExtensionItem[]>(INITIAL_EXTENSIONS);
  const [commandPaletteOpen, setCommandPaletteOpen] = useState<boolean>(false);
  const [splitEditor, setSplitEditor] = useState<boolean>(false);

  // Helper to locate file in VFS
  const getFileByPath = (targetPath: string): VFSItem | null => {
    const search = (node: VFSItem): VFSItem | null => {
      if (node.path === targetPath) return node;
      if (node.children) {
        for (const child of node.children) {
          const res = search(child);
          if (res) return res;
        }
      }
      return null;
    };
    return search(vfs);
  };

  // Open default file on initial load
  useEffect(() => {
    openFile('my-web-app/src/App.tsx');
  }, []);

  const openFile = (path: string) => {
    const fileNode = getFileByPath(path);
    if (!fileNode || fileNode.type !== 'file') return;

    // Check if already open
    const existingTab = openTabs.find(t => t.path === path);
    if (existingTab) {
      setActiveTabId(existingTab.id);
      return;
    }

    const newTab: OpenTab = {
      id: fileNode.id,
      path: fileNode.path,
      name: fileNode.name,
      content: fileNode.content || '',
      language: fileNode.language || getLanguageFromPath(fileNode.name),
      isDirty: false,
      originalContent: fileNode.content || ''
    };

    setOpenTabs(prev => [...prev, newTab]);
    setActiveTabId(newTab.id);
  };

  const closeTab = (id: string) => {
    setOpenTabs(prev => {
      const filtered = prev.filter(t => t.id !== id);
      if (activeTabId === id && filtered.length > 0) {
        setActiveTabId(filtered[filtered.length - 1].id);
      } else if (filtered.length === 0) {
        setActiveTabId(null);
      }
      return filtered;
    });
  };

  const updateFileContent = (path: string, content: string) => {
    // Update tab status
    setOpenTabs(prev => prev.map(tab => {
      if (tab.path === path) {
        const isDirty = content !== tab.originalContent;
        return { ...tab, content, isDirty };
      }
      return tab;
    }));

    // Update VFS node content
    const updateVFS = (node: VFSItem): VFSItem => {
      if (node.path === path) {
        return { ...node, content, isModified: true, gitStatus: 'modified' };
      }
      if (node.children) {
        return { ...node, children: node.children.map(updateVFS) };
      }
      return node;
    };
    setVfs(prev => updateVFS(prev));
  };

  const saveFile = (path: string) => {
    setOpenTabs(prev => prev.map(tab => {
      if (tab.path === path) {
        return { ...tab, isDirty: false, originalContent: tab.content };
      }
      return tab;
    }));
  };

  const toggleFolder = (path: string) => {
    const updateVFS = (node: VFSItem): VFSItem => {
      if (node.path === path && node.type === 'directory') {
        return { ...node, isOpen: !node.isOpen };
      }
      if (node.children) {
        return { ...node, children: node.children.map(updateVFS) };
      }
      return node;
    };
    setVfs(prev => updateVFS(prev));
  };

  const createFile = (parentPath: string, name: string) => {
    const filePath = `${parentPath}/${name}`.replace(/\/+/g, '/');
    const newFileNode: VFSItem = {
      id: `file-${Date.now()}`,
      name,
      path: filePath,
      type: 'file',
      language: getLanguageFromPath(name),
      content: `// New file ${name}\n`,
      gitStatus: 'untracked'
    };

    const insertVFS = (node: VFSItem): VFSItem => {
      if (node.path === parentPath) {
        return {
          ...node,
          isOpen: true,
          children: [...(node.children || []), newFileNode]
        };
      }
      if (node.children) {
        return { ...node, children: node.children.map(insertVFS) };
      }
      return node;
    };

    setVfs(prev => insertVFS(prev));
    openFile(filePath);
  };

  const createFolder = (parentPath: string, name: string) => {
    const folderPath = `${parentPath}/${name}`.replace(/\/+/g, '/');
    const newFolderNode: VFSItem = {
      id: `dir-${Date.now()}`,
      name,
      path: folderPath,
      type: 'directory',
      isOpen: true,
      children: []
    };

    const insertVFS = (node: VFSItem): VFSItem => {
      if (node.path === parentPath) {
        return {
          ...node,
          isOpen: true,
          children: [...(node.children || []), newFolderNode]
        };
      }
      if (node.children) {
        return { ...node, children: node.children.map(insertVFS) };
      }
      return node;
    };

    setVfs(prev => insertVFS(prev));
  };

  const deleteItem = (path: string) => {
    const deleteVFS = (node: VFSItem): VFSItem => {
      if (node.children) {
        return {
          ...node,
          children: node.children.filter(c => c.path !== path).map(deleteVFS)
        };
      }
      return node;
    };

    setVfs(prev => deleteVFS(prev));
    
    // Close tab if open
    const openTab = openTabs.find(t => t.path === path);
    if (openTab) {
      closeTab(openTab.id);
    }
  };

  const renameItem = (path: string, newName: string) => {
    const updateVFS = (node: VFSItem): VFSItem => {
      if (node.path === path) {
        const pathParts = node.path.split('/');
        pathParts[pathParts.length - 1] = newName;
        const newPath = pathParts.join('/');
        return {
          ...node,
          name: newName,
          path: newPath,
          language: node.type === 'file' ? getLanguageFromPath(newName) : undefined
        };
      }
      if (node.children) {
        return { ...node, children: node.children.map(updateVFS) };
      }
      return node;
    };

    setVfs(prev => updateVFS(prev));
  };

  const setSidebarView = (view: SidebarView) => {
    if (activeSidebarView === view && isSidebarOpen) {
      setIsSidebarOpen(false);
    } else {
      setActiveSidebarView(view);
      setIsSidebarOpen(true);
    }
  };

  const setBottomTab = (tab: BottomPanelTab) => {
    if (activeBottomTab === tab && isBottomPanelOpen) {
      setIsBottomPanelOpen(false);
    } else {
      setActiveBottomTab(tab);
      setIsBottomPanelOpen(true);
    }
  };

  const toggleSidebar = () => setIsSidebarOpen(prev => !prev);
  const toggleBottomPanel = () => setIsBottomPanelOpen(prev => !prev);
  const toggleCommandPalette = () => setCommandPaletteOpen(prev => !prev);
  const toggleSplitEditor = () => setSplitEditor(prev => !prev);

  const executeCLICommand = (cmd: string): CLIResult => {
    const res = parseAndExecuteCLI(cmd, vfs, cwd);
    if (res.newVFS) {
      setVfs(res.newVFS);
    }
    if (res.newCwd) {
      setCwd(res.newCwd);
    }
    if (res.openFile) {
      openFile(res.openFile);
    }
    if (res.triggerDevServer) {
      setDevServerRunning(true);
    }
    return res;
  };

  const toggleExtension = (id: string) => {
    setExtensions(prev => prev.map(ext => ext.id === id ? { ...ext, installed: !ext.installed } : ext));
  };

  return (
    <IDEContext.Provider
      value={{
        vfs,
        cwd,
        setCwd,
        openTabs,
        activeTabId,
        activeSidebarView,
        activeBottomTab,
        isSidebarOpen,
        isBottomPanelOpen,
        sidebarWidth,
        setSidebarWidth,
        bottomPanelHeight,
        setBottomPanelHeight,
        devServerRunning,
        setDevServerRunning,
        problems,
        extensions,
        commandPaletteOpen,
        splitEditor,
        openFile,
        closeTab,
        setActiveTabId,
        updateFileContent,
        saveFile,
        createFile,
        createFolder,
        deleteItem,
        renameItem,
        toggleFolder,
        setSidebarView,
        setBottomTab,
        toggleSidebar,
        toggleBottomPanel,
        toggleCommandPalette,
        toggleSplitEditor,
        executeCLICommand,
        toggleExtension,
        getFileByPath,
      }}
    >
      {children}
    </IDEContext.Provider>
  );
};

export const useIDE = () => {
  const context = useContext(IDEContext);
  if (!context) {
    throw new Error('useIDE must be used within an IDEProvider');
  }
  return context;
};
