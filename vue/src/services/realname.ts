import { http, type ApiResp } from './http'

export interface RealNameRecord {
  id: number
  userId: number
  fullName: string
  idNumber: string // 掩码后的
}

export function checkIdUsed(idNumber: string) {
  return http.get<ApiResp & { used: boolean; data?: RealNameRecord }>(`/realname/id/${encodeURIComponent(idNumber)}`).then(r => r.data)
}

// 绑定实名认证：POST /api/realname/bind
export function bindRealName(payload: { userId: number; fullName: string; idNumber: string }) {
  return http.post<ApiResp<RealNameRecord>>('/realname/bind', payload).then(r => r.data)
}

// 根据用户ID查询实名认证：GET /api/realname/user/{userId}
export function getRealNameByUser(userId: number) {
  return http.get<ApiResp<RealNameRecord>>(`/realname/user/${userId}`).then(r => r.data)
}

// 获取所有实名认证信息：GET /api/realname/list
export function getAllRealNames() {
  return http.get<ApiResp<RealNameRecord[]>>('/realname/list').then(r => r.data)
}
