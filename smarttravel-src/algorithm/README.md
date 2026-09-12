# 因果多模态情感分析框架

## 核心算法

### 1. BART文本编码
- 序列到序列预训练
- 上下文感知

### 2. GCN因果图
- 方面-观点图构建
- 因果干预去除混淆

### 3. 因果对比学习
- InfoNCE损失
- Hard Negative Mining

### 4. 两级优化
- Upper: 元学习
- Lower: 任务优化

## 使用

```typescript
const analyzer = CausalMultimodalAnalyzer.getInstance();
const result = await analyzer.analyze({
  text: "这家餐厅的海鲜很新鲜，但价格太贵",
  image: "restaurant.jpg"
});

// 输出:
// [
//   { aspect: "海鲜", sentiment: "positive", score: 0.95 },
//   { aspect: "价格", sentiment: "negative", score: 0.88 }
// ]
```

## 技术栈

- BART: 文本理解
- GCN: 图神经网络
- 因果推断: do-calculus
- 对比学习: SimCLR
- 两级优化: MAML

完整实现在 `CausalMultimodalFramework.ets`
