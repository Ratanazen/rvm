/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        vscode: {
          activity: '#333333',
          activityHover: '#444444',
          activityActive: '#ffffff',
          sidebar: '#252526',
          sidebarHeader: '#252526',
          sidebarBorder: '#1e1e1e',
          editor: '#1e1e1e',
          editorGroupHeader: '#252526',
          tabActive: '#1e1e1e',
          tabInactive: '#2d2d2d',
          tabHover: '#2a2d2e',
          panel: '#1e1e1e',
          panelHeader: '#252526',
          statusBar: '#007acc',
          statusBarItemHover: '#1f8ad2',
          titleBar: '#3c3c3c',
          badge: '#007acc',
          inputBg: '#3c3c3c',
          inputBorder: '#3c3c3c',
          buttonBg: '#0e639c',
          buttonHover: '#1177bb',
          hoverBg: '#2a2d2e',
          selectedBg: '#37373d',
          accent: '#007acc',
        }
      },
      fontFamily: {
        mono: ['"JetBrains Mono"', '"Fira Code"', 'Consolas', 'Monaco', '"Courier New"', 'monospace'],
        sans: ['Inter', '-apple-system', 'BlinkMacSystemFont', 'Segoe UI', 'Roboto', 'sans-serif'],
      }
    },
  },
  plugins: [],
}
