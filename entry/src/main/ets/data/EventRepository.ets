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

import { Logger } from '../common/Logger';
import { Constants } from '../common/Constants';
import { PreferencesUtil } from './PreferencesUtil';
import { EventModel, EventStatus } from '../model/EventModel';

/**
 * 缓存数据接口
 */
interface CacheData {
  events: EventModel[];
  timestamp: number;
}

/**
 * 事件数据仓库
 * 统一管理数据源（网络、缓存）
 */
export class EventRepository {
  private static readonly TAG: string = 'EventRepository';
  private static memoryCache: EventModel[] = [];
  private static lastUpdateTime: number = 0;
  
  /**
   * 保存事件到缓存
   */
  static saveToCache(events: EventModel[]): void {
    EventRepository.memoryCache = events;
    EventRepository.lastUpdateTime = Date.now();
    
    // 持久化到本地存储
    try {
      const cacheData: CacheData = {
        events: events,
        timestamp: EventRepository.lastUpdateTime
      };
      PreferencesUtil.putJson<CacheData>(Constants.CACHE_KEY_EVENTS, cacheData);
      PreferencesUtil.putNumber(Constants.CACHE_KEY_LAST_UPDATE, EventRepository.lastUpdateTime);
      
      Logger.info(EventRepository.TAG, 'Saved %{public}d events to cache', events.length.toString());
    } catch (err) {
      Logger.error(EventRepository.TAG, 'Failed to save cache: %{public}s', JSON.stringify(err));
    }
  }
  
  /**
   * 从缓存加载事件
   */
  static loadFromCache(): EventModel[] {
    // 优先使用内存缓存
    if (EventRepository.memoryCache.length > 0) {
      return EventRepository.memoryCache;
    }
    
    // 从本地存储加载
    try {
      const cacheData = PreferencesUtil.getJson<CacheData>(Constants.CACHE_KEY_EVENTS, { events: [], timestamp: 0 });
      EventRepository.memoryCache = cacheData.events;
      EventRepository.lastUpdateTime = cacheData.timestamp;
      
      Logger.info(EventRepository.TAG, 'Loaded %{public}d events from cache', EventRepository.memoryCache.length.toString());
      return EventRepository.memoryCache;
    } catch (err) {
      Logger.error(EventRepository.TAG, 'Failed to load cache: %{public}s', JSON.stringify(err));
      return [];
    }
  }
  
  /**
   * 获取所有事件
   */
  static getAllEvents(): EventModel[] {
    return EventRepository.memoryCache;
  }
  
  /**
   * 根据ID获取事件
   */
  static getEventById(id: string): EventModel | undefined {
    for (let i = 0; i < EventRepository.memoryCache.length; i++) {
      if (EventRepository.memoryCache[i].id === id) {
        return EventRepository.memoryCache[i];
      }
    }
    return undefined;
  }
  
  /**
   * 获取即将到来的事件（用于服务卡片）
   */
  static getUpcomingEvents(count: number): EventModel[] {
    const now = Date.now();
    const upcoming: EventModel[] = [];
    
    // 筛选未截止的事件
    for (let i = 0; i < EventRepository.memoryCache.length; i++) {
      const event = EventRepository.memoryCache[i];
      if (event.status !== EventStatus.EXPIRED) {
        upcoming.push(event);
      }
    }
    
    // 按截止日期排序
    upcoming.sort((a: EventModel, b: EventModel) => {
      return a.remainingDays - b.remainingDays;
    });
    
    // 返回前N个
    return upcoming.slice(0, count);
  }
  
  /**
   * 检查缓存是否有效
   */
  static isCacheValid(): boolean {
    if (EventRepository.lastUpdateTime === 0) {
      return false;
    }
    
    const elapsed = Date.now() - EventRepository.lastUpdateTime;
    return elapsed < Constants.CACHE_DURATION;
  }
  
  /**
   * 获取最后更新时间
   */
  static getLastUpdateTime(): number {
    return EventRepository.lastUpdateTime;
  }
  
  /**
   * 清空缓存
   */
  static clearCache(): void {
    EventRepository.memoryCache = [];
    EventRepository.lastUpdateTime = 0;
    PreferencesUtil.delete(Constants.CACHE_KEY_EVENTS);
    PreferencesUtil.delete(Constants.CACHE_KEY_LAST_UPDATE);
  }
}
