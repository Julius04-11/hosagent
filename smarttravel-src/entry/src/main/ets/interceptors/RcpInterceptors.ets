import { rcp } from '@kit.RemoteCommunicationKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'RcpInterceptors';
const DOMAIN = 0xFF00;

/**
 * 响应缓存类
 */
export class ResponseCache {
  public readonly cache: Record<string, rcp.Response> = {};

  getResponse(url: string): rcp.Response | null {
    return this.cache[url] || null;
  }

  setResponse(url: string, response: rcp.Response): void {
    this.cache[url] = response;
  }

  clearCache(): void {
    for (const key in this.cache) {
      delete this.cache[key];
    }
  }

  removeResponse(url: string): void {
    delete this.cache[url];
  }

  getCacheSize(): number {
    return Object.keys(this.cache).length;
  }
}

/**
 * 响应缓存拦截器
 * 缓存 GET 请求的响应，减少重复请求
 */
export class ResponseCachingInterceptor implements rcp.Interceptor {
  public readonly cache: ResponseCache;

  constructor(cache: ResponseCache) {
    this.cache = cache;
  }

  async intercept(context: rcp.RequestContext, next: rcp.RequestHandler): Promise<rcp.Response> {
    const url = context.request.url.href;
    const method = context.request.method;

    // 只缓存 GET 请求
    if (method !== 'GET') {
      return next.handle(context);
    }

    // 检查缓存
    const responseFromCache = this.cache.getResponse(url);
    if (responseFromCache) {
      hilog.info(DOMAIN, TAG, `[ResponseCachingInterceptor]: Cache hit for "${url}"`);
      return Promise.resolve(responseFromCache);
    }

    // 执行请求
    hilog.info(DOMAIN, TAG, `[ResponseCachingInterceptor]: Cache miss for "${url}"`);
    const promise = next.handle(context);

    // 缓存响应
    promise.then((resp) => {
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        this.cache.setResponse(url, resp);
        hilog.info(DOMAIN, TAG, `[ResponseCachingInterceptor]: Response cached for "${url}"`);
      }
    });

    return promise;
  }
}

/**
 * 请求日志拦截器
 * 记录所有请求和响应的详细信息
 */
export class LoggingInterceptor implements rcp.Interceptor {
  async intercept(context: rcp.RequestContext, next: rcp.RequestHandler): Promise<rcp.Response> {
    const startTime = Date.now();
    const url = context.request.url.href;
    const method = context.request.method;

    hilog.info(DOMAIN, TAG, `[LoggingInterceptor]: → ${method} ${url}`);
    hilog.info(DOMAIN, TAG, `[LoggingInterceptor]: Headers: ${JSON.stringify(context.request.headers)}`);

    try {
      const response = await next.handle(context);
      const duration = Date.now() - startTime;

      hilog.info(DOMAIN, TAG, `[LoggingInterceptor]: ← ${response.statusCode} ${url} (${duration}ms)`);
      hilog.info(DOMAIN, TAG, `[LoggingInterceptor]: Response headers: ${JSON.stringify(response.headers)}`);

      return response;
    } catch (error) {
      const duration = Date.now() - startTime;
      hilog.error(DOMAIN, TAG, `[LoggingInterceptor]: ✗ ${method} ${url} failed (${duration}ms)`);
      hilog.error(DOMAIN, TAG, `[LoggingInterceptor]: Error: ${JSON.stringify(error)}`);
      throw error;
    }
  }
}

/**
 * 认证拦截器
 * 自动添加认证令牌到请求头
 */
export class AuthenticationInterceptor implements rcp.Interceptor {
  private authToken: string = '';

  setAuthToken(token: string): void {
    this.authToken = token;
    hilog.info(DOMAIN, TAG, '[AuthenticationInterceptor]: Auth token updated');
  }

  clearAuthToken(): void {
    this.authToken = '';
    hilog.info(DOMAIN, TAG, '[AuthenticationInterceptor]: Auth token cleared');
  }

  async intercept(context: rcp.RequestContext, next: rcp.RequestHandler): Promise<rcp.Response> {
    // 添加认证头
    if (this.authToken) {
      const modifiedHeaders = {
        ...context.request.headers,
        'Authorization': `Bearer ${this.authToken}`
      };

      const modifiedRequest: rcp.Request = {
        ...context.request,
        headers: modifiedHeaders
      };

      const modifiedContext: rcp.RequestContext = {
        request: modifiedRequest
      };

      hilog.info(DOMAIN, TAG, '[AuthenticationInterceptor]: Authorization header added');
      return next.handle(modifiedContext);
    }

    return next.handle(context);
  }
}

/**
 * 响应头过滤拦截器
 * 移除敏感响应头，只保留必要的
 */
export class ResponseHeaderFilterInterceptor implements rcp.Interceptor {
  async intercept(context: rcp.RequestContext, next: rcp.RequestHandler): Promise<rcp.Response> {
    const response = await next.handle(context);

    // 只保留需要的响应头
    const filteredHeaders: rcp.RequestHeaders = {};
    const allowedHeaders = [
      'content-type',
      'content-length',
      'content-range',
      'etag',
      'last-modified',
      'cache-control'
    ];

    for (const key in response.headers) {
      if (allowedHeaders.includes(key.toLowerCase())) {
        filteredHeaders[key] = response.headers[key];
      }
    }

    const filteredResponse: rcp.Response = {
      request: response.request,
      statusCode: response.statusCode,
      httpVersion: response.httpVersion,
      headers: filteredHeaders,
      result: response.result,
      effectiveUrl: response.effectiveUrl,
      timeInfo: response.timeInfo,
      toJSON: () => null
    };

    hilog.info(DOMAIN, TAG, '[ResponseHeaderFilterInterceptor]: Response headers filtered');
    return filteredResponse;
  }
}

/**
 * 重试拦截器
 * 自动重试失败的请求
 */
export class RetryInterceptor implements rcp.Interceptor {
  private maxRetries: number;
  private retryDelay: number;

  constructor(maxRetries: number = 3, retryDelay: number = 1000) {
    this.maxRetries = maxRetries;
    this.retryDelay = retryDelay;
  }

  async intercept(context: rcp.RequestContext, next: rcp.RequestHandler): Promise<rcp.Response> {
    let lastError: Error | null = null;

    for (let attempt = 0; attempt <= this.maxRetries; attempt++) {
      try {
        if (attempt > 0) {
          hilog.info(DOMAIN, TAG, `[RetryInterceptor]: Retry attempt ${attempt}/${this.maxRetries}`);
          await this.delay(this.retryDelay * attempt);
        }

        const response = await next.handle(context);

        // 如果响应成功，直接返回
        if (response.statusCode >= 200 && response.statusCode < 300) {
          if (attempt > 0) {
            hilog.info(DOMAIN, TAG, `[RetryInterceptor]: Request succeeded on attempt ${attempt + 1}`);
          }
          return response;
        }

        // 5xx 错误才重试
        if (response.statusCode >= 500) {
          lastError = new Error(`HTTP ${response.statusCode}`);
          continue;
        }

        // 其他错误不重试
        return response;
      } catch (error) {
        lastError = error as Error;
        hilog.warn(DOMAIN, TAG, `[RetryInterceptor]: Attempt ${attempt + 1} failed: ${lastError.message}`);
      }
    }

    hilog.error(DOMAIN, TAG, `[RetryInterceptor]: All ${this.maxRetries + 1} attempts failed`);
    throw lastError;
  }

  private delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}

/**
 * 请求超时拦截器
 * 为每个请求添加超时控制
 */
export class TimeoutInterceptor implements rcp.Interceptor {
  private timeoutMs: number;

  constructor(timeoutMs: number = 30000) {
    this.timeoutMs = timeoutMs;
  }

  async intercept(context: rcp.RequestContext, next: rcp.RequestHandler): Promise<rcp.Response> {
    const timeoutPromise = new Promise<never>((_, reject) => {
      setTimeout(() => {
        reject(new Error(`Request timeout after ${this.timeoutMs}ms`));
      }, this.timeoutMs);
    });

    try {
      const response = await Promise.race([
        next.handle(context),
        timeoutPromise
      ]);
      return response;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `[TimeoutInterceptor]: ${(error as Error).message}`);
      throw error;
    }
  }
}

/**
 * 请求速率限制拦截器
 * 限制请求频率，防止过载
 */
export class RateLimitInterceptor implements rcp.Interceptor {
  private requests: number[] = [];
  private maxRequests: number;
  private timeWindowMs: number;

  constructor(maxRequests: number = 10, timeWindowMs: number = 1000) {
    this.maxRequests = maxRequests;
    this.timeWindowMs = timeWindowMs;
  }

  async intercept(context: rcp.RequestContext, next: rcp.RequestHandler): Promise<rcp.Response> {
    const now = Date.now();

    // 清理过期请求记录
    this.requests = this.requests.filter(time => now - time < this.timeWindowMs);

    // 检查是否超过限制
    if (this.requests.length >= this.maxRequests) {
      const oldestRequest = this.requests[0];
      const waitTime = this.timeWindowMs - (now - oldestRequest);

      hilog.warn(DOMAIN, TAG, `[RateLimitInterceptor]: Rate limit exceeded, waiting ${waitTime}ms`);
      await this.delay(waitTime);
    }

    // 记录请求
    this.requests.push(Date.now());

    return next.handle(context);
  }

  private delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}

/**
 * 用户代理拦截器
 * 自动添加 User-Agent 头
 */
export class UserAgentInterceptor implements rcp.Interceptor {
  private userAgent: string;

  constructor(userAgent: string = 'SmartTravel/1.0.0 (HarmonyOS)') {
    this.userAgent = userAgent;
  }

  async intercept(context: rcp.RequestContext, next: rcp.RequestHandler): Promise<rcp.Response> {
    const modifiedHeaders = {
      ...context.request.headers,
      'User-Agent': this.userAgent
    };

    const modifiedRequest: rcp.Request = {
      ...context.request,
      headers: modifiedHeaders
    };

    const modifiedContext: rcp.RequestContext = {
      request: modifiedRequest
    };

    return next.handle(modifiedContext);
  }
}
