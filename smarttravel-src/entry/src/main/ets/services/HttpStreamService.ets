import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'HttpStreamService';
const DOMAIN = 0xFF00;

/**
 * 流式传输进度回调
 */
export interface StreamProgressCallback {
  onReceiveProgress?: (receiveSize: number, totalSize: number) => void;
  onSendProgress?: (sendSize: number, totalSize: number) => void;
  onDataReceive?: (data: ArrayBuffer) => void;
  onDataEnd?: () => void;
}

/**
 * HTTP 流式传输服务
 * 用于大文件上传下载，支持进度监控
 */
export class HttpStreamService {
  private static instance: HttpStreamService;
  private activeRequests: Map<string, http.HttpRequest> = new Map();

  private constructor() {}

  /**
   * 获取单例实例
   */
  public static getInstance(): HttpStreamService {
    if (!HttpStreamService.instance) {
      HttpStreamService.instance = new HttpStreamService();
    }
    return HttpStreamService.instance;
  }

  /**
   * 流式下载文件
   */
  public async downloadStream(
    url: string,
    requestId: string,
    callbacks?: StreamProgressCallback
  ): Promise<ArrayBuffer> {
    const httpRequest = http.createHttp();
    this.activeRequests.set(requestId, httpRequest);

    try {
      hilog.info(DOMAIN, TAG, `Start stream download: ${url}`);

      // 用于累积接收的数据
      let accumulatedData = new ArrayBuffer(0);

      // 订阅数据接收事件
      httpRequest.on('dataReceive', (data: ArrayBuffer) => {
        hilog.info(DOMAIN, TAG, `Data chunk received: ${data.byteLength} bytes`);

        // 累积数据
        const newData = new ArrayBuffer(accumulatedData.byteLength + data.byteLength);
        const newDataView = new Uint8Array(newData);
        newDataView.set(new Uint8Array(accumulatedData));
        newDataView.set(new Uint8Array(data), accumulatedData.byteLength);
        accumulatedData = newData;

        // 回调
        if (callbacks?.onDataReceive) {
          callbacks.onDataReceive(data);
        }
      });

      // 订阅数据接收完成事件
      httpRequest.on('dataEnd', () => {
        hilog.info(DOMAIN, TAG, 'Data receive completed');
        if (callbacks?.onDataEnd) {
          callbacks.onDataEnd();
        }
      });

      // 订阅接收进度事件
      httpRequest.on('dataReceiveProgress', (progress: http.DataReceiveProgressInfo) => {
        hilog.info(DOMAIN, TAG, `Receive progress: ${progress.receiveSize}/${progress.totalSize}`);
        if (callbacks?.onReceiveProgress) {
          callbacks.onReceiveProgress(progress.receiveSize, progress.totalSize);
        }
      });

      // 发起流式请求
      const streamOptions: http.HttpRequestOptions = {
        method: http.RequestMethod.GET,
        expectDataType: http.HttpDataType.ARRAY_BUFFER,
        readTimeout: 300000 // 5分钟超时，适合大文件
      };

      const responseCode = await httpRequest.requestInStream(url, streamOptions);
      hilog.info(DOMAIN, TAG, `Stream download completed with code: ${responseCode}`);

      return accumulatedData;
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(DOMAIN, TAG, `Stream download failed: ${err.code} ${err.message}`);
      throw this.createStreamError(err);
    } finally {
      this.destroyRequest(requestId, httpRequest);
    }
  }

  /**
   * 流式上传文件
   */
  public async uploadStream(
    url: string,
    requestId: string,
    data: string | ArrayBuffer,
    callbacks?: StreamProgressCallback
  ): Promise<number> {
    const httpRequest = http.createHttp();
    this.activeRequests.set(requestId, httpRequest);

    try {
      hilog.info(DOMAIN, TAG, `Start stream upload: ${url}`);

      // 订阅发送进度事件
      httpRequest.on('dataSendProgress', (progress: http.DataSendProgressInfo) => {
        hilog.info(DOMAIN, TAG, `Send progress: ${progress.sendSize}/${progress.totalSize}`);
        if (callbacks?.onSendProgress) {
          callbacks.onSendProgress(progress.sendSize, progress.totalSize);
        }
      });

      // 订阅接收进度事件（服务器响应）
      httpRequest.on('dataReceiveProgress', (progress: http.DataReceiveProgressInfo) => {
        if (callbacks?.onReceiveProgress) {
          callbacks.onReceiveProgress(progress.receiveSize, progress.totalSize);
        }
      });

      // 发起流式上传请求
      const streamOptions: http.HttpRequestOptions = {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/octet-stream'
        },
        extraData: data,
        readTimeout: 300000 // 5分钟超时
      };

      const responseCode = await httpRequest.requestInStream(url, streamOptions);
      hilog.info(DOMAIN, TAG, `Stream upload completed with code: ${responseCode}`);

      return responseCode;
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(DOMAIN, TAG, `Stream upload failed: ${err.code} ${err.message}`);
      throw this.createStreamError(err);
    } finally {
      this.destroyRequest(requestId, httpRequest);
    }
  }

  /**
   * 分块上传大文件
   */
  public async uploadLargeFile(
    url: string,
    requestId: string,
    filePath: string,
    callbacks?: StreamProgressCallback
  ): Promise<number> {
    const httpRequest = http.createHttp();
    this.activeRequests.set(requestId, httpRequest);

    try {
      hilog.info(DOMAIN, TAG, `Start large file upload: ${filePath}`);

      // 订阅发送进度
      httpRequest.on('dataSendProgress', (progress: http.DataSendProgressInfo) => {
        hilog.info(DOMAIN, TAG, `Upload progress: ${progress.sendSize}/${progress.totalSize}`);
        if (callbacks?.onSendProgress) {
          callbacks.onSendProgress(progress.sendSize, progress.totalSize);
        }
      });

      // 构建 multipart/form-data
      const streamOptions: http.HttpRequestOptions = {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'multipart/form-data'
        },
        multiFormDataList: [
          {
            name: 'file',
            contentType: 'application/octet-stream',
            filePath: filePath,
            remoteFileName: this.getFileNameFromPath(filePath)
          }
        ],
        readTimeout: 600000 // 10分钟超时，适合大文件
      };

      const responseCode = await httpRequest.requestInStream(url, streamOptions);
      hilog.info(DOMAIN, TAG, `Large file upload completed with code: ${responseCode}`);

      return responseCode;
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(DOMAIN, TAG, `Large file upload failed: ${err.code} ${err.message}`);
      throw this.createStreamError(err);
    } finally {
      this.destroyRequest(requestId, httpRequest);
    }
  }

  /**
   * 下载大文件到指定路径
   */
  public async downloadLargeFile(
    url: string,
    requestId: string,
    onProgress?: (percent: number) => void
  ): Promise<ArrayBuffer> {
    return this.downloadStream(url, requestId, {
      onReceiveProgress: (receiveSize, totalSize) => {
        if (onProgress && totalSize > 0) {
          const percent = (receiveSize / totalSize) * 100;
          onProgress(percent);
        }
      }
    });
  }

  /**
   * 取消流式请求
   */
  public cancelRequest(requestId: string): void {
    const httpRequest = this.activeRequests.get(requestId);
    if (httpRequest) {
      hilog.info(DOMAIN, TAG, `Cancel request: ${requestId}`);
      this.destroyRequest(requestId, httpRequest);
    }
  }

  /**
   * 取消所有流式请求
   */
  public cancelAllRequests(): void {
    hilog.info(DOMAIN, TAG, `Cancel all requests, count: ${this.activeRequests.size}`);
    this.activeRequests.forEach((httpRequest, requestId) => {
      this.destroyRequest(requestId, httpRequest);
    });
  }

  /**
   * 销毁请求并清理资源
   */
  private destroyRequest(requestId: string, httpRequest: http.HttpRequest): void {
    try {
      // 取消所有事件订阅
      httpRequest.off('dataReceive');
      httpRequest.off('dataEnd');
      httpRequest.off('dataReceiveProgress');
      httpRequest.off('dataSendProgress');

      // 销毁请求
      httpRequest.destroy();

      // 从活动请求中移除
      this.activeRequests.delete(requestId);

      hilog.info(DOMAIN, TAG, `Request destroyed: ${requestId}`);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to destroy request: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 创建流式错误对象
   */
  private createStreamError(err: BusinessError): Error {
    const error = new Error(`Stream Error: ${err.message}`);
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
   * 获取活动请求数量
   */
  public getActiveRequestCount(): number {
    return this.activeRequests.size;
  }

  /**
   * 检查请求是否活动
   */
  public isRequestActive(requestId: string): boolean {
    return this.activeRequests.has(requestId);
  }
}

/**
 * 创建流式传输服务实例
 */
export function createHttpStreamService(): HttpStreamService {
  return HttpStreamService.getInstance();
}
