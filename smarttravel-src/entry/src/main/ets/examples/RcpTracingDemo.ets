/**
 * RCP 请求追踪演示
 * 
 * 本示例演示如何使用 TracingConfiguration 和 HttpEventsHandler 
 * 捕获HTTP请求/响应的详细信息和性能数据
 */

import { rcp } from '@kit.RemoteCommunicationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { RcpService } from '../services/RcpService';

const TAG = 'RcpTracingDemo';
const DOMAIN = 0xFF00;

/**
 * 追踪信息收集器
 */
export class TracingInfoCollector {
  private dataReceiveCount: number = 0;
  private totalBytesReceived: number = 0;
  private headers: Record<string, string> = {};
  private events: string[] = [];

  reset(): void {
    this.dataReceiveCount = 0;
    this.totalBytesReceived = 0;
    this.headers = {};
    this.events = [];
  }

  recordDataReceive(bytes: number): void {
    this.dataReceiveCount++;
    this.totalBytesReceived += bytes;
    this.events.push(`[${new Date().toISOString()}] 收到数据: ${bytes} bytes`);
  }

  recordHeaderReceive(headers: rcp.RequestHeaders): void {
    this.headers = headers as Record<string, string>;
    this.events.push(`[${new Date().toISOString()}] 收到响应头`);
  }

  recordDataEnd(): void {
    this.events.push(`[${new Date().toISOString()}] 数据传输完成`);
  }

  getReport(): string {
    let report = '========== 追踪报告 ==========\n\n';
    report += `数据接收次数: ${this.dataReceiveCount}\n`;
    report += `总字节数: ${this.totalBytesReceived} bytes\n\n`;
    report += `响应头 (${Object.keys(this.headers).length}个):\n`;
    for (const key in this.headers) {
      report += `  ${key}: ${this.headers[key]}\n`;
    }
    report += `\n事件时间线:\n`;
    this.events.forEach(event => {
      report += `  ${event}\n`;
    });
    return report;
  }
}

/**
 * 创建自定义 HttpEventsHandler
 */
export function createCustomHttpEventsHandler(
  collector: TracingInfoCollector
): rcp.HttpEventsHandler {
  return {
    onDataReceive: (incomingData: ArrayBuffer) => {
      const bytes = incomingData.byteLength;
      collector.recordDataReceive(bytes);
      hilog.info(DOMAIN, TAG, `[HttpEventsHandler] 收到数据: ${bytes} bytes`);
      return bytes;
    },
    onHeaderReceive: (headers: rcp.RequestHeaders) => {
      collector.recordHeaderReceive(headers);
      hilog.info(DOMAIN, TAG, `[HttpEventsHandler] 收到响应头: ${JSON.stringify(headers)}`);
    },
    onDataEnd: () => {
      collector.recordDataEnd();
      hilog.info(DOMAIN, TAG, '[HttpEventsHandler] 数据传输完成');
    }
  };
}

/**
 * 演示1: 基础追踪功能
 */
export async function demo1_BasicTracing(): Promise<string> {
  hilog.info(DOMAIN, TAG, '========== 演示1: 基础追踪功能 ==========');

  const collector = new TracingInfoCollector();
  const customHandler = createCustomHttpEventsHandler(collector);

  // 创建追踪配置
  const tracingConfig: rcp.TracingConfiguration = {
    verbose: true,
    infoToCollect: {
      incomingHeader: true,
      outgoingHeader: true,
      incomingData: true,
      outgoingData: true
    },
    collectTimeInfo: true,
    httpEventsHandler: customHandler
  };

  const rcpService = RcpService.getInstance();
  const session = rcpService.createSessionWithTracing(tracingConfig);

  try {
    const response = await session.get('http://developer.huawei.com');

    let report = '✅ 请求成功\n\n';
    report += `状态码: ${response.statusCode}\n\n`;
    report += RcpService.parseTimeInfo(response) + '\n\n';
    report += collector.getReport();

    return report;
  } catch (error) {
    const err = error as BusinessError;
    return `❌ 请求失败: ${err.message}`;
  }
}

/**
 * 演示2: 性能对比（无追踪 vs 有追踪）
 */
export async function demo2_PerformanceComparison(): Promise<string> {
  hilog.info(DOMAIN, TAG, '========== 演示2: 性能对比 ==========');

  const url = 'http://developer.huawei.com';
  let report = '';

  // 1. 无追踪请求
  const normalSession = rcp.createSession({
    requestConfiguration: {
      security: {
        tlsOptions: {
          tlsVersion: 'TlsV1.3'
        }
      }
    }
  });

  const startTime1 = Date.now();
  try {
    await normalSession.get(url);
    const duration1 = Date.now() - startTime1;
    report += `📊 无追踪模式:\n  耗时: ${duration1}ms\n\n`;
  } catch (error) {
    report += '❌ 无追踪模式失败\n\n';
  }

  // 2. 有追踪请求
  const collector = new TracingInfoCollector();
  const tracingConfig = RcpService.createDefaultTracingConfig(
    createCustomHttpEventsHandler(collector)
  );

  const rcpService = RcpService.getInstance();
  const tracingSession = rcpService.createSessionWithTracing(tracingConfig);

  const startTime2 = Date.now();
  try {
    const response = await tracingSession.get(url);
    const duration2 = Date.now() - startTime2;

    report += `📊 追踪模式:\n  耗时: ${duration2}ms\n\n`;
    report += `性能影响: ${((duration2 - startTime1) / startTime1 * 100).toFixed(2)}%\n\n`;
    report += RcpService.parseTimeInfo(response);
  } catch (error) {
    report += '❌ 追踪模式失败\n';
  }

  return report;
}

/**
 * 演示3: 详细时间分析
 */
export async function demo3_DetailedTimeAnalysis(): Promise<string> {
  hilog.info(DOMAIN, TAG, '========== 演示3: 详细时间分析 ==========');

  const tracingConfig = RcpService.createDefaultTracingConfig();
  const rcpService = RcpService.getInstance();
  const session = rcpService.createSessionWithTracing(tracingConfig);

  try {
    const response = await session.get('https://developer.huawei.com');

    let report = '✅ 请求成功\n\n';
    report += '⏱️ 时间分析:\n';

    if (response.timeInfo) {
      const timeInfo = response.timeInfo;
      
      // DNS解析
      if (timeInfo.dnsLookupTime !== undefined) {
        report += `  DNS解析: ${timeInfo.dnsLookupTime}ms\n`;
      }
      
      // TCP连接
      if (timeInfo.tcpConnectionTime !== undefined) {
        report += `  TCP连接: ${timeInfo.tcpConnectionTime}ms\n`;
      }
      
      // TLS握手
      if (timeInfo.tlsConnectionTime !== undefined) {
        report += `  TLS握手: ${timeInfo.tlsConnectionTime}ms\n`;
      }
      
      // 首次发送
      if (timeInfo.firstSendTime !== undefined) {
        report += `  首次发送: ${timeInfo.firstSendTime}ms\n`;
      }
      
      // 首次接收
      if (timeInfo.firstReceiveTime !== undefined) {
        report += `  首次接收: ${timeInfo.firstReceiveTime}ms\n`;
      }
      
      // 总耗时
      if (timeInfo.totalTime !== undefined) {
        report += `  总耗时: ${timeInfo.totalTime}ms\n\n`;
        
        // 计算各阶段占比
        const total = timeInfo.totalTime;
        if (timeInfo.dnsLookupTime) {
          report += `  DNS占比: ${(timeInfo.dnsLookupTime / total * 100).toFixed(2)}%\n`;
        }
        if (timeInfo.tcpConnectionTime) {
          report += `  TCP占比: ${(timeInfo.tcpConnectionTime / total * 100).toFixed(2)}%\n`;
        }
        if (timeInfo.tlsConnectionTime) {
          report += `  TLS占比: ${(timeInfo.tlsConnectionTime / total * 100).toFixed(2)}%\n`;
        }
      }
    } else {
      report += '  ⚠️ 无时间信息\n';
    }

    return report;
  } catch (error) {
    const err = error as BusinessError;
    return `❌ 请求失败: ${err.message}`;
  }
}

/**
 * 演示4: 多个请求的追踪对比
 */
export async function demo4_MultipleRequestsComparison(): Promise<string> {
  hilog.info(DOMAIN, TAG, '========== 演示4: 多个请求追踪对比 ==========');

  const urls = [
    'http://developer.huawei.com',
    'http://www.example.com',
    'https://api.github.com'
  ];

  const tracingConfig = RcpService.createDefaultTracingConfig();
  const rcpService = RcpService.getInstance();
  const session = rcpService.createSessionWithTracing(tracingConfig);

  let report = '📊 多请求性能对比\n\n';

  for (let i = 0; i < urls.length; i++) {
    const url = urls[i];
    report += `请求 ${i + 1}: ${url}\n`;

    try {
      const startTime = Date.now();
      const response = await session.get(url);
      const duration = Date.now() - startTime;

      report += `  状态: ✅ 成功 (${response.statusCode})\n`;
      report += `  总耗时: ${duration}ms\n`;

      if (response.timeInfo?.totalTime) {
        report += `  RCP测量: ${response.timeInfo.totalTime}ms\n`;
        report += `  DNS: ${response.timeInfo.dnsLookupTime || 0}ms\n`;
        report += `  TCP: ${response.timeInfo.tcpConnectionTime || 0}ms\n`;
        report += `  TLS: ${response.timeInfo.tlsConnectionTime || 0}ms\n`;
      }
    } catch (error) {
      const err = error as BusinessError;
      report += `  状态: ❌ 失败 (${err.message})\n`;
    }

    report += '\n';
  }

  return report;
}

/**
 * 运行所有演示
 */
export async function runAllTracingDemos(): Promise<string> {
  let fullReport = '========== RCP 追踪功能完整演示 ==========\n\n';

  // 演示1
  fullReport += await demo1_BasicTracing();
  fullReport += '\n\n';

  // 延迟
  await new Promise(resolve => setTimeout(resolve, 1000));

  // 演示2
  fullReport += await demo2_PerformanceComparison();
  fullReport += '\n\n';

  // 延迟
  await new Promise(resolve => setTimeout(resolve, 1000));

  // 演示3
  fullReport += await demo3_DetailedTimeAnalysis();
  fullReport += '\n\n';

  // 延迟
  await new Promise(resolve => setTimeout(resolve, 1000));

  // 演示4
  fullReport += await demo4_MultipleRequestsComparison();

  fullReport += '\n========== 演示完成 ==========';

  return fullReport;
}
