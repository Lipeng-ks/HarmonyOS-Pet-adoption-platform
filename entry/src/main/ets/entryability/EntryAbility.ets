import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { UserService } from '../common/database/UserService';
import { UserInfo } from '../common/models/UserInfo';
import { AuthService } from '../common/services/AuthService';

const DOMAIN = 0x0000;
const TAG = 'EntryAbility';

// 错误类型接口
interface ErrorLike {
  message?: string;
  toString(): string;
}

export default class EntryAbility extends UIAbility {
  private userService: UserService = UserService.getInstance();
  private authService: AuthService = AuthService.getInstance();

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onCreate');

    // 初始化数据库
    this.initDatabase();
  }

  onDestroy(): void {
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onDestroy');

    // 关闭数据库连接
    this.userService.close().catch((error: Error) => {
      hilog.error(DOMAIN, TAG, 'Failed to close database: %{public}s', error.message);
    });
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Auth/Login', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, TAG, 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onBackground');
  }

  /**
   * 初始化数据库
   */
  private async initDatabase(): Promise<void> {
    try {
      // 初始化数据库服务
      const result = await this.userService.init();
      if (result) {
        hilog.info(DOMAIN, TAG, 'Database initialized successfully');

        // 已禁用默认用户和示例数据的自动初始化（改为手动或真实数据填充）
        hilog.info(DOMAIN, TAG, '已禁用默认用户/示例数据自动初始化');
      } else {
        hilog.error(DOMAIN, TAG, 'Failed to initialize database');
      }
    } catch (error) {
      const errorObj = error as ErrorLike;
      hilog.error(DOMAIN, TAG, 'Error initializing database: %{public}s', errorObj.message || errorObj.toString());
    }
  }

  /**
   * 初始化默认用户数据
   */
  private async initDefaultUserData(): Promise<void> {
    try {
      // initDefaultUserData 已被禁用以移除示例用户数据插入逻辑
      hilog.info(DOMAIN, TAG, 'initDefaultUserData 已禁用，跳过创建默认用户');
    } catch (error) {
      const errorObj = error as ErrorLike;
      hilog.error(DOMAIN, TAG, 'Error initializing default user data: %{public}s', errorObj.message || errorObj.toString());
    }
  }
}