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

/**
 * 空状态类型
 */
export enum EmptyStateType {
  NO_EVENTS = 'no_events',
  NO_RESULTS = 'no_results',
  NO_FAVORITES = 'no_favorites',
  NETWORK_ERROR = 'network_error'
}

/**
 * 空状态配置接口
 */
export interface EmptyStateConfig {
  icon: string;
  title: string;
  description: string;
}

/**
 * 空状态视图
 */
@ComponentV2
export struct EmptyStateView {
  @Param type: EmptyStateType = EmptyStateType.NO_EVENTS;
  @Param message: string = '';
  @Param onRetry: (() => void) | undefined = undefined;
  
  /**
   * 获取空状态配置
   */
  private getConfig(): EmptyStateConfig {
    switch (this.type) {
      case EmptyStateType.NO_EVENTS:
        return {
          icon: '📅',
          title: '暂无事件数据',
          description: '请检查网络连接后重试'
        };
      case EmptyStateType.NO_RESULTS:
        return {
          icon: '🔍',
          title: '未找到匹配的事件',
          description: '请尝试其他搜索关键词或筛选条件'
        };
      case EmptyStateType.NO_FAVORITES:
        return {
          icon: '⭐',
          title: '暂无收藏事件',
          description: '点击事件卡片上的收藏按钮添加收藏'
        };
      case EmptyStateType.NETWORK_ERROR:
        return {
          icon: '⚠️',
          title: '网络连接失败',
          description: '请检查网络连接后重试'
        };
      default:
        return {
          icon: '📭',
          title: '暂无数据',
          description: ''
        };
    }
  }
  
  /**
   * 是否显示重试按钮
   */
  private shouldShowRetry(): boolean {
    return this.type === EmptyStateType.NETWORK_ERROR || 
           this.type === EmptyStateType.NO_EVENTS ||
           this.onRetry !== undefined;
  }
  
  build() {
    Column() {
      // 图标
      Text(this.getConfig().icon)
        .fontSize(48)
        .margin({ bottom: 16 })
      
      // 标题
      Text(this.getConfig().title)
        .fontSize(18)
        .fontColor($r('app.color.text_primary'))
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 8 })
      
      // 描述
      if (this.getConfig().description !== '') {
        Text(this.getConfig().description)
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .textAlign(TextAlign.Center)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      
      // 自定义消息
      if (this.message !== '') {
        Text(this.message)
          .fontSize(12)
          .fontColor($r('app.color.text_tertiary'))
          .margin({ top: 8 })
      }
      
      // 重试按钮
      if (this.shouldShowRetry() && this.onRetry !== undefined) {
        Button('重试')
          .fontSize(14)
          .fontColor($r('app.color.text_primary'))
          .backgroundColor($r('app.color.primary_color'))
          .borderRadius(20)
          .height(40)
          .width(120)
          .margin({ top: 24 })
          .onClick(() => {
            if (this.onRetry !== undefined) {
              this.onRetry();
            }
          })
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding(32)
  }
}
