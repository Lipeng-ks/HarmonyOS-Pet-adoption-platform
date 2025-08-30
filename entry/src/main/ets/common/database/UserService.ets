import { DbHelper } from './DbHelper';
import common from '@ohos.app.ability.common';
import { UserInfo, ErrorLike } from '../../common/models/UserInfo';

/**
 * 用户服务类，提供用户信息的CRUD操作
 */
export class UserService {
  private static instance: UserService;
  private dbHelper: DbHelper | null = null;
  private context: common.Context;
  private initialized: boolean = false;

  private constructor() {
    // 获取应用上下文
    this.context = getContext(this) as common.Context;
  }

  /**
   * 获取UserService单例
   * @returns UserService实例
   */
  static getInstance(): UserService {
    if (!UserService.instance) {
      UserService.instance = new UserService();
    }
    return UserService.instance;
  }

  /**
   * 初始化用户服务
   * @returns Promise<boolean> 是否初始化成功
   */
  async init(): Promise<boolean> {
    if (this.initialized && this.dbHelper) {
      console.info('UserService已经初始化，无需重复初始化');
      return true;
    }

    try {
      console.info('正在初始化UserService...');
      this.dbHelper = new DbHelper(this.context);
      const result = await this.dbHelper.initDb();
      this.initialized = result;
      
      if (result) {
        console.info('UserService初始化成功');
      } else {
        console.error('UserService初始化失败');
      }
      
      return result;
    } catch (error) {
      console.error(`UserService初始化失败: ${error}`);
      this.initialized = false;
      return false;
    }
  }

  /**
   * 获取用户ID
   * @param username 用户名
   * @returns Promise<string | null> 用户ID
   */
  async getUserIdByUsername(username: string): Promise<string | null> {
    if (!this.initialized || !this.dbHelper) {
      console.error('UserService未初始化，无法获取用户ID');
      return null;
    }

    try {
      console.info(`正在获取用户ID: ${username}`);
      const userId = await this.dbHelper.getUserId(username);
      
      if (userId) {
        console.info(`获取用户ID成功: ${username} -> ${userId}`);
      } else {
        console.warn(`未找到用户ID: ${username}`);
      }
      
      return userId;
    } catch (error) {
      console.error(`获取用户ID失败: ${error}`);
      return null;
    }
  }

  /**
   * 获取用户信息
   * @param username 用户名
   * @returns Promise<UserInfo | null> 用户信息
   */
  async getUserInfo(username: string): Promise<UserInfo | null> {
    try {
      if (!this.initialized || !this.dbHelper) {
        await this.init();
      }

      return await this.dbHelper!.getUserInfo(username);
    } catch (error) {
      console.error(`获取用户信息失败: ${error}`);
      return null;
    }
  }

  /**
   * 保存用户信息
   * @param userInfo 用户信息
   * @returns Promise<boolean> 是否保存成功
   */
  async saveUserInfo(userInfo: UserInfo): Promise<boolean> {
    try {
      if (!this.initialized || !this.dbHelper) {
        await this.init();
      }

      const result = await this.dbHelper!.saveUserInfo(userInfo);
      return result > 0;
    } catch (error) {
      console.error(`保存用户信息失败: ${error}`);
      return false;
    }
  }

  /**
   * 删除用户信息
   * @param username 用户名
   * @returns Promise<boolean> 是否删除成功
   */
  async deleteUserInfo(username: string): Promise<boolean> {
    try {
      if (!this.initialized || !this.dbHelper) {
        await this.init();
      }

      const result = await this.dbHelper!.deleteUserInfo(username);
      return result > 0;
    } catch (error) {
      console.error(`删除用户信息失败: ${error}`);
      return false;
    }
  }

  /**
   * 更新用户信息
   * @param originalUsername 原始用户名
   * @param userInfo 更新后的用户信息
   * @returns Promise<UserInfo | null> 是否更新成功
   */
  async updateUserInfo(originalUsername: string, userInfo: UserInfo): Promise<UserInfo | null> {
    try {
      if (!this.initialized || !this.dbHelper) {
        await this.init();
      }

      return await this.dbHelper!.updateUserInfo(originalUsername, userInfo);
    } catch (error) {
      console.error(`更新用户信息失败: ${error}`);
      return null;
    }
  }

  /**
   * 关闭用户服务
   */
  async close(): Promise<void> {
    if (this.dbHelper) {
      await this.dbHelper.closeDb();
      this.dbHelper = null;
      this.initialized = false;
      console.info('UserService已关闭');
    }
  }
} 