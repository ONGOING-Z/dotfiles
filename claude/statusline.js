#!/usr/bin/env node

const fs = require('node:fs');
const { execSync } = require('node:child_process');

// 超过此百分比时变红
const DUMB_ZONE = 59;

function getGitBranch() {
  try {
    return execSync('git branch --show-current 2>/dev/null', { encoding: 'utf-8' }).trim();
  } catch {
    return '';
  }
}

function ansi(text, bgColor, fgColor = 'rgb(255, 255, 255)') {
  const RESET = '\x1b[0m';
  const bg = bgColor.match(/\d+/g);
  const fg = fgColor.match(/\d+/g);
  return `${RESET}\x1b[48;2;${bg.join(';')}m\x1b[38;2;${fg.join(';')}m${text}${RESET}`;
}

function formatSections(sections) {
  return sections.map((s, i) => {
    return ansi(` ${s.text} `, s.bg, s.fg || 'rgb(255,255,255)');
  }).join('');
}

try {
  const input = JSON.parse(fs.readFileSync(0, 'utf-8'));
  const sections = [];

  // 目录名
  const dir = input.workspace.current_dir.split('/').at(-1);
  sections.push({ text: dir, bg: 'rgb(33, 88, 156)' });

  // git 分支
  const branch = getGitBranch();
  if (branch) {
    sections.push({ text: `${branch}`, bg: 'rgb(70, 107, 62)' });
  }

  // 模型名称
  const model = input.model.display_name;
  sections.push({ text: model, bg: 'rgb(68, 68, 68)' });

  // 上下文窗口使用率
  const cw = input.context_window;
  if (cw?.current_usage && cw?.context_window_size) {
    const used =
      (cw.current_usage.input_tokens || 0) +
      (cw.current_usage.output_tokens || 0) +
      (cw.current_usage.cache_creation_input_tokens || 0) +
      (cw.current_usage.cache_read_input_tokens || 0);
    const pct = Math.round((used / cw.context_window_size) * 100);
    const danger = pct > DUMB_ZONE;
    sections.push({
      text: `${pct}%`,
      bg: danger ? 'rgb(226, 0, 0)' : 'rgb(217, 119, 87)',
      fg: danger ? 'rgb(255,255,255)' : 'rgb(0,0,0)',
    });
  }

  console.log(formatSections(sections));
} catch (e) {
  console.error('statusline error:', e.message);
  process.exit(1);
}
