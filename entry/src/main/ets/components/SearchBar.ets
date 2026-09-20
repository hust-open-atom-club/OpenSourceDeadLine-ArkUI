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

const TAG = 'SearchBar';

/**
 * 搜索栏组件
 * 支持防抖搜索
 */
@ComponentV2
export struct SearchBar {
  @Param keyword: string = '';
  @Param placeholder: string = '搜索...';
  @Param onKeywordChange: (keyword: string) => void = (_: string): void => {};
  
  @Local inputValue: string = '';
  
  // 防抖定时器
  private debounceTimer: number = 0;
  
  aboutToAppear(): void {
    this.inputValue = this.keyword;
  }
  
  /**
   * 输入变化处理（带防抖）
   */
  onInputChange(value: string): void {
    this.inputValue = value;
    
    // 清除之前的定时器
    if (this.debounceTimer !== 0) {
      clearTimeout(this.debounceTimer);
    }
    
    // 设置新的防抖定时器
    this.debounceTimer = setTimeout(() => {
      Logger.info(TAG, 'Search keyword: %{public}s', this.inputValue);
      this.onKeywordChange(this.inputValue);
    }, Constants.REFRESH_DEBOUNCE);
  }
  
  /**
   * 清空搜索
   */
  onClear(): void {
    this.inputValue = '';
    this.onKeywordChange('');
  }
  
  build() {
    Row() {
      // 搜索图标
      Text('🔍')
        .fontSize(18)
        .margin({ left: 12, right: 8 })
      
      // 输入框
      TextInput({ text: $$this.inputValue, placeholder: this.placeholder })
        .layoutWeight(1)
        .height(40)
        .backgroundColor(Color.Transparent)
        .placeholderColor($r('app.color.text_tertiary'))
        .placeholderFont({ size: 14 })
        .fontColor($r('app.color.text_primary'))
        .fontSize(14)
        .onChange((value: string) => { this.onInputChange(value); })
        .onSubmit(() => { this.onKeywordChange(this.inputValue); })
      
      // 清空按钮
      if (this.inputValue !== '') {
        Button() {
          Text('✕')
            .fontSize(16)
            .fontColor($r('app.color.text_tertiary'))
        }
        .width(32)
        .height(32)
        .backgroundColor(Color.Transparent)
        .margin({ right: 8 })
        .onClick(() => { this.onClear(); })
      }
    }
    .width('100%')
    .height(48)
    .backgroundColor($r('app.color.background_primary'))
    .borderRadius(24)
    .margin({ left: 16, right: 16, top: 8, bottom: 8 })
    .shadow({
      radius: 4,
      color: $r('app.color.card_shadow'),
      offsetX: 0,
      offsetY: 1
    })
  }
}
