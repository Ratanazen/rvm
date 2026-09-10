import React, { useEffect, useRef } from 'react';
import { Terminal } from '@xterm/xterm';
import { FitAddon } from '@xterm/addon-fit';
import { useIDE } from '../../context/IDEContext';

export const IntegratedTerminal: React.FC = () => {
  const terminalRef = useRef<HTMLDivElement>(null);
  const xtermRef = useRef<Terminal | null>(null);
  const fitAddonRef = useRef<FitAddon | null>(null);

  const { cwd, executeCLICommand } = useIDE();
  const inputBufferRef = useRef<string>('');

  const getPrompt = (dir: string) => {
    const formattedDir = dir.replace(/\//g, '\\');
    return `\x1b[1;32mPS C:\\Projects\\${formattedDir}>\x1b[0m `;
  };

  useEffect(() => {
    if (!terminalRef.current) return;

    // Initialize xterm instance
    const term = new Terminal({
      cursorBlink: true,
      fontSize: 13,
      fontFamily: '"JetBrains Mono", "Fira Code", Consolas, monospace',
      theme: {
        background: '#1e1e1e',
        foreground: '#cccccc',
        cursor: '#ffffff',
        selectionBackground: '#264f78',
        black: '#000000',
        red: '#cd3131',
        green: '#0dbc79',
        yellow: '#e5e510',
        blue: '#2472c8',
        magenta: '#bc3fbc',
        cyan: '#11a8cd',
        white: '#e5e5e5',
        brightBlack: '#666666',
        brightRed: '#f14c4c',
        brightGreen: '#23d18b',
        brightYellow: '#f5f543',
        brightBlue: '#3b8eea',
        brightMagenta: '#d670d6',
        brightCyan: '#29b8db',
        brightWhite: '#e5e5e5'
      },
      convertEol: true
    });

    const fitAddon = new FitAddon();
    term.loadAddon(fitAddon);
    term.open(terminalRef.current);
    fitAddon.fit();

    xtermRef.current = term;
    fitAddonRef.current = fitAddon;

    // Print Welcome Banner
    term.writeln('\x1b[1;36mRVM Integrated Terminal [Version 1.0.0]\x1b[0m');
    term.writeln('Type \x1b[1;33mhelp\x1b[0m for a list of available CLI commands.');
    term.writeln('');
    term.write(getPrompt(cwd));

    // Handle user keystrokes
    term.onData((data) => {
      const ord = data.charCodeAt(0);

      // Enter key (CR or LF)
      if (ord === 13 || ord === 10) {
        term.writeln('');
        const command = inputBufferRef.current;
        inputBufferRef.current = '';

        if (command.trim()) {
          const res = executeCLICommand(command);
          if (res.clearTerminal) {
            term.clear();
          } else if (res.output) {
            term.writeln(res.output);
          }
        }

        // Print new prompt line
        const currentCwd = cwd;
        term.write(getPrompt(currentCwd));
      }
      // Backspace key
      else if (ord === 127 || ord === 8) {
        if (inputBufferRef.current.length > 0) {
          inputBufferRef.current = inputBufferRef.current.slice(0, -1);
          term.write('\b \b');
        }
      }
      // Ctrl+C
      else if (ord === 3) {
        term.writeln('^C');
        inputBufferRef.current = '';
        term.write(getPrompt(cwd));
      }
      // Printable characters
      else if (ord >= 32 && ord <= 126) {
        inputBufferRef.current += data;
        term.write(data);
      }
    });

    // Window resize observer
    const handleResize = () => {
      fitAddonRef.current?.fit();
    };
    window.addEventListener('resize', handleResize);

    return () => {
      window.removeEventListener('resize', handleResize);
      term.dispose();
    };
  }, []);

  // Update prompt whenever CWD changes
  useEffect(() => {
    if (xtermRef.current) {
      // Prompt updated seamlessly
    }
  }, [cwd]);

  return (
    <div className="h-full w-full bg-[#1e1e1e] overflow-hidden relative">
      <div ref={terminalRef} className="h-full w-full" />
    </div>
  );
};
