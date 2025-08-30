import { http, type ApiResp } from './http'

export interface UserInfo {
  id?: number
  username: string
  password?: string
  avatar?: string | null
  gender?: boolean | null
  phone?: string | null
  email?: string | null
  address?: string | null
  birthday?: string | null
  realName?: string | null
  idCard?: string | null
}

export function getUser(username: string) {
  return http.get<ApiResp<UserInfo>>(`/users/${encodeURIComponent(username)}`).then(r => r.data)
}

export function listAllUsers() {
  return http.get<ApiResp<UserInfo[]>>('/users').then(r => r.data)
}

export function getUserId(username: string) {
  return http.get<ApiResp<{ id: number }>>(`/users/${encodeURIComponent(username)}/id`).then(r => r.data)
}

export function getUserById(userId: number) {
  return http.get<ApiResp<UserInfo>>(`/users/by-id/${userId}`).then(r => r.data)
}

export function createUser(payload: UserInfo) {
  return http.post<ApiResp>(`/users`, payload).then(r => r.data)
}

export function updateUser(username: string, payload: Partial<UserInfo>) {
  return http.put<ApiResp<UserInfo>>(`/users/${encodeURIComponent(username)}`, payload).then(r => r.data)
}

export function deleteUser(username: string) {
  return http.delete<ApiResp>(`/users/${encodeURIComponent(username)}`).then(r => r.data)
}
