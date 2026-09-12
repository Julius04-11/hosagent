// 批量修复space参数类型错误的脚本
const fs = require('fs');
const path = require('path');

console.log('🔧 开始修复space参数类型错误...\n');

// 需要修复的文件列表（从grep结果中提取）
const filesToFix = [
  'entry/src/main/ets/pages/transport/TransportDetailPage.ets',
  'entry/src/main/ets/pages/ticket/TicketBookingPage.ets', 
  'entry/src/main/ets/pages/scan/ScanPage.ets',
  'entry/src/main/ets/pages/profile/ProfilePage.ets',
  'entry/src/main/ets/pages/profile/MyAlbumPage.ets',
  'entry/src/main/ets/pages/profile/HelpFeedbackPage.ets',
  'entry/src/main/ets/pages/payment/PaymentPage.ets',
  'entry/src/main/ets/pages/order/UserReviewPage.ets',
  'entry/src/main/ets/pages/order/OrderListPage.ets'
];

// 需要替换的模式
const patterns = [
  { from: /space:\s*(\d+)/g, to: 'space: LengthMetrics.vp($1)' },
  { from: /space:\s*{\s*main:\s*(\d+),\s*cross:\s*(\d+)\s*}/g, to: 'space: { main: LengthMetrics.vp($1), cross: LengthMetrics.vp($2) }' }
];

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
      fs.writeFileSync(fullPath, content, 'utf8');
      console.log(`✅ 修复 ${filePath} - ${fileReplacements} 处替换`);
      fixedFiles++;
      totalReplacements += fileReplacements;
    }
  } catch (error) {
    console.log(`❌ 修复失败 ${filePath}: ${error.message}`);
  }
});

console.log(`\n🎯 修复完成:`);
console.log(`- 修复文件数: ${fixedFiles}`);
console.log(`- 总替换数: ${totalReplacements}`);
console.log('\n💡 建议: 现在可以重新编译项目了！');
