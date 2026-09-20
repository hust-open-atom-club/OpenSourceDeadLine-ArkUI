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

import { preferences } from '@kit.ArkData';
import { Logger } from '../common/Logger';
import { Context } from '@kit.AbilityKit';

/**
 * Preferences存储工具类
 */
export class PreferencesUtil {
  private static readonly TAG: string = 'PreferencesUtil';
  private static readonly STORE_NAME: string = 'oseddl_store';
  private static preferences: preferences.Preferences | undefined = undefined;
  
  /**
   * 初始化Preferences
   */
  static async init(context: Context): Promise<void> {
    try {
      PreferencesUtil.preferences = await preferences.getPreferences(context, PreferencesUtil.STORE_NAME);
      Logger.info(PreferencesUtil.TAG, 'Preferences initialized successfully');
    } catch (err) {
      Logger.error(PreferencesUtil.TAG, 'Failed to init preferences: %{public}s', JSON.stringify(err));
    }
  }
  
  /**
   * 获取字符串值
   */
  static getString(key: string, defaultValue: string = ''): string {
    if (PreferencesUtil.preferences === undefined) {
      Logger.warn(PreferencesUtil.TAG, 'Preferences not initialized');
      return defaultValue;
    }
    try {
      return PreferencesUtil.preferences.getSync(key, defaultValue) as string;
    } catch (err) {
      Logger.error(PreferencesUtil.TAG, 'Failed to get string: %{public}s', JSON.stringify(err));
      return defaultValue;
    }
  }
  
  /**
   * 存储字符串值
   */
  static putString(key: string, value: string): void {
    if (PreferencesUtil.preferences === undefined) {
      Logger.warn(PreferencesUtil.TAG, 'Preferences not initialized');
      return;
    }
    try {
      PreferencesUtil.preferences.putSync(key, value);
      PreferencesUtil.preferences.flush();
    } catch (err) {
      Logger.error(PreferencesUtil.TAG, 'Failed to put string: %{public}s', JSON.stringify(err));
    }
  }
  
  /**
   * 获取数字值
   */
  static getNumber(key: string, defaultValue: number = 0): number {
    if (PreferencesUtil.preferences === undefined) {
      Logger.warn(PreferencesUtil.TAG, 'Preferences not initialized');
      return defaultValue;
    }
    try {
      return PreferencesUtil.preferences.getSync(key, defaultValue) as number;
    } catch (err) {
      Logger.error(PreferencesUtil.TAG, 'Failed to get number: %{public}s', JSON.stringify(err));
      return defaultValue;
    }
  }
  
  /**
   * 存储数字值
   */
  static putNumber(key: string, value: number): void {
    if (PreferencesUtil.preferences === undefined) {
      Logger.warn(PreferencesUtil.TAG, 'Preferences not initialized');
      return;
    }
    try {
      PreferencesUtil.preferences.putSync(key, value);
      PreferencesUtil.preferences.flush();
    } catch (err) {
      Logger.error(PreferencesUtil.TAG, 'Failed to put number: %{public}s', JSON.stringify(err));
    }
  }
  
  /**
   * 获取布尔值
   */
  static getBoolean(key: string, defaultValue: boolean = false): boolean {
    if (PreferencesUtil.preferences === undefined) {
      Logger.warn(PreferencesUtil.TAG, 'Preferences not initialized');
      return defaultValue;
    }
    try {
      return PreferencesUtil.preferences.getSync(key, defaultValue) as boolean;
    } catch (err) {
      Logger.error(PreferencesUtil.TAG, 'Failed to get boolean: %{public}s', JSON.stringify(err));
      return defaultValue;
    }
  }
  
  /**
   * 存储布尔值
   */
  static putBoolean(key: string, value: boolean): void {
    if (PreferencesUtil.preferences === undefined) {
      Logger.warn(PreferencesUtil.TAG, 'Preferences not initialized');
      return;
    }
    try {
      PreferencesUtil.preferences.putSync(key, value);
      PreferencesUtil.preferences.flush();
    } catch (err) {
      Logger.error(PreferencesUtil.TAG, 'Failed to put boolean: %{public}s', JSON.stringify(err));
    }
  }
  
  /**
   * 获取JSON对象
   */
  static getJson<T>(key: string, defaultValue: T): T {
    const str = PreferencesUtil.getString(key, '');
    if (str === '') {
      return defaultValue;
    }
    try {
      return JSON.parse(str) as T;
    } catch (err) {
      Logger.error(PreferencesUtil.TAG, 'Failed to parse JSON: %{public}s', JSON.stringify(err));
      return defaultValue;
    }
  }
  
  /**
   * 存储JSON对象
   */
  static putJson<T>(key: string, value: T): void {
    try {
      const str = JSON.stringify(value);
      PreferencesUtil.putString(key, str);
    } catch (err) {
      Logger.error(PreferencesUtil.TAG, 'Failed to stringify JSON: %{public}s', JSON.stringify(err));
    }
  }
  
  /**
   * 删除键
   */
  static delete(key: string): void {
    if (PreferencesUtil.preferences === undefined) {
      Logger.warn(PreferencesUtil.TAG, 'Preferences not initialized');
      return;
    }
    try {
      PreferencesUtil.preferences.deleteSync(key);
      PreferencesUtil.preferences.flush();
    } catch (err) {
      Logger.error(PreferencesUtil.TAG, 'Failed to delete: %{public}s', JSON.stringify(err));
    }
  }
  
  /**
   * 清空所有数据
   */
  static clear(): void {
    if (PreferencesUtil.preferences === undefined) {
      Logger.warn(PreferencesUtil.TAG, 'Preferences not initialized');
      return;
    }
    try {
      PreferencesUtil.preferences.clearSync();
      PreferencesUtil.preferences.flush();
    } catch (err) {
      Logger.error(PreferencesUtil.TAG, 'Failed to clear: %{public}s', JSON.stringify(err));
    }
  }
}
