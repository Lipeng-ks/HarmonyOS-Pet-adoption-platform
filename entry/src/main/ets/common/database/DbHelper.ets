import common from '@ohos.app.ability.common';
import http from '@ohos.net.http';
import { 
  UserInfo, 
  Address, 
  AddressRequest, 
  AddressIdResponse, 
  AddressResult,
  UserIdData,
  UserIdResult,
  ApiResult,
  ApiErrorResult,
  ErrorLike,
  ApiResponse,
  UserData
} from '../../common/models/UserInfo';

// 数据库配置接口
interface DbConfig {
  apiBaseUrl: string;
  timeout: number;
  retries: number; // 重试次数
}

// HTTP请求头接口
interface HttpHeader {
  'Content-Type': string;
  Accept?: string;
  Authorization?: string;
  'User-Agent'?: string;
}

// HTTP请求选项接口
interface HttpOptions {
  method: http.RequestMethod;
  readTimeout: number;
  connectTimeout: number;
  header: HttpHeader;
  extraData?: string | Record<string, string | number | boolean | null>;
}

// 更新地址接口的通用返回体（兼容不同后端实现）
interface UpdateAddressApi {
  success?: boolean;
  message?: string;
  affectedRows?: number;
}

// MySQL数据库配置
const DB_CONFIG: DbConfig = {
  apiBaseUrl: '192.168.1.2:8080/api',
  timeout: 10000, // 请求超时时间(ms)
  retries: 3 // 减少重试次数，避免频繁请求
};

// 数据库用户信息接口
interface DbUserInfo {
  username: string;
  avatar: string;
  gender: string;
  phone: string;
  email: string;
  address: string;
  birthday: string;
}

/**
 * 处理错误信息
 * @param error 错误对象
 * @returns 格式化的错误消息
 */
function formatError(error: ErrorLike): string {
  return error.message || error.toString();
}

/**
 * 数据库帮助类，通过HTTP API连接MySQL数据库
 */
export class DbHelper {
  private httpClient: http.HttpRequest | null = null;
  private context: common.Context;
  private initialized: boolean = false;

  constructor(context: common.Context) {
    this.context = context;
  }

  /**
   * 带重试的HTTP请求
   * @param url 请求URL
   * @param options 请求选项
   * @param retries 重试次数
   * @returns HTTP响应
   */
  private async requestWithRetry(
    url: string,
    options: HttpOptions,
    retries: number = DB_CONFIG.retries
  ): Promise<http.HttpResponse> {
    if (!this.httpClient) {
      this.httpClient = http.createHttp();
    }

    try {
      console.info(`发送HTTP请求: ${url}, 方法: ${options.method}`);
      const response = await this.httpClient.request(url, options);
      console.info(`HTTP响应: ${response.responseCode}, ${response.result.toString()}`);
      return response;
    } catch (error) {
      console.error(`HTTP请求失败: ${formatError(error as ErrorLike)}`);
      
      if (retries > 0) {
        const delay = 1000; // 延迟1秒后重试
        console.info(`将在${delay}ms后重试，剩余重试次数: ${retries - 1}`);
        
        return new Promise<http.HttpResponse>((resolve, reject) => {
          setTimeout(async () => {
            try {
              const response = await this.requestWithRetry(url, options, retries - 1);
              resolve(response);
            } catch (retryError) {
              reject(retryError);
            }
          }, delay);
        });
      }
      
      throw new Error(formatError(error as ErrorLike));
    }
  }

  /**
   * 初始化数据库连接
   * @returns Promise<boolean> 是否初始化成功
   */
  async initDb(): Promise<boolean> {
    try {
      // 创建HTTP客户端
      this.httpClient = http.createHttp();
      
      // 设置请求选项
      const options: HttpOptions = {
        method: http.RequestMethod.GET,
        readTimeout: DB_CONFIG.timeout,
        connectTimeout: DB_CONFIG.timeout,
        header: {
          'Content-Type': 'application/json'
        }
      };
      
      // 简化为只使用一个固定地址
      const apiUrl = DB_CONFIG.apiBaseUrl;
      
      console.info(`尝试连接API服务器: ${apiUrl}/ping`);
      
      try {
        const response = await this.httpClient.request(`${apiUrl}/ping`, options);
        
        console.info(`API服务器响应: ${response.responseCode}, ${response.result.toString()}`);
        
        if (response.responseCode === 200) {
          console.info(`API服务器连接成功: ${apiUrl}`);
          this.initialized = true;
          return true;
        } else {
          console.error(`API服务器返回非成功状态码: ${response.responseCode}`);
          return false;
        }
      } catch (error) {
        const errorMsg = formatError(error as ErrorLike);
        console.error(`连接API服务器失败: ${apiUrl}, 错误: ${errorMsg}`);
        return false;
      }
    } catch (error) {
      console.error(`数据库初始化失败: ${formatError(error as ErrorLike)}`);
      this.initialized = false;
      return false;
    }
  }

  /**
   * 保存用户信息
   * @param userInfo 用户信息
   * @returns Promise<number> 受影响的行数
   */
  async saveUserInfo(userInfo: UserInfo): Promise<number> {
    if (!this.initialized || !this.httpClient) {
      throw new Error('数据库未初始化');
    }

    try {
      // 处理可能的undefined值
      const cleanUserInfo: DbUserInfo = {
        username: userInfo.username,
        avatar: userInfo.avatar || 'app.media.man',
        gender: userInfo.gender || '男',
        phone: userInfo.phone || '',
        email: userInfo.email || '',
        address: userInfo.address || '',
        birthday: userInfo.birthday || ''
      };

      // 设置请求选项
      const options: HttpOptions = {
        method: http.RequestMethod.POST,
        readTimeout: DB_CONFIG.timeout,
        connectTimeout: DB_CONFIG.timeout,
        header: {
          'Content-Type': 'application/json'
        },
        extraData: JSON.stringify(cleanUserInfo)
      };
      
      // 发送HTTP请求保存用户信息
      console.info(`正在保存用户信息: ${DB_CONFIG.apiBaseUrl}/users`);
      const response = await this.requestWithRetry(
        `${DB_CONFIG.apiBaseUrl}/users`,
        options
      );
      
      console.info(`保存用户信息响应: ${response.responseCode}, ${response.result.toString()}`);
      
      if (response.responseCode === 200 || response.responseCode === 201) {
        const result = JSON.parse(response.result.toString()) as ApiResult;
        const affectedRows = result.affectedRows || 0;
        console.info(`保存用户信息成功，影响 ${affectedRows} 行`);
        return affectedRows;
      } else {
        // 解析错误信息
        try {
          const errorResult = JSON.parse(response.result.toString()) as ApiErrorResult;
          const errorMessage = errorResult.message || `API请求失败: ${response.responseCode}`;
          throw new Error(errorMessage);
        } catch (parseError) {
          throw new Error(`API请求失败: ${response.responseCode}`);
        }
      }
    } catch (error) {
      const errorMsg = `保存用户信息失败: ${formatError(error as ErrorLike)}`;
      console.error(errorMsg);
      throw new Error(errorMsg);
    }
  }

  /**
   * 获取用户信息
   * @param username 用户名
   * @returns Promise<UserInfo | null> 用户信息
   */
  async getUserInfo(username: string): Promise<UserInfo | null> {
    if (!this.initialized || !this.httpClient) {
      throw new Error('数据库未初始化');
    }

    try {
      // 设置请求选项
      const options: HttpOptions = {
        method: http.RequestMethod.GET,
        readTimeout: DB_CONFIG.timeout,
        connectTimeout: DB_CONFIG.timeout,
        header: {
          'Content-Type': 'application/json'
        }
      };
      
      // 发送HTTP请求获取用户信息
      console.info(`正在获取用户信息: ${DB_CONFIG.apiBaseUrl}/users/${encodeURIComponent(username)}`);
      const response = await this.requestWithRetry(
        `${DB_CONFIG.apiBaseUrl}/users/${encodeURIComponent(username)}`,
        options
      );
      
      console.info(`获取用户信息响应: ${response.responseCode}, ${response.result.toString()}`);
      
      if (response.responseCode === 200) {
        const result = JSON.parse(response.result.toString()) as ApiResult;
        if (result && result.data) {
          // 添加类型检查和类型转换
          const data = result.data as Record<string, string | number | boolean | null | undefined>;
          
          // 检查是否为UserInfo类型
          if (this.isUserInfo(data)) {
            // 调试日志：检查从API返回的头像数据
            console.log('DbHelper.getUserInfo - API返回的头像数据:', (data.avatar as string)?.substring(0, 50) + '...');
            
            return {
              id: data.id as number | undefined,
              username: data.username as string,
              avatar: data.avatar as string,
              gender: data.gender as string,
              phone: data.phone as string | undefined,
              email: data.email as string | undefined,
              address: data.address as string | undefined,
              birthday: data.birthday as string | undefined
            };
          } else {
            console.error('API返回的数据不是有效的UserInfo类型');
            return null;
          }
        }
        return null;
      } else if (response.responseCode === 404) {
        return null;
      } else {
        // 解析错误信息
        try {
          const errorResult = JSON.parse(response.result.toString()) as ApiErrorResult;
          const errorMessage = errorResult.message || `API请求失败: ${response.responseCode}`;
          throw new Error(errorMessage);
        } catch (parseError) {
          throw new Error(`API请求失败: ${response.responseCode}`);
        }
      }
    } catch (error) {
      const errorMsg = `获取用户信息失败: ${formatError(error as ErrorLike)}`;
      console.error(errorMsg);
      throw new Error(errorMsg);
    }
  }

  /**
   * 类型检查辅助方法，判断对象是否为UserInfo类型
   * @param obj 要检查的对象
   * @returns 是否为UserInfo类型
   */
  private isUserInfo(obj: Record<string, string | number | boolean | null | undefined>): boolean {
    return obj !== null &&
           typeof obj === 'object' &&
           obj !== undefined &&
           obj.username !== undefined &&
           obj.avatar !== undefined &&
           obj.gender !== undefined &&
           typeof obj.username === 'string' &&
           typeof obj.avatar === 'string' &&
           typeof obj.gender === 'string';
  }

  /**
   * 删除用户信息
   * @param username 用户名
   * @returns Promise<number> 受影响的行数
   */
  async deleteUserInfo(username: string): Promise<number> {
    if (!this.initialized || !this.httpClient) {
      throw new Error('数据库未初始化');
    }

    try {
      // 设置请求选项
      const options: HttpOptions = {
        method: http.RequestMethod.DELETE,
        readTimeout: DB_CONFIG.timeout,
        connectTimeout: DB_CONFIG.timeout,
        header: {
          'Content-Type': 'application/json'
        }
      };
      
      // 发送HTTP请求删除用户信息
      console.info(`正在删除用户信息: ${DB_CONFIG.apiBaseUrl}/users/${encodeURIComponent(username)}`);
      const response = await this.requestWithRetry(
        `${DB_CONFIG.apiBaseUrl}/users/${encodeURIComponent(username)}`,
        options
      );
      
      console.info(`删除用户信息响应: ${response.responseCode}, ${response.result.toString()}`);
      
      if (response.responseCode === 200) {
        const result = JSON.parse(response.result.toString()) as ApiResult;
        const affectedRows = result.affectedRows || 0;
        console.info(`删除用户信息成功，影响 ${affectedRows} 行`);
        return affectedRows;
      } else {
        // 解析错误信息
        try {
          const errorResult = JSON.parse(response.result.toString()) as ApiErrorResult;
          const errorMessage = errorResult.message || `API请求失败: ${response.responseCode}`;
          throw new Error(errorMessage);
        } catch (parseError) {
          throw new Error(`API请求失败: ${response.responseCode}`);
        }
      }
    } catch (error) {
      const errorMsg = `删除用户信息失败: ${formatError(error as ErrorLike)}`;
      console.error(errorMsg);
      throw new Error(errorMsg);
    }
  }

  /**
   * 更新用户信息
   * @param originalUsername 原始用户名（用于查找要更新的用户）
   * @param userInfo 更新后的用户信息
   * @returns Promise<UserInfo | null> 更新后的用户信息
   */
  async updateUserInfo(originalUsername: string, userInfo: UserInfo): Promise<UserInfo | null> {
    if (!this.initialized || !this.httpClient) {
      console.error('数据库未初始化，无法更新用户信息');
      throw new Error('数据库未初始化');
    }

    try {
      // 确保头像字段有效
      if (!userInfo.avatar) {
        userInfo.avatar = 'app.media.man';
      }
      
      // 确保性别字段有效
      if (!userInfo.gender) {
        userInfo.gender = '男';
      }
      
      // 创建一个新的用户信息对象，确保数据格式正确
      // 重要：将所有undefined值转换为空字符串，避免SQL错误
      const cleanUserInfo: DbUserInfo = {
        username: userInfo.username || originalUsername,
        avatar: userInfo.avatar || 'app.media.man',
        gender: userInfo.gender || '男',
        phone: userInfo.phone || '',
        email: userInfo.email || '',
        address: userInfo.address || '',
        birthday: userInfo.birthday || ''
      };
      
      // 打印完整的用户信息对象用于调试
      console.info(`完整的用户信息对象: ${JSON.stringify(cleanUserInfo)}`);
      
      // 设置请求选项
      const options: HttpOptions = {
        method: http.RequestMethod.PUT,
        readTimeout: DB_CONFIG.timeout,
        connectTimeout: DB_CONFIG.timeout,
        header: {
          'Content-Type': 'application/json'
        },
        extraData: JSON.stringify(userInfo) // Send the original userInfo with possible password
      };
      
      // 发送HTTP请求更新用户信息
      const url = `${DB_CONFIG.apiBaseUrl}/users/${encodeURIComponent(originalUsername)}`;
      console.info(`正在更新用户信息: ${url}`);
      
      // 使用带重试的请求方法
      const response = await this.requestWithRetry(url, options);
      
      console.info(`更新用户信息响应状态码: ${response.responseCode}`);
      console.info(`更新用户信息响应内容: ${response.result.toString()}`);
      
      // 处理响应
      if (response.responseCode === 200) {
        try {
          const result = JSON.parse(response.result.toString()) as ApiResponse<UserData>;
          if (result.success && result.data) {
            console.info(`更新用户信息成功`);
            // 后端返回的数据可能包含 avatar 字段（远程 URL），优先使用后端返回值
            const returnedData = result.data as UserData;
            // Normalize avatar: if backend returns full URL, keep it; otherwise keep local value
            if (returnedData.avatar && returnedData.avatar.toString().startsWith('http')) {
              returnedData.avatar = returnedData.avatar.toString();
            }
            return returnedData;
          }
          console.warn('更新用户信息API调用成功但未返回数据');
          return null;
        } catch (parseError) {
          console.error(`解析响应结果失败: ${formatError(parseError as ErrorLike)}`);
          return null; // 解析失败
        }
      } else {
        throw new Error(`API请求失败: ${response.responseCode}`);
      }
    } catch (error) {
      const errorMsg = `更新用户信息失败: ${formatError(error as ErrorLike)}`;
      console.error(errorMsg);
      throw new Error(errorMsg);
    }
  }

  /**
   * 获取用户ID
   * @param username 用户名
   * @returns Promise<string | null> 用户ID
   */
  async getUserId(username: string): Promise<string | null> {
    if (!this.initialized || !this.httpClient) {
      throw new Error('数据库未初始化');
    }

    try {
      // 设置请求选项
      const options: HttpOptions = {
        method: http.RequestMethod.GET,
        readTimeout: DB_CONFIG.timeout,
        connectTimeout: DB_CONFIG.timeout,
        header: {
          'Content-Type': 'application/json'
        }
      };
      
      // 发送HTTP请求获取用户ID
      console.info(`正在获取用户ID: ${DB_CONFIG.apiBaseUrl}/users/${username}/id`);
      const response = await this.requestWithRetry(
        `${DB_CONFIG.apiBaseUrl}/users/${username}/id`,
        options
      );
      
      if (response.responseCode === 200) {
        const result = JSON.parse(response.result.toString()) as UserIdResult;
        if (result && result.data && result.data.id) {
          return result.data.id.toString();
        }
        return null;
      } else {
        console.error(`获取用户ID失败，状态码: ${response.responseCode}`);
        return null;
      }
    } catch (error) {
      const errorMsg = `获取用户ID失败: ${formatError(error as ErrorLike)}`;
      console.error(errorMsg);
      throw new Error(errorMsg);
    }
  }

  /**
   * 获取用户地址列表
   * @param username 用户名
   * @returns Promise<Address[]> 地址列表
   */
  async getAddresses(username: string): Promise<Address[]> {
    if (!this.initialized || !this.httpClient) {
      throw new Error('数据库未初始化');
    }

    try {
      // 设置请求选项
      const options: HttpOptions = {
        method: http.RequestMethod.GET,
        readTimeout: DB_CONFIG.timeout,
        connectTimeout: DB_CONFIG.timeout,
        header: {
          'Content-Type': 'application/json'
        }
      };
      
      // 发送HTTP请求获取地址列表
      console.info(`正在获取地址列表: ${DB_CONFIG.apiBaseUrl}/users/${encodeURIComponent(username)}/addresses`);
      const response = await this.requestWithRetry(
        `${DB_CONFIG.apiBaseUrl}/users/${encodeURIComponent(username)}/addresses`,
        options
      );
      
      console.info(`获取地址列表响应: ${response.responseCode}`);
      
      if (response.responseCode === 200) {
        const result = JSON.parse(response.result.toString()) as AddressResult;
        if (result && result.data && Array.isArray(result.data)) {
          return result.data as Address[];
        }
        return [];
      } else {
        console.error(`获取地址列表失败，状态码: ${response.responseCode}`);
        return [];
      }
    } catch (error) {
      const errorMsg = `获取地址列表失败: ${formatError(error as ErrorLike)}`;
      console.error(errorMsg);
      throw new Error(errorMsg);
    }
  }

  /**
   * 添加新地址
   * @param username 用户名
   * @param address 地址信息
   * @returns Promise<string | null> 新地址ID
   */
  async addAddress(username: string, address: AddressRequest): Promise<string | null> {
    if (!this.initialized || !this.httpClient) {
      throw new Error('数据库未初始化');
    }

    try {
      // 设置请求选项
      const options: HttpOptions = {
        method: http.RequestMethod.POST,
        readTimeout: DB_CONFIG.timeout,
        connectTimeout: DB_CONFIG.timeout,
        header: {
          'Content-Type': 'application/json'
        },
        extraData: JSON.stringify(address)
      };
      
      // 发送HTTP请求添加地址
      console.info(`正在添加地址: ${DB_CONFIG.apiBaseUrl}/users/${encodeURIComponent(username)}/addresses`);
      const response = await this.requestWithRetry(
        `${DB_CONFIG.apiBaseUrl}/users/${encodeURIComponent(username)}/addresses`,
        options
      );
      
      console.info(`添加地址响应: ${response.responseCode}, ${response.result.toString()}`);
      
      if (response.responseCode === 201) {
        const result = JSON.parse(response.result.toString()) as AddressResult;
        if (result && result.data && !Array.isArray(result.data) && (result.data as AddressIdResponse).id !== undefined) {
          return ((result.data as AddressIdResponse).id).toString();
        }
        return null;
      } else {
        console.error(`添加地址失败，状态码: ${response.responseCode}`);
        return null;
      }
    } catch (error) {
      const errorMsg = `添加地址失败: ${formatError(error as ErrorLike)}`;
      console.error(errorMsg);
      throw new Error(errorMsg);
    }
  }

  /**
   * 更新地址信息
   * @param username 用户名
   * @param addressId 地址ID
   * @param address 地址信息
   * @returns Promise<boolean> 是否更新成功
   */
  async updateAddress(username: string, addressId: string, address: AddressRequest): Promise<boolean> {
    if (!this.initialized || !this.httpClient) {
      throw new Error('数据库未初始化');
    }

    try {
      // 设置请求选项
      const options: HttpOptions = {
        method: http.RequestMethod.PUT,
        readTimeout: DB_CONFIG.timeout,
        connectTimeout: DB_CONFIG.timeout,
        header: {
          'Content-Type': 'application/json'
        },
        extraData: JSON.stringify(address)
      };
      
      // 发送HTTP请求更新地址
      const url = `${DB_CONFIG.apiBaseUrl}/users/${encodeURIComponent(username)}/addresses/${encodeURIComponent(addressId)}`;
      console.info(`正在更新地址: ${url}`);
      const response = await this.requestWithRetry(url, options);
      
      console.info(`更新地址响应: ${response.responseCode}, ${response.result.toString()}`);
      
      if (response.responseCode === 200) {
        // 使用明确的响应类型，避免 unknown/any
        const updateResp = JSON.parse(response.result.toString()) as UpdateAddressApi;
        if (updateResp && updateResp.success === true) {
          return true;
        }
        // 兼容旧实现（受影响行数）
        const affectedRows = updateResp && updateResp.affectedRows ? updateResp.affectedRows : 0;
        return affectedRows > 0;
      } else {
        console.error(`更新地址失败，状态码: ${response.responseCode}`);
        return false;
      }
    } catch (error) {
      const errorMsg = `更新地址失败: ${formatError(error as ErrorLike)}`;
      console.error(errorMsg);
      throw new Error(errorMsg);
    }
  }

  /**
   * 删除地址
   * @param username 用户名
   * @param addressId 地址ID
   * @returns Promise<boolean> 是否删除成功
   */
  async deleteAddress(username: string, addressId: string): Promise<boolean> {
    if (!this.initialized || !this.httpClient) {
      throw new Error('数据库未初始化');
    }

    try {
      // 设置请求选项
      const options: HttpOptions = {
        method: http.RequestMethod.DELETE,
        readTimeout: DB_CONFIG.timeout,
        connectTimeout: DB_CONFIG.timeout,
        header: {
          'Content-Type': 'application/json'
        }
      };
      
      // 发送HTTP请求删除地址
      const url = `${DB_CONFIG.apiBaseUrl}/users/${encodeURIComponent(username)}/addresses/${encodeURIComponent(addressId)}`;
      console.info(`正在删除地址: ${url}`);
      const response = await this.requestWithRetry(url, options);
      
      console.info(`删除地址响应: ${response.responseCode}, ${response.result.toString()}`);
      
      if (response.responseCode === 200) {
        // 统一解析为通用更新返回结构，优先 success
        const delResp = JSON.parse(response.result.toString()) as UpdateAddressApi;
        if (delResp && delResp.success === true) {
          return true;
        }
        const affectedRows = delResp && delResp.affectedRows ? delResp.affectedRows : 0;
        return affectedRows > 0;
      } else {
        console.error(`删除地址失败，状态码: ${response.responseCode}`);
        return false;
      }
    } catch (error) {
      const errorMsg = `删除地址失败: ${formatError(error as ErrorLike)}`;
      console.error(errorMsg);
      throw new Error(errorMsg);
    }
  }

  /**
   * 关闭数据库连接
   */
  async closeDb(): Promise<void> {
    if (this.httpClient) {
      this.httpClient.destroy();
      this.httpClient = null;
      this.initialized = false;
      console.info('数据库连接已关闭');
    }
  }
} 