// 验证编译问题是否完全解决
const fs = require('fs');
const path = require('path');

console.log('🔍 最终编译验证...\n');

// 检查SearchPage.ets的关键行
const searchPagePath = path.join(__dirname, 'entry/src/main/ets/pages/search/SearchPage.ets');

if (fs.existsSync(searchPagePath)) {
  const content = fs.readFileSync(searchPagePath, 'utf8');
  const lines = content.split('\n');
  
  console.log('📄 检查 SearchPage.ets 第160行:');
  if (lines[159]) { // 数组索引从0开始，所以159对应第160行
    console.log(`第160行: ${lines[159].trim()}`);
    
    if (lines[159].includes('Flex({ wrap: FlexWrap.Wrap })')) {
      console.log('✅ Flex组件语法正确');
    } else if (lines[159].includes('space:')) {
      console.log('❌ 仍然包含space参数');
    } else {
      console.log('⚠️ 行内容与预期不符');
    }
  } else {
    console.log('❌ 无法读取第160行');
  }
} else {
  console.log('❌ SearchPage.ets 文件不存在');
}

// 检查可能的问题模式
console.log('\n🔎 检查潜在问题模式:');

function scanForPatterns(dir) {
  const results = [];
  const files = fs.readdirSync(dir, { withFileTypes: true });
  
  for (const file of files) {
    const fullPath = path.join(dir, file.name);
    
    if (file.isDirectory()) {
      results.push(...scanForPatterns(fullPath));
    } else if (file.name.endsWith('.ets')) {
      results.push(fullPath);
    }
  }
  
  return results;
}

const etsFiles = scanForPatterns(path.join(__dirname, 'entry/src/main/ets'));
const problemPatterns = [
  { name: 'Flex space参数', pattern: /Flex\([^)]*space\s*:/ },
  { name: 'LengthMetrics使用', pattern: /LengthMetrics\./}
];

let totalIssues = 0;

problemPatterns.forEach(({ name, pattern }) => {
  let count = 0;
  
  etsFiles.forEach(filePath => {
    try {
      const content = fs.readFileSync(filePath, 'utf8');
      const matches = content.match(pattern);
      if (matches) {
        count += matches.length;
        const relativePath = path.relative(__dirname, filePath);
        console.log(`  ⚠️ ${relativePath} - ${matches.length} 处`);
      }
    } catch (error) {
      // 忽略读取错误
    }
  });
  
  if (count === 0) {
    console.log(`✅ ${name}: 无问题`);
  } else {
    console.log(`❌ ${name}: ${count} 处问题`);
  }
  
  totalIssues += count;
});

console.log('\n📊 验证结果:');
if (totalIssues === 0) {
  console.log('🎉 所有已知编译错误已修复！');
  console.log('✅ 应用应该可以正常编译');
} else {
  console.log(`❌ 仍有 ${totalIssues} 处问题需要解决`);
}

console.log('\n💡 修复说明:');
console.log('- Flex组件不支持space参数');
console.log('- 使用margin为子元素添加间距');
console.log('- Row/Column组件可以直接使用space参数');
