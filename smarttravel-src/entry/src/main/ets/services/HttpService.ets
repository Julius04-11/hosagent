import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'HttpService';
const DOMAIN = 0xFF00;

/**
 * HTTP 请求配置
 */
export interface HttpRequestConfig {
  method?: http.RequestMethod;
  header?: Record<string, string>;
  extraData?: string | Object | ArrayBuffer;
  expectDataType?: http.HttpDataType;
  usingCache?: boolean;
  priority?: number;
  connectTimeout?: number;
  readTimeout?: number;
  usingProtocol?: http.HttpProtocol;
  usingProxy?: boolean;
}

/**
 * HTTP 响应数据
 */
export interface HttpResponseData<T = any> {
  data: T;
  statusCode: number;
  headers: Record<string, string>;
  cookies?: string;
}

/**
 * HTTP 请求服务
 * 提供统一的 HTTP 请求封装，支持 GET/POST/PUT/DELETE 等常见方法
 */
export class HttpService {
  private static instance: HttpService;
  private baseUrl: string = '';
  private defaultHeaders: Record<string, string> = {
    'Content-Type': 'application/json'
  };
  private defaultTimeout: number = 60000;

  private constructor() {}

  /**
   * 获取单例实例
   */
  public static getInstance(): HttpService {
    if (!HttpService.instance) {
      HttpService.instance = new HttpService();
    }
    return HttpService.instance;
  }

  /**
   * 设置基础 URL
   */
  public setBaseUrl(url: string): void {
    this.baseUrl = url;
    hilog.info(DOMAIN, TAG, `Base URL set to: ${url}`);
  }

  /**
   * 设置默认请求头
   */
  public setDefaultHeaders(headers: Record<string, string>): void {
    this.defaultHeaders = { ...this.defaultHeaders, ...headers };
    hilog.info(DOMAIN, TAG, `Default headers updated`);
  }

  /**
   * 设置默认超时时间
   */
  public setDefaultTimeout(timeout: number): void {
    this.defaultTimeout = timeout;
    hilog.info(DOMAIN, TAG, `Default timeout set to: ${timeout}ms`);
  }

  /**
   * GET 请求
   */
  public async get<T = any>(url: string, config?: HttpRequestConfig): Promise<HttpResponseData<T>> {
    return this.request<T>(url, {
      ...config,
      method: http.RequestMethod.GET
    });
  }

  /**
   * POST 请求
   */
  public async post<T = any>(url: string, data?: any, config?: HttpRequestConfig): Promise<HttpResponseData<T>> {
    return this.request<T>(url, {
      ...config,
      method: http.RequestMethod.POST,
      extraData: data
    });
  }

  /**
   * PUT 请求
   */
  public async put<T = any>(url: string, data?: any, config?: HttpRequestConfig): Promise<HttpResponseData<T>> {
    return this.request<T>(url, {
      ...config,
      method: http.RequestMethod.PUT,
      extraData: data
    });
  }

  /**
   * DELETE 请求
   */
  public async delete<T = any>(url: string, config?: HttpRequestConfig): Promise<HttpResponseData<T>> {
    return this.request<T>(url, {
      ...config,
      method: http.RequestMethod.DELETE
    });
  }

  /**
   * 通用请求方法
   */
  public async request<T = any>(url: string, config?: HttpRequestConfig): Promise<HttpResponseData<T>> {
    const fullUrl = this.buildFullUrl(url);
    const httpRequest = http.createHttp();

    try {
      hilog.info(DOMAIN, TAG, `Request: ${config?.method || 'GET'} ${fullUrl}`);

      // 订阅响应头事件
      httpRequest.on('headersReceive', (header) => {
        hilog.info(DOMAIN, TAG, `Headers received: ${JSON.stringify(header)}`);
      });

      // 合并配置
      const requestOptions: http.HttpRequestOptions = {
        method: config?.method || http.RequestMethod.GET,
        header: { ...this.defaultHeaders, ...config?.header },
        extraData: this.serializeExtraData(config?.extraData),
        expectDataType: config?.expectDataType || http.HttpDataType.STRING,
        usingCache: config?.usingCache ?? true,
        priority: config?.priority || 1,
        connectTimeout: config?.connectTimeout || this.defaultTimeout,
        readTimeout: config?.readTimeout || this.defaultTimeout,
        usingProtocol: config?.usingProtocol || http.HttpProtocol.HTTP1_1,
        usingProxy: config?.usingProxy ?? false
      };

      // 发起请求
      const response = await httpRequest.request(fullUrl, requestOptions);

      hilog.info(DOMAIN, TAG, `Response: ${response.responseCode} ${fullUrl}`);

      // 解析响应
      return this.parseResponse<T>(response);
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(DOMAIN, TAG, `Request failed: ${err.code} ${err.message}`);
      throw this.createHttpError(err);
    } finally {
      // 清理资源
      httpRequest.off('headersReceive');
      httpRequest.destroy();
    }
  }

  /**
   * 上传文件（multipart/form-data）
   */
  public async uploadFile(
    url: string,
    filePath: string,
    fieldName: string = 'file',
    additionalData?: Record<string, string>
  ): Promise<HttpResponseData> {
    const fullUrl = this.buildFullUrl(url);
    const httpRequest = http.createHttp();

    try {
      hilog.info(DOMAIN, TAG, `Upload file: ${filePath} to ${fullUrl}`);

      // 构建 multipart 数据
      const multiFormDataList: http.MultipartFormData[] = [
        {
          name: fieldName,
          contentType: 'application/octet-stream',
          filePath: filePath,
          remoteFileName: this.getFileNameFromPath(filePath)
        }
      ];

      // 添加额外字段
      if (additionalData) {
        for (const key in additionalData) {
          multiFormDataList.push({
            name: key,
            contentType: 'text/plain',
            data: additionalData[key]
          });
        }
      }

      const requestOptions: http.HttpRequestOptions = {
        method: http.RequestMethod.POST,
        header: {
          ...this.defaultHeaders,
          'Content-Type': 'multipart/form-data'
        },
        multiFormDataList: multiFormDataList,
        connectTimeout: this.defaultTimeout,
        readTimeout: this.defaultTimeout * 2 // 上传文件超时时间加倍
      };

      const response = await httpRequest.request(fullUrl, requestOptions);
      hilog.info(DOMAIN, TAG, `Upload completed: ${response.responseCode}`);

      return this.parseResponse(response);
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(DOMAIN, TAG, `Upload failed: ${err.code} ${err.message}`);
      throw this.createHttpError(err);
    } finally {
      httpRequest.destroy();
    }
  }

  /**
   * 下载文件
   */
  public async downloadFile(
    url: string,
    onProgress?: (progress: number) => void
  ): Promise<ArrayBuffer> {
    const fullUrl = this.buildFullUrl(url);
    const httpRequest = http.createHttp();

    try {
      hilog.info(DOMAIN, TAG, `Download file: ${fullUrl}`);

      // 订阅下载进度
      if (onProgress) {
        httpRequest.on('dataReceiveProgress', (data: http.DataReceiveProgressInfo) => {
          const progress = data.receiveSize / data.totalSize;
          onProgress(progress);
        });
      }

      const requestOptions: http.HttpRequestOptions = {
        method: http.RequestMethod.GET,
        expectDataType: http.HttpDataType.ARRAY_BUFFER,
        readTimeout: this.defaultTimeout * 3 // 下载超时时间加长
      };

      const response = await httpRequest.request(fullUrl, requestOptions);
      hilog.info(DOMAIN, TAG, `Download completed: ${response.responseCode}`);

      return response.result as ArrayBuffer;
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(DOMAIN, TAG, `Download failed: ${err.code} ${err.message}`);
      throw this.createHttpError(err);
    } finally {
      httpRequest.off('dataReceiveProgress');
      httpRequest.destroy();
    }
  }

  /**
   * 构建完整 URL
   */
  private buildFullUrl(url: string): string {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    return this.baseUrl + url;
  }

  /**
   * 序列化请求数据
   */
  private serializeExtraData(data?: string | Object | ArrayBuffer): string | Object | ArrayBuffer | undefined {
    if (!data) {
      return undefined;
    }

    if (typeof data === 'string' || data instanceof ArrayBuffer) {
      return data;
    }

    // 对象转 JSON 字符串
    return JSON.stringify(data);
  }

  /**
   * 解析响应数据
   */
  private parseResponse<T>(response: http.HttpResponse): HttpResponseData<T> {
    let parsedData: T;

    // 根据响应类型解析数据
    if (typeof response.result === 'string') {
      try {
        parsedData = JSON.parse(response.result) as T;
      } catch {
        parsedData = response.result as T;
      }
    } else {
      parsedData = response.result as T;
    }

    return {
      data: parsedData,
      statusCode: response.responseCode,
      headers: response.header as Record<string, string>,
      cookies: response.cookies
    };
  }

  /**
   * 创建 HTTP 错误对象
   */
  private createHttpError(err: BusinessError): Error {
    const error = new Error(`HTTP Error: ${err.message}`);
    (error as any).code = err.code;
    (error as any).data = err.data;
    return error;
  }

  /**
   * 从路径中提取文件名
   */
  private getFileNameFromPath(filePath: string): string {
    const parts = filePath.split('/');
    return parts[parts.length - 1] || 'file';
  }

  /**
   * 取消所有请求（用于页面销毁时）
   */
  public cancelAllRequests(): void {
    hilog.info(DOMAIN, TAG, 'All requests cancelled');
    // HTTP 请求是一次性的，无需额外取消逻辑
  }
}

/**
 * 创建默认配置的 HTTP 服务实例
 */
export function createHttpService(baseUrl?: string): HttpService {
  const service = HttpService.getInstance();
  if (baseUrl) {
    service.setBaseUrl(baseUrl);
  }
  return service;
}
