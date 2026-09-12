import { rcp } from '@kit.RemoteCommunicationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'RcpService';
const DOMAIN = 0xFF00;

/**
 * RCP 服务类
 * 基于 Remote Communication Platform 实现高级网络请求功能
 * 
 * 相比 HTTP，RCP 提供：
 * - PATCH 请求支持
 * - 请求/响应拦截器
 * - 自动重定向控制
 * - 响应缓存
 * - 自定义 DNS 解析
 * - 双向证书校验
 * - 请求详细追踪
 */
export class RcpService {
  private static instance: RcpService;
  private session: rcp.Session | null = null;
  private baseAddress: string = 'https://api.smarttravel.com';

  private constructor() {
    this.initSession();
  }

  public static getInstance(): RcpService {
    if (!RcpService.instance) {
      RcpService.instance = new RcpService();
    }
    return RcpService.instance;
  }

  /**
   * 初始化会话
   */
  private initSession(): void {
    try {
      const sessionConfig: rcp.SessionConfiguration = {
        baseAddress: this.baseAddress,
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'SmartTravel/1.0.0'
        },
        requestConfiguration: {
          security: {
            tlsOptions: {
              tlsVersion: 'TlsV1.3'
            }
          },
          transfer: {
            timeout: {
              connectMs: 10000,
              transferMs: 60000
            }
          }
        }
      };

      this.session = rcp.createSession(sessionConfig);
      hilog.info(DOMAIN, TAG, 'RCP session initialized successfully');
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to initialize session: ${JSON.stringify(error)}`);
      throw error;
    }
  }

  /**
   * 设置基础 URL
   */
  public setBaseAddress(url: string): void {
    this.baseAddress = url;
    this.initSession();
  }

  /**
   * 创建自定义会话
   */
  public createCustomSession(config: rcp.SessionConfiguration): rcp.Session {
    return rcp.createSession(config);
  }

  /**
   * GET 请求
   */
  public async get<T>(url: string, headers?: rcp.RequestHeaders): Promise<T> {
    if (!this.session) {
      throw new Error('Session not initialized');
    }

    try {
      hilog.info(DOMAIN, TAG, `GET request: ${url}`);

      let request: rcp.Request;
      if (headers) {
        request = new rcp.Request(url, 'GET', headers);
      } else {
        request = new rcp.Request(url, 'GET');
      }

      const response = await this.session.fetch(request);
      hilog.info(DOMAIN, TAG, `GET response: ${response.statusCode}`);

      return this.parseResponse<T>(response);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `GET request failed: ${JSON.stringify(error)}`);
      throw this.handleError(error as BusinessError);
    }
  }

  /**
   * POST 请求
   */
  public async post<T>(url: string, data?: ESObject, headers?: rcp.RequestHeaders): Promise<T> {
    if (!this.session) {
      throw new Error('Session not initialized');
    }

    try {
      hilog.info(DOMAIN, TAG, `POST request: ${url}`);

      const request = new rcp.Request(url, 'POST', headers || {}, data);
      const response = await this.session.fetch(request);
      hilog.info(DOMAIN, TAG, `POST response: ${response.statusCode}`);

      return this.parseResponse<T>(response);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `POST request failed: ${JSON.stringify(error)}`);
      throw this.handleError(error as BusinessError);
    }
  }

  /**
   * PUT 请求
   */
  public async put<T>(url: string, data?: ESObject, headers?: rcp.RequestHeaders): Promise<T> {
    if (!this.session) {
      throw new Error('Session not initialized');
    }

    try {
      hilog.info(DOMAIN, TAG, `PUT request: ${url}`);

      const request = new rcp.Request(url, 'PUT', headers || {}, data);
      const response = await this.session.fetch(request);
      hilog.info(DOMAIN, TAG, `PUT response: ${response.statusCode}`);

      return this.parseResponse<T>(response);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `PUT request failed: ${JSON.stringify(error)}`);
      throw this.handleError(error as BusinessError);
    }
  }

  /**
   * DELETE 请求
   */
  public async delete<T>(url: string, headers?: rcp.RequestHeaders): Promise<T> {
    if (!this.session) {
      throw new Error('Session not initialized');
    }

    try {
      hilog.info(DOMAIN, TAG, `DELETE request: ${url}`);

      const request = new rcp.Request(url, 'DELETE', headers || {});
      const response = await this.session.fetch(request);
      hilog.info(DOMAIN, TAG, `DELETE response: ${response.statusCode}`);

      return this.parseResponse<T>(response);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `DELETE request failed: ${JSON.stringify(error)}`);
      throw this.handleError(error as BusinessError);
    }
  }

  /**
   * PATCH 请求（RCP 特有）
   * 用于部分更新资源
   */
  public async patch<T>(url: string, data: ESObject, headers?: rcp.RequestHeaders): Promise<T> {
    if (!this.session) {
      throw new Error('Session not initialized');
    }

    try {
      hilog.info(DOMAIN, TAG, `PATCH request: ${url}`);

      const request = new rcp.Request(url, 'PATCH', headers || {}, data);
      const response = await this.session.fetch(request);
      hilog.info(DOMAIN, TAG, `PATCH response: ${response.statusCode}`);

      return this.parseResponse<T>(response);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `PATCH request failed: ${JSON.stringify(error)}`);
      throw this.handleError(error as BusinessError);
    }
  }

  /**
   * HEAD 请求
   */
  public async head(url: string, headers?: rcp.RequestHeaders): Promise<rcp.Response> {
    if (!this.session) {
      throw new Error('Session not initialized');
    }

    try {
      hilog.info(DOMAIN, TAG, `HEAD request: ${url}`);

      const request = new rcp.Request(url, 'HEAD', headers || {});
      const response = await this.session.fetch(request);
      hilog.info(DOMAIN, TAG, `HEAD response: ${response.statusCode}`);

      return response;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `HEAD request failed: ${JSON.stringify(error)}`);
      throw this.handleError(error as BusinessError);
    }
  }

  /**
   * OPTIONS 请求
   */
  public async options(url: string, headers?: rcp.RequestHeaders): Promise<rcp.Response> {
    if (!this.session) {
      throw new Error('Session not initialized');
    }

    try {
      hilog.info(DOMAIN, TAG, `OPTIONS request: ${url}`);

      const request = new rcp.Request(url, 'OPTIONS', headers || {});
      const response = await this.session.fetch(request);
      hilog.info(DOMAIN, TAG, `OPTIONS response: ${response.statusCode}`);

      return response;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `OPTIONS request failed: ${JSON.stringify(error)}`);
      throw this.handleError(error as BusinessError);
    }
  }

  /**
   * 多表单提交（RCP 特有）
   */
  public async submitMultipartForm<T>(
    url: string,
    formData: Record<string, string | rcp.MultipartFormValue>,
    headers?: rcp.RequestHeaders
  ): Promise<T> {
    if (!this.session) {
      throw new Error('Session not initialized');
    }

    try {
      hilog.info(DOMAIN, TAG, `Multipart form submit: ${url}`);

      const multiForm = new rcp.MultipartForm(formData);
      const request = new rcp.Request(url, 'POST', headers || {}, multiForm);
      const response = await this.session.fetch(request);

      hilog.info(DOMAIN, TAG, `Multipart form response: ${response.statusCode}`);

      return this.parseResponse<T>(response);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Multipart form submit failed: ${JSON.stringify(error)}`);
      throw this.handleError(error as BusinessError);
    }
  }

  /**
   * 上传文件
   */
  public async uploadFile<T>(
    url: string,
    filePath: string,
    fieldName: string = 'file',
    additionalData?: Record<string, string>
  ): Promise<T> {
    const formData: Record<string, string | rcp.MultipartFormValue> = {
      [fieldName]: {
        contentType: 'application/octet-stream',
        remoteFileName: filePath.split('/').pop() || 'file',
        contentOrPath: filePath
      }
    };

    if (additionalData) {
      Object.assign(formData, additionalData);
    }

    return this.submitMultipartForm<T>(url, formData);
  }

  /**
   * 解析响应
   */
  private async parseResponse<T>(response: rcp.Response): Promise<T> {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // 成功响应
      if (response.result) {
        return response.result as T;
      }
      return {} as T;
    } else {
      // 错误响应
      throw new Error(`HTTP ${response.statusCode}: Request failed`);
    }
  }

  /**
   * 错误处理
   */
  private handleError(error: BusinessError): Error {
    const errorMessage = error.message || 'Unknown error';
    const errorCode = error.code || -1;

    hilog.error(DOMAIN, TAG, `Error code: ${errorCode}, message: ${errorMessage}`);

    // 根据错误码返回友好提示
    if (errorCode === 2300001) {
      return new Error('网络连接失败');
    } else if (errorCode === 2300002) {
      return new Error('DNS 解析失败');
    } else if (errorCode === 2300003) {
      return new Error('连接超时');
    } else if (errorCode === 2300006) {
      return new Error('SSL 证书验证失败');
    } else {
      return new Error(errorMessage);
    }
  }

  /**
   * 获取会话对象（用于高级配置）
   */
  public getSession(): rcp.Session | null {
    return this.session;
  }

  /**
   * 创建带有追踪配置的会话（用于性能分析和调试）
   * @param tracingConfig 追踪配置
   * @param interceptors 拦截器列表（可选）
   */
  public createSessionWithTracing(
    tracingConfig: rcp.TracingConfiguration,
    interceptors?: rcp.Interceptor[]
  ): rcp.Session {
    try {
      const sessionConfig: rcp.SessionConfiguration = {
        baseAddress: this.baseAddress,
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'SmartTravel/1.0.0'
        },
        requestConfiguration: {
          tracing: tracingConfig,
          security: {
            tlsOptions: {
              tlsVersion: 'TlsV1.3'
            }
          },
          transfer: {
            timeout: {
              connectMs: 10000,
              transferMs: 60000
            }
          }
        }
      };

      // 添加拦截器
      if (interceptors && interceptors.length > 0) {
        sessionConfig.interceptors = interceptors;
      }

      const tracingSession = rcp.createSession(sessionConfig);
      hilog.info(DOMAIN, TAG, 'Tracing session created successfully');
      return tracingSession;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to create tracing session: ${JSON.stringify(error)}`);
      throw error;
    }
  }

  /**
   * 创建默认的 HttpEventsHandler（用于捕获请求/响应详细信息）
   */
  public static createDefaultHttpEventsHandler(): rcp.HttpEventsHandler {
    return {
      onDataReceive: (incomingData: ArrayBuffer) => {
        hilog.info(DOMAIN, TAG, `[HttpEventsHandler] Received data: ${incomingData.byteLength} bytes`);
        return incomingData.byteLength;
      },
      onHeaderReceive: (headers: rcp.RequestHeaders) => {
        hilog.info(DOMAIN, TAG, `[HttpEventsHandler] Received headers: ${JSON.stringify(headers)}`);
      },
      onDataEnd: () => {
        hilog.info(DOMAIN, TAG, '[HttpEventsHandler] Data transfer complete');
      }
    };
  }

  /**
   * 创建默认的追踪配置（启用所有追踪功能）
   */
  public static createDefaultTracingConfig(
    customHandler?: rcp.HttpEventsHandler
  ): rcp.TracingConfiguration {
    return {
      verbose: true,
      infoToCollect: {
        incomingHeader: true,  // 收集传入的header信息事件
        outgoingHeader: true,  // 收集传出的header信息事件
        incomingData: true,    // 收集传入数据信息事件
        outgoingData: true     // 收集传出数据信息事件
      },
      collectTimeInfo: true,  // 收集时间相关信息
      httpEventsHandler: customHandler || RcpService.createDefaultHttpEventsHandler()
    };
  }

  /**
   * 解析响应中的时间信息（用于性能分析）
   */
  public static parseTimeInfo(response: rcp.Response): string {
    if (!response.timeInfo) {
      return '无时间信息';
    }

    const timeInfo = response.timeInfo;
    const details: string[] = [];

    if (timeInfo.dnsLookupTime !== undefined) {
      details.push(`DNS解析: ${timeInfo.dnsLookupTime}ms`);
    }
    if (timeInfo.tcpConnectionTime !== undefined) {
      details.push(`TCP连接: ${timeInfo.tcpConnectionTime}ms`);
    }
    if (timeInfo.tlsConnectionTime !== undefined) {
      details.push(`TLS握手: ${timeInfo.tlsConnectionTime}ms`);
    }
    if (timeInfo.firstSendTime !== undefined) {
      details.push(`首次发送: ${timeInfo.firstSendTime}ms`);
    }
    if (timeInfo.firstReceiveTime !== undefined) {
      details.push(`首次接收: ${timeInfo.firstReceiveTime}ms`);
    }
    if (timeInfo.totalTime !== undefined) {
      details.push(`总耗时: ${timeInfo.totalTime}ms`);
    }

    return details.join(', ');
  }

  /**
   * 销毁会话
   */
  public destroySession(): void {
    this.session = null;
    hilog.info(DOMAIN, TAG, 'Session destroyed');
  }
}
