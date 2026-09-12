// 修复LengthMetrics错误 - 改回使用数字或vp()函数
const fs = require('fs');
const path = require('path');

console.log('🔧 修复LengthMetrics类型错误...\n');

function scanDirectory(dir) {
  const results = [];
  const files = fs.readdirSync(dir, { withFileTypes: true });
  
  for (const file of files) {
    const fullPath = path.join(dir, file.name);
    
    if (file.isDirectory()) {
      results.push(...scanDirectory(fullPath));
    } else if (file.name.endsWith('.ets')) {
      results.push(fullPath);
    }
  }
  
  return results;
}

const etsFiles = scanDirectory(path.join(__dirname, 'entry/src/main/ets'));

// 修复模式 - 将LengthMetrics.vp(数字)改回数字
const patterns = [
  { from: /LengthMetrics\.vp\((\d+)\)/g, to: '$1' },
  { from: /space:\s*{\s*main:\s*LengthMetrics\.vp\((\d+)\),\s*cross:\s*LengthMetrics\.vp\((\d+)\)\s*}/g, to: 'space: { main: $1, cross: $2 }' },
  { from: /gutter:\s*{\s*x:\s*LengthMetrics\.vp\((\d+)\),\s*y:\s*LengthMetrics\.vp\((\d+)\)\s*}/g, to: 'gutter: { x: $1, y: $2 }' }
];

let fixedFiles = 0;
let totalReplacements = 0;

console.log(`📁 处理 ${etsFiles.length} 个 .ets 文件...\n`);

etsFiles.forEach(filePath => {
  try {
    let content = fs.readFileSync(filePath, 'utf8');
    let modified = false;
    let fileReplacements = 0;
    
    patterns.forEach(pattern => {
      const matches = content.match(pattern.from);
      if (matches) {
        content = content.replace(pattern.from, pattern.to);
        modified = true;
        fileReplacements += matches.length;
      }
    });
    
    if (modified) {
      fs.writeFileSync(filePath, content, 'utf8');
      const relativePath = path.relative(__dirname, filePath);
      console.log(`✅ ${relativePath} - ${fileReplacements} 处修复`);
      fixedFiles++;
      totalReplacements += fileReplacements;
    }
  } catch (error) {
    const relativePath = path.relative(__dirname, filePath);
    console.log(`❌ ${relativePath} - 修复失败: ${error.message}`);
  }
});

console.log(`\n🎯 LengthMetrics修复完成:`);
console.log(`- 修复文件数: ${fixedFiles}`);
console.log(`- 总修复数: ${totalReplacements}`);

console.log('\n✨ 修复说明:');
console.log('- 将 LengthMetrics.vp(数字) 改回 数字');
console.log('- ArkTS中space和gutter参数直接使用数字即可');
console.log('- 这是正确的ArkTS语法');

if (totalReplacements > 0) {
  console.log('\n🚀 现在应该可以成功编译了！');
} else {
  console.log('\n✅ 没有发现需要修复的LengthMetrics错误');
}
