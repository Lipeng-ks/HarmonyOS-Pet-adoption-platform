import http from '@ohos.net.http';
import { City } from '../data/cityData';
import { UserInfo } from '../models/UserInfo';
import { MissingPet, CreateMissingPetRequest, MissingPetStatus } from '../models/MissingPet';

// 用户打卡汇总类型（前端使用）
export interface UserCheckinSummary {
  checkinCount?: number;
  checkedToday?: boolean;
}

// 后端返回的聚合响应
interface UserSummaryApiResponse {
  success?: boolean;
  summary?: UserCheckinSummary;
}

// 明确的用户响应类型，避免使用匿名对象字面量类型
interface UserInfoResponse {
  success?: boolean;
  data?: UserInfo;
  message?: string;
}

// 签到 API 响应
interface PostCheckinApiResponse {
  success?: boolean;
  message?: string;
}

// 登录返回的用户数据（不含密码）
interface LoginUserData {
  id?: number;
  username?: string;
  avatar?: string;
  gender?: boolean;
  phone?: string;
  email?: string;
  address?: string;
  birthday?: string;
}

// 登录 API 响应
interface AuthLoginApiResponse {
  success?: boolean;
  message?: string;
  data?: LoginUserData;
}

// 获取签到日期 API 响应
interface GetCheckinDatesApiResponse {
  success?: boolean;
  dates?: string[];
}

// 订单状态类型（兼容后端可能返回的“已取消”）
export type OrderStatus = '审核中' | '已发货' | '完成' | '评价' | '已取消';

// 领养订单接口
export interface AdoptionOrder {
  id: number;
  userId?: number;
  petName: string;
  petAddress: string;
  image?: string;
  shippingAddress?: string;
  petExperience?: string;
  applicationReason?: string;
  animal?: Animal; // optional full animal object if backend provides it
  orderNo?: string;
  adoptionFee?: number;
  urgencyLevel?: 'low' | 'medium' | 'high';
  status: OrderStatus;
  applicationTime: string;
  createdAt?: string;
  updatedAt?: string;
  completedAt?: string;
}

// 创建订单请求体
export interface CreateAdoptionOrderRequest {
  userId: number;
  petName: string;
  petAddress: string;
  image?: string;
  shippingAddress?: string;
  petExperience?: string;
  applicationReason?: string;
  status: OrderStatus; // 初次创建传入 "审核中"
}

// 获取订单列表 API 响应
interface GetOrdersApiResponse {
  success?: boolean;
  data?: AdoptionOrder[];
  message?: string;
}

interface CreateOrderApiResponse {
  success?: boolean;
  data?: AdoptionOrder;
  message?: string;
}

// 实名信息接口（前端使用）
export interface UserRealName {
  id: number;
  userId: number;
  fullName: string;
  idNumber?: string; // 可能为掩码形式
}

// 用户收藏前端类型
export interface UserFavorite {
  id: number;
  userId: number;
  animalId: number;
  createdAt?: string;
}

// 创建收藏请求体
export interface CreateFavoriteRequest {
  userId: number;
  animalId: number;
}

// 收藏相关 API 响应类型
interface CreateFavoriteApiResponse {
  success?: boolean;
  data?: UserFavorite;
  message?: string;
}

interface GetFavoritesApiResponse {
  success?: boolean;
  data?: UserFavorite[];
  message?: string;
}

interface ExistsApiResponse {
  success?: boolean;
  favorited?: boolean;
  message?: string;
}

// 批量检查收藏状态响应
interface BatchCheckApiResponse {
  success?: boolean;
  data?: number[]; // 已收藏的 animalId 列表
  message?: string;
}

// 简单成功响应
interface SimpleSuccessResponse {
  success?: boolean;
  message?: string;
}

// 获取实名认证的后端响应结构
interface GetUserRealNameApiResponse {
  success?: boolean;
  data?: UserRealName;
  message?: string;
}

// 实名绑定请求体（显式接口，避免未类型化对象字面量）
interface RealNameBindRequest {
  userId: number;
  fullName: string;
  idNumber: string;
}

// 寻宠相关 API 响应类型
interface CreateMissingPetApiResponse {
  success?: boolean;
  data?: MissingPet;
  message?: string;
}

interface GetMissingPetsApiResponse {
  success?: boolean;
  data?: MissingPet[];
  message?: string;
}

interface GetMissingPetApiResponse {
  success?: boolean;
  data?: MissingPet;
  message?: string;
}

// 动物接口定义
export interface Animal {
  id: number;
  name: string;
  gender: boolean;
  age: number;
  type: string;
  description: string;
  vaccinated: boolean;
  dewormed: boolean;
  neutered: boolean;
  image: string;
  city: string;
  isFree: boolean;
  favoriteCount?: number;
  userId?: number;
  adopted?: boolean;
  listed?: boolean;
}

// 创建送养动物请求体（显式类型，避免匿名对象类型）
export interface CreateAnimalRequest {
  userId: number;
  name: string;
  gender: boolean;
  age: number;
  type: string;
  description: string;
  vaccinated: boolean;
  dewormed: boolean;
  neutered: boolean;
  image?: string;
  city: string;
  isFree: boolean;
  listed?: boolean;
}

// 更新送养动物请求体（显式类型，避免 Partial Utility Type）
export interface UpdateAnimalRequest {
  userId?: number;
  name?: string;
  gender?: boolean;
  age?: number;
  type?: string;
  description?: string;
  vaccinated?: boolean;
  dewormed?: boolean;
  neutered?: boolean;
  image?: string;
  city?: string;
  isFree?: boolean;
  listed?: boolean;
}

// 定义API响应结构
interface ApiResponse<T> {
  success: boolean;
  data: T;
  message?: string;
}

// 更新寻宠请求体（使用显式类，避免对象字面量与交叉类型）
class UpdateMissingPetBody {
  id: number;
  userId?: number;
  title?: string;
  petName?: string;
  type?: string;
  gender?: boolean;
  age?: number;
  lostTime?: string;
  city?: string;
  lostAddress?: string;
  description?: string;
  contactName?: string;
  contactPhone?: string;
  reward?: number;
  image?: string;
  constructor(id: number) {
    this.id = id;
  }
 }
 
export class ApiService {
  private static instance: ApiService;
  // private baseUrl: string = 'http://localhost:8080/api'; // 本地API地址（与后端服务器保持一致）
  // 如果网络环境/主机IP变动，请同步更新此地址。例如:
  private baseUrl: string = 'http://192.168.1.2:8080/api';
  // private baseUrl: string = 'http://10.0.2.2:8080/api';

  private constructor() {}

  /**
   * 绑定实名认证信息（POST /api/realname/bind）
   * 返回掩码处理后的实名信息
   */
  async bindUserRealName(userId: number, fullName: string, idNumber: string): Promise<UserRealName | null> {
    try {
      const httpRequest = http.createHttp();
      const payload: RealNameBindRequest = { userId, fullName, idNumber };
      const response: http.HttpResponse = await httpRequest.request(
        `${this.baseUrl}/realname/bind`,
        {
          method: http.RequestMethod.POST,
          readTimeout: 10000,
          connectTimeout: 10000,
          header: { 'Content-Type': 'application/json' },
          extraData: JSON.stringify(payload)
        }
      );

      if (response && (response.responseCode === 200 || response.responseCode === 201)) {
        const raw = response.result.toString();
        const result = JSON.parse(raw) as ApiResponse<UserRealName> | null;
        if (result && result.success && result.data) {
          return result.data as UserRealName;
        }
      } else if (response) {
        try {
          const raw = response.result ? response.result.toString() : '';
          console.error(`绑定实名认证失败，状态码: ${response.responseCode}, 响应: ${raw}`);
        } catch (_) {
          console.error(`绑定实名认证失败，状态码: ${response.responseCode}`);
        }
      }
      return null;
    } catch (error) {
      console.error(`绑定实名认证异常: ${error}`);
      return null;
    }
  }

  /**
   * 获取单例实例
   */
  static getInstance(): ApiService {
    if (!ApiService.instance) {
      ApiService.instance = new ApiService();
    }
    return ApiService.instance;
  }

  /**
   * 用户登录（校验用户名与密码是否匹配）
   * 仅用于前端在修改密码前验证旧密码
   */
  async login(username: string, password: string): Promise<boolean> {
    try {
      const httpRequest = http.createHttp();
      const response: http.HttpResponse = await httpRequest.request(
        `${this.baseUrl}/auth/login`,
        {
          method: http.RequestMethod.POST,
          readTimeout: 10000,
          connectTimeout: 10000,
          header: { 'Content-Type': 'application/json' },
          extraData: JSON.stringify({ username, password })
        }
      );

      if (!response) return false;
      const code = response.responseCode;
      const raw = response.result ? response.result.toString() : '';
      try {
        const body = raw ? JSON.parse(raw) as AuthLoginApiResponse : {} as AuthLoginApiResponse;
        if (code === 200 && body && body.success) {
          return true;
        }
        return false;
      } catch (_) {
        return code === 200; // 容错：部分实现可能未返回JSON
      }
    } catch (err) {
      console.error('login error:', err);
      return false;
    }
  }

  /**
   * 获取用户信息（/api/users/{username}）
   * 后端响应形如 { data: UserInfo } 或 { success, data }
   */
  async getUserInfo(username: string): Promise<UserInfo | null> {
    try {
      const httpRequest = http.createHttp();
      const response: http.HttpResponse = await httpRequest.request(
        `${this.baseUrl}/users/${encodeURIComponent(username)}`,
        {
          method: http.RequestMethod.GET,
          readTimeout: 10000,
          connectTimeout: 10000,
          header: { 'Content-Type': 'application/json' }
        }
      );

      if (response && response.responseCode === 200) {
        const raw = response.result.toString();
        const parsed = JSON.parse(raw) as UserInfoResponse | null;
        if (parsed && parsed.data) {
          return parsed.data;
        }
      }
      return null;
    } catch (error) {
      console.error(`获取用户信息异常: ${error}`);
      return null;
    }
  }

  /**
   * 更新动物的上/下架状态
   * @param id 动物ID
   * @param listed true=上架; false=下架
   * @returns 更新后的 Animal 或 null
   */
  async updateAnimalListed(id: number, listed: boolean): Promise<Animal | null> {
    try {
      const httpRequest = http.createHttp();
      const url = `${this.baseUrl}/animals/${encodeURIComponent(String(id))}/listed?listed=${encodeURIComponent(String(listed))}`;
      const response: http.HttpResponse = await httpRequest.request(url, {
        method: http.RequestMethod.PUT,
        readTimeout: 10000,
        connectTimeout: 10000,
        header: { 'Content-Type': 'application/json' }
      });
      if (response && (response.responseCode === 200)) {
        const body = JSON.parse(response.result.toString()) as ApiResponse<Animal>;
        if (body && body.success && body.data) {
          return body.data;
        }
      }
      console.error(`更新上/下架失败，状态码: ${response && response.responseCode}`);
      return null;
    } catch (err) {
      console.error('updateAnimalListed error:', err);
      return null;
    }
  }

  /**
   * 更新用户信息（/api/users/{username}）
   * 后端响应形如 { success: true, data: UserInfo }
   */
  async updateUserInfo(username: string, payload: Partial<UserInfo>): Promise<UserInfo | null> {
    try {
      const httpRequest = http.createHttp();
      const response: http.HttpResponse = await httpRequest.request(
        `${this.baseUrl}/users/${encodeURIComponent(username)}`,
        {
          method: http.RequestMethod.PUT,
          readTimeout: 10000,
          connectTimeout: 10000,
          header: { 'Content-Type': 'application/json' },
          extraData: JSON.stringify(payload)
        }
      );

      if (response && (response.responseCode === 200)) {
        const raw = response.result.toString();
        const parsed = JSON.parse(raw) as UserInfoResponse | null;
        if (parsed && parsed.data) {
          return parsed.data;
        }
      }
      console.error(`更新用户信息失败，状态码: ${response && response.responseCode}`);
      return null;
    } catch (error) {
      console.error(`更新用户信息异常: ${error}`);
      return null;
    }
  }
  
  /**
   * 根据用户ID获取用户信息（/api/users/by-id/{userId}）
   */
  async getUserInfoById(userId: number): Promise<UserInfo | null> {
    try {
      const httpRequest = http.createHttp();
      const response: http.HttpResponse = await httpRequest.request(
        `${this.baseUrl}/users/by-id/${encodeURIComponent(String(userId))}`,
        {
          method: http.RequestMethod.GET,
          readTimeout: 10000,
          connectTimeout: 10000,
          header: { 'Content-Type': 'application/json' }
        }
      );

      if (response && response.responseCode === 200) {
        const raw = response.result.toString();
        const parsed = JSON.parse(raw) as UserInfoResponse | null;
        if (parsed && parsed.data) {
          return parsed.data;
        }
      }
      return null;
    } catch (error) {
      console.error(`根据用户ID获取用户信息异常: ${error}`);
      return null;
    }
  }
  /**
   * 批量检查某用户对一组动物的收藏状态
   * @returns 已收藏的 animalId 数组
   */
  async batchIsFavorited(userId: number, animalIds: number[]): Promise<number[]> {
    if (!animalIds || animalIds.length === 0) return [];
    try {
      const httpRequest = http.createHttp();
      const ids = animalIds.join(',');
      const response: http.HttpResponse = await httpRequest.request(
        `${this.baseUrl}/favorites/batch-check?userId=${encodeURIComponent(String(userId))}&animalIds=${encodeURIComponent(ids)}`,
        {
          method: http.RequestMethod.GET,
          readTimeout: 10000,
          connectTimeout: 10000,
          header: { 'Content-Type': 'application/json' }
        }
      );
      if (response && response.responseCode === 200) {
        const result = JSON.parse(response.result.toString()) as BatchCheckApiResponse | null;
        if (result && result.success && Array.isArray(result.data)) {
          return result.data as number[];
        }
      }
      return [];
    } catch (error) {
      console.error(`批量检查收藏状态异常: ${error}`);
      return [];
    }
  }

  /**
   * 为用户添加收藏（如果已收藏则返回现有记录）
   */
  async addFavorite(userId: number, animalId: number): Promise<UserFavorite | null> {
    try {
      const httpRequest = http.createHttp();
      const payload: CreateFavoriteRequest = { userId, animalId };
      const response: http.HttpResponse = await httpRequest.request(
        `${this.baseUrl}/favorites`,
        {
          method: http.RequestMethod.POST,
          readTimeout: 10000,
          connectTimeout: 10000,
          header: { 'Content-Type': 'application/json' },
          extraData: JSON.stringify(payload)
        }
      );

      if (response && response.responseCode === 200) {
        const result = JSON.parse(response.result.toString()) as CreateFavoriteApiResponse | null;
        if (result && result.success && result.data) {
          return result.data as UserFavorite;
        }
      }
      console.error(`添加收藏失败，状态码: ${response && response.responseCode}`);
      return null;
    } catch (error) {
      console.error(`添加收藏异常: ${error}`);
      return null;
    }
  }

  /**
   * 取消收藏
   */
  async removeFavorite(userId: number, animalId: number): Promise<boolean> {
    try {
      const httpRequest = http.createHttp();
      const response: http.HttpResponse = await httpRequest.request(
        `${this.baseUrl}/favorites?userId=${encodeURIComponent(String(userId))}&animalId=${encodeURIComponent(String(animalId))}`,
        {
          method: http.RequestMethod.DELETE,
          readTimeout: 10000,
          connectTimeout: 10000,
          header: { 'Content-Type': 'application/json' }
        }
      );

      if (response && response.responseCode === 200) {
        const result = JSON.parse(response.result.toString()) as SimpleSuccessResponse | null;
        return !!(result && result.success);
      }
      console.error(`取消收藏失败，状态码: ${response && response.responseCode}`);
      return false;
    } catch (error) {
      console.error(`取消收藏异常: ${error}`);
      return false;
    }
  }

  /**
   * 获取用户的收藏列表
   */
  async getFavoritesByUser(userId: number): Promise<UserFavorite[]> {
    try {
      const httpRequest = http.createHttp();
      const response: http.HttpResponse = await httpRequest.request(
        `${this.baseUrl}/favorites/user/${encodeURIComponent(String(userId))}`,
        {
          method: http.RequestMethod.GET,
          readTimeout: 10000,
          connectTimeout: 10000,
          header: { 'Content-Type': 'application/json' }
        }
      );

      if (response && response.responseCode === 200) {
        const result = JSON.parse(response.result.toString()) as GetFavoritesApiResponse | null;
        if (result && result.success && Array.isArray(result.data)) {
          return result.data as UserFavorite[];
        }
      }
      console.error(`获取用户收藏列表失败，状态码: ${response && response.responseCode}`);
      return [];
    } catch (error) {
      console.error(`获取用户收藏列表异常: ${error}`);
      return [];
    }
  }

  /**
   * 检查某用户是否已收藏指定动物
   */
  async isFavorited(userId: number, animalId: number): Promise<boolean> {
    try {
      const httpRequest = http.createHttp();
      const response: http.HttpResponse = await httpRequest.request(
        `${this.baseUrl}/favorites/exists?userId=${encodeURIComponent(String(userId))}&animalId=${encodeURIComponent(String(animalId))}`,
        {
          method: http.RequestMethod.GET,
          readTimeout: 10000,
          connectTimeout: 10000,
          header: { 'Content-Type': 'application/json' }
        }
      );
      if (response && response.responseCode === 200) {
        const result = JSON.parse(response.result.toString()) as ExistsApiResponse | null;
        return !!(result && result.success && result.favorited);
      }
      console.error(`检查收藏失败，状态码: ${response && response.responseCode}`);
      return false;
    } catch (error) {
      console.error(`检查收藏异常: ${error}`);
      return false;
    }
  }

  /**
   * 创建领养订单
   */
  async createAdoptionOrder(payload: CreateAdoptionOrderRequest): Promise<AdoptionOrder | null> {
    try {
      const httpRequest = http.createHttp();
      const response: http.HttpResponse = await httpRequest.request(
        `${this.baseUrl}/adoption-orders`,
        {
          method: http.RequestMethod.POST,
          readTimeout: 10000,
          connectTimeout: 10000,
          header: { 'Content-Type': 'application/json' },
          extraData: JSON.stringify(payload)
        }
      );

      if (response && (response.responseCode === 200 || response.responseCode === 201)) {
        const result = JSON.parse(response.result.toString()) as CreateOrderApiResponse;
        if (result && result.success && result.data) {
          return result.data;
        }
      }
      console.error(`创建订单失败，状态码: ${response && response.responseCode}`);
      return null;
    } catch (error) {
      console.error(`创建订单异常: ${error}`);
      return null;
    }
  }

  /**
   * 获取所有动物ID
   * @returns 所有动物ID数组
   */
  async getAllAnimalIds(): Promise<number[]> {
    const animals = await this.getAnimals();
    return animals.map(animal => animal.id);
  }

  /**
   * 获取随机动物ID
   * @param n 需要获取的ID数量
   * @returns 随机动物ID数组
   */
  async getRandomAnimalIds(n: number): Promise<number[]> {
    const animals = await this.getAnimals();
    const ids = animals.map(animal => animal.id);
    const result: number[] = [];
    const len = Math.min(n, ids.length);
    
    while (result.length < len) {
      const idx = Math.floor(Math.random() * ids.length);
      const id = ids[idx];
      if (!result.includes(id)) {
        result.push(id);
      }
    }
    
    return result;
  }

  /**
   * 获取随机动物数据
   * @param count 需要获取的动物数量
   * @returns 随机动物数据数组
   */
  async getRandomAnimals(count: number): Promise<Animal[]> {
    const animals = await this.getAnimals();
    if (animals.length <= count) {
      return animals;
    }
    
    const result: Animal[] = [];
    const animalsCopy = [...animals];
    
    for (let i = 0; i < count; i++) {
      const randomIndex = Math.floor(Math.random() * animalsCopy.length);
      result.push(animalsCopy[randomIndex]);
      animalsCopy.splice(randomIndex, 1);
    }
    
    return result;
  }

  /**
   * 获取随机动物图片
   * @returns 随机动物图片路径
   */
  async getRandomAnimalImage(): Promise<string> {
    const animals = await this.getAnimals();
    if (animals.length === 0) {
      return '';
    }
    const idx = Math.floor(Math.random() * animals.length);
    return animals[idx].image;
  }

  /**
   * 获取随机动物名称
   * @returns 随机动物名称
   */
  async getRandomAnimalName(): Promise<string> {
    const animals = await this.getAnimals();
    if (animals.length === 0) {
      return '';
    }
    const idx = Math.floor(Math.random() * animals.length);
    return animals[idx].name;
  }

  /**
   * 获取动物数据，可按是否已领养进行过滤
   * @param adopted 可选；true=仅已领养，false=仅未领养；undefined=全部
   * @returns 动物数据列表
   */
  async getAnimals(adopted?: boolean, listed?: boolean): Promise<Animal[]> {
    try {
      const httpRequest = http.createHttp();
      // 构建查询字符串，支持 adopted 与 listed 两个可选参数
      const params: string[] = [];
      if (adopted !== undefined) params.push(`adopted=${encodeURIComponent(String(adopted))}`);
      if (listed !== undefined) params.push(`listed=${encodeURIComponent(String(listed))}`);
      const query = params.length > 0 ? `?${params.join('&')}` : '';
      const response: http.HttpResponse = await httpRequest.request(
        `${this.baseUrl}/animals${query}`,
        {
          method: http.RequestMethod.GET,
          readTimeout: 10000,
          connectTimeout: 10000,
          header: {
            'Content-Type': 'application/json'
          }
        }
      );

      if (response.responseCode === 200) {
        const result: ApiResponse<Animal[]> = JSON.parse(response.result.toString());
        if (result.success && result.data) {
          console.info(`成功获取${result.data.length}条动物数据`);
          return result.data;
        }
      }
      console.error(`获取动物数据失败，状态码: ${response.responseCode}`);
      return [];
    } catch (error) {
      console.error(`获取动物数据异常: ${error}`);
      return [];
    }
  }

  /**
   * 获取所有城市数据
   * @returns 城市数据列表
   */
  async getCities(): Promise<City[]> {
    try {
      const httpRequest = http.createHttp();
      const response: http.HttpResponse = await httpRequest.request(
        `${this.baseUrl}/cities`,
        {
          method: http.RequestMethod.GET,
          readTimeout: 10000,
          connectTimeout: 10000,
          header: {
            'Content-Type': 'application/json'
          }
        }
      );

      if (response.responseCode === 200) {
        const result: ApiResponse<City[]> = JSON.parse(response.result.toString());
        if (result.success && result.data) {
          console.info(`成功获取${result.data.length}条城市数据`);
          return result.data;
        }
      }
      console.error(`获取城市数据失败，状态码: ${response.responseCode}`);
      return [];
    } catch (error) {
      console.error(`获取城市数据异常: ${error}`);
      return [];
    }
  }

  /**
   * 获取所有省份（后端接口返回 string[]）
   */
  async getProvinces(): Promise<string[]> {
    try {
      const httpRequest = http.createHttp();
      const response: http.HttpResponse = await httpRequest.request(
        `${this.baseUrl}/provinces`,
        {
          method: http.RequestMethod.GET,
          readTimeout: 10000,
          connectTimeout: 10000,
          header: {
            'Content-Type': 'application/json'
          }
        }
      );

      if (response.responseCode === 200) {
        const result = JSON.parse(response.result.toString()) as string[] | ApiResponse<string[]>;
        if (Array.isArray(result)) {
          return result as string[];
        }
        // 有些实现可能返回 { success, data }
        if ((result as ApiResponse<string[]>) && Array.isArray((result as ApiResponse<string[]>).data)) {
          return (result as ApiResponse<string[]>).data;
        }
      }
      console.error(`获取省份列表失败，状态码: ${response.responseCode}`);
      return [];
    } catch (error) {
      console.error(`获取省份列表异常: ${error}`);
      return [];
    }
  }

  /**
   * 获取指定省份的地级市（后端接口返回 string[]）
   */
  async getCitiesByProvince(province: string): Promise<string[]> {
    try {
      const httpRequest = http.createHttp();
      const encoded = encodeURIComponent(province);
      const response: http.HttpResponse = await httpRequest.request(
        `${this.baseUrl}/provinces/${encoded}/cities`,
        {
          method: http.RequestMethod.GET,
          readTimeout: 10000,
          connectTimeout: 10000,
          header: {
            'Content-Type': 'application/json'
          }
        }
      );

      if (response.responseCode === 200) {
        const result = JSON.parse(response.result.toString()) as string[] | ApiResponse<string[]>;
        if (Array.isArray(result)) {
          return result as string[];
        }
        if ((result as ApiResponse<string[]>) && Array.isArray((result as ApiResponse<string[]>).data)) {
          return (result as ApiResponse<string[]>).data;
        }
      }
      console.error(`获取省 ${province} 的城市列表失败，状态码: ${response.responseCode}`);
      return [];
    } catch (error) {
      console.error(`获取省 ${province} 的城市列表异常: ${error}`);
      return [];
    }
  }

  /**
   * 获取单个动物详情
   * @param id 动物ID
   * @returns 动物详情
   */
  async getAnimalById(id: number): Promise<Animal | null> {
    try {
      const httpRequest = http.createHttp();
      const response: http.HttpResponse = await httpRequest.request(
        `${this.baseUrl}/animals/${id}`,
        {
          method: http.RequestMethod.GET,
          readTimeout: 10000,
          connectTimeout: 10000,
          header: {
            'Content-Type': 'application/json'
          }
        }
      );

      if (response.responseCode === 200) {
        const result: ApiResponse<Animal> = JSON.parse(response.result.toString());
        if (result.success && result.data) {
          console.info(`成功获取ID为${id}的动物数据`);
          return result.data;
        }
      }
      console.error(`获取动物详情失败，状态码: ${response.responseCode}`);
      return null;
    } catch (error) {
      console.error(`获取动物详情异常: ${error}`);
      return null;
    }
  }

  /**
   * 创建送养动物
   */
  async createAnimal(payload: CreateAnimalRequest): Promise<Animal | null> {
    try {
      const httpRequest = http.createHttp();
      const response: http.HttpResponse = await httpRequest.request(
        `${this.baseUrl}/animals`,
        {
          method: http.RequestMethod.POST,
          readTimeout: 10000,
          connectTimeout: 10000,
          header: { 'Content-Type': 'application/json' },
          extraData: JSON.stringify(payload)
        }
      );

      if (response && (response.responseCode === 200 || response.responseCode === 201)) {
        const result = JSON.parse(response.result.toString()) as ApiResponse<Animal>;
        if (result && result.success && result.data) {
          console.info(`成功创建送养动物`);
          return result.data;
        }
      }
      try {
        const raw = response && response.result ? response.result.toString() : '';
        console.error(`创建动物失败，状态码: ${response && response.responseCode}, 响应: ${raw}`);
      } catch (_) {
        console.error(`创建动物失败，状态码: ${response && response.responseCode}, 响应体解析异常`);
      }
      return null;
    } catch (error) {
      console.error(`创建动物异常: ${error}`);
      return null;
    }
  }

  /**
   * 更新送养动物
   */
  async updateAnimal(id: number, payload: UpdateAnimalRequest): Promise<Animal | null> {
    try {
      const httpRequest = http.createHttp();
      const response: http.HttpResponse = await httpRequest.request(
        `${this.baseUrl}/animals/${encodeURIComponent(String(id))}`,
        {
          method: http.RequestMethod.PUT,
          readTimeout: 10000,
          connectTimeout: 10000,
          header: { 'Content-Type': 'application/json' },
          extraData: JSON.stringify(payload || {})
        }
      );

      if (response && response.responseCode === 200) {
        const result = JSON.parse(response.result.toString()) as ApiResponse<Animal>;
        if (result && result.success && result.data) {
          console.info(`成功更新动物信息，ID: ${id}`);
          return result.data;
        }
      }
      try {
        const raw = response && response.result ? response.result.toString() : '';
        console.error(`更新动物失败，状态码: ${response && response.responseCode}, 响应: ${raw}`);
      } catch (_) {
        console.error(`更新动物失败，状态码: ${response && response.responseCode}, 响应体解析异常`);
      }
      return null;
    } catch (error) {
      console.error(`更新动物异常: ${error}`);
      return null;
    }
  }

  /**
   * 获取用户的打卡汇总（包含 checkinCount 和 checkedToday）
   */
  async getUserCheckinSummary(username: string): Promise<UserCheckinSummary | null> {
    try {
      const httpRequest = http.createHttp();
      const response: http.HttpResponse = await httpRequest.request(
        `${this.baseUrl}/users/${encodeURIComponent(username)}/checkins`,
        {
          method: http.RequestMethod.GET,
          readTimeout: 10000,
          connectTimeout: 10000,
          header: {
            'Content-Type': 'application/json'
          }
        }
      );

      if (response.responseCode === 200) {
        const result = JSON.parse(response.result.toString()) as UserSummaryApiResponse;
        if (result && result.summary) {
          return result.summary;
        }
      }
      console.error(`获取用户 ${username} 打卡汇总失败，状态码: ${response.responseCode}`);
      return null;
    } catch (error) {
      console.error(`获取用户 ${username} 打卡汇总异常: ${error}`);
      return null;
    }
  }

  /**
   * 用户签到（POST）
   */
  async postUserCheckin(username: string): Promise<PostCheckinApiResponse | null> {
    try {
      const httpRequest = http.createHttp();
      const response: http.HttpResponse = await httpRequest.request(
        `${this.baseUrl}/users/${encodeURIComponent(username)}/checkin`,
        {
          method: http.RequestMethod.POST,
          readTimeout: 10000,
          connectTimeout: 10000,
          header: { 'Content-Type': 'application/json' }
        }
      );

      if (response && (response.responseCode === 200 || response.responseCode === 201 || response.responseCode === 409)) {
        const result = JSON.parse(response.result.toString()) as PostCheckinApiResponse | null;
        return result;
      }
      console.error(`用户 ${username} 签到失败，状态码: ${response && response.responseCode}`);
      return null;
    } catch (error) {
      console.error(`用户 ${username} 签到异常: ${error}`);
      return null;
    }
  }

  /**
   * 获取用户历史签到日期列表
   * @param username 用户名
   * @returns 签到日期字符串数组（格式：YYYY-MM-DD，按日期倒序）
   */
  async getUserCheckinDates(username: string): Promise<string[]> {
    try {
      const httpRequest = http.createHttp();
      const response: http.HttpResponse = await httpRequest.request(
        `${this.baseUrl}/users/${encodeURIComponent(username)}/checkin-dates`,
        {
          method: http.RequestMethod.GET,
          readTimeout: 10000,
          connectTimeout: 10000,
          header: { 'Content-Type': 'application/json' }
        }
      );

      if (response.responseCode === 200) {
        const result = JSON.parse(response.result.toString()) as GetCheckinDatesApiResponse;
        if (result && result.success && Array.isArray(result.dates)) {
          console.info(`成功获取用户 ${username} 的 ${result.dates.length} 条签到记录`);
          return result.dates;
        }
      }
      console.error(`获取用户 ${username} 签到日期失败，状态码: ${response.responseCode}`);
      return [];
    } catch (error) {
      console.error(`获取用户 ${username} 签到日期异常: ${error}`);
      return [];
    }
  }

  /**
   * 根据ID获取单个领养订单详情
   * @param orderId 订单ID
   * @returns 订单详情
   */
  async getAdoptionOrderById(orderId: number): Promise<AdoptionOrder | null> {
    try {
      const httpRequest = http.createHttp();
      const response: http.HttpResponse = await httpRequest.request(
        `${this.baseUrl}/adoption-orders/${encodeURIComponent(String(orderId))}`,
        {
          method: http.RequestMethod.GET,
          readTimeout: 10000,
          connectTimeout: 10000,
          header: { 'Content-Type': 'application/json' }
        }
      );

      if (response.responseCode === 200) {
        const result = JSON.parse(response.result.toString()) as CreateOrderApiResponse;
        if (result && result.success && result.data) {
          console.info(`成功获取订单 ${orderId} 的详情`);
          return result.data;
        }
      }
      console.error(`获取订单详情失败，状态码: ${response.responseCode}`);
      return null;
    } catch (error) {
      console.error(`获取订单详情异常: ${error}`);
      return null;
    }
  }

  /**
   * 获取所有领养订单
   * @returns 订单列表
   */
  async getAllAdoptionOrders(): Promise<AdoptionOrder[]> {
    try {
      const httpRequest = http.createHttp();
      const response: http.HttpResponse = await httpRequest.request(
        `${this.baseUrl}/adoption-orders`,
        {
          method: http.RequestMethod.GET,
          readTimeout: 10000,
          connectTimeout: 10000,
          header: { 'Content-Type': 'application/json' }
        }
      );

      if (response.responseCode === 200) {
        const result = JSON.parse(response.result.toString()) as GetOrdersApiResponse;
        if (result && result.success && Array.isArray(result.data)) {
          console.info(`成功获取 ${result.data.length} 条订单记录`);
          return result.data;
        }
      }
      console.error(`获取订单列表失败，状态码: ${response.responseCode}`);
      return [];
    } catch (error) {
      console.error(`获取订单列表异常: ${error}`);
      return [];
    }
  }

  /**
   * 根据状态获取领养订单
   * @param status 订单状态
   * @returns 订单列表
   */
  async getAdoptionOrdersByStatus(status: OrderStatus): Promise<AdoptionOrder[]> {
    try {
      const httpRequest = http.createHttp();
      const response: http.HttpResponse = await httpRequest.request(
        `${this.baseUrl}/adoption-orders/status/${encodeURIComponent(status)}`,
        {
          method: http.RequestMethod.GET,
          readTimeout: 10000,
          connectTimeout: 10000,
          header: { 'Content-Type': 'application/json' }
        }
      );

      if (response.responseCode === 200) {
        const result = JSON.parse(response.result.toString()) as GetOrdersApiResponse;
        if (result && result.success && Array.isArray(result.data)) {
          console.info(`成功获取状态为"${status}"的 ${result.data.length} 条订单记录`);
          return result.data;
        }
      }
      console.error(`获取订单列表失败，状态码: ${response.responseCode}`);
      return [];
    } catch (error) {
      console.error(`获取订单列表异常: ${error}`);
      return [];
    }
  }

  /**
   * 根据用户ID获取领养订单
   * @param userId 用户ID
   * @returns 订单列表
   */
  async getAdoptionOrdersByUser(userId: number): Promise<AdoptionOrder[]> {
    try {
      const httpRequest = http.createHttp();
      const response: http.HttpResponse = await httpRequest.request(
        `${this.baseUrl}/adoption-orders/user/${encodeURIComponent(String(userId))}`,
        {
          method: http.RequestMethod.GET,
          readTimeout: 10000,
          connectTimeout: 10000,
          header: { 'Content-Type': 'application/json' }
        }
      );

      if (response.responseCode === 200) {
        const result = JSON.parse(response.result.toString()) as GetOrdersApiResponse;
        if (result && result.success && Array.isArray(result.data)) {
          console.info(`成功获取用户 ${userId} 的 ${result.data.length} 条订单记录`);
          return result.data;
        }
      }
      console.error(`获取用户 ${userId} 的订单失败，状态码: ${response.responseCode}`);
      return [];
    } catch (error) {
      console.error(`获取用户 ${userId} 的订单异常: ${error}`);
      return [];
    }
  }

  /**
   * 删除领养订单
   * @param orderId 订单ID
   * @returns 是否删除成功
   */
  async deleteAdoptionOrder(orderId: number): Promise<boolean> {
    try {
      const httpRequest = http.createHttp();
      const response: http.HttpResponse = await httpRequest.request(
        `${this.baseUrl}/adoption-orders/${encodeURIComponent(String(orderId))}`,
        {
          method: http.RequestMethod.DELETE,
          readTimeout: 10000,
          connectTimeout: 10000,
          header: { 'Content-Type': 'application/json' }
        }
      );

      if (response && response.responseCode === 200) {
        const raw = response.result?.toString?.();
        if (raw) {
          const result = JSON.parse(raw) as SimpleSuccessResponse | null;
          return !!(result && result.success);
        }
        // 有些实现可能返回空体但 200
        return true;
      }
      console.error(`删除订单失败，状态码: ${response && response.responseCode}`);
      return false;
    } catch (error) {
      console.error(`删除订单异常: ${error}`);
      return false;
    }
  }

  /**
   * 获取指定用户的实名认证信息（如后端返回掩码则返回掩码）
   */
  async getUserRealNameByUserId(userId: number): Promise<UserRealName | null> {
    try {
      const httpRequest = http.createHttp();
      const response: http.HttpResponse = await httpRequest.request(
        `${this.baseUrl}/realname/user/${encodeURIComponent(String(userId))}`,
        {
          method: http.RequestMethod.GET,
          readTimeout: 10000,
          connectTimeout: 10000,
          header: { 'Content-Type': 'application/json' }
        }
      );

      if (response && response.responseCode === 200) {
        const raw = response.result.toString();
        const result = JSON.parse(raw) as GetUserRealNameApiResponse | null;
        if (result && result.success && result.data) {
          const d = result.data;
          return {
            id: d.id,
            userId: d.userId,
            fullName: d.fullName,
            idNumber: d.idNumber
          } as UserRealName;
        }
      }
      return null;
    } catch (error) {
      console.error(`获取用户实名认证失败: ${error}`);
      return null;
    }
  }

  /**
   * 获取寻宠列表
   * @param status 可选；按状态过滤
   * @param city 可选；按城市过滤
   * @returns 寻宠列表
   */
  async getMissingPets(status?: MissingPetStatus, city?: string): Promise<MissingPet[]> {
    try {
      const httpRequest = http.createHttp();
      const params: string[] = [];
      if (status) params.push(`status=${encodeURIComponent(status)}`);
      if (city && city !== '全国') params.push(`city=${encodeURIComponent(city)}`);
      const query = params.length > 0 ? `?${params.join('&')}` : '';
      
      const response: http.HttpResponse = await httpRequest.request(
        `${this.baseUrl}/missing-pets${query}`,
        {
          method: http.RequestMethod.GET,
          readTimeout: 10000,
          connectTimeout: 10000,
          header: { 'Content-Type': 'application/json' }
        }
      );

      if (response.responseCode === 200) {
        const result = JSON.parse(response.result.toString()) as GetMissingPetsApiResponse;
        if (result && result.success && Array.isArray(result.data)) {
          console.info(`成功获取${result.data.length}条寻宠数据`);
          return result.data;
        }
      }
      console.error(`获取寻宠列表失败，状态码: ${response.responseCode}`);
      return [];
    } catch (error) {
      console.error(`获取寻宠列表异常: ${error}`);
      return [];
    }
  }

  /**
   * 根据ID获取单个寻宠详情
   * @param id 寻宠ID
   * @returns 寻宠详情
   */
  async getMissingPetById(id: number): Promise<MissingPet | null> {
    try {
      const httpRequest = http.createHttp();
      const response: http.HttpResponse = await httpRequest.request(
        `${this.baseUrl}/missing-pets/${encodeURIComponent(String(id))}`,
        {
          method: http.RequestMethod.GET,
          readTimeout: 10000,
          connectTimeout: 10000,
          header: { 'Content-Type': 'application/json' }
        }
      );

      if (response.responseCode === 200) {
        const result = JSON.parse(response.result.toString()) as GetMissingPetApiResponse;
        if (result && result.success && result.data) {
          console.info(`成功获取ID为${id}的寻宠数据`);
          return result.data;
        }
      }
      console.error(`获取寻宠详情失败，状态码: ${response.responseCode}`);
      return null;
    } catch (error) {
      console.error(`获取寻宠详情异常: ${error}`);
      return null;
    }
  }

  /**
   * 创建寻宠信息
   * @param payload 寻宠信息
   * @returns 创建的寻宠信息
   */
  async createMissingPet(payload: CreateMissingPetRequest): Promise<MissingPet | null> {
    try {
      const httpRequest = http.createHttp();
      const response: http.HttpResponse = await httpRequest.request(
        `${this.baseUrl}/missing-pets`,
        {
          method: http.RequestMethod.POST,
          readTimeout: 10000,
          connectTimeout: 10000,
          header: { 'Content-Type': 'application/json' },
          extraData: JSON.stringify(payload)
        }
      );

      if (response && (response.responseCode === 200 || response.responseCode === 201)) {
        const result = JSON.parse(response.result.toString()) as CreateMissingPetApiResponse;
        if (result && result.success && result.data) {
          console.info(`成功创建寻宠信息`);
          return result.data;
        }
      }
      try {
        const raw = response && response.result ? response.result.toString() : '';
        console.error(`创建寻宠信息失败，状态码: ${response && response.responseCode}, 响应: ${raw}`);
      } catch (e) {
        console.error(`创建寻宠信息失败，状态码: ${response && response.responseCode}, 响应体解析异常`);
      }
      return null;
    } catch (error) {
      console.error(`创建寻宠信息异常: ${error}`);
      return null;
    }
  }

  /**
   * 更新寻宠状态
   * @param id 寻宠ID
   * @param status 新状态
   * @returns 更新后的寻宠信息
   */
  async updateMissingPetStatus(id: number, status: MissingPetStatus): Promise<MissingPet | null> {
    try {
      const httpRequest = http.createHttp();
      const response: http.HttpResponse = await httpRequest.request(
        `${this.baseUrl}/missing-pets/${encodeURIComponent(String(id))}/status`,
        {
          method: http.RequestMethod.PUT,
          readTimeout: 10000,
          connectTimeout: 10000,
          header: { 'Content-Type': 'application/json' },
          extraData: JSON.stringify({ status })
        }
      );

      if (response && response.responseCode === 200) {
        const result = JSON.parse(response.result.toString()) as GetMissingPetApiResponse;
        if (result && result.success && result.data) {
          console.info(`成功更新寻宠状态`);
          return result.data;
        }
      }
      console.error(`更新寻宠状态失败，状态码: ${response && response.responseCode}`);
      return null;
    } catch (error) {
      console.error(`更新寻宠状态异常: ${error}`);
      return null;
    }
  }

  /**
   * 根据用户ID获取用户发布的寻宠信息
   * @param userId 用户ID
   * @returns 寻宠列表
   */
  async getMissingPetsByUser(userId: number): Promise<MissingPet[]> {
    try {
      const httpRequest = http.createHttp();
      const response: http.HttpResponse = await httpRequest.request(
        `${this.baseUrl}/missing-pets/user/${encodeURIComponent(String(userId))}`,
        {
          method: http.RequestMethod.GET,
          readTimeout: 10000,
          connectTimeout: 10000,
          header: { 'Content-Type': 'application/json' }
        }
      );

      if (response.responseCode === 200) {
        const result = JSON.parse(response.result.toString()) as GetMissingPetsApiResponse;
        if (result && result.success && Array.isArray(result.data)) {
          console.info(`成功获取用户 ${userId} 的 ${result.data.length} 条寻宠记录`);
          return result.data;
        }
      }
      console.error(`获取用户寻宠列表失败，状态码: ${response.responseCode}`);
      return [];
    } catch (error) {
      console.error(`获取用户寻宠列表异常: ${error}`);
      return [];
    }
  }

  /**
   * 更新寻宠信息
   * @param id 寻宠ID
   * @param payload 要更新的寻宠信息
   * @returns 更新后的寻宠信息
   */
  async updateMissingPet(id: number, payload: Partial<CreateMissingPetRequest>): Promise<MissingPet | null> {
    try {
      const httpRequest = http.createHttp();
      // 兼容后端对 LocalDateTime 的要求：仅日期时补齐到 00:00:00
      const readyPayload: Partial<CreateMissingPetRequest> = {};
      if (payload.userId !== undefined) readyPayload.userId = payload.userId;
      if (payload.title !== undefined) readyPayload.title = payload.title;
      if (payload.petName !== undefined) readyPayload.petName = payload.petName;
      if (payload.type !== undefined) readyPayload.type = payload.type;
      if (payload.gender !== undefined) readyPayload.gender = payload.gender;
      if (payload.age !== undefined) readyPayload.age = payload.age;
      if (payload.lostTime !== undefined) readyPayload.lostTime = payload.lostTime;
      if (payload.city !== undefined) readyPayload.city = payload.city;
      if (payload.lostAddress !== undefined) readyPayload.lostAddress = payload.lostAddress;
      if (payload.description !== undefined) readyPayload.description = payload.description;
      if (payload.contactName !== undefined) readyPayload.contactName = payload.contactName;
      if (payload.contactPhone !== undefined) readyPayload.contactPhone = payload.contactPhone;
      if (payload.reward !== undefined) readyPayload.reward = payload.reward;
      if (payload.image !== undefined) readyPayload.image = payload.image;

      if (readyPayload.lostTime && typeof readyPayload.lostTime === 'string' && /^\d{4}-\d{2}-\d{2}$/.test(readyPayload.lostTime)) {
        readyPayload.lostTime = `${readyPayload.lostTime}T00:00:00`;
      }

      // 有些后端更新接口需要在请求体中携带 id，使用显式类实例
      const bodyObj: UpdateMissingPetBody = new UpdateMissingPetBody(id);
      if (readyPayload.userId !== undefined) bodyObj.userId = readyPayload.userId;
      if (readyPayload.title !== undefined) bodyObj.title = readyPayload.title;
      if (readyPayload.petName !== undefined) bodyObj.petName = readyPayload.petName;
      if (readyPayload.type !== undefined) bodyObj.type = readyPayload.type;
      if (readyPayload.gender !== undefined) bodyObj.gender = readyPayload.gender;
      if (readyPayload.age !== undefined) bodyObj.age = readyPayload.age;
      if (readyPayload.lostTime !== undefined) bodyObj.lostTime = readyPayload.lostTime;
      if (readyPayload.city !== undefined) bodyObj.city = readyPayload.city;
      if (readyPayload.lostAddress !== undefined) bodyObj.lostAddress = readyPayload.lostAddress;
      if (readyPayload.description !== undefined) bodyObj.description = readyPayload.description;
      if (readyPayload.contactName !== undefined) bodyObj.contactName = readyPayload.contactName;
      if (readyPayload.contactPhone !== undefined) bodyObj.contactPhone = readyPayload.contactPhone;
      if (readyPayload.reward !== undefined) bodyObj.reward = readyPayload.reward;
      if (readyPayload.image !== undefined) bodyObj.image = readyPayload.image;

      const body = JSON.stringify(bodyObj);
      const response: http.HttpResponse = await httpRequest.request(
        `${this.baseUrl}/missing-pets/${encodeURIComponent(String(id))}`,
        {
          method: http.RequestMethod.PUT,
          readTimeout: 10000,
          connectTimeout: 10000,
          header: { 'Content-Type': 'application/json' },
          extraData: body
        }
      );

      if (response && response.responseCode === 200) {
        const result = JSON.parse(response.result.toString()) as GetMissingPetApiResponse;
        if (result && result.success && result.data) {
          console.info(`成功更新寻宠信息，ID: ${id}`);
          return result.data;
        }
      }
      try {
        const raw = response && response.result ? response.result.toString() : '';
        console.error(`更新寻宠信息失败，状态码: ${response && response.responseCode}, 响应: ${raw}`);
      } catch (e) {
        console.error(`更新寻宠信息失败，状态码: ${response && response.responseCode}, 响应体解析异常`);
      }
      return null;
    } catch (error) {
      console.error(`更新寻宠信息异常: ${error}`);
      return null;
    }
  }

  /**
   * 删除寻宠信息
   * @param id 寻宠ID
   * @returns 是否删除成功
   */
  async deleteMissingPet(id: number): Promise<boolean> {
    try {
      const httpRequest = http.createHttp();
      const response: http.HttpResponse = await httpRequest.request(
        `${this.baseUrl}/missing-pets/${encodeURIComponent(String(id))}`,
        {
          method: http.RequestMethod.DELETE,
          readTimeout: 10000,
          connectTimeout: 10000,
          header: { 'Content-Type': 'application/json' }
        }
      );

      if (response && response.responseCode === 200) {
        const raw = response.result?.toString?.();
        if (raw) {
          const result = JSON.parse(raw) as SimpleSuccessResponse | null;
          return !!(result && result.success);
        }
        return true; // 兼容无响应体但返回200
      }
      console.error(`删除寻宠失败，状态码: ${response && response.responseCode}`);
      return false;
    } catch (error) {
      console.error(`删除寻宠异常: ${error}`);
      return false;
    }
  }

  /**
   * 删除送养动物
   * @param id 动物ID
   * @returns 是否删除成功
   */
  async deleteAnimal(id: number): Promise<boolean> {
    try {
      const httpRequest = http.createHttp();
      const response: http.HttpResponse = await httpRequest.request(
        `${this.baseUrl}/animals/${encodeURIComponent(String(id))}`,
        {
          method: http.RequestMethod.DELETE,
          readTimeout: 10000,
          connectTimeout: 10000,
          header: { 'Content-Type': 'application/json' }
        }
      );

      if (response && response.responseCode === 200) {
        const raw = response.result?.toString?.();
        if (raw) {
          const result = JSON.parse(raw) as SimpleSuccessResponse | null;
          return !!(result && result.success);
        }
        return true;
      }
      console.error(`删除动物失败，状态码: ${response && response.responseCode}`);
      return false;
    } catch (error) {
      console.error(`删除动物异常: ${error}`);
      return false;
    }
  }

}