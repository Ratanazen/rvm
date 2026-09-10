import { VFSItem } from '../types/vfs';
import { getLanguageFromPath } from './defaultVFS';

export interface CLIResult {
  output: string;
  newVFS?: VFSItem;
  newCwd?: string;
  openFile?: string;
  clearTerminal?: boolean;
  triggerDevServer?: boolean;
}

export function parseAndExecuteCLI(
  commandRaw: string,
  currentVFS: VFSItem,
  cwd: string // e.g. "my-web-app" or "my-web-app/src"
): CLIResult {
  const cmdLine = commandRaw.trim();
  if (!cmdLine) {
    return { output: '' };
  }

  // Split into tokens handling simple quotes
  const parts = cmdLine.match(/(?:[^\s"']+|"[^"]*"|'[^']*')+/g) || [cmdLine];
  const mainCmd = parts[0].toLowerCase();
  const args = parts.slice(1).map(arg => arg.replace(/^['"]|['"]$/g, ''));

  // Find node in VFS helper
  const findNodeByPath = (root: VFSItem, targetPath: string): VFSItem | null => {
    if (root.path === targetPath) return root;
    if (root.children) {
      for (const child of root.children) {
        const found = findNodeByPath(child, targetPath);
        if (found) return found;
      }
    }
    return null;
  };

  // Helper to resolve relative path against cwd
  const resolvePath = (relPath: string): string => {
    if (!relPath || relPath === '.') return cwd;
    if (relPath === '..') {
      const parts = cwd.split('/');
      if (parts.length > 1) {
        parts.pop();
        return parts.join('/');
      }
      return cwd;
    }
    if (relPath.startsWith('my-web-app')) return relPath;
    return `${cwd}/${relPath}`.replace(/\/+/g, '/');
  };

  // Helper to update / insert node into VFS tree
  const insertNode = (root: VFSItem, parentPath: string, newNode: VFSItem): VFSItem => {
    if (root.path === parentPath) {
      const existingIdx = root.children?.findIndex(c => c.name === newNode.name) ?? -1;
      let newChildren = root.children ? [...root.children] : [];
      if (existingIdx >= 0) {
        newChildren[existingIdx] = newNode;
      } else {
        newChildren.push(newNode);
      }
      return { ...root, children: newChildren };
    }
    if (root.children) {
      return {
        ...root,
        children: root.children.map(child => insertNode(child, parentPath, newNode))
      };
    }
    return root;
  };

  // Helper to delete node from VFS
  const deleteNode = (root: VFSItem, targetPath: string): VFSItem => {
    if (root.children) {
      return {
        ...root,
        children: root.children
          .filter(child => child.path !== targetPath)
          .map(child => deleteNode(child, targetPath))
      };
    }
    return root;
  };

  const currentFolderNode = findNodeByPath(currentVFS, cwd);

  switch (mainCmd) {
    case 'pwd':
      return { output: `\x1b[36mC:\\Projects\\${cwd.replace(/\//g, '\\')}\x1b[0m` };

    case 'clear':
    case 'cls':
      return { output: '', clearTerminal: true };

    case 'help':
      return {
        output: `\x1b[1;33mRVM Integrated Terminal Commands:\x1b[0m
  \x1b[36mcd <dir>\x1b[0m            - Change directory (e.g. \`cd src\`, \`cd ..\`)
  \x1b[36mls\x1b[0m / \x1b[36mdir\x1b[0m           - List directory contents
  \x1b[36mmkdir <dir>\x1b[0m        - Create new directory
  \x1b[36mtouch <file>\x1b[0m       - Create empty file
  \x1b[36mecho "txt" > file\x1b[0m  - Write text to file
  \x1b[36mcat <file>\x1b[0m         - View file contents
  \x1b[36mrm <file>\x1b[0m          - Delete file or directory
  \x1b[36mcode <file>\x1b[0m        - Open file in Monaco editor tab
  \x1b[36mnpm install\x1b[0m        - Simulate package installation
  \x1b[36mnpm run dev\x1b[0m        - Launch virtual Vite dev server
  \x1b[36mgit status\x1b[0m         - View git changes
  \x1b[36mpython <file>\x1b[0m      - Execute Python script
  \x1b[36mclear\x1b[0m              - Clear terminal screen`
      };

    case 'ls':
    case 'dir': {
      if (!currentFolderNode || currentFolderNode.type !== 'directory') {
        return { output: `\x1b[31mError: Path not found ${cwd}\x1b[0m` };
      }
      const children = currentFolderNode.children || [];
      if (children.length === 0) {
        return { output: '\x1b[90m(empty directory)\x1b[0m' };
      }

      let outLines = [`\x1b[90mDirectory of C:\\Projects\\${cwd.replace(/\//g, '\\')}\x1b[0m\n`];
      children.forEach(item => {
        if (item.type === 'directory') {
          outLines.push(`  \x1b[1;34m<DIR>\x1b[0m       \x1b[1;34m${item.name}/\x1b[0m`);
        } else {
          const size = (item.content || '').length;
          const lang = item.language || 'txt';
          outLines.push(`  ${size.toString().padStart(6, ' ')} bytes  \x1b[37m${item.name}\x1b[0m \x1b[90m(${lang})\x1b[0m`);
        }
      });
      return { output: outLines.join('\n') };
    }

    case 'cd': {
      const target = args[0];
      if (!target || target === '~' || target === '/') {
        return { newCwd: 'my-web-app', output: '' };
      }
      const resolved = resolvePath(target);
      const targetNode = findNodeByPath(currentVFS, resolved);
      if (targetNode && targetNode.type === 'directory') {
        return { newCwd: resolved, output: '' };
      }
      return { output: `\x1b[31mcd: The system cannot find the path specified: ${target}\x1b[0m` };
    }

    case 'mkdir': {
      const folderName = args[0];
      if (!folderName) return { output: '\x1b[31mmkdir: missing directory name\x1b[0m' };
      const folderPath = `${cwd}/${folderName}`.replace(/\/+/g, '/');
      const newFolder: VFSItem = {
        id: `dir-${Date.now()}`,
        name: folderName,
        path: folderPath,
        type: 'directory',
        isOpen: true,
        children: []
      };
      const updatedVFS = insertNode(currentVFS, cwd, newFolder);
      return {
        newVFS: updatedVFS,
        output: `\x1b[32mSuccessfully created directory: ${folderName}\x1b[0m`
      };
    }

    case 'touch': {
      const fileName = args[0];
      if (!fileName) return { output: '\x1b[31mtouch: missing file name\x1b[0m' };
      const filePath = `${cwd}/${fileName}`.replace(/\/+/g, '/');
      const newFile: VFSItem = {
        id: `file-${Date.now()}`,
        name: fileName,
        path: filePath,
        type: 'file',
        language: getLanguageFromPath(fileName),
        content: `// Created via CLI command on ${new Date().toLocaleTimeString()}\n`
      };
      const updatedVFS = insertNode(currentVFS, cwd, newFile);
      return {
        newVFS: updatedVFS,
        openFile: filePath,
        output: `\x1b[32mCreated file ${fileName}\x1b[0m`
      };
    }

    case 'cat': {
      const fileName = args[0];
      if (!fileName) return { output: '\x1b[31mcat: missing file argument\x1b[0m' };
      const filePath = resolvePath(fileName);
      const fileNode = findNodeByPath(currentVFS, filePath);
      if (fileNode && fileNode.type === 'file') {
        return { output: fileNode.content || '\x1b[90m(file is empty)\x1b[0m' };
      }
      return { output: `\x1b[31mcat: ${fileName}: No such file\x1b[0m` };
    }

    case 'echo': {
      // Handle echo "hello" > filename.js
      const rawText = commandRaw.substring(commandRaw.indexOf('echo') + 4).trim();
      const redirectMatch = rawText.match(/^(?:"([^"]*)"|'([^']*)'|(.+?))\s*(>>|>)\s*(.+)$/);
      if (redirectMatch) {
        const content = redirectMatch[1] || redirectMatch[2] || redirectMatch[3] || '';
        const append = redirectMatch[4] === '>>';
        const targetFile = redirectMatch[5].trim();
        const filePath = resolvePath(targetFile);

        let existingFile = findNodeByPath(currentVFS, filePath);
        let updatedContent = content;
        if (existingFile && append) {
          updatedContent = (existingFile.content || '') + '\n' + content;
        }

        const newFile: VFSItem = {
          id: existingFile ? existingFile.id : `file-${Date.now()}`,
          name: targetFile.split('/').pop() || targetFile,
          path: filePath,
          type: 'file',
          language: getLanguageFromPath(targetFile),
          content: updatedContent,
          isModified: true
        };

        const targetParentPath = filePath.substring(0, filePath.lastIndexOf('/')) || cwd;
        const updatedVFS = insertNode(currentVFS, targetParentPath, newFile);
        return {
          newVFS: updatedVFS,
          output: `\x1b[32mWrote to ${targetFile}\x1b[0m`
        };
      }
      return { output: rawText.replace(/^['"]|['"]$/g, '') };
    }

    case 'rm':
    case 'rmdir': {
      const targetName = args[0];
      if (!targetName) return { output: '\x1b[31mrm: missing argument\x1b[0m' };
      const targetPath = resolvePath(targetName);
      const targetNode = findNodeByPath(currentVFS, targetPath);
      if (!targetNode) return { output: `\x1b[31mrm: ${targetName}: No such file or directory\x1b[0m` };

      const updatedVFS = deleteNode(currentVFS, targetPath);
      return {
        newVFS: updatedVFS,
        output: `\x1b[33mDeleted ${targetName}\x1b[0m`
      };
    }

    case 'code': {
      const fileName = args[0];
      if (!fileName) return { output: '\x1b[31mcode: missing filename\x1b[0m' };
      const filePath = resolvePath(fileName);
      const node = findNodeByPath(currentVFS, filePath);
      if (node && node.type === 'file') {
        return {
          openFile: filePath,
          output: `\x1b[32mOpened ${fileName} in Monaco Editor\x1b[0m`
        };
      }
      return { output: `\x1b[31mcode: ${fileName} not found\x1b[0m` };
    }

    case 'npm': {
      const sub = args[0];
      if (sub === 'install' || sub === 'i' || sub === 'add') {
        const pkgName = args[1] || 'dependencies';
        return {
          output: `\x1b[34m[npm]\x1b[0m Fetching packages for ${pkgName}...
\x1b[33m[1/4]\x1b[0m 🔍 Resolving package graph...
\x1b[33m[2/4]\x1b[0m 🚚 Fetching tarballs...
\x1b[33m[3/4]\x1b[0m 🔗 Linking dependencies...
\x1b[33m[4/4]\x1b[0m 🏗️ Building fresh packages...

\x1b[32m✔ Added 142 packages, and audited 143 packages in 1.2s\x1b[0m
\x1b[36mfound 0 vulnerabilities\x1b[0m`
        };
      }
      if (sub === 'run' && (args[1] === 'dev' || args[1] === 'start')) {
        return {
          triggerDevServer: true,
          output: `\x1b[32m
  VITE v6.1.0  ready in 240 ms

  \x1b[1;32m➜\x1b[0m  \x1b[1mLocal:\x1b[0m   \x1b[36mhttp://localhost:5173/\x1b[0m
  \x1b[1;32m➜\x1b[0m  \x1b[1mNetwork:\x1b[0m \x1b[36mhttp://192.168.1.100:5173/\x1b[0m
  \x1b[1;32m➜\x1b[0m  press \x1b[1mh\x1b[0m to show help
\x1b[0m`
        };
      }
      return { output: `\x1b[33mnpm command executed: ${args.join(' ')}\x1b[0m` };
    }

    case 'git': {
      const sub = args[0];
      if (sub === 'status') {
        return {
          output: `\x1b[1;32mOn branch main\x1b[0m
Your branch is up to date with 'origin/main'.

\x1b[1;33mChanges not staged for commit:\x1b[0m
  (use "git add <file>..." to update what will be committed)
	\x1b[31mmodified:   src/App.tsx\x1b[0m
	\x1b[31mmodified:   package.json\x1b[0m

\x1b[1;31mUntracked files:\x1b[0m
  (use "git add <file>..." to include in what will be committed)
	\x1b[31mpython_script.py\x1b[0m

no changes added to commit (use "git add" and/or "git commit -a")`
        };
      }
      if (sub === 'commit') {
        return {
          output: `\x1b[32m[main 7f8a92b] ${args.join(' ')}\x1b[0m
 2 files changed, 18 insertions(+), 4 deletions(-)`
        };
      }
      return { output: `\x1b[36mgit ${args.join(' ')}\x1b[0m` };
    }

    case 'python':
    case 'python3': {
      const script = args[0];
      if (!script) return { output: '\x1b[31mpython: missing script argument\x1b[0m' };
      const filePath = resolvePath(script);
      const fileNode = findNodeByPath(currentVFS, filePath);
      if (fileNode && fileNode.content) {
        return {
          output: `\x1b[36m[Python 3.12.1 Execution Result]\x1b[0m
[13:42:01] Processing virtual pipeline for RVM User...
Computed squared values: [1, 4, 9, 16, 25]
\x1b[32mTotal calculated sum: 55\x1b[0m`
        };
      }
      return { output: `\x1b[31mpython: can't open file '${script}': No such file\x1b[0m` };
    }

    default:
      return {
        output: `\x1b[31m'${mainCmd}' is not recognized as an internal command. Type 'help' for available CLI commands.\x1b[0m`
      };
  }
}
