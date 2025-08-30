import axios, { type AxiosResponse, type AxiosError } from 'axios'

const baseURL = '/api'

export const http = axios.create({
  baseURL,
  timeout: 15000
})

http.interceptors.response.use(
  (res: AxiosResponse) => res,
  (error: AxiosError<any>) => {
    const msg = (error.response?.data as any)?.message || error.message || '网络错误'
    return Promise.reject(new Error(msg))
  }
)

export interface ApiResp<T = any> {
  success?: boolean
  message?: string
  data?: T
  [k: string]: any
}
