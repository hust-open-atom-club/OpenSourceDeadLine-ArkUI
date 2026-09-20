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

/**
 * 应用常量定义
 */
export class Constants {
  // API配置
  static readonly API_BASE_URL: string = 'https://oseddl.openatom.club/api/data';
  static readonly API_TIMEOUT: number = 30000;
  
  // 缓存键
  static readonly CACHE_KEY_EVENTS: string = 'oseddl_events_cache';
  static readonly CACHE_KEY_FAVORITES: string = 'oseddl_favorites';
  static readonly CACHE_KEY_LAST_UPDATE: string = 'oseddl_last_update';
  
  // 缓存配置
  static readonly CACHE_DURATION: number = 30 * 60 * 1000; // 30分钟
  static readonly MAX_CACHE_SIZE: number = 500;
  
  // 刷新配置
  static readonly REFRESH_DEBOUNCE: number = 300; // 300ms防抖
  static readonly AUTO_REFRESH_INTERVAL: number = 30 * 60 * 1000; // 30分钟自动刷新
  
  // 服务卡片配置
  static readonly FORM_UPDATE_DURATION: number = 5; // 5分钟
  static readonly FORM_DISPLAY_COUNT: number = 3; // 显示前3个事件
  
  // 列表配置
  static readonly LIST_CACHED_COUNT: number = 5; // LazyForEach缓存数量
  static readonly PAGE_SIZE: number = 20;
  
  // 日期配置
  static readonly UPCOMING_THRESHOLD_DAYS: number = 7; // 7天内算即将截止
  
  // 日志域
  static readonly LOG_DOMAIN: number = 0x0000;
  static readonly LOG_TAG: string = 'OSEDDL';
}

/**
 * 设备类型枚举
 */
export enum DeviceType {
  WEARABLE = 'wearable',
  PHONE = 'phone',
  TABLET = 'tablet',
  PC = '2in1'
}

/**
 * 断点配置
 */
export class Breakpoints {
  static readonly SM: string = 'sm'; // < 600vp (手表、小屏手机)
  static readonly MD: string = 'md'; // 600-840vp (手机)
  static readonly LG: string = 'lg'; // > 840vp (平板、PC)
  
  static readonly SM_BREAKPOINT: number = 600;
  static readonly MD_BREAKPOINT: number = 840;
}
