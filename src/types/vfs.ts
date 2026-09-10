export type FileType = 'file' | 'directory';

export interface VFSItem {
  id: string;
  name: string;
  path: string;
  type: FileType;
  content?: string;
  language?: string;
  children?: VFSItem[];
  isOpen?: boolean;
  isModified?: boolean;
  staged?: boolean;
  gitStatus?: 'untracked' | 'modified' | 'deleted' | 'added' | 'clean';
}

export interface OpenTab {
  id: string;
  path: string;
  name: string;
  content: string;
  language: string;
  isDirty: boolean;
  originalContent: string;
}

export type SidebarView = 'explorer' | 'search' | 'git' | 'debug' | 'extensions' | 'settings';
export type BottomPanelTab = 'problems' | 'output' | 'debug' | 'terminal';

export interface ProblemItem {
  id: string;
  file: string;
  line: number;
  col: number;
  message: string;
  severity: 'error' | 'warning' | 'info';
  code?: string;
}

export interface ExtensionItem {
  id: string;
  name: string;
  publisher: string;
  description: string;
  version: string;
  downloads: string;
  rating: number;
  installed: boolean;
  category: string;
}

export interface CommandHistory {
  id: string;
  command: string;
  output: string;
  type: 'info' | 'error' | 'success' | 'system';
  directory: string;
}
