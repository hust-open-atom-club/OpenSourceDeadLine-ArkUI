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
import { EventModel } from '../model/EventModel';
import { FavoriteService } from '../service/FavoriteService';
import { EventService, LoadState } from '../service/EventService';

const TAG = 'FavoriteViewModel';

/**
 * 收藏状态管理
 */
export class FavoriteViewModel {
  private static readonly TAG: string = 'FavoriteViewModel';
  
  // 收藏的事件列表
  favoriteEvents: EventModel[] = [];
  
  // 加载状态
  loadState: LoadState = LoadState.IDLE;
  
  // 收藏数量
  favoriteCount: number = 0;
  
  /**
   * 加载收藏事件
   */
  async loadFavorites(): Promise<void> {
    this.loadState = LoadState.LOADING;
    
    try {
      // 获取所有事件
      const allEvents = await EventService.getEvents();
      
      // 获取收藏的事件
      this.favoriteEvents = FavoriteService.getFavoriteEvents(allEvents);
      this.favoriteCount = this.favoriteEvents.length;
      
      this.loadState = LoadState.SUCCESS;
      
      Logger.info(TAG, 'Loaded %{public}d favorite events', this.favoriteCount.toString());
    } catch (err) {
      Logger.error(TAG, 'Failed to load favorites: %{public}s', JSON.stringify(err));
      this.loadState = LoadState.ERROR;
    }
  }
  
  /**
   * 切换收藏状态
   */
  toggleFavorite(eventId: string): boolean {
    const result = FavoriteService.toggleFavorite(eventId);
    this.favoriteCount = FavoriteService.getFavoriteCount();
    return result;
  }
  
  /**
   * 检查是否已收藏
   */
  isFavorite(eventId: string): boolean {
    return FavoriteService.isFavorite(eventId);
  }
  
  /**
   * 获取收藏数量
   */
  getFavoriteCount(): number {
    return FavoriteService.getFavoriteCount();
  }
  
  /**
   * 移除收藏
   */
  removeFavorite(eventId: string): void {
    FavoriteService.removeFavorite(eventId);
    this.favoriteCount = FavoriteService.getFavoriteCount();
    
    // 从列表中移除
    const index = this.favoriteEvents.findIndex((e: EventModel) => e.id === eventId);
    if (index >= 0) {
      this.favoriteEvents.splice(index, 1);
    }
  }
}
