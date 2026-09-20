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

import { Constants } from '../common/Constants';

/**
 * 事件分类枚举
 */
export enum Category {
  HACKATHON = 'hackathon',
  CONFERENCE = 'conference',
  OPEN_SOURCE = 'open_source',
  SCHOLARSHIP = 'scholarship',
  OTHER = 'other'
}

/**
 * 事件状态枚举
 */
export enum EventStatus {
  ONGOING = 'ongoing',
  UPCOMING = 'upcoming',
  EXPIRED = 'expired'
}

/**
 * 时间线节点（关键日期）
 */
export class TimelineItem {
  deadline: string = ''; // ISO 8601 关键日期
  comment: string = '';  // 日期说明，如"项目申请书提交"
  
  constructor(deadline: string = '', comment: string = '') {
    this.deadline = deadline;
    this.comment = comment;
  }
  
  /**
   * 格式化节点日期为 YYYY-MM-DD
   */
  getFormattedDate(): string {
    const date = new Date(this.deadline);
    if (isNaN(date.getTime())) {
      return '';
    }
    const year = date.getFullYear();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    return `${year}-${month}-${day}`;
  }
}

/**
 * 事件数据模型
 */
export class EventModel {
  id: string = '';
  name: string = '';
  description: string = '';
  deadline: string = '';
  category: Category = Category.OTHER;
  status: EventStatus = EventStatus.ONGOING;
  organizer: string = '';
  url: string = '';
  tags: string[] = [];
  cover: string = '';
  remainingDays: number = 0;
  
  // 时间线（完整关键日期，参考 oseddl 数据结构）
  timeline: TimelineItem[] = [];
  // 人类可读日期范围，如 "2025 年 4 月 30 日" 或 "2025年4月30日 - 9月30日"
  date: string = '';
  // 活动地点，如 "中国，上海" 或 "线上"
  place: string = '';
  // 所在时区，如 "Asia/Shanghai"
  timezone: string = '';
  
  /**
   * 计算事件状态和剩余天数
   */
  calculateStatus(): void {
    const now = Date.now();
    const deadlineTime = new Date(this.deadline).getTime();
    const diffDays = Math.ceil((deadlineTime - now) / (1000 * 60 * 60 * 24));
    
    this.remainingDays = diffDays;
    
    if (diffDays <= 0) {
      this.status = EventStatus.EXPIRED;
    } else if (diffDays <= Constants.UPCOMING_THRESHOLD_DAYS) {
      this.status = EventStatus.UPCOMING;
    } else {
      this.status = EventStatus.ONGOING;
    }
  }
  
  /**
   * 获取分类显示名称
   */
  getCategoryName(): string {
    switch (this.category) {
      case Category.HACKATHON:
        return '黑客松';
      case Category.CONFERENCE:
        return '技术会议';
      case Category.OPEN_SOURCE:
        return '开源项目';
      case Category.SCHOLARSHIP:
        return '奖学金申请';
      case Category.OTHER:
      default:
        return '其他';
    }
  }
  
  /**
   * 获取状态显示名称
   */
  getStatusName(): string {
    switch (this.status) {
      case EventStatus.ONGOING:
        return '进行中';
      case EventStatus.UPCOMING:
        return '即将截止';
      case EventStatus.EXPIRED:
        return '已截止';
      default:
        return '';
    }
  }
  
  /**
   * 格式化截止日期
   */
  getFormattedDeadline(): string {
    const date = new Date(this.deadline);
    const year = date.getFullYear();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    return `${year}-${month}-${day}`;
  }
  
  /**
   * 获取剩余天数文本
   */
  getRemainingDaysText(): string {
    if (this.remainingDays <= 0) {
      return '已截止';
    } else if (this.remainingDays === 1) {
      return '剩余1天';
    } else {
      return `剩余${this.remainingDays}天`;
    }
  }
  
  /**
   * 从JSON对象创建EventModel
   */
  static fromJson(json: Record<string, Object>): EventModel {
    const event = new EventModel();
    event.id = (json['id'] as string) ?? '';
    event.name = (json['name'] as string) ?? '';
    event.description = (json['description'] as string) ?? '';
    event.deadline = (json['deadline'] as string) ?? '';
    event.organizer = (json['organizer'] as string) ?? '';
    event.url = (json['url'] as string) ?? '';
    event.cover = (json['cover'] as string) ?? '';
    
    // 解析分类
    const categoryStr = json['category'] as string;
    if (categoryStr !== undefined) {
      event.category = EventModel.parseCategoryString(categoryStr);
    }
    
    // 解析标签
    const tags = json['tags'];
    if (Array.isArray(tags)) {
      event.tags = tags as string[];
    }
    
    // 计算状态
    event.calculateStatus();
    
    return event;
  }
  
  /**
   * 解析分类字符串
   */
  private static parseCategoryString(categoryStr: string): Category {
    switch (categoryStr.toUpperCase()) {
      case 'HACKATHON':
        return Category.HACKATHON;
      case 'CONFERENCE':
        return Category.CONFERENCE;
      case 'OPEN_SOURCE':
      case 'OPENSOURCE':
        return Category.OPEN_SOURCE;
      case 'SCHOLARSHIP':
        return Category.SCHOLARSHIP;
      default:
        return Category.OTHER;
    }
  }
}

/**
 * API响应数据接口
 */
export interface EventApiResponse {
  id: string;
  name: string;
  description: string;
  deadline: string;
  category: string;
  organizer: string;
  url: string;
  tags: string[];
  cover?: string;
}
