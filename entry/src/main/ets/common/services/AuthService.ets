import http from '@ohos.net.http';
import { UserInfo, AuthResponse, UserData } from '../../common/models/UserInfo';
import { UserService } from '../database/UserService';

// 错误类型接口
interface ErrorLike {
  message?: string;
  toString(): string;
}

/**
 * 错误结果接口
 */
interface ErrorResult {
  message: string;
}

/**
 * HTTP头部选项接口
 */
interface HeaderOptions {
  'Content-Type': string;
}

/**
 * 登录凭证接口
 */
interface LoginCredentials {
  username: string;
  password: string;
}

/**
 * API响应接口
 */
interface ApiResponse {
  success: boolean;
  message: string;
  data?: UserInfo;
}

/**
 * API登录响应接口
 */
interface ApiLoginResponse {
  success: boolean;
  message: string;
  data?: UserData;
}

/**
 * 登录结果接口
 */
interface LoginResponse {
  success: boolean;
  message: string;
  userInfo?: UserInfo;
  data?: UserData;
}

/**
 * 数据Blob接口
 */
interface DataBlob {
  data: Uint8Array;
}

/**
 * 哈希结果接口
 */
interface HashResult {
  data: Uint8Array;
}

/**
 * API错误响应接口
 */
interface ApiError {
  message: string;
}

/**
 * 注册用户请求数据接口
 */
interface RegisterRequest {
  username: string;
  avatar: string;
  gender: string;
  phone?: string;
  email?: string;
  address?: string;
  birthday?: string;
  password?: string;
}

/**
 * 更新用户请求数据接口
 */
interface UpdateUserRequest {
  username: string;
  avatar: string;
  gender: string;
  phone?: string;
  email?: string;
  address?: string;
  birthday?: string;
  password?: string;
}

/**
 * 认证服务，处理登录注册功能
 */
export class AuthService {
  private static instance: AuthService;
  private apiBaseUrl: string = 'http://192.168.1.2:8080/api'; // 局域网IP，供模拟器/真机访问宿主机 SpringBoot API
  // 如更换网络或IP，请同步更新此地址。例如：'http://10.0.2.2:8080/api'（部分模拟器支持）
  private userService: UserService;

  private constructor() {
    this.userService = UserService.getInstance();
  }

  /**
   * 获取AuthService单例
   * @returns AuthService实例
   */
  static getInstance(): AuthService {
    if (!AuthService.instance) {
      AuthService.instance = new AuthService();
    }
    return AuthService.instance;
  }

  /**
   * 登录方法
   * @param username 用户名
   * @param password 密码 (明文)
   * @returns Promise<AuthResponse>
   */
  async login(username: string, password: string): Promise<AuthResponse> {
    try {
      const httpRequest = http.createHttp();
      const loginData: LoginCredentials = { username, password };
      
      const response = await httpRequest.request(`${this.apiBaseUrl}/auth/login`, {
        method: http.RequestMethod.POST,
        readTimeout: 10000,
        connectTimeout: 10000,
        header: { 'Content-Type': 'application/json' } as HeaderOptions,
        extraData: JSON.stringify(loginData)
      });

      const result = JSON.parse(response.result.toString()) as AuthResponse;
      if (response.responseCode === 200 && result.success) {
        return { success: true, message: '登录成功', data: result.data };
      } else {
        return { success: false, message: result.message || '登录失败' };
      }
    } catch (error) {
      const err = error as ErrorLike;
      console.error(`登录请求失败: ${err.message || err.toString()}`);
      return { success: false, message: `登录请求失败: ${err.message || err.toString()}` };
    }
  }
  
  /**
   * 注册用户
   * @param userInfo 用户信息
   * @param password 密码 (明文)
   * @returns Promise<AuthResponse>
   */
  async register(userInfo: UserInfo, password: string): Promise<AuthResponse> {
    try {
      const httpRequest = http.createHttp();
      const requestData: RegisterRequest = {
        username: userInfo.username,
        avatar: userInfo.avatar,
        gender: userInfo.gender,
        phone: userInfo.phone,
        email: userInfo.email,
        address: userInfo.address,
        birthday: userInfo.birthday,
        password: password
      };
      
      const response = await httpRequest.request(`${this.apiBaseUrl}/users`, {
        method: http.RequestMethod.POST,
        readTimeout: 10000,
        connectTimeout: 10000,
        header: { 'Content-Type': 'application/json' } as HeaderOptions,
        extraData: JSON.stringify(requestData)
      });

      if (response.responseCode === 201) { // 201 Created
        return { success: true, message: '注册成功' };
      }

      // 处理非201响应，优先解析返回的 JSON 错误信息
      try {
        const text = response && response.result ? response.result.toString() : '';
        if (text && text.trim().length > 0) {
          const errorResult = JSON.parse(text) as ErrorResult;
          return { success: false, message: errorResult.message || `注册失败: ${response.responseCode}` };
        }
      } catch (parseErr) {
        console.error('解析注册错误响应失败:', parseErr);
      }

      return { success: false, message: `注册失败: ${response ? response.responseCode : 'no response'}` };

    } catch (error) {
      const err = error as ErrorLike;
      console.error(`注册失败: ${err.message || err.toString()}`);
      return { success: false, message: `注册失败: ${err.message || err.toString()}` };
    }
  }

  /**
   * 更新用户资料
   * @param originalUsername 原始用户名
   * @param userInfo 更新后的用户信息
   * @param password 新密码（可选）
   * @returns Promise<LoginResponse>
   */
  async updateUserProfile(originalUsername: string, userInfo: UserInfo, password?: string): Promise<LoginResponse> {
    try {
      const httpRequest = http.createHttp();

      const requestData: UpdateUserRequest = {
        username: userInfo.username,
        avatar: userInfo.avatar,
        gender: userInfo.gender,
        phone: userInfo.phone,
        email: userInfo.email,
        address: userInfo.address,
        birthday: userInfo.birthday
      };

      if (password && password.trim() !== '') {
        requestData.password = password;
      }

      const response = await httpRequest.request(`${this.apiBaseUrl}/users/${originalUsername}`, {
        method: http.RequestMethod.PUT,
        readTimeout: 10000,
        connectTimeout: 10000,
        header: { 'Content-Type': 'application/json' } as HeaderOptions,
        extraData: JSON.stringify(requestData)
      });

      if (response.responseCode === 200) {
        const result = JSON.parse(response.result.toString()) as ApiLoginResponse;
        if (result.success) {
          const updatedUserInfo: UserInfo = {
            username: result.data?.username || userInfo.username,
            avatar: result.data?.avatar || userInfo.avatar,
            gender: result.data?.gender || userInfo.gender,
            phone: result.data?.phone || userInfo.phone,
            email: result.data?.email || userInfo.email,
            address: result.data?.address || userInfo.address,
            birthday: result.data?.birthday || userInfo.birthday
          };
          const updateResponse: LoginResponse = { 
            success: true, 
            message: '资料更新成功', 
            userInfo: updatedUserInfo, 
            data: result.data 
          };
          return updateResponse;
        } else {
          const updateResponse: LoginResponse = { 
            success: false, 
            message: result.message || '资料更新失败' 
          };
          return updateResponse;
        }
      } else {
        const errorResult = JSON.parse(response.result.toString()) as ApiError;
        const updateResponse: LoginResponse = { 
          success: false, 
          message: errorResult.message || `更新失败: ${response.responseCode}` 
        };
        return updateResponse;
      }
    } catch (error) {
      const err = error as ErrorLike;
      console.error(`更新用户资料失败: ${err.message || err.toString()}`);
      const updateResponse: LoginResponse = {
        success: false,
        message: `更新用户资料失败: ${err.message || err.toString()}`
      };
      return updateResponse;
    }
  }
} 