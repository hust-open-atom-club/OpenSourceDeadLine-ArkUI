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

import { Category, EventStatus } from './EventModel';

/**
 * 筛选条件模型
 */
export class FilterModel {
  keyword: string = '';
  categories: Category[] = [];
  statuses: EventStatus[] = [];
  
  /**
   * 是否有筛选条件
   */
  hasFilter(): boolean {
    return this.keyword !== '' || this.categories.length > 0 || this.statuses.length > 0;
  }
  
  /**
   * 重置筛选条件
   */
  reset(): void {
    this.keyword = '';
    this.categories = [];
    this.statuses = [];
  }
  
  /**
   * 克隆筛选条件
   */
  clone(): FilterModel {
    const cloned = new FilterModel();
    cloned.keyword = this.keyword;
    cloned.categories = this.categories.slice();
    cloned.statuses = this.statuses.slice();
    return cloned;
  }
}

/**
 * 默认筛选条件
 */
export const DEFAULT_FILTER: FilterModel = new FilterModel();
