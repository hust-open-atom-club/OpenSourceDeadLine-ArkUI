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
import { HttpUtil, HttpResponse } from '../common/HttpUtil';
import { EventRepository } from '../data/EventRepository';
import { EventModel, EventApiResponse, Category, EventStatus, TimelineItem } from '../model/EventModel';

/**
 * 加载状态枚举
 */
export enum LoadState {
  IDLE = 'idle',
  LOADING = 'loading',
  SUCCESS = 'success',
  ERROR = 'error'
}

/**
 * 事件服务
 * 负责网络请求、缓存策略、数据解析
 */
export class EventService {
  private static readonly TAG: string = 'EventService';
  
  /**
   * 获取事件列表
   * @param forceRefresh 是否强制刷新
   */
  static async getEvents(forceRefresh: boolean = false): Promise<EventModel[]> {
    Logger.info(EventService.TAG, 'getEvents called, forceRefresh: %{public}s', forceRefresh.toString());
    
    // 检查缓存
    if (!forceRefresh && EventRepository.isCacheValid()) {
      Logger.info(EventService.TAG, 'Using cached events');
      return EventRepository.getAllEvents();
    }
    
    // 从网络获取
    Logger.info(EventService.TAG, 'Fetching events from network, URL: %{public}s', Constants.API_BASE_URL);
    const events = await EventService.fetchFromNetwork();
    
    Logger.info(EventService.TAG, 'fetchFromNetwork returned %{public}d events', events.length.toString());
    
    if (events.length > 0) {
      // 保存到缓存
      EventRepository.saveToCache(events);
      return events;
    } else {
      // 网络失败，返回缓存数据
      Logger.warn(EventService.TAG, 'Network failed, using cache');
      return EventRepository.loadFromCache();
    }
  }
  
  /**
   * 从网络获取事件
   */
  private static async fetchFromNetwork(): Promise<EventModel[]> {
    Logger.info(EventService.TAG, 'fetchFromNetwork started');
    
    try {
      Logger.info(EventService.TAG, 'Sending HTTP GET request to: %{public}s', Constants.API_BASE_URL);
      const response = await HttpUtil.get<Object>(Constants.API_BASE_URL);
      
      Logger.info(EventService.TAG, 'HTTP response received: %{public}s', response !== undefined ? 'success' : 'undefined');
      
      if (response === undefined) {
        Logger.error(EventService.TAG, 'HTTP request failed - response is undefined');
        return [];
      }
      
      // API返回的是数组格式，每个项目包含events子数组
      let dataArray: Object[];
      if (Array.isArray(response)) {
        Logger.info(EventService.TAG, 'Response is array, length: %{public}d', response.length.toString());
        dataArray = response;
      } else if (response !== null && typeof response === 'object') {
        const responseObj = response as Record<string, Object>;
        const dataField = responseObj['data'];
        if (dataField !== undefined && Array.isArray(dataField)) {
          Logger.info(EventService.TAG, 'Response.data is array, length: %{public}d', dataField.length.toString());
          dataArray = dataField;
        } else {
          Logger.error(EventService.TAG, 'Invalid data field in API response');
          return [];
        }
      } else {
        Logger.error(EventService.TAG, 'Invalid API response format');
        return [];
      }
      
      // 解析数据
      const events: EventModel[] = [];
      
      Logger.info(EventService.TAG, 'Starting to parse %{public}d projects', dataArray.length.toString());
      
      for (let i = 0; i < dataArray.length; i++) {
        const project = dataArray[i] as Record<string, Object>;
        
        // 获取项目基本信息
        const title = (project['title'] as string) ?? '';
        const description = (project['description'] as string) ?? '';
        const categoryStr = (project['category'] as string) ?? 'other';
        const tags = project['tags'];
        const tagsArray = Array.isArray(tags) ? (tags as string[]) : [];
        // 人类可读日期范围与地点（项目级字段）
        const projectDate = (project['date'] as string) ?? '';
        const projectPlace = (project['place'] as string) ?? '';
        const projectTimezone = (project['timezone'] as string) ?? '';
        
        // 获取events数组
        const projectEvents = project['events'];
        if (Array.isArray(projectEvents)) {
          Logger.info(EventService.TAG, 'Project "%{public}s" has %{public}d events', title, projectEvents.length.toString());
          
          // 遍历每个年份的事件
          for (let j = 0; j < projectEvents.length; j++) {
            const yearEvent = projectEvents[j] as Record<string, Object>;
            
            const eventId = (yearEvent['id'] as string) ?? '';
            const link = (yearEvent['link'] as string) ?? '';
            const timeline = yearEvent['timeline'];
            
            // 解析完整时间线（多个关键日期，每个带说明）
            const timelineItems: TimelineItem[] = [];
            if (Array.isArray(timeline)) {
              for (let k = 0; k < timeline.length; k++) {
                const timeItem = timeline[k] as Record<string, Object>;
                const deadlineStr = (timeItem['deadline'] as string) ?? '';
                const commentStr = (timeItem['comment'] as string) ?? '';
                timelineItems.push(new TimelineItem(deadlineStr, commentStr));
              }
            }
            
            // 找到最近的deadline
            let nearestDeadline = '';
            let deadlineComment = '';
            if (Array.isArray(timeline)) {
              const now = Date.now();
              let nearestTime = Infinity;
              
              for (let k = 0; k < timeline.length; k++) {
                const timeItem = timeline[k] as Record<string, Object>;
                const deadline = (timeItem['deadline'] as string) ?? '';
                const comment = (timeItem['comment'] as string) ?? '';
                const deadlineTime = new Date(deadline).getTime();
                
                // 找到最近的未来deadline
                if (deadlineTime > now && deadlineTime < nearestTime) {
                  nearestTime = deadlineTime;
                  nearestDeadline = deadline;
                  deadlineComment = comment;
                }
              }
              
              // 如果没有未来的deadline，使用最后一个
              if (nearestDeadline === '' && timeline.length > 0) {
                const lastItem = timeline[timeline.length - 1] as Record<string, Object>;
                nearestDeadline = (lastItem['deadline'] as string) ?? '';
              }
            }
            
            // 创建EventModel
            const event = new EventModel();
            event.id = eventId;
            event.name = title;
            event.description = description + (deadlineComment !== '' ? `\n${deadlineComment}` : '');
            event.deadline = nearestDeadline;
            event.category = EventService.parseCategory(categoryStr);
            event.organizer = '';
            event.url = link;
            event.tags = tagsArray;
            event.cover = '';
            // 完整时间线 + 项目级信息
            event.timeline = timelineItems;
            event.date = projectDate;
            event.place = projectPlace;
            event.timezone = projectTimezone;
            
            // 计算状态
            event.calculateStatus();
            
            events.push(event);
            
            Logger.info(EventService.TAG, 'Parsed event: %{public}s, deadline: %{public}s', eventId, nearestDeadline);
          }
        }
      }
      
      Logger.info(EventService.TAG, 'Successfully parsed %{public}d events', events.length.toString());
      return events;
      
    } catch (err) {
      Logger.error(EventService.TAG, 'Failed to fetch events: %{public}s', JSON.stringify(err));
      return [];
    }
  }
  
  /**
   * 解析分类字符串
   */
  private static parseCategory(categoryStr: string): Category {
    switch (categoryStr.toLowerCase()) {
      case 'hackathon':
        return Category.HACKATHON;
      case 'conference':
        return Category.CONFERENCE;
      case 'open_source':
      case 'opensource':
        return Category.OPEN_SOURCE;
      case 'scholarship':
        return Category.SCHOLARSHIP;
      default:
        return Category.OTHER;
    }
  }
  
  /**
   * 根据ID获取事件详情
   */
  static getEventById(id: string): EventModel | undefined {
    return EventRepository.getEventById(id);
  }
  
  /**
   * 获取即将到来的事件（用于服务卡片）
   */
  static getUpcomingEvents(count: number = Constants.FORM_DISPLAY_COUNT): EventModel[] {
    return EventRepository.getUpcomingEvents(count);
  }
  
  /**
   * 检查是否为离线模式
   */
  static isOfflineMode(): boolean {
    return EventRepository.getAllEvents().length > 0 && !EventRepository.isCacheValid();
  }
  
  /**
   * 刷新事件数据
   */
  static async refreshEvents(): Promise<EventModel[]> {
    return EventService.getEvents(true);
  }
}
