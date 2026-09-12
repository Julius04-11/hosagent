/**
 * RCP 官方示例代码
 * 
 * 本文件包含完全符合 HarmonyOS 官方文档的 RCP 示例代码
 * 参考文档：Remote Communication Kit 使用指南
 * 
 * 包含内容：
 * 1. PATCH 请求示例
 * 2. 设置会话基地址
 * 3. 多表单提交
 * 4. DNS 配置（自定义DNS服务器、静态DNS规则、DNS over HTTPS）
 * 5. 拦截器（ResponseCachingInterceptor、ResponseHeaderRemoveInterceptor）
 * 6. 请求追踪（TracingConfiguration + HttpEventsHandler）
 * 
 * @author SmartTravel Team
 * @since 2024-01-01
 */

import { rcp } from '@kit.RemoteCommunicationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'RcpOfficialExamples';
const DOMAIN = 0xFF00;

// ==================== 1. PATCH 请求示例 ====================

/**
 * 用户信息接口
 */
interface UserInfo {
  userId?: string;
  userName?: string;
  userGender?: string;
  userAge?: number;
  userEmail?: string;
  userPhone?: string;
  userAddress?: string;
  userAvatar?: string;
  userBio?: string;
  userRole?: string;
}

/**
 * 示例1：发送 PATCH 请求
 * 场景：只修改用户名，不需要传递完整的用户信息
 */
export async function example1_PatchRequest(): Promise<void> {
  hilog.info(DOMAIN, TAG, '========== 示例1：PATCH 请求 ==========');

  // 定义请求头
  let headers: rcp.RequestHeaders = {
    'accept': 'application/json'
  };

  // 定义要修改的内容（只修改 userName）
  let modifiedContent: UserInfo = {
    'userName': '新用户名_Updated'
  };

  const securityConfig: rcp.SecurityConfiguration = {
    tlsOptions: {
      tlsVersion: 'TlsV1.3'
    }
  };

  // 创建通信会话对象
  const session = rcp.createSession({ requestConfiguration: { security: securityConfig } });

  // 定义请求对象 req
  let req = new rcp.Request('http://example.com/fetch', 'PATCH', headers, modifiedContent);

  // 发起请求
  session.fetch(req).then((response) => {
    hilog.info(DOMAIN, TAG, `Request succeeded, message is ${JSON.stringify(response)}`);
  }).catch((err: BusinessError) => {
    hilog.error(DOMAIN, TAG, `err: err code is ${err.code}, err message is ${JSON.stringify(err)}`);
  });
}

// ==================== 2. 设置会话中URL的基地址 ====================

/**
 * 示例2：设置会话基地址
 * 场景：所有请求自动添加基地址前缀
 */
export async function example2_SetBaseAddress(): Promise<void> {
  hilog.info(DOMAIN, TAG, '========== 示例2：设置基地址 ==========');

  // 定义 sessionConfig 对象
  const sessionConfig: rcp.SessionConfiguration = {
    baseAddress: 'http://api.example.com',
    headers: {
      'authorization': 'Bearer YOUR_ACCESS_TOKEN',
      'content-type': 'application/json'
    },
    requestConfiguration: {
      security: {
        tlsOptions: {
          tlsVersion: 'TlsV1.3'
        }
      }
    }
  };

  // 创建通信会话对象，并传入 sessionConfig
  const session = rcp.createSession(sessionConfig);

  // 发起请求（会自动加上 baseAddress）
  // 实际请求地址为：http://api.example.com/users/123
  session.get('/users/123').then((response) => {
    hilog.info(DOMAIN, TAG, `Request succeeded: ${JSON.stringify(response)}`);
  }).catch((err: BusinessError) => {
    hilog.error(DOMAIN, TAG, `Request failed: ${JSON.stringify(err)}`);
  });
}

// ==================== 3. 多表单提交 ====================

/**
 * 示例3：多表单提交
 * 场景：同时提交多个表单数据和文件
 */
export async function example3_MultipartForm(name: string, hobbies: string): Promise<void> {
  hilog.info(DOMAIN, TAG, '========== 示例3：多表单提交 ==========');

  // 定义请求头类型
  let headers: rcp.RequestHeaders = {
    'accept': 'application/json'
  };

  // 配置HTTP请求的超时值
  let configuration: rcp.Configuration = {
    transfer: {
      timeout: {
        connectMs: 60000,
        transferMs: 60000
      }
    }
  };

  // HTTP请求中的Cookie
  let cookies: rcp.RequestCookies = {
    'name1': 'value1',
    'name2': 'value2',
  };

  // 设置数据传输范围
  let transferRange: rcp.TransferRange = {
    from: 100,
    to: 200
  };

  // 设置 multipartForm 数据
  const multiForm = new rcp.MultipartForm({
    'Form1': name, // string
    'Form2': hobbies, // string
    'Form3': {
      contentType: 'text/plain',
      remoteFileName: 'RemoteFileName',
      contentOrPath: '/file/to/Path'
    } // object
  });

  const securityConfig: rcp.SecurityConfiguration = {
    tlsOptions: {
      tlsVersion: 'TlsV1.3'
    }
  };

  // 创建通信会话对象
  const session = rcp.createSession({ requestConfiguration: { security: securityConfig } });

  // 定义请求对象 req
  let req =
    new rcp.Request('https://www.example.com', 'POST', headers, multiForm, cookies, transferRange, configuration);
  req.content = multiForm;

  // 发起请求
  session.fetch(req).then((response) => {
    hilog.info(DOMAIN, TAG, `Request succeeded, message is ${JSON.stringify(response)}`);
  }).catch((err: BusinessError) => {
    hilog.error(DOMAIN, TAG, `err: err code is ${err.code}, err message is ${JSON.stringify(err)}`);
  });
}

// ==================== 4. DNS 配置 ====================

/**
 * 示例4.1：自定义DNS服务器
 */
export async function example4_1_CustomDNSServers(): Promise<void> {
  hilog.info(DOMAIN, TAG, '========== 示例4.1：自定义DNS服务器 ==========');

  // 配置自定义DNS服务器
  const customDnsServers: rcp.DnsServers = [
    { ip: '8.8.8.8' },
    { ip: '8.8.4.4', port: 53 }
  ];

  // 创建通信会话对象
  const sessionWithCustomDns = rcp.createSession({
    requestConfiguration: {
      dns: {
        dnsRules: customDnsServers
      },
      security: {
        tlsOptions: {
          tlsVersion: 'TlsV1.3'
        }
      }
    }
  });

  // 发起请求
  sessionWithCustomDns.get('http://www.example.com').then((response) => {
    hilog.info(DOMAIN, TAG, `Request succeeded, message is ${JSON.stringify(response)}`);
  }).catch((err: BusinessError) => {
    hilog.error(DOMAIN, TAG, `err: err code is ${err.code}, err message is ${JSON.stringify(err)}`);
  });
}

/**
 * 示例4.2：自定义静态DNS
 */
export async function example4_2_StaticDNS(): Promise<void> {
  hilog.info(DOMAIN, TAG, '========== 示例4.2：自定义静态DNS ==========');

  // 当匹配到hostname时，优先使用指定的地址
  const staticDnsRules: rcp.StaticDnsRules = [
    {
      host: 'example.com',
      port: 80,
      ipAddresses: ['192.168.1.1', '192.168.1.2']
    }
  ];

  // 创建通信会话对象
  const sessionWithCustomDns = rcp.createSession({
    requestConfiguration: {
      dns: {
        dnsRules: staticDnsRules
      },
      security: {
        tlsOptions: {
          tlsVersion: 'TlsV1.3'
        }
      }
    }
  });

  // 发起请求
  sessionWithCustomDns.get('http://www.example.com').then((response) => {
    hilog.info(DOMAIN, TAG, `Request succeeded, message is ${JSON.stringify(response)}`);
  }).catch((err: BusinessError) => {
    hilog.error(DOMAIN, TAG, `err: err code is ${err.code}, err message is ${JSON.stringify(err)}`);
  });
}

/**
 * 示例4.3：配置HTTPS上的DNS（DNS over HTTPS）
 */
export async function example4_3_DNSOverHTTPS(): Promise<void> {
  hilog.info(DOMAIN, TAG, '========== 示例4.3：DNS over HTTPS ==========');

  // DNS over HTTPS配置
  const dohConfig: rcp.DnsOverHttpsConfiguration = {
    url: 'https://dns.example.com/dns-query',
    skipCertificatesValidation: true
  };

  // 创建通信会话对象
  const sessionWithCustomDns = rcp.createSession({
    requestConfiguration: {
      dns: {
        dnsOverHttps: dohConfig
      },
      security: {
        tlsOptions: {
          tlsVersion: 'TlsV1.3'
        }
      }
    }
  });

  // 发起请求
  sessionWithCustomDns.get('http://www.example.com').then((response) => {
    hilog.info(DOMAIN, TAG, `Request succeeded, message is ${JSON.stringify(response)}`);
  }).catch((err: BusinessError) => {
    hilog.error(DOMAIN, TAG, `err: err code is ${err.code}, err message is ${JSON.stringify(err)}`);
  });
}

// ==================== 5. 拦截器 ====================

/**
 * 响应缓存类（官方示例）
 */
export class ResponseCache {
  public readonly cache: Record<string, rcp.Response> = {};

  getResponse(url: string): rcp.Response {
    return this.cache[url];
  }

  setResponse(url: string, response: rcp.Response): void {
    this.cache[url] = response;
  }
}

/**
 * 响应缓存拦截器（官方示例）
 */
export class ResponseCachingInterceptor implements rcp.Interceptor {
  public readonly cache: ResponseCache;

  constructor(cache: ResponseCache) {
    this.cache = cache;
  }

  async intercept(context: rcp.RequestContext, next: rcp.RequestHandler): Promise<rcp.Response> {
    const url = context.request.url.href;
    const responseFromCache = this.cache.getResponse(url);
    if (responseFromCache) {
      return Promise.resolve(responseFromCache);
    }
    hilog.info(DOMAIN, TAG, `[ResponseCachingInterceptor]: Request URL is "${context.request.url.href}"`);
    const promise = next.handle(context);
    promise.then((resp) => {
      resp.statusCode;
      this.cache.setResponse(url, resp);
    });
    return promise;
  }
}

/**
 * 响应头移除拦截器（官方示例）
 */
export class ResponseHeaderRemoveInterceptor implements rcp.Interceptor {
  // Custom Response processing Logic
  async intercept(context: rcp.RequestContext, next: rcp.RequestHandler): Promise<rcp.Response> {
    const response = await next.handle(context);
    const toReturn: rcp.Response = {
      request: response.request,
      statusCode: response.statusCode,
      httpVersion: response.httpVersion,
      headers: {
        'content-range': response.headers['content-range']
      },
      effectiveUrl: response.effectiveUrl,
      timeInfo: response.timeInfo,
      toJSON: () => null
    };
    hilog.info(DOMAIN, TAG, '[ResponseHeaderRemoveInterceptor]: Response was modified');
    return toReturn;
  }
}

/**
 * 示例5：使用拦截器
 */
export async function example5_UseInterceptors(): Promise<void> {
  hilog.info(DOMAIN, TAG, '========== 示例5：使用拦截器 ==========');

  const cache = new ResponseCache();
  const sessionConfig: rcp.SessionConfiguration = {
    interceptors: [
      new ResponseCachingInterceptor(cache),
      new ResponseHeaderRemoveInterceptor()
    ],
    requestConfiguration: {
      security: {
        tlsOptions: {
          tlsVersion: 'TlsV1.3'
        }
      }
    }
  };

  const session = rcp.createSession(sessionConfig);

  // 发起请求
  session.get('http://www.example.com').then((response) => {
    hilog.info(DOMAIN, TAG, `Request succeeded: ${JSON.stringify(response)}`);
  }).catch((err: BusinessError) => {
    hilog.error(DOMAIN, TAG, `Request failed: ${JSON.stringify(err)}`);
  });
}

// ==================== 6. 请求追踪 ====================

/**
 * 示例6：捕获HTTP请求/响应的详细信息
 */
export async function example6_RequestTracing(): Promise<void> {
  hilog.info(DOMAIN, TAG, '========== 示例6：请求追踪 ==========');

  // 定义自定义响应处理程序
  const customHttpEventsHandler: rcp.HttpEventsHandler = {
    onDataReceive: (incomingData: ArrayBuffer) => {
      // 用于处理传入数据的自定义逻辑
      hilog.info(DOMAIN, TAG, 'Received data:' + JSON.stringify(incomingData));
      return incomingData.byteLength;
    },
    onHeaderReceive: (headers: rcp.RequestHeaders) => {
      // 处理响应头的自定义逻辑
      hilog.info(DOMAIN, TAG, 'Received headers:' + JSON.stringify(headers));
    },
    onDataEnd: () => {
      // 用于处理数据传输完成的自定义逻辑
      hilog.info(DOMAIN, TAG, 'Data transfer complete');
    }
  };

  // 配置跟踪设置
  const tracingConfig: rcp.TracingConfiguration = {
    verbose: true,
    infoToCollect: {
      incomingHeader: true, // 收集传入的header信息事件
      outgoingHeader: true, // 收集传出的header信息事件
      incomingData: true, // 收集传入数据信息事件
      outgoingData: true // 收集传出数据信息事件
    },
    collectTimeInfo: true,
    httpEventsHandler: customHttpEventsHandler
  };

  const securityConfig: rcp.SecurityConfiguration = {
    tlsOptions: {
      tlsVersion: 'TlsV1.3'
    }
  };

  // 创建通信会话对象，并传入相关配置
  const session = rcp.createSession({
    requestConfiguration: {
      tracing: tracingConfig,
      security: securityConfig
    }
  });

  session.get('http://developer.huawei.com').then((response) => {
    hilog.info(DOMAIN, TAG, `Request succeeded, message is ${JSON.stringify(response)}`);

    // 查看时间信息
    if (response.timeInfo) {
      hilog.info(DOMAIN, TAG, `DNS解析时间: ${response.timeInfo.dnsLookupTime}ms`);
      hilog.info(DOMAIN, TAG, `TCP连接时间: ${response.timeInfo.tcpConnectionTime}ms`);
      hilog.info(DOMAIN, TAG, `TLS握手时间: ${response.timeInfo.tlsConnectionTime}ms`);
      hilog.info(DOMAIN, TAG, `总耗时: ${response.timeInfo.totalTime}ms`);
    }
  }).catch((err: BusinessError) => {
    hilog.error(DOMAIN, TAG, `err: err code is ${err.code}, err message is ${JSON.stringify(err)}`);
  });
}

// ==================== 运行所有示例 ====================

/**
 * 运行所有官方示例
 */
export async function runAllExamples(): Promise<void> {
  hilog.info(DOMAIN, TAG, '========== 开始运行所有官方示例 ==========');

  // 示例1：PATCH请求
  await example1_PatchRequest();

  // 延迟1秒
  await new Promise(resolve => setTimeout(resolve, 1000));

  // 示例2：设置基地址
  await example2_SetBaseAddress();

  // 延迟1秒
  await new Promise(resolve => setTimeout(resolve, 1000));

  // 示例3：多表单提交
  await example3_MultipartForm('张三', '阅读,旅游');

  // 延迟1秒
  await new Promise(resolve => setTimeout(resolve, 1000));

  // 示例4：DNS配置
  await example4_1_CustomDNSServers();
  await example4_2_StaticDNS();
  await example4_3_DNSOverHTTPS();

  // 延迟1秒
  await new Promise(resolve => setTimeout(resolve, 1000));

  // 示例5：拦截器
  await example5_UseInterceptors();

  // 延迟1秒
  await new Promise(resolve => setTimeout(resolve, 1000));

  // 示例6：请求追踪
  await example6_RequestTracing();

  hilog.info(DOMAIN, TAG, '========== 所有官方示例运行完成 ==========');
}
