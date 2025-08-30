import { http, type ApiResp } from './http'

export interface CheckinSummary {
  userId?: number
  username?: string
  checkinCount?: number
  checkedToday?: boolean
}

export interface CheckinRecord {
  id?: string
  date: string
  username: string
  userId?: number
}

// POST /api/users/{username}/checkin - 用户签到
export function checkin(username: string) {
  return http.post<ApiResp>(`/users/${encodeURIComponent(username)}/checkin`).then(r => r.data)
}

// GET /api/users/{username}/checkin-dates - 获取用户签到日期列表
export function getCheckinDates(username: string) {
  return http.get<ApiResp & { dates: string[] }>(`/users/${encodeURIComponent(username)}/checkin-dates`).then(r => r.data)
}

// GET /api/users/{username}/checkins - 获取用户签到汇总
export function getCheckins(username: string) {
  return http.get<ApiResp & { summary: CheckinSummary }>(`/users/${encodeURIComponent(username)}/checkins`).then(r => r.data)
}

// GET /api/users/checkins/all - 获取所有用户的签到记录
export function getAllCheckins() {
  return http.get<ApiResp & { records: CheckinRecord[] }>(`/users/checkins/all`).then(r => r.data)
}
