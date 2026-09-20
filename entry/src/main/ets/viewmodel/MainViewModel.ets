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
import { EventModel, Category, EventStatus } from '../model/EventModel';
import { FilterModel } from '../model/FilterModel';
import { EventService, LoadState } from '../service/EventService';
import { FavoriteService } from '../service/FavoriteService';

const TAG = 'MainViewModel';

/**
 * 主页面状态管理
 */
export class MainViewModel {
  private static readonly TAG: string = 'MainViewModel';
  
  // 事件列表
  events: EventModel[] = [];
  
  // 筛选后的事件列表
  filteredEvents: EventModel[] = [];
  
  // 加载状态
  loadState: LoadState = LoadState.IDLE;
  
  // 筛选条件
  filter: FilterModel = new FilterModel();
  
  // 是否离线模式
  isOffline: boolean = false;
  
  // 搜索防抖定时器ID
  private searchTimer: number = 0;
  
  /**
   * 加载事件数据
   */
  async loadEvents(forceRefresh: boolean = false): Promise<void> {
    Logger.info(TAG, 'loadEvents called, forceRefresh: %{public}s', forceRefresh.toString());
    this.loadState = LoadState.LOADING;
    
    try {
      Logger.info(TAG, 'Calling EventService.getEvents...');
      const events = await EventService.getEvents(forceRefresh);
      Logger.info(TAG, 'EventService returned %{public}d events', events.length.toString());
      
      this.events = events;
      this.isOffline = EventService.isOfflineMode();
      
      // 应用筛选
      this.applyFilter();
      
      this.loadState = events.length > 0 ? LoadState.SUCCESS : LoadState.ERROR;
      
      Logger.info(TAG, 'Loaded %{public}d events, loadState: %{public}s', events.length.toString(), this.loadState);
    } catch (err) {
      Logger.error(TAG, 'Failed to load events: %{public}s', JSON.stringify(err));
      this.loadState = LoadState.ERROR;
    }
  }
  
  /**
   * 刷新事件数据
   */
  async refreshEvents(): Promise<void> {
    await this.loadEvents(true);
  }
  
  /**
   * 设置搜索关键词（带防抖）
   */
  setSearchKeyword(keyword: string): void {
    this.filter.keyword = keyword;
    
    // 清除之前的定时器
    if (this.searchTimer !== 0) {
      clearTimeout(this.searchTimer);
    }
    
    // 设置新的定时器
    this.searchTimer = setTimeout(() => {
      this.applyFilter();
    }, Constants.REFRESH_DEBOUNCE);
  }
  
  /**
   * 设置分类筛选
   */
  setCategoryFilter(categories: Category[]): void {
    this.filter.categories = categories;
    this.applyFilter();
  }
  
  /**
   * 设置状态筛选
   */
  setStatusFilter(statuses: EventStatus[]): void {
    this.filter.statuses = statuses;
    this.applyFilter();
  }
  
  /**
   * 重置筛选条件
   */
  resetFilter(): void {
    this.filter.reset();
    this.applyFilter();
  }
  
  /**
   * 应用筛选条件
   */
  applyFilter(): void {
    let result = this.events.slice();
    
    // 关键词筛选
    if (this.filter.keyword !== '') {
      const keyword = this.filter.keyword.toLowerCase();
      result = result.filter((event: EventModel) => {
        const nameMatch = event.name.toLowerCase().includes(keyword);
        const descMatch = event.description.toLowerCase().includes(keyword);
        const tagMatch = event.tags.some((tag: string) => tag.toLowerCase().includes(keyword));
        return nameMatch || descMatch || tagMatch;
      });
    }
    
    // 分类筛选
    if (this.filter.categories.length > 0) {
      result = result.filter((event: EventModel) => {
        return this.filter.categories.includes(event.category);
      });
    }
    
    // 状态筛选
    if (this.filter.statuses.length > 0) {
      result = result.filter((event: EventModel) => {
        return this.filter.statuses.includes(event.status);
      });
    }
    
    this.filteredEvents = result;
    
    Logger.info(TAG, 'Filter applied: %{public}d results', result.length.toString());
  }
  
  /**
   * 切换收藏状态
   */
  toggleFavorite(eventId: string): boolean {
    return FavoriteService.toggleFavorite(eventId);
  }
  
  /**
   * 检查是否已收藏
   */
  isFavorite(eventId: string): boolean {
    return FavoriteService.isFavorite(eventId);
  }
  
  /**
   * 获取收藏的事件列表
   */
  getFavoriteEvents(): EventModel[] {
    return FavoriteService.getFavoriteEvents(this.events);
  }
  
  /**
   * 获取筛选后的事件数量
   */
  getFilteredCount(): number {
    return this.filteredEvents.length;
  }
  
  /**
   * 获取总事件数量
   */
  getTotalCount(): number {
    return this.events.length;
  }
  
  /**
   * 是否有筛选条件
   */
  hasFilter(): boolean {
    return this.filter.hasFilter();
  }
}
