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
import { Category, EventStatus } from '../model/EventModel';

const TAG = 'FilterPanel';

/**
 * 分类选项接口
 */
interface CategoryOption {
  value: Category;
  label: string;
}

/**
 * 状态选项接口
 */
interface StatusOption {
  value: EventStatus;
  label: string;
}

/**
 * 筛选面板组件
 */
@ComponentV2
export struct FilterPanel {
  @Param onFilterChange: () => void = (): void => {};
  
  @Local selectedCategories: Category[] = [];
  @Local selectedStatuses: EventStatus[] = [];
  
  /**
   * 分类选项
   */
  private categoryOptions: CategoryOption[] = [
    { value: Category.HACKATHON, label: '黑客松' },
    { value: Category.CONFERENCE, label: '技术会议' },
    { value: Category.OPEN_SOURCE, label: '开源项目' },
    { value: Category.SCHOLARSHIP, label: '奖学金申请' },
    { value: Category.OTHER, label: '其他' }
  ];
  
  /**
   * 状态选项
   */
  private statusOptions: StatusOption[] = [
    { value: EventStatus.ONGOING, label: '进行中' },
    { value: EventStatus.UPCOMING, label: '即将截止' },
    { value: EventStatus.EXPIRED, label: '已截止' }
  ];
  
  /**
   * 切换分类选择
   */
  toggleCategory(category: Category): void {
    const index = this.selectedCategories.indexOf(category);
    if (index >= 0) {
      this.selectedCategories.splice(index, 1);
    } else {
      this.selectedCategories.push(category);
    }
  }
  
  /**
   * 切换状态选择
   */
  toggleStatus(status: EventStatus): void {
    const index = this.selectedStatuses.indexOf(status);
    if (index >= 0) {
      this.selectedStatuses.splice(index, 1);
    } else {
      this.selectedStatuses.push(status);
    }
  }
  
  /**
   * 重置筛选
   */
  resetFilter(): void {
    this.selectedCategories = [];
    this.selectedStatuses = [];
  }
  
  /**
   * 应用筛选
   */
  applyFilter(): void {
    Logger.info(TAG, 'Apply filter: categories=%{public}d, statuses=%{public}d', 
      this.selectedCategories.length.toString(), this.selectedStatuses.length.toString());
    this.onFilterChange();
  }
  
  build() {
    Column() {
      // 标题
      Row() {
        Text('筛选条件')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
        
        Blank()
        
        Button('重置')
          .fontSize(14)
          .fontColor($r('app.color.primary_color'))
          .backgroundColor(Color.Transparent)
          .onClick(() => { this.resetFilter(); })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 16 })
      
      Divider().color($r('app.color.divider_color'))
      
      // 分类筛选
      Column() {
        Text('事件分类')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .width('100%')
          .margin({ bottom: 12 })
        
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.categoryOptions, (option: CategoryOption) => {
            this.buildFilterChip(option.label, this.selectedCategories.includes(option.value), () => {
              this.toggleCategory(option.value);
            })
          }, (option: CategoryOption) => option.value)
        }
        .width('100%')
      }
      .width('100%')
      .padding(16)
      .alignItems(HorizontalAlign.Start)
      
      // 状态筛选
      Column() {
        Text('事件状态')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .width('100%')
          .margin({ bottom: 12 })
        
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.statusOptions, (option: StatusOption) => {
            this.buildFilterChip(option.label, this.selectedStatuses.includes(option.value), () => {
              this.toggleStatus(option.value);
            })
          }, (option: StatusOption) => option.value)
        }
        .width('100%')
      }
      .width('100%')
      .padding(16)
      .alignItems(HorizontalAlign.Start)
      
      Blank()
      
      // 应用按钮
      Button('应用筛选')
        .width('100%')
        .height(48)
        .fontSize(16)
        .fontColor('#FFFFFF')
        .backgroundColor($r('app.color.primary_color'))
        .borderRadius(24)
        .margin({ left: 16, right: 16, bottom: 24 })
        .onClick(() => { this.applyFilter(); })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background_primary'))
  }
  
  @Builder
  buildFilterChip(label: string, isSelected: boolean, onClick: () => void): void {
    Button(label)
      .fontSize(14)
      .fontColor(isSelected ? '#FFFFFF' : $r('app.color.text_primary'))
      .backgroundColor(isSelected ? $r('app.color.primary_color') : $r('app.color.background_tertiary'))
      .borderRadius(16)
      .height(32)
      .padding({ left: 16, right: 16 })
      .margin({ right: 8, bottom: 8 })
      .onClick(onClick)
  }
}
