import http from '@ohos.net.http';

export class HttpUtil {
  private static BASE_URL = 'https://api.smarttravel.com';

  static async get<T>(url: string): Promise<T> {
    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(this.BASE_URL + url, {
        method: http.RequestMethod.GET,
        header: { 'Content-Type': 'application/json' }
      });
      if (response.responseCode === 200) {
        return JSON.parse(response.result as string) as T;
      }
      throw new Error(`请求失败: ${response.responseCode}`);
    } finally {
      httpRequest.destroy();
    }
  }

  static async post<T>(url: string, data: Object): Promise<T> {
    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(this.BASE_URL + url, {
        method: http.RequestMethod.POST,
        header: { 'Content-Type': 'application/json' },
        extraData: JSON.stringify(data)
      });
      if (response.responseCode === 200) {
        return JSON.parse(response.result as string) as T;
      }
      throw new Error(`请求失败: ${response.responseCode}`);
    } finally {
      httpRequest.destroy();
    }
  }
}
