import { http, type ApiResp } from './http'
import type { AxiosRequestConfig } from 'axios'

export type OrderStatus = '审核中' | '已发货' | '完成' | '评价'

export interface AdoptionOrder {
  id?: number
  userId: number
  animalId?: number
  petName: string
  petAddress: string
  applicationTime?: string
  status?: OrderStatus
  applicationReason?: string | null
  petExperience?: string | null
  shippingAddress?: string | null
}

export function listOrders(config?: AxiosRequestConfig) {
  return http.get<ApiResp<AdoptionOrder[]>>('/adoption-orders', { ...config }).then(r => r.data)
}

export function listOrdersByStatus(status: OrderStatus, config?: AxiosRequestConfig) {
  return http.get<ApiResp<AdoptionOrder[]>>(`/adoption-orders/status/${status}`, { ...config }).then(r => r.data)
}

export function listOrdersByUser(userId: number, config?: AxiosRequestConfig) {
  return http.get<ApiResp<AdoptionOrder[]>>(`/adoption-orders/user/${userId}`, { ...config }).then(r => r.data)
}

export function getOrder(id: number) {
  return http.get<ApiResp<AdoptionOrder>>(`/adoption-orders/${id}`).then(r => r.data)
}

export function updateOrderStatus(id: number, status: OrderStatus) {
  return http.put<ApiResp<AdoptionOrder>>(`/adoption-orders/${id}/status`, { status }).then(r => r.data)
}

export function deleteOrder(id: number) {
  return http.delete<ApiResp>(`/adoption-orders/${id}`).then(r => r.data)
}

// 创建订单：POST /api/adoption-orders（后端会强制设置初始状态为“审核中”）
export function createOrder(payload: { userId: number; petName: string; petAddress: string; animalId?: number; applicationReason?: string | null; petExperience?: string | null; shippingAddress?: string | null }) {
  return http.post<ApiResp<AdoptionOrder>>('/adoption-orders', payload).then(r => r.data)
}

// 更新订单：PUT /api/adoption-orders/{id}
export function updateOrder(id: number, payload: Partial<AdoptionOrder>) {
  return http.put<ApiResp<AdoptionOrder>>(`/adoption-orders/${id}`, payload).then(r => r.data)
}

// 分页查询：GET /api/adoption-orders/page?page=&size=&status=&userId=&keyword=
export function getOrdersPage(params: { page?: number; size?: number; status?: OrderStatus; userId?: number; keyword?: string }) {
  return http
    .get<ApiResp & { records: AdoptionOrder[]; total: number; page: number; size: number }>(
      '/adoption-orders/page',
      { params }
    )
    .then(r => r.data)
}

