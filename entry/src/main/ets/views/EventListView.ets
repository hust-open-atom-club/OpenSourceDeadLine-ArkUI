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
import { EventModel } from '../model/EventModel';
import { EventCardView } from './EventCardView';
import { EmptyStateView, EmptyStateType } from './EmptyStateView';

const TAG = 'EventListView';

/**
 * 事件数据源（用于LazyForEach）
 */
class EventDataSource implements IDataSource {
  private events: EventModel[] = [];
  private listeners: DataChangeListener[] = [];
  
  constructor(events: EventModel[]) {
    this.events = events;
  }
  
  getData(index: number): EventModel {
    return this.events[index];
  }
  
  totalCount(): number {
    return this.events.length;
  }
  
  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }
  
  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      this.listeners.splice(pos, 1);
    }
  }
  
  updateData(events: EventModel[]): void {
    this.events = events;
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDataReloaded();
    });
  }
}

/**
 * 事件列表视图
 */
@ComponentV2
export struct EventListView {
  @Param events: EventModel[] = [];
  @Param isOffline: boolean = false;
  @Param onRefresh: () => Promise<void> = async (): Promise<void> => {};
  @Param onFavoriteChange: (eventId: string) => void = (_: string): void => {};
  
  @Local isRefreshing: boolean = false;
  @Local filteredEvents: EventModel[] = [];
  
  private scroller: Scroller = new Scroller();
  private dataSource: EventDataSource = new EventDataSource([]);
  
  aboutToAppear(): void {
    this.filteredEvents = this.events;
    this.dataSource.updateData(this.filteredEvents);
  }
  
  /**
   * 下拉刷新完成
   */
  async onRefreshComplete(): Promise<void> {
    this.isRefreshing = true;
    await this.onRefresh();
    this.isRefreshing = false;
    this.filteredEvents = this.events;
    this.dataSource.updateData(this.filteredEvents);
  }
  
  build() {
    Column() {
      if (this.filteredEvents.length === 0) {
        EmptyStateView({ type: EmptyStateType.NO_EVENTS })
      } else {
        Refresh({ refreshing: $$this.isRefreshing }) {
          List({ scroller: this.scroller }) {
            LazyForEach(this.dataSource, (event: EventModel, index: number) => {
              ListItem() {
                EventCardView({
                  event: event,
                  isFavorite: false, // TODO: 从FavoriteService获取
                  onFavoriteChange: this.onFavoriteChange
                })
              }
            }, (event: EventModel) => event.id)
          }
          .width('100%')
          .layoutWeight(1)
          .divider({ strokeWidth: 1, color: $r('app.color.divider_color'), startMargin: 16, endMargin: 16 })
          .edgeEffect(EdgeEffect.Spring)
          .listDirection(Axis.Vertical)
          .scrollBar(BarState.Auto)
          .cachedCount(Constants.LIST_CACHED_COUNT)
        }
        .width('100%')
        .height('100%')
        .onRefreshing(async () => { await this.onRefreshComplete(); })
      }
    }
    .width('100%')
    .height('100%')
  }
}
