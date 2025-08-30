import { http, type ApiResp } from './http'

export async function uploadFile(file: File) {
  const form = new FormData()
  form.append('file', file)
  const res = await http.post<ApiResp<{ url: string; filename: string; size: number }>>('/upload', form, {
    headers: { 'Content-Type': 'multipart/form-data' }
  })
  return res.data
}
