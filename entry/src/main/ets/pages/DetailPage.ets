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

import { router } from '@kit.ArkUI';
import { common, Want } from '@kit.AbilityKit';
import { Logger } from '../common/Logger';
import { DeviceUtil } from '../common/DeviceUtil';
import { DeviceType } from '../common/Constants';
import { EventModel, EventStatus, Category, TimelineItem } from '../model/EventModel';
import { EventService } from '../service/EventService';
import { FavoriteService } from '../service/FavoriteService';
import { DetailParams } from '../model/RouteParams';

const TAG = 'DetailPage';

/**
 * 详情页面
 */
@Entry
@ComponentV2
struct DetailPage {
  @Local event: EventModel = new EventModel();
  @Local isFavorite: boolean = false;
  @Local isLoading: boolean = true;
  
  private eventId: string = '';
  
  aboutToAppear(): void {
    Logger.info(TAG, 'DetailPage aboutToAppear');
    
    // 获取路由参数
    const params = this.getUIContext().getRouter().getParams() as DetailParams;
    this.eventId = params?.eventId ?? '';
    
    Logger.info(TAG, 'Event ID: %{public}s', this.eventId);
    
    // 加载事件详情
    this.loadEventDetail();
  }
  
  /**
   * 加载事件详情
   */
  async loadEventDetail(): Promise<void> {
    this.isLoading = true;
    
    // 从EventService获取事件
    const events = await EventService.getEvents();
    for (let i = 0; i < events.length; i++) {
      if (events[i].id === this.eventId) {
        this.event = events[i];
        break;
      }
    }
    
    // 检查收藏状态
    this.isFavorite = FavoriteService.isFavorite(this.eventId);
    
    this.isLoading = false;
  }
  
  /**
   * 返回上一页
   */
  onBack(): void {
    this.getUIContext().getRouter().back();
  }
  
  /**
   * 打开外部链接
   */
  onOpenLink(): void {
    Logger.info(TAG, 'Opening link: %{public}s', this.event.url);
    
    try {
      // 使用UIContext获取UIAbilityContext
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      const want: Want = {
        action: 'ohos.want.action.viewData',
        uri: this.event.url
      };
      context.startAbility(want);
    } catch (err) {
      Logger.error(TAG, 'Failed to open link: %{public}s', JSON.stringify(err));
    }
  }
  
  /**
   * 切换收藏状态
   */
  onToggleFavorite(): void {
    this.isFavorite = FavoriteService.toggleFavorite(this.eventId);
  }
  
  /**
   * 分享事件
   */
  onShare(): void {
    Logger.info(TAG, 'Sharing event: %{public}s', this.event.id);
    
    try {
      // 构建分享内容
      const shareText = `${this.event.name}\n截止日期：${this.event.getFormattedDeadline()}\n${this.event.url}`;
      
      // 使用UIContext获取UIAbilityContext
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      const want: Want = {
        action: 'ohos.want.action.sendData',
        type: 'text/plain',
        parameters: {
          'ohos.extra.param.key.content': shareText
        }
      };
      context.startAbility(want);
    } catch (err) {
      Logger.error(TAG, 'Failed to share: %{public}s', JSON.stringify(err));
    }
  }
  
  build() {
    Column() {
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(48)
            .height(48)
            .color($r('app.color.primary_color'))
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor($r('app.color.background_primary'))
      } else if (DeviceUtil.getDeviceType() === DeviceType.WEARABLE) {
        // 手表简化详情页
        this.buildWearableDetail();
      } else {
        // 完整详情页
        this.buildFullDetail();
      }
    }
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
  
  /**
   * 手表简化详情页
   */
  @Builder
  buildWearableDetail(): void {
    Column() {
      // 导航栏
      Row() {
        Button() {
          Text('←')
            .fontSize(18)
            .fontColor($r('app.color.text_primary'))
        }
        .width(36)
        .height(36)
        .backgroundColor(Color.Transparent)
        .onClick(() => { this.onBack(); })
        
        Text('详情')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Row().width(36)
      }
      .width('100%')
      .height(48)
      .padding({ left: 8, right: 8 })
      
      // 内容
      Column() {
        Text(this.event.name)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .width('100%')
          .margin({ bottom: 12 })
        
        Text(this.event.getRemainingDaysText())
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getRemainingDaysColor())
          .margin({ bottom: 12 })
        
        if (this.event.url !== '') {
          Button('打开链接')
            .width('100%')
            .height(40)
            .fontSize(14)
            .fontColor('#FFFFFF')
            .backgroundColor($r('app.color.primary_color'))
            .borderRadius(20)
            .onClick(() => { this.onOpenLink(); })
        }
      }
      .width('100%')
      .padding(16)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background_primary'))
  }
  
  /**
   * 完整详情页
   */
  @Builder
  buildFullDetail(): void {
    Column() {
      // 顶部导航栏
      this.buildNavBar();
      
      // 内容区域
      Scroll() {
        Column() {
          // 事件标题
          Text(this.event.name)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .width('100%')
            .margin({ bottom: 12 })
          
          // 分类标签 + 年份/状态徽章
          Row() {
            Text(this.event.getCategoryName())
              .fontSize(12)
              .fontColor('#FFFFFF')
              .backgroundColor(this.getCategoryColor())
              .borderRadius(8)
              .padding({ left: 10, right: 10, top: 4, bottom: 4 })
            
            Blank()
            
            // 状态徽章
            if (this.event.status === EventStatus.EXPIRED) {
              Text('已结束')
                .fontSize(11)
                .fontColor('#FFFFFF')
                .backgroundColor($r('app.color.status_expired'))
                .borderRadius(8)
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            } else if (this.event.status === EventStatus.UPCOMING) {
              Text('即将截止')
                .fontSize(11)
                .fontColor('#FFFFFF')
                .backgroundColor($r('app.color.status_upcoming'))
                .borderRadius(8)
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            } else {
              Text('进行中')
                .fontSize(11)
                .fontColor('#FFFFFF')
                .backgroundColor($r('app.color.status_ongoing'))
                .borderRadius(8)
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            }
          }
          .width('100%')
          .margin({ bottom: 16 })
          
          // 信息区（日期范围 / 时区 / 地点 / 主办方）
          this.buildInfoSection()
          
          // 时间线（关键日期轴）
          this.buildTimeline();
          
          // 倒计时盒（下一个截止日期）
          this.buildCountdownBox();
          
          // 描述
          if (this.event.description !== '') {
            Column() {
              Text('描述')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.text_secondary'))
                .width('100%')
                .margin({ bottom: 8 })
              
              Text(this.event.description)
                .fontSize(16)
                .fontColor($r('app.color.text_primary'))
                .width('100%')
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .margin({ bottom: 16 })
          }
          
          // 标签
          if (this.event.tags.length > 0) {
            Column() {
              Text('标签')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.text_secondary'))
                .width('100%')
                .margin({ bottom: 8 })
              
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.event.tags, (tag: string) => {
                  Text(tag)
                    .fontSize(12)
                    .fontColor($r('app.color.primary_color'))
                    .backgroundColor('#1A007DFF')
                    .borderRadius(12)
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .margin({ right: 8, bottom: 8 })
                }, (tag: string) => tag)
              }
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .margin({ bottom: 16 })
          }
          
          // 操作按钮
          Row() {
            // 收藏按钮
            Button(this.isFavorite ? '取消收藏' : '收藏')
              .fontSize(14)
              .fontColor(this.isFavorite ? $r('app.color.favorite_active') : $r('app.color.text_primary'))
              .backgroundColor(this.isFavorite ? '#1AE84026' : $r('app.color.background_tertiary'))
              .borderRadius(8)
              .height(40)
              .flexGrow(1)
              .onClick(() => { this.onToggleFavorite(); })
            
            // 分享按钮
            Button('分享')
              .fontSize(14)
              .fontColor($r('app.color.text_primary'))
              .backgroundColor($r('app.color.background_tertiary'))
              .borderRadius(8)
              .height(40)
              .flexGrow(1)
              .margin({ left: 12 })
              .onClick(() => { this.onShare(); })
            
            // 打开链接按钮
            if (this.event.url !== '') {
              Button('打开官网')
                .fontSize(14)
                .fontColor('#FFFFFF')
                .backgroundColor($r('app.color.primary_color'))
                .borderRadius(8)
                .height(40)
                .flexGrow(1)
                .margin({ left: 12 })
                .onClick(() => { this.onOpenLink(); })
            }
          }
          .width('100%')
          .margin({ top: 24 })
        }
        .width('100%')
        .padding(16)
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background_primary'))
  }
  
  /**
   * 时间线：关键日期轴展示
   */
  @Builder
  buildTimeline(): void {
    if (this.event.timeline.length > 0) {
      Column() {
        Text('关键日期')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_secondary'))
          .width('100%')
          .margin({ bottom: 12 })
        
        ForEach(this.event.timeline, (item: TimelineItem, index: number) => {
          this.buildTimelineNode(item, index === this.getNearestTimelineIndex())
        }, (item: TimelineItem, index: number) => `${index}_${item.deadline}`)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .backgroundColor($r('app.color.background_secondary'))
      .borderRadius(12)
      .padding(16)
      .margin({ bottom: 16 })
    }
  }
  
  /**
   * 时间线节点
   */
  @Builder
  buildTimelineNode(item: TimelineItem, isCurrent: boolean): void {
    Row() {
      // 时间轴指示点
      Column() {
        Circle({ width: 12, height: 12 })
          .fill(isCurrent ? $r('app.color.primary_color') : $r('app.color.background_tertiary'))
      }
      .width(24)
      .alignItems(HorizontalAlign.Center)
      
      // 节点内容
      Column() {
        Text(item.getFormattedDate())
          .fontSize(16)
          .fontWeight(isCurrent ? FontWeight.Bold : FontWeight.Medium)
          .fontColor(isCurrent ? $r('app.color.primary_color') : $r('app.color.text_primary'))
          .width('100%')
        
        if (item.comment !== '') {
          Text(item.comment)
            .fontSize(13)
            .fontColor($r('app.color.text_secondary'))
            .width('100%')
            .margin({ top: 2 })
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      
      // 当前节点标记
      if (isCurrent) {
        Text('当前')
          .fontSize(11)
          .fontColor('#FFFFFF')
          .backgroundColor($r('app.color.primary_color'))
          .borderRadius(8)
          .padding({ left: 8, right: 8, top: 2, bottom: 2 })
      }
    }
    .width('100%')
    .margin({ bottom: 16 })
  }
  
  /**
   * 获取最近（当前）时间线节点下标
   */
  private getNearestTimelineIndex(): number {
    const now = Date.now();
    let nearestIndex = this.event.timeline.length - 1;
    for (let i = 0; i < this.event.timeline.length; i++) {
      const t = new Date(this.event.timeline[i].deadline).getTime();
      if (t >= now) {
        nearestIndex = i;
        break;
      }
    }
    return nearestIndex;
  }
  
  @Builder
  buildNavBar(): void {
    Row() {
      // 返回按钮
      Button() {
        Text('←')
          .fontSize(20)
          .fontColor($r('app.color.text_primary'))
      }
      .width(40)
      .height(40)
      .backgroundColor(Color.Transparent)
      .onClick(() => { this.onBack(); })
      
      Text('事件详情')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
      
      // 占位
      Row()
        .width(40)
    }
    .width('100%')
    .height(56)
    .padding({ left: 8, right: 8 })
  }
  
  @Builder
  buildInfoItem(label: string, value: string): void {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
        .width(80)
      
      Text(value)
        .fontSize(16)
        .fontColor($r('app.color.text_primary'))
        .layoutWeight(1)
    }
    .width('100%')
    .margin({ bottom: 12 })
  }
  
  /**
   * 信息区：日期范围 / 时区 / 地点 / 主办方（图标行样式，参考 oseddl-rn）
   */
  @Builder
  buildInfoSection(): void {
    Column() {
      if (this.event.date !== '') {
        this.buildInfoIconRow('📅', this.event.date)
      }
      if (this.event.timezone !== '') {
        this.buildInfoIconRow('🕐', this.event.timezone)
      }
      if (this.event.place !== '') {
        this.buildInfoIconRow('📍', this.event.place)
      }
      if (this.event.organizer !== '') {
        this.buildInfoIconRow('🏢', this.event.organizer)
      }
    }
    .width('100%')
    .backgroundColor($r('app.color.background_secondary'))
    .borderRadius(12)
    .padding(16)
    .margin({ bottom: 16 })
  }
  
  /**
   * 单行图标信息
   */
  @Builder
  buildInfoIconRow(icon: string, text: string): void {
    Row() {
      Text(icon)
        .fontSize(16)
        .margin({ right: 8 })
      Text(text)
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
        .layoutWeight(1)
    }
    .width('100%')
    .margin({ bottom: 8 })
  }
  
  /**
   * 倒计时盒：展示下一个截止日期（参考 oseddl-rn countdownBox）
   */
  @Builder
  buildCountdownBox(): void {
    Column() {
      if (this.event.status === EventStatus.EXPIRED) {
        // 已结束
        Column() {
          Text('活动已结束')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_secondary'))
            .margin({ bottom: 4 })
          Text('所有截止日期已过')
            .fontSize(12)
            .fontColor($r('app.color.text_tertiary'))
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      } else {
        // 下一个截止日期
        Column() {
          Text('下一个截止日期')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor('#9A3412')
            .margin({ bottom: 4 })
          if (this.event.timeline[this.getNearestTimelineIndex()] !== undefined && this.event.timeline[this.getNearestTimelineIndex()].comment !== '') {
            Text(this.event.timeline[this.getNearestTimelineIndex()].comment)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#7C2D12')
              .margin({ bottom: 4 })
          }
          Text(this.event.getFormattedDeadline() + ' (' + this.event.getRemainingDaysText() + ')')
            .fontSize(12)
            .fontColor('#C2410C')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .backgroundColor('#FFF7ED')
    .borderRadius(12)
    .border({ width: 2, color: '#FDBA74' })
    .padding(16)
    .margin({ bottom: 16 })
  }
  
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
