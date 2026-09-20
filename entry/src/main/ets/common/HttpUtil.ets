/*
 * Copyright (c) 2026 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { http } from '@kit.NetworkKit';
import { Logger } from './Logger';
import { Constants } from './Constants';

/**
 * HTTP响应结果接口
 */
export interface HttpResponse<T> {
  code: number;
  message: string;
  data: T;
}

/**
 * HTTP请求配置接口
 */
export interface HttpRequestConfig {
  url: string;
  method: http.RequestMethod;
  header?: Record<string, string>;
  extraData?: string | Object;
  connectTimeout?: number;
  readTimeout?: number;
}

/**
 * HTTP请求工具类
 */
export class HttpUtil {
  private static readonly TAG: string = 'HttpUtil';
  
  /**
   * 发起HTTP请求
   */
  static async request<T>(config: HttpRequestConfig): Promise<T | undefined> {
    Logger.info(HttpUtil.TAG, 'HTTP request started: %{public}s', config.url);
    const httpRequest = http.createHttp();
    
    try {
      const headers: Record<string, string> = {
        'Content-Type': 'application/json'
      };
      
      // 合并自定义header
      if (config.header !== undefined) {
        const keys = Object.keys(config.header);
        for (let i = 0; i < keys.length; i++) {
          const key = keys[i];
          headers[key] = config.header[key];
        }
      }
      
      Logger.info(HttpUtil.TAG, 'Sending request with timeout: %{public}d', (config.connectTimeout ?? Constants.API_TIMEOUT).toString());
      
      const response = await httpRequest.request(config.url, {
        method: config.method,
        header: headers,
        extraData: config.extraData,
        connectTimeout: config.connectTimeout ?? Constants.API_TIMEOUT,
        readTimeout: config.readTimeout ?? Constants.API_TIMEOUT
      });
      
      Logger.info(HttpUtil.TAG, 'HTTP response received, code: %{public}d', response.responseCode.toString());
      
      if (response.responseCode === 200) {
        const result = response.result as string;
        Logger.info(HttpUtil.TAG, 'Response result length: %{public}d', result.length.toString());
        const parsed: T = JSON.parse(result) as T;
        Logger.info(HttpUtil.TAG, 'JSON parsed successfully');
        return parsed;
      } else {
        Logger.error(HttpUtil.TAG, 'HTTP request failed with code: %{public}d', response.responseCode.toString());
        return undefined;
      }
    } catch (err) {
      Logger.error(HttpUtil.TAG, 'HTTP request error: %{public}s', JSON.stringify(err));
      return undefined;
    } finally {
      httpRequest.destroy();
      Logger.info(HttpUtil.TAG, 'HTTP request completed');
    }
  }
  
  /**
   * GET请求
   */
  static async get<T>(url: string, header?: Record<string, string>): Promise<T | undefined> {
    return HttpUtil.request<T>({
      url: url,
      method: http.RequestMethod.GET,
      header: header
    });
  }
  
  /**
   * POST请求
   */
  static async post<T>(url: string, data: Object | string, header?: Record<string, string>): Promise<T | undefined> {
    return HttpUtil.request<T>({
      url: url,
      method: http.RequestMethod.POST,
      header: header,
      extraData: data
    });
  }
}
