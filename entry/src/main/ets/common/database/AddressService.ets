import { DbHelper } from './DbHelper';
import common from '@ohos.app.ability.common';
import { Address, AddressRequest, AddressIdResponse, AddressResult } from '../../common/models/UserInfo';

/**
 * 地址服务类，提供地址的CRUD操作
 */
export class AddressService {
  private static instance: AddressService;
  private dbHelper: DbHelper | null = null;
  private context: common.Context;
  private initialized: boolean = false;

  private constructor() {
    // 获取应用上下文
    this.context = getContext(this) as common.Context;
  }

  /**
   * 获取AddressService单例
   * @returns AddressService实例
   */
  static getInstance(): AddressService {
    if (!AddressService.instance) {
      AddressService.instance = new AddressService();
    }
    return AddressService.instance;
  }

  /**
   * 初始化地址服务
   * @returns Promise<boolean> 是否初始化成功
   */
  async init(): Promise<boolean> {
    if (this.initialized && this.dbHelper) {
      console.info('AddressService已经初始化，无需重复初始化');
      return true;
    }

    try {
      console.info('正在初始化AddressService...');
      this.dbHelper = new DbHelper(this.context);
      const result = await this.dbHelper.initDb();
      this.initialized = result;
      
      if (result) {
        console.info('AddressService初始化成功');
      } else {
        console.error('AddressService初始化失败');
      }
      
      return result;
    } catch (error) {
      console.error(`AddressService初始化失败: ${error}`);
      this.initialized = false;
      return false;
    }
  }

  /**
   * 获取用户所有地址
   * @param username 用户名
   * @returns Promise<Address[]> 地址列表
   */
  async getAddresses(username: string): Promise<Address[]> {
    if (!this.initialized || !this.dbHelper) {
      console.error('AddressService未初始化，无法获取地址');
      await this.init();
    }

    try {
      console.info(`正在获取用户地址: ${username}`);
      if (!this.dbHelper) {
        console.error('DbHelper为空，无法获取地址');
        return [];
      }
      const addresses = await this.dbHelper.getAddresses(username);
      
      if (addresses && addresses.length > 0) {
        console.info(`获取用户地址成功，共${addresses.length}条: ${username}`);
      } else {
        console.warn(`未找到用户地址或地址为空: ${username}`);
      }
      
      return addresses || [];
    } catch (error) {
      console.error(`获取用户地址失败: ${error}`);
      return [];
    }
  }

  /**
   * 添加新地址
   * @param username 用户名
   * @param address 地址信息
   * @returns Promise<string | null> 新地址ID
   */
  async addAddress(username: string, address: AddressRequest): Promise<string | null> {
    if (!this.initialized || !this.dbHelper) {
      console.error('AddressService未初始化，无法添加地址');
      await this.init();
    }

    try {
      console.info(`正在添加地址: ${username}, 姓名: ${address.name}, 电话: ${address.phone}`);
      if (!this.dbHelper) {
        console.error('DbHelper为空，无法添加地址');
        return null;
      }
      const addressId = await this.dbHelper.addAddress(username, address);
      
      if (addressId) {
        console.info(`添加地址成功: ${addressId}`);
      } else {
        console.warn(`添加地址失败`);
      }
      
      return addressId;
    } catch (error) {
      console.error(`添加地址失败: ${error}`);
      return null;
    }
  }

  /**
   * 更新地址
   * @param username 用户名
   * @param addressId 地址ID
   * @param address 地址信息
   * @returns Promise<boolean> 是否更新成功
   */
  async updateAddress(username: string, addressId: string, address: AddressRequest): Promise<boolean> {
    if (!this.initialized || !this.dbHelper) {
      console.error('AddressService未初始化，无法更新地址');
      await this.init();
    }

    try {
      console.info(`正在更新地址: ${username}, ID: ${addressId}, 姓名: ${address.name}`);
      if (!this.dbHelper) {
        console.error('DbHelper为空，无法更新地址');
        return false;
      }
      const success = await this.dbHelper.updateAddress(username, addressId, address);
      
      if (success) {
        console.info(`更新地址成功: ${addressId}`);
      } else {
        console.warn(`更新地址失败: ${addressId}`);
      }
      
      return success;
    } catch (error) {
      console.error(`更新地址失败: ${error}`);
      return false;
    }
  }

  /**
   * 删除地址
   * @param username 用户名
   * @param addressId 地址ID
   * @returns Promise<boolean> 是否删除成功
   */
  async deleteAddress(username: string, addressId: string): Promise<boolean> {
    if (!this.initialized || !this.dbHelper) {
      console.error('AddressService未初始化，无法删除地址');
      await this.init();
    }

    try {
      console.info(`正在删除地址: ${username}, ID: ${addressId}`);
      if (!this.dbHelper) {
        console.error('DbHelper为空，无法删除地址');
        return false;
      }
      const success = await this.dbHelper.deleteAddress(username, addressId);
      
      if (success) {
        console.info(`删除地址成功: ${addressId}`);
      } else {
        console.warn(`删除地址失败: ${addressId}`);
      }
      
      return success;
    } catch (error) {
      console.error(`删除地址失败: ${error}`);
      return false;
    }
  }
} 