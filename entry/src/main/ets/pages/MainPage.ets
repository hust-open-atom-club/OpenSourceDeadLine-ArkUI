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
import { DeviceUtil } from '../common/DeviceUtil';
import { EventService, LoadState } from '../service/EventService';
import { EventModel } from '../model/EventModel';
import { FavoriteService } from '../service/FavoriteService';
import { MainViewModel } from '../viewmodel/MainViewModel';
import { EventListView } from '../views/EventListView';
import { EmptyStateView, EmptyStateType } from '../views/EmptyStateView';
import { SearchBar } from '../components/SearchBar';
import { FilterPanel } from '../components/FilterPanel';

const TAG = 'MainPage';

/**
 * 主页面
 */
@Entry
@ComponentV2
struct MainPage {
  @Local events: EventModel[] = [];
  @Local filteredEvents: EventModel[] = [];
  @Local loadState: LoadState = LoadState.IDLE;
  @Local isOffline: boolean = false;
  @Local searchKeyword: string = '';
  @Local showFilterPanel: boolean = false;
  
  private viewModel: MainViewModel = new MainViewModel();
  private scroller: Scroller = new Scroller();
  
  aboutToAppear(): void {
    Logger.info(TAG, 'MainPage aboutToAppear');
    
    this.loadEvents();
  }
  
  /**
   * 加载事件数据
   */
  async loadEvents(): Promise<void> {
    await this.viewModel.loadEvents();
    this.syncViewModel();
  }
  
  /**
   * 同步ViewModel状态
   */
  private syncViewModel(): void {
    this.events = this.viewModel.events;
    this.filteredEvents = this.viewModel.filteredEvents;
    this.loadState = this.viewModel.loadState;
    this.isOffline = this.viewModel.isOffline;
  }
  
  /**
   * 下拉刷新
   */
  async onRefresh(): Promise<void> {
    Logger.info(TAG, 'Refreshing events');
    await this.viewModel.refreshEvents();
    this.syncViewModel();
  }
  
  /**
   * 搜索关键词变化
   */
  onSearchChange(keyword: string): void {
    this.searchKeyword = keyword;
    this.viewModel.setSearchKeyword(keyword);
    this.syncViewModel();
  }
  
  /**
   * 收藏状态变化
   */
  onFavoriteChange(eventId: string): void {
    this.viewModel.toggleFavorite(eventId);
  }
  
  /**
   * 显示筛选面板
   */
  onShowFilter(): void {
    this.showFilterPanel = true;
  }
  
  build() {
    Column() {
      // 顶部标题栏
      this.buildTitleBar();
      
      // 搜索栏
      SearchBar({
        keyword: this.searchKeyword,
        placeholder: '搜索事件...',
        onKeywordChange: (keyword: string): void => { this.onSearchChange(keyword); }
      })
      
      // 内容区域
      if (this.loadState === LoadState.LOADING) {
        // 加载中 - 更明显的加载动画
        Column() {
          LoadingProgress()
            .width(64)
            .height(64)
            .color($r('app.color.primary_color'))
          
          Text('正在加载事件数据...')
            .fontSize(16)
            .fontColor($r('app.color.text_primary'))
            .fontWeight(FontWeight.Medium)
            .margin({ top: 20 })
          
          Text('请稍候...')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 8 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor($r('app.color.background_secondary'))
      } else if (this.loadState === LoadState.ERROR && this.events.length === 0) {
        // 加载失败且无缓存
        EmptyStateView({ 
          type: EmptyStateType.NETWORK_ERROR,
          onRetry: (): void => { this.loadEvents(); }
        })
      } else if (this.events.length === 0) {
        // 无数据
        EmptyStateView({ 
          type: EmptyStateType.NO_EVENTS,
          onRetry: (): void => { this.loadEvents(); }
        })
      } else {
        // 显示事件列表
        Stack() {
          EventListView({
            events: this.filteredEvents,
            isOffline: this.isOffline,
            onRefresh: async (): Promise<void> => { await this.onRefresh(); },
            onFavoriteChange: (eventId: string): void => { this.onFavoriteChange(eventId); }
          })
          
          // 离线模式提示
          if (this.isOffline) {
            this.buildOfflineTip();
          }
        }
        .width('100%')
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background_secondary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .bindSheet($$this.showFilterPanel, this.buildFilterSheet(), {
      height: 400,
      dragBar: true,
      backgroundColor: $r('app.color.background_primary'),
      onDisappear: () => { this.showFilterPanel = false; }
    })
  }
  
  @Builder
  buildTitleBar(): void {
    Row() {
      Text($r('app.string.app_title'))
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
      
      Blank()
      
      // 筛选按钮
      Button() {
        Text('筛选')
          .fontSize(14)
          .fontColor($r('app.color.text_primary'))
      }
      .height(32)
      .backgroundColor($r('app.color.background_tertiary'))
      .borderRadius(16)
      .padding({ left: 12, right: 12 })
      .onClick(() => { this.onShowFilter(); })
      
      // 离线状态图标
      if (this.isOffline) {
        Text('📡')
          .fontSize(20)
          .margin({ left: 8 })
      }
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor($r('app.color.background_primary'))
  }
  
  @Builder
  buildOfflineTip(): void {
    Column() {
      Text($r('app.string.offline_mode'))
        .fontSize(12)
        .fontColor('#FFFFFF')
        .padding({ left: 12, right: 12, top: 4, bottom: 4 })
    }
    .backgroundColor($r('app.color.warning_color'))
    .borderRadius(4)
    .position({ x: 16, y: 8 })
  }
  
  @Builder
  buildFilterSheet(): void {
    FilterPanel({
      onFilterChange: (): void => {
        this.showFilterPanel = false;
        this.syncViewModel();
      }
    })
  }
}
