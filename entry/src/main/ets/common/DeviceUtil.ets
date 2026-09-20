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

import { display } from '@kit.ArkUI';
import { Logger } from './Logger';
import { DeviceType, Breakpoints } from './Constants';

/**
 * 设备信息接口
 */
export interface DeviceInfo {
  type: DeviceType;
  width: number;
  height: number;
  density: number;
  breakpoint: string;
}

/**
 * 设备适配工具类
 */
export class DeviceUtil {
  private static readonly TAG: string = 'DeviceUtil';
  private static deviceInfo: DeviceInfo | undefined = undefined;
  
  /**
   * 初始化设备信息
   */
  static init(): void {
    try {
      const displayInfo = display.getDefaultDisplaySync();
      const width = displayInfo.width;
      const height = displayInfo.height;
      const density = displayInfo.densityPixels;
      
      // 判断设备类型
      let deviceType: DeviceType = DeviceType.PHONE;
      const screenWidthVp = px2vp(width);
      const screenHeightVp = px2vp(height);
      const minDimension = Math.min(screenWidthVp, screenHeightVp);
      
      if (minDimension < Breakpoints.SM_BREAKPOINT) {
        deviceType = DeviceType.WEARABLE;
      } else if (minDimension >= Breakpoints.MD_BREAKPOINT) {
        deviceType = DeviceType.TABLET;
      }
      
      // 判断断点
      let breakpoint: string = Breakpoints.SM;
      if (screenWidthVp >= Breakpoints.MD_BREAKPOINT) {
        breakpoint = Breakpoints.LG;
      } else if (screenWidthVp >= Breakpoints.SM_BREAKPOINT) {
        breakpoint = Breakpoints.MD;
      }
      
      DeviceUtil.deviceInfo = {
        type: deviceType,
        width: width,
        height: height,
        density: density,
        breakpoint: breakpoint
      };
      
      Logger.info(DeviceUtil.TAG, 'Device initialized: %{public}s, breakpoint: %{public}s', deviceType, breakpoint);
    } catch (err) {
      Logger.error(DeviceUtil.TAG, 'Failed to init device info: %{public}s', JSON.stringify(err));
      // 默认值
      DeviceUtil.deviceInfo = {
        type: DeviceType.PHONE,
        width: 1080,
        height: 1920,
        density: 3,
        breakpoint: Breakpoints.MD
      };
    }
  }
  
  /**
   * 获取设备信息
   */
  static getDeviceInfo(): DeviceInfo {
    if (DeviceUtil.deviceInfo === undefined) {
      DeviceUtil.init();
    }
    return DeviceUtil.deviceInfo!;
  }
  
  /**
   * 获取设备类型
   */
  static getDeviceType(): DeviceType {
    return DeviceUtil.getDeviceInfo().type;
  }
  
  /**
   * 获取当前断点
   */
  static getBreakpoint(): string {
    return DeviceUtil.getDeviceInfo().breakpoint;
  }
  
  /**
   * 是否为手表设备
   */
  static isWearable(): boolean {
    return DeviceUtil.getDeviceType() === DeviceType.WEARABLE;
  }
  
  /**
   * 是否为手机设备
   */
  static isPhone(): boolean {
    return DeviceUtil.getDeviceType() === DeviceType.PHONE;
  }
  
  /**
   * 是否为平板设备
   */
  static isTablet(): boolean {
    return DeviceUtil.getDeviceType() === DeviceType.TABLET;
  }
  
  /**
   * 是否为PC设备
   */
  static isPC(): boolean {
    return DeviceUtil.getDeviceType() === DeviceType.PC;
  }
  
  /**
   * 获取列表列数
   */
  static getListColumns(): number {
    const breakpoint = DeviceUtil.getBreakpoint();
    if (breakpoint === Breakpoints.SM) {
      return 1;
    } else if (breakpoint === Breakpoints.MD) {
      return 1;
    } else {
      return 2;
    }
  }
  
  /**
   * 获取卡片宽度
   */
  static getCardWidth(): string {
    const columns = DeviceUtil.getListColumns();
    if (columns === 1) {
      return '100%';
    } else {
      return '50%';
    }
  }
  
  /**
   * 获取内容内边距
   */
  static getContentPadding(): number {
    const breakpoint = DeviceUtil.getBreakpoint();
    if (breakpoint === Breakpoints.SM) {
      return 12;
    } else if (breakpoint === Breakpoints.MD) {
      return 16;
    } else {
      return 24;
    }
  }
}

/**
 * px转vp (使用display density)
 */
function px2vp(px: number): number {
  try {
    const displayInfo = display.getDefaultDisplaySync();
    return px / displayInfo.densityPixels;
  } catch (err) {
    return px / 3; // 默认density
  }
}
