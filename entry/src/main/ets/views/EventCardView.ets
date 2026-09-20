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
import { DeviceType } from '../common/Constants';
import { DeviceUtil } from '../common/DeviceUtil';
import { EventModel, EventStatus, Category } from '../model/EventModel';
import { EventCard } from '../components/EventCard';
import { DetailParams } from '../model/RouteParams';

const TAG = 'EventCardView';

/**
 * 事件卡片视图
 * 封装EventCard，处理点击事件和收藏状态
 */
@ComponentV2
export struct EventCardView {
  @Param event: EventModel = new EventModel();
  @Param isFavorite: boolean = false;
  @Param onFavoriteChange: (eventId: string) => void = (_: string): void => {};
  
  /**
   * 点击事件卡片，跳转到详情页
   */
  onCardClick(): void {
    Logger.info(TAG, 'Card clicked: %{public}s', this.event.id);
    
    try {
      // 跳转到详情页
      const params: DetailParams = { eventId: this.event.id };
      this.getUIContext().getRouter().pushUrl({ url: 'pages/DetailPage', params: params });
    } catch (err) {
      Logger.error(TAG, 'Failed to navigate to detail page: %{public}s', JSON.stringify(err));
    }
  }
  
  /**
   * 点击收藏按钮
   */
  onFavoriteClick(): void {
    Logger.info(TAG, 'Favorite clicked: %{public}s', this.event.id);
    this.onFavoriteChange(this.event.id);
  }
  
  build() {
    EventCard({
      event: this.event,
      isFavorite: this.isFavorite,
      deviceType: DeviceUtil.getDeviceType(),
      onFavoriteClick: (): void => { this.onFavoriteClick(); },
      onCardClick: (): void => { this.onCardClick(); }
    })
  }
}
