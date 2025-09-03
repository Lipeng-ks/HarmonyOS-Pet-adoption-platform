import { http, type ApiResp } from './http'

// 系统设置相关接口类型定义
export interface BasicSettings {
  siteName: string
  siteDescription: string
  contactPhone: string
  contactEmail: string
  logoUrl: string
  maintenanceMode: boolean
}

export interface NotificationSettings {
  smtpHost: string
  smtpPort: string
  fromEmail: string
  emailPassword: string
  smsProvider: string
  smsAccessKey: string
  smsSecretKey: string
}

export interface PaymentSettings {
  enabled: boolean
  wechat: {
    enabled: boolean
    mchId: string
    apiKey: string
  }
  alipay: {
    enabled: boolean
    appId: string
    privateKey: string
  }
}

export interface AuditSettings {
  animalAudit: boolean
  realnameAudit: boolean
  adoptionAudit: boolean
  autoAuditHours: number
}

export interface SecuritySettings {
  loginCaptcha: boolean
  passwordStrength: 'low' | 'medium' | 'high'
  maxLoginAttempts: number
  lockoutMinutes: number
  sessionTimeout: number
}

// 获取基本设置
export function getBasicSettings() {
  return http.get<ApiResp<BasicSettings>>('/settings/basic').then(r => r.data)
}

// 保存基本设置
export function saveBasicSettings(settings: BasicSettings) {
  return http.put<ApiResp<BasicSettings>>('/settings/basic', settings).then(r => r.data)
}

// 获取通知设置
export function getNotificationSettings() {
  return http.get<ApiResp<NotificationSettings>>('/settings/notification').then(r => r.data)
}

// 保存通知设置
export function saveNotificationSettings(settings: NotificationSettings) {
  return http.put<ApiResp<NotificationSettings>>('/settings/notification', settings).then(r => r.data)
}

// 获取支付设置
export function getPaymentSettings() {
  return http.get<ApiResp<PaymentSettings>>('/settings/payment').then(r => r.data)
}

// 保存支付设置
export function savePaymentSettings(settings: PaymentSettings) {
  return http.put<ApiResp<PaymentSettings>>('/settings/payment', settings).then(r => r.data)
}

// 获取审核设置
export function getAuditSettings() {
  return http.get<ApiResp<AuditSettings>>('/settings/audit').then(r => r.data)
}

// 保存审核设置
export function saveAuditSettings(settings: AuditSettings) {
  return http.put<ApiResp<AuditSettings>>('/settings/audit', settings).then(r => r.data)
}

// 获取安全设置
export function getSecuritySettings() {
  return http.get<ApiResp<SecuritySettings>>('/settings/security').then(r => r.data)
}

// 保存安全设置
export function saveSecuritySettings(settings: SecuritySettings) {
  return http.put<ApiResp<SecuritySettings>>('/settings/security', settings).then(r => r.data)
}

// 测试邮件发送
export function testEmail(email: string) {
  return http.post<ApiResp<boolean>>('/settings/test-email', { email }).then(r => r.data)
}

// 测试短信发送
export function testSms(phone: string) {
  return http.post<ApiResp<boolean>>('/settings/test-sms', { phone }).then(r => r.data)
}

// 上传Logo
export function uploadLogo(file: File) {
  const formData = new FormData()
  formData.append('file', file)
  return http.post<ApiResp<{ url: string }>>('/settings/upload-logo', formData, {
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  }).then(r => r.data)
}

// 获取系统信息
export function getSystemInfo() {
  return http.get<ApiResp<{
    version: string
    buildTime: string
    javaVersion: string
    osName: string
    totalMemory: string
    freeMemory: string
    cpuUsage: number
    diskUsage: number
  }>>('/settings/system-info').then(r => r.data)
}

// 清理系统缓存
export function clearCache() {
  return http.post<ApiResp<boolean>>('/settings/clear-cache').then(r => r.data)
}

// 备份数据库
export function backupDatabase() {
  return http.post<ApiResp<{ fileName: string; size: string }>>('/settings/backup').then(r => r.data)
}

// 获取备份列表
export function getBackupList() {
  return http.get<ApiResp<Array<{
    fileName: string
    size: string
    createTime: string
  }>>>('/settings/backups').then(r => r.data)
}