import { http, type ApiResp } from './http'

export function loginApi(payload: { username: string; password: string }) {
  return http.post<ApiResp>('/auth/login', payload).then(r => r.data)
}
