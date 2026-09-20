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

import { hilog } from '@kit.PerformanceAnalysisKit';
import { Constants } from './Constants';

/**
 * 日志级别
 */
export enum LogLevel {
  DEBUG = 3,
  INFO = 4,
  WARN = 5,
  ERROR = 6
}

/**
 * 日志工具类
 */
export class Logger {
  private static domain: number = Constants.LOG_DOMAIN;
  private static tag: string = Constants.LOG_TAG;
  private static isDebug: boolean = true;
  
  /**
   * 设置是否为调试模式
   */
  static setDebug(isDebug: boolean): void {
    Logger.isDebug = isDebug;
  }
  
  /**
   * 调试日志
   */
  static debug(tag: string, format: string, ...args: string[]): void {
    if (Logger.isDebug) {
      hilog.debug(Logger.domain, tag, format, ...args);
    }
  }
  
  /**
   * 信息日志
   */
  static info(tag: string, format: string, ...args: string[]): void {
    hilog.info(Logger.domain, tag, format, ...args);
  }
  
  /**
   * 警告日志
   */
  static warn(tag: string, format: string, ...args: string[]): void {
    hilog.warn(Logger.domain, tag, format, ...args);
  }
  
  /**
   * 错误日志
   */
  static error(tag: string, format: string, ...args: string[]): void {
    hilog.error(Logger.domain, tag, format, ...args);
  }
  
  /**
   * 致命错误日志
   */
  static fatal(tag: string, format: string, ...args: string[]): void {
    hilog.fatal(Logger.domain, tag, format, ...args);
  }
}
