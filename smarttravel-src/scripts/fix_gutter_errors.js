// 修复gutter参数类型错误的脚本
const fs = require('fs');
const path = require('path');

console.log('🔧 开始修复gutter参数类型错误...\n');

// 需要修复的文件列表
const filesToFix = [
  'entry/src/main/ets/pages/scan/ScanPage.ets',
  'entry/src/main/ets/pages/profile/ProfilePage.ets',
  'entry/src/main/ets/pages/profile/MyAlbumPage.ets',
  'entry/src/main/ets/pages/profile/HelpFeedbackPage.ets',
  'entry/src/main/ets/pages/home/HomePage.ets',
  'entry/src/main/ets/pages/customer/CustomerServicePage.ets'
];

// 修复gutter参数的正则表达式
const gutterPattern = /gutter:\s*{\s*x:\s*(\d+),\s*y:\s*(\d+)\s*}/g;

let fixedFiles = 0;
let totalReplacements = 0;

filesToFix.forEach(filePath => {
  const fullPath = path.join(__dirname, filePath);
  
  if (!fs.existsSync(fullPath)) {
    console.log(`⚠️ 文件不存在: ${filePath}`);
    return;
  }
  
  try {
    let content = fs.readFileSync(fullPath, 'utf8');
    const matches = content.match(gutterPattern);
    
    if (matches) {
      content = content.replace(gutterPattern, 'gutter: { x: LengthMetrics.vp($1), y: LengthMetrics.vp($2) }');
      fs.writeFileSync(fullPath, content, 'utf8');
      console.log(`✅ 修复 ${filePath} - ${matches.length} 处替换`);
      fixedFiles++;
      totalReplacements += matches.length;
    }
  } catch (error) {
    console.log(`❌ 修复失败 ${filePath}: ${error.message}`);
  }
});

console.log(`\n🎯 Gutter修复完成:`);
console.log(`- 修复文件数: ${fixedFiles}`);
console.log(`- 总替换数: ${totalReplacements}`);
console.log('\n💡 所有类型错误应该已经修复完毕！');
