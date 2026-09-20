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
import { LoadState } from '../service/EventService';
import { FavoriteViewModel } from '../viewmodel/FavoriteViewModel';
import { EmptyStateView, EmptyStateType } from '../views/EmptyStateView';
import { EventCardView } from '../views/EventCardView';

const TAG = 'FavoritePage';

/**
 * 收藏页面
 */
@Entry
@ComponentV2
struct FavoritePage {
  @Local favoriteEvents: EventModel[] = [];
  @Local loadState: LoadState = LoadState.IDLE;
  
  private viewModel: FavoriteViewModel = new FavoriteViewModel();
  
  aboutToAppear(): void {
    Logger.info(TAG, 'FavoritePage aboutToAppear');
    
    this.loadFavorites();
  }
  
  /**
   * 加载收藏事件
   */
  async loadFavorites(): Promise<void> {
    await this.viewModel.loadFavorites();
    this.syncViewModel();
  }
  
  /**
   * 同步ViewModel状态
   */
  private syncViewModel(): void {
    this.favoriteEvents = this.viewModel.favoriteEvents;
    this.loadState = this.viewModel.loadState;
  }
  
  /**
   * 返回上一页
   */
  onBack(): void {
    this.getUIContext().getRouter().back();
  }
  
  /**
   * 收藏状态变化
   */
  onFavoriteChange(eventId: string): void {
    this.viewModel.removeFavorite(eventId);
    this.syncViewModel();
  }
  
  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button() {
          Text('←')
            .fontSize(20)
            .fontColor($r('app.color.text_primary'))
        }
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .onClick(() => { this.onBack(); })
        
        Text($r('app.string.favorite_tab'))
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Row()
          .width(40)
      }
      .width('100%')
      .height(56)
      .padding({ left: 8, right: 8 })
      .backgroundColor($r('app.color.background_primary'))
      
      // 内容区域
      if (this.loadState === LoadState.LOADING) {
        Column() {
          LoadingProgress()
            .width(48)
            .height(48)
            .color($r('app.color.primary_color'))
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.favoriteEvents.length === 0) {
        EmptyStateView({ type: EmptyStateType.NO_FAVORITES })
      } else {
        List() {
          ForEach(this.favoriteEvents, (event: EventModel) => {
            ListItem() {
              EventCardView({
                event: event,
                isFavorite: true,
                onFavoriteChange: (eventId: string): void => { this.onFavoriteChange(eventId); }
              })
            }
          }, (event: EventModel) => event.id)
        }
        .width('100%')
        .layoutWeight(1)
        .divider({ strokeWidth: 1, color: $r('app.color.divider_color') })
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background_secondary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}
