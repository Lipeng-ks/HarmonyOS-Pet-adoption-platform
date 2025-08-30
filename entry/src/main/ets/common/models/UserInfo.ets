/**
 * 用户信息接口，定义了用户数据的结构
 */
export interface UserInfo {
  id?: number;
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
 * 通用的API响应结构
 */
export interface ApiResponse<T> {
  success: boolean;
  message: string;
  data?: T;
}

/**
 * 登录/注册/更新用户信息时的用户数据
 */
export interface UserData {
  id?: number;
  username: string;
  avatar: string;
  gender: string;
  phone?: string;
  email?: string;
  address?: string;
  birthday?: string;
}

/**
 * 认证响应（登录、注册、更新）
 */
export interface AuthResponse extends ApiResponse<UserData> {}

/**
 * 地址接口定义
 */
export interface Address {
  id: string;
  name: string;
  phone: string;
  city: string;
  detail: string;
  isDefault: boolean;
}

/**
 * 地址新增/更新请求接口
 */
export interface AddressRequest {
  name: string;
  phone: string;
  city: string;
  detail: string;
  isDefault: boolean;
}

/**
 * 地址ID响应接口
 */
export interface AddressIdResponse {
  id: string | number;
}

/**
 * 地址API响应接口
 */
export interface AddressResult {
  data?: Address[] | AddressIdResponse;
  message?: string;
  affectedRows?: number;
}

/**
 * 用户ID数据接口
 */
export interface UserIdData {
  id: string | number;
}

/**
 * 用户ID响应结果接口
 */
export interface UserIdResult {
  data?: UserIdData;
  message?: string;
}

/**
 * HTTP API响应结果接口
 * @deprecated Use specific response types like ApiResponse<T> instead.
 */
export interface ApiResult {
  data?: UserInfo | Address[] | AddressIdResponse | UserIdData | Record<string, string | number | boolean | null>;
  message?: string;
  affectedRows?: number;
  success?: boolean; // Added for compatibility
}

/**
 * HTTP API响应错误结果接口
 */
export interface ApiErrorResult {
  message?: string;
  error?: string;
}

/**
 * 错误类型接口
 */
export interface ErrorLike {
  message?: string;
  toString(): string;
}