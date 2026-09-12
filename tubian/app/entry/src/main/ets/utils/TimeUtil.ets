/**
 * 时间处理工具。
 */

/** "112" -> "1小时52分" */
export function formatDuration(minutes: number): string {
  if (minutes < 60) {
    return `${minutes}分钟`;
  }
  const h = Math.floor(minutes / 60);
  const m = minutes % 60;
  return m === 0 ? `${h}小时` : `${h}小时${m}分`;
}

/** 当前时间 HH:MM */
export function nowHHMM(): string {
  const d = new Date();
  const pad = (n: number): string => (n < 10 ? `0${n}` : `${n}`);
  return `${pad(d.getHours())}:${pad(d.getMinutes())}`;
}

/** 中文时间 -> "HH:MM"，供目标解析兜底（客户端侧简化版）。 */
export function parseChineseTime(text: string): string {
  const m = text.match(/(\d{1,2})[:：](\d{2})/);
  if (m) {
    return `${Number(m[1]) < 10 ? '0' : ''}${m[1]}:${m[2]}`;
  }
  const cn: Record<string, number> = { '一': 1, '二': 2, '三': 3, '四': 4, '五': 5, '六': 6, '七': 7, '八': 8, '九': 9, '十': 10 };
  const m2 = text.match(/([0-9一二两三四五六七八九十]+)点(半)?/);
  if (m2) {
    const raw = m2[1];
    let h = 0;
    if (/^\d+$/.test(raw)) {
      h = Number(raw);
    } else if (raw === '十') {
      h = 10;
    } else {
      h = cn[raw[0]] || 0;
      if (raw.length > 1 && raw[1] === '十') {
        h = h * 10;
      }
    }
    if (text.includes('下午') || text.includes('晚上')) {
      h = h === 12 ? 12 : h + 12;
    }
    return `${h < 10 ? '0' : ''}${h}:${m2[2] ? '30' : '00'}`;
  }
  return '19:00';
}
