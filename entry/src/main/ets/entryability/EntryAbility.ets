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

import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { Logger } from '../common/Logger';
import { DeviceUtil } from '../common/DeviceUtil';
import { PreferencesUtil } from '../data/PreferencesUtil';
import { FavoriteService } from '../service/FavoriteService';

const DOMAIN = 0x0000;
const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    
    Logger.info(TAG, 'Ability onCreate');
    
    // 初始化设备信息
    DeviceUtil.init();
    
    // 初始化Preferences
    await PreferencesUtil.init(this.context);
    
    // 初始化收藏服务
    FavoriteService.init();
    
    Logger.info(TAG, 'Services initialized');
  }

  onDestroy(): void {
    Logger.info(TAG, 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    Logger.info(TAG, 'Ability onWindowStageCreate');

    // 设置窗口属性
    try {
      const windowClass = windowStage.getMainWindowSync();

      // 设置状态栏和导航栏颜色
      const systemBarProperties: window.SystemBarProperties = {
        statusBarColor: '#FFFFFF',
        statusBarContentColor: '#182431',
        navigationBarColor: '#FFFFFF',
        navigationBarContentColor: '#182431'
      };
      windowClass.setWindowSystemBarProperties(systemBarProperties);

    } catch (err) {
      Logger.error(TAG, 'Failed to set window properties: %{public}s', JSON.stringify(err));
    }

    // 加载主页面
    windowStage.loadContent('pages/MainPage', (err) => {
      if (err.code) {
        Logger.error(TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      Logger.info(TAG, 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    Logger.info(TAG, 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    Logger.info(TAG, 'Ability onForeground');
  }

  onBackground(): void {
    Logger.info(TAG, 'Ability onBackground');
  }
}