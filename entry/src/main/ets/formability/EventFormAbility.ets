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

import { formBindingData, FormExtensionAbility } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { EventService } from '../service/EventService';
import { EventModel } from '../model/EventModel';
import { Constants } from '../common/Constants';

const DOMAIN = 0x0000;
const TAG = 'EventFormAbility';

/**
 * 服务卡片Ability
 */
export default class EventFormAbility extends FormExtensionAbility {
  /**
   * 卡片添加时调用
   */
  onAddForm(want: Want): formBindingData.FormBindingData {
    hilog.info(DOMAIN, TAG, 'onAddForm called');
    
    // 获取即将到来的事件
    const upcomingEvents = this.getUpcomingEvents();
    
    // 构建卡片数据
    const formData: Record<string, Object> = {
      'events': this.formatEventsForCard(upcomingEvents),
      'count': upcomingEvents.length,
      'updateTime': new Date().toLocaleString()
    };
    
    return formBindingData.createFormBindingData(formData);
  }
  
  /**
   * 卡片更新时调用
   */
  onUpdateForm(formId: string): formBindingData.FormBindingData {
    hilog.info(DOMAIN, TAG, 'onUpdateForm called, formId: %{public}s', formId);
    
    // 获取即将到来的事件
    const upcomingEvents = this.getUpcomingEvents();
    
    // 构建卡片数据
    const formData: Record<string, Object> = {
      'events': this.formatEventsForCard(upcomingEvents),
      'count': upcomingEvents.length,
      'updateTime': new Date().toLocaleString()
    };
    
    return formBindingData.createFormBindingData(formData);
  }
  
  /**
   * 卡片移除时调用
   */
  onRemoveForm(formId: string): void {
    hilog.info(DOMAIN, TAG, 'onRemoveForm called, formId: %{public}s', formId);
  }
  
  /**
   * 卡片事件处理
   */
  onFormEvent(formId: string, message: string): void {
    hilog.info(DOMAIN, TAG, 'onFormEvent called, formId: %{public}s, message: %{public}s', formId, message);
  }
  
  /**
   * 获取即将到来的事件
   */
  private getUpcomingEvents(): EventModel[] {
    try {
      return EventService.getUpcomingEvents(Constants.FORM_DISPLAY_COUNT);
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'Failed to get upcoming events: %{public}s', JSON.stringify(err));
      return [];
    }
  }
  
  /**
   * 格式化事件数据用于卡片显示
   */
  private formatEventsForCard(events: EventModel[]): Record<string, string>[] {
    return events.map((event: EventModel) => {
      return {
        'id': event.id,
        'name': event.name,
        'remainingDays': event.getRemainingDaysText(),
        'deadline': event.getFormattedDeadline()
      };
    });
  }
}
