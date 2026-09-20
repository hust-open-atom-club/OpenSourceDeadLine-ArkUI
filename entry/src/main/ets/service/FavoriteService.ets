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
import { PreferencesUtil } from '../data/PreferencesUtil';
import { EventModel } from '../model/EventModel';

/**
 * 收藏数据模型
 */
export class FavoriteModel {
  eventId: string = '';
  timestamp: number = 0;
}

/**
 * 收藏服务
 */
export class FavoriteService {
  private static readonly TAG: string = 'FavoriteService';
  private static favorites: Map<string, FavoriteModel> = new Map<string, FavoriteModel>();
  private static initialized: boolean = false;
  
  /**
   * 初始化收藏服务
   */
  static init(): void {
    if (FavoriteService.initialized) {
      return;
    }
    
    try {
      const savedFavorites = PreferencesUtil.getJson<FavoriteModel[]>(Constants.CACHE_KEY_FAVORITES, []);
      FavoriteService.favorites.clear();
      
      for (let i = 0; i < savedFavorites.length; i++) {
        const fav = savedFavorites[i];
        FavoriteService.favorites.set(fav.eventId, fav);
      }
      
      FavoriteService.initialized = true;
      Logger.info(FavoriteService.TAG, 'FavoriteService initialized with %{public}d favorites', savedFavorites.length.toString());
    } catch (err) {
      Logger.error(FavoriteService.TAG, 'Failed to init FavoriteService: %{public}s', JSON.stringify(err));
    }
  }
  
  /**
   * 保存收藏数据到本地
   */
  private static save(): void {
    try {
      const favArray: FavoriteModel[] = [];
      FavoriteService.favorites.forEach((value: FavoriteModel) => {
        favArray.push(value);
      });
      PreferencesUtil.putJson<FavoriteModel[]>(Constants.CACHE_KEY_FAVORITES, favArray);
    } catch (err) {
      Logger.error(FavoriteService.TAG, 'Failed to save favorites: %{public}s', JSON.stringify(err));
    }
  }
  
  /**
   * 添加收藏
   */
  static addFavorite(eventId: string): void {
    if (!FavoriteService.initialized) {
      FavoriteService.init();
    }
    
    if (!FavoriteService.favorites.has(eventId)) {
      const fav = new FavoriteModel();
      fav.eventId = eventId;
      fav.timestamp = Date.now();
      FavoriteService.favorites.set(eventId, fav);
      FavoriteService.save();
      Logger.info(FavoriteService.TAG, 'Added favorite: %{public}s', eventId);
    }
  }
  
  /**
   * 移除收藏
   */
  static removeFavorite(eventId: string): void {
    if (!FavoriteService.initialized) {
      FavoriteService.init();
    }
    
    if (FavoriteService.favorites.has(eventId)) {
      FavoriteService.favorites.delete(eventId);
      FavoriteService.save();
      Logger.info(FavoriteService.TAG, 'Removed favorite: %{public}s', eventId);
    }
  }
  
  /**
   * 切换收藏状态
   */
  static toggleFavorite(eventId: string): boolean {
    if (FavoriteService.isFavorite(eventId)) {
      FavoriteService.removeFavorite(eventId);
      return false;
    } else {
      FavoriteService.addFavorite(eventId);
      return true;
    }
  }
  
  /**
   * 是否已收藏
   */
  static isFavorite(eventId: string): boolean {
    if (!FavoriteService.initialized) {
      FavoriteService.init();
    }
    return FavoriteService.favorites.has(eventId);
  }
  
  /**
   * 获取所有收藏ID
   */
  static getAllFavoriteIds(): string[] {
    if (!FavoriteService.initialized) {
      FavoriteService.init();
    }
    
    const ids: string[] = [];
    FavoriteService.favorites.forEach((_: FavoriteModel, key: string) => {
      ids.push(key);
    });
    return ids;
  }
  
  /**
   * 获取收藏的事件列表
   */
  static getFavoriteEvents(allEvents: EventModel[]): EventModel[] {
    const favoriteIds = FavoriteService.getAllFavoriteIds();
    const result: EventModel[] = [];
    
    for (let i = 0; i < allEvents.length; i++) {
      const event = allEvents[i];
      if (favoriteIds.includes(event.id)) {
        result.push(event);
      }
    }
    
    // 按收藏时间倒序排列
    result.sort((a: EventModel, b: EventModel) => {
      const favA = FavoriteService.favorites.get(a.id);
      const favB = FavoriteService.favorites.get(b.id);
      const timeA = favA !== undefined ? favA.timestamp : 0;
      const timeB = favB !== undefined ? favB.timestamp : 0;
      return timeB - timeA;
    });
    
    return result;
  }
  
  /**
   * 获取收藏数量
   */
  static getFavoriteCount(): number {
    if (!FavoriteService.initialized) {
      FavoriteService.init();
    }
    return FavoriteService.favorites.size;
  }
}
