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

import { DeviceType } from '../common/Constants';
import { EventModel, EventStatus, Category } from '../model/EventModel';

/**
 * 事件卡片基础组件
 * 支持多设备自适应布局
 */
@ComponentV2
export struct EventCard {
  @Param event: EventModel = new EventModel();
  @Param isFavorite: boolean = false;
  @Param deviceType: DeviceType = DeviceType.PHONE;
  @Param onFavoriteClick: () => void = (): void => {};
  @Param onCardClick: () => void = (): void => {};
  
  build() {
    if (this.deviceType === DeviceType.WEARABLE) {
      // 手表设备：简化卡片
      this.buildWearableCard();
    } else {
      // 手机/平板/PC：完整卡片
      this.buildFullCard();
    }
  }
  
  /**
   * 手表简化卡片
   */
  @Builder
  buildWearableCard(): void {
    Column() {
      Row() {
        // 事件名称
        Text(this.event.name)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
        
        // 剩余天数
        Text(this.event.getRemainingDaysText())
          .fontSize(12)
          .fontColor(this.getRemainingDaysColor())
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .padding(12)
    }
    .width('100%')
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(8)
    .onClick(() => { this.onCardClick(); })
  }
  
  /**
   * 完整卡片
   */
  @Builder
  buildFullCard(): void {
    Column() {
      // 顶部：标题和收藏按钮
      Row() {
        Text(this.event.name)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
        
        // 收藏按钮
        Button() {
          Text(this.isFavorite ? '★' : '☆')
            .fontSize(20)
            .fontColor(this.isFavorite ? $r('app.color.favorite_active') : $r('app.color.favorite_inactive'))
        }
        .width(36)
        .height(36)
        .backgroundColor(Color.Transparent)
        .onClick(() => { this.onFavoriteClick(); })
      }
      .width('100%')
      .margin({ bottom: 8 })
      
      // 中部：状态和分类标签
      Row() {
        // 状态标签
        Text(this.event.getStatusName())
          .fontSize(12)
          .fontColor('#FFFFFF')
          .backgroundColor(this.getStatusColor())
          .borderRadius(4)
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
        
        // 分类标签
        Text(this.event.getCategoryName())
          .fontSize(12)
          .fontColor('#FFFFFF')
          .backgroundColor(this.getCategoryColor())
          .borderRadius(4)
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .margin({ left: 6 })
        
        Blank()
        
        // 剩余天数
        Text(this.event.getRemainingDaysText())
          .fontSize(14)
          .fontColor(this.getRemainingDaysColor())
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .margin({ bottom: 8 })
      
      // 底部：时间范围/截止日期和主办方
      Row() {
        Text(this.event.date !== '' ? this.event.date : ('截止: ' + this.event.getFormattedDeadline()))
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
        
        if (this.event.organizer !== '') {
          Text(this.event.organizer)
            .fontSize(12)
            .fontColor($r('app.color.text_tertiary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(12)
    .shadow({
      radius: 8,
      color: $r('app.color.card_shadow'),
      offsetX: 0,
      offsetY: 2
    })
    .onClick(() => { this.onCardClick(); })
  }
  
  /**
   * 获取状态颜色
   */
  private getStatusColor(): ResourceColor {
    switch (this.event.status) {
      case EventStatus.ONGOING:
        return $r('app.color.status_ongoing');
      case EventStatus.UPCOMING:
        return $r('app.color.status_upcoming');
      case EventStatus.EXPIRED:
        return $r('app.color.status_expired');
      default:
        return $r('app.color.text_tertiary');
    }
  }
  
  /**
   * 获取分类颜色
   */
  private getCategoryColor(): ResourceColor {
    switch (this.event.category) {
      case Category.HACKATHON:
        return $r('app.color.category_hackathon');
      case Category.CONFERENCE:
        return $r('app.color.category_conference');
      case Category.OPEN_SOURCE:
        return $r('app.color.category_open_source');
      case Category.SCHOLARSHIP:
        return $r('app.color.category_scholarship');
      default:
        return $r('app.color.category_other');
    }
  }
  
  /**
   * 获取剩余天数颜色
   */
  private getRemainingDaysColor(): ResourceColor {
    if (this.event.remainingDays <= 0) {
      return $r('app.color.status_expired');
    } else if (this.event.remainingDays <= 7) {
      return $r('app.color.status_upcoming');
    } else {
      return $r('app.color.status_ongoing');
    }
  }
}
