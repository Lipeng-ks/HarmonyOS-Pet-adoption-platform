<template>
  <div class="settings-page">
    <!-- 页面标题 -->
    <div class="page-header">
      <h2>⚙️ 系统设置</h2>
      <p>管理系统配置和基本信息</p>
    </div>

    <el-row :gutter="20">
      <!-- 左侧设置菜单 -->
      <el-col :span="6">
        <el-card class="menu-card">
          <el-menu :default-active="activeTab" @select="handleTabChange">
            <el-menu-item index="basic">
              <el-icon><Setting /></el-icon>
              <span>基本设置</span>
            </el-menu-item>
            <el-menu-item index="notification">
              <el-icon><Bell /></el-icon>
              <span>通知设置</span>
            </el-menu-item>
            <el-menu-item index="payment">
              <el-icon><CreditCard /></el-icon>
              <span>支付配置</span>
            </el-menu-item>
            <el-menu-item index="audit">
              <el-icon><DocumentChecked /></el-icon>
              <span>审核流程</span>
            </el-menu-item>
            <el-menu-item index="security">
              <el-icon><Lock /></el-icon>
              <span>安全设置</span>
            </el-menu-item>
          </el-menu>
        </el-card>
      </el-col>

      <!-- 右侧设置内容 -->
      <el-col :span="18">
        <!-- 基本设置 -->
        <el-card v-show="activeTab === 'basic'" class="content-card">
          <template #header>
            <span>🏢 基本设置</span>
          </template>
          
          <el-form :model="basicSettings" label-width="120px" class="settings-form">
            <el-form-item label="网站名称">
              <el-input v-model="basicSettings.siteName" placeholder="请输入网站名称" />
            </el-form-item>
            
            <el-form-item label="网站描述">
              <el-input 
                v-model="basicSettings.siteDescription" 
                type="textarea" 
                :rows="3"
                placeholder="请输入网站描述"
              />
            </el-form-item>
            
            <el-form-item label="联系电话">
              <el-input v-model="basicSettings.contactPhone" placeholder="请输入联系电话" />
            </el-form-item>
            
            <el-form-item label="联系邮箱">
              <el-input v-model="basicSettings.contactEmail" placeholder="请输入联系邮箱" />
            </el-form-item>
            
            <el-form-item label="网站Logo">
              <el-upload
                class="logo-uploader"
                action="#"
                :show-file-list="false"
                :before-upload="beforeLogoUpload"
              >
                <img v-if="basicSettings.logoUrl" :src="basicSettings.logoUrl" class="logo" />
                <el-icon v-else class="logo-uploader-icon"><Plus /></el-icon>
              </el-upload>
            </el-form-item>
            
            <el-form-item label="维护模式">
              <el-switch 
                v-model="basicSettings.maintenanceMode"
                active-text="开启"
                inactive-text="关闭"
              />
              <div class="form-tip">开启后，普通用户将无法访问网站</div>
            </el-form-item>
            
            <el-form-item>
              <el-button type="primary" @click="saveBasicSettings">保存设置</el-button>
            </el-form-item>
          </el-form>
        </el-card>

        <!-- 通知设置 -->
        <el-card v-show="activeTab === 'notification'" class="content-card">
          <template #header>
            <span>📧 通知设置</span>
          </template>
          
          <el-form :model="notificationSettings" label-width="120px" class="settings-form">
            <el-divider content-position="left">邮件配置</el-divider>
            
            <el-form-item label="SMTP服务器">
              <el-input v-model="notificationSettings.smtpHost" placeholder="smtp.example.com" />
            </el-form-item>
            
            <el-form-item label="SMTP端口">
              <el-input v-model="notificationSettings.smtpPort" placeholder="587" />
            </el-form-item>
            
            <el-form-item label="发件邮箱">
              <el-input v-model="notificationSettings.fromEmail" placeholder="noreply@example.com" />
            </el-form-item>
            
            <el-form-item label="邮箱密码">
              <el-input 
                v-model="notificationSettings.emailPassword" 
                type="password" 
                placeholder="请输入邮箱密码"
                show-password
              />
            </el-form-item>
            
            <el-divider content-position="left">短信配置</el-divider>
            
            <el-form-item label="短信服务商">
              <el-select v-model="notificationSettings.smsProvider" placeholder="请选择">
                <el-option label="阿里云" value="aliyun" />
                <el-option label="腾讯云" value="tencent" />
                <el-option label="华为云" value="huawei" />
              </el-select>
            </el-form-item>
            
            <el-form-item label="AccessKey">
              <el-input v-model="notificationSettings.smsAccessKey" placeholder="请输入AccessKey" />
            </el-form-item>
            
            <el-form-item label="SecretKey">
              <el-input 
                v-model="notificationSettings.smsSecretKey" 
                type="password" 
                placeholder="请输入SecretKey"
                show-password
              />
            </el-form-item>
            
            <el-form-item>
              <el-button type="primary" @click="saveNotificationSettings">保存设置</el-button>
              <el-button @click="testEmail">测试邮件</el-button>
              <el-button @click="testSms">测试短信</el-button>
            </el-form-item>
          </el-form>
        </el-card>

        <!-- 支付配置 -->
        <el-card v-show="activeTab === 'payment'" class="content-card">
          <template #header>
            <span>💳 支付配置</span>
          </template>
          
          <el-form :model="paymentSettings" label-width="120px" class="settings-form">
            <el-form-item label="启用支付">
              <el-switch 
                v-model="paymentSettings.enabled"
                active-text="开启"
                inactive-text="关闭"
              />
            </el-form-item>
            
            <template v-if="paymentSettings.enabled">
              <el-divider content-position="left">微信支付</el-divider>
              
              <el-form-item label="微信支付">
                <el-switch 
                  v-model="paymentSettings.wechat.enabled"
                  active-text="开启"
                  inactive-text="关闭"
                />
              </el-form-item>
              
              <template v-if="paymentSettings.wechat.enabled">
                <el-form-item label="商户号">
                  <el-input v-model="paymentSettings.wechat.mchId" placeholder="请输入微信商户号" />
                </el-form-item>
                
                <el-form-item label="API密钥">
                  <el-input 
                    v-model="paymentSettings.wechat.apiKey" 
                    type="password" 
                    placeholder="请输入API密钥"
                    show-password
                  />
                </el-form-item>
              </template>
              
              <el-divider content-position="left">支付宝</el-divider>
              
              <el-form-item label="支付宝">
                <el-switch 
                  v-model="paymentSettings.alipay.enabled"
                  active-text="开启"
                  inactive-text="关闭"
                />
              </el-form-item>
              
              <template v-if="paymentSettings.alipay.enabled">
                <el-form-item label="应用ID">
                  <el-input v-model="paymentSettings.alipay.appId" placeholder="请输入支付宝应用ID" />
                </el-form-item>
                
                <el-form-item label="私钥">
                  <el-input 
                    v-model="paymentSettings.alipay.privateKey" 
                    type="textarea"
                    :rows="3"
                    placeholder="请输入应用私钥"
                  />
                </el-form-item>
              </template>
            </template>
            
            <el-form-item>
              <el-button type="primary" @click="savePaymentSettings">保存设置</el-button>
            </el-form-item>
          </el-form>
        </el-card>

        <!-- 审核流程 -->
        <el-card v-show="activeTab === 'audit'" class="content-card">
          <template #header>
            <span>📋 审核流程</span>
          </template>
          
          <el-form :model="auditSettings" label-width="120px" class="settings-form">
            <el-form-item label="宠物信息审核">
              <el-switch 
                v-model="auditSettings.animalAudit"
                active-text="开启"
                inactive-text="关闭"
              />
              <div class="form-tip">开启后，新增宠物信息需要管理员审核</div>
            </el-form-item>
            
            <el-form-item label="用户实名审核">
              <el-switch 
                v-model="auditSettings.realnameAudit"
                active-text="开启"
                inactive-text="关闭"
              />
              <div class="form-tip">开启后，用户实名认证需要管理员审核</div>
            </el-form-item>
            
            <el-form-item label="领养申请审核">
              <el-switch 
                v-model="auditSettings.adoptionAudit"
                active-text="开启"
                inactive-text="关闭"
              />
              <div class="form-tip">开启后，领养申请需要管理员审核</div>
            </el-form-item>
            
            <el-form-item label="自动审核时间">
              <el-input-number 
                v-model="auditSettings.autoAuditHours" 
                :min="1" 
                :max="168"
                controls-position="right"
              />
              <span class="form-unit">小时</span>
              <div class="form-tip">超过指定时间未审核将自动通过</div>
            </el-form-item>
            
            <el-form-item>
              <el-button type="primary" @click="saveAuditSettings">保存设置</el-button>
            </el-form-item>
          </el-form>
        </el-card>

        <!-- 安全设置 -->
        <el-card v-show="activeTab === 'security'" class="content-card">
          <template #header>
            <span>🔒 安全设置</span>
          </template>
          
          <el-form :model="securitySettings" label-width="120px" class="settings-form">
            <el-form-item label="登录验证码">
              <el-switch 
                v-model="securitySettings.loginCaptcha"
                active-text="开启"
                inactive-text="关闭"
              />
            </el-form-item>
            
            <el-form-item label="密码强度">
              <el-select v-model="securitySettings.passwordStrength">
                <el-option label="低（6位以上）" value="low" />
                <el-option label="中（8位包含字母数字）" value="medium" />
                <el-option label="高（8位包含大小写字母数字特殊字符）" value="high" />
              </el-select>
            </el-form-item>
            
            <el-form-item label="登录失败锁定">
              <el-input-number 
                v-model="securitySettings.maxLoginAttempts" 
                :min="3" 
                :max="10"
                controls-position="right"
              />
              <span class="form-unit">次</span>
              <div class="form-tip">连续登录失败达到次数后锁定账户</div>
            </el-form-item>
            
            <el-form-item label="锁定时间">
              <el-input-number 
                v-model="securitySettings.lockoutMinutes" 
                :min="5" 
                :max="1440"
                controls-position="right"
              />
              <span class="form-unit">分钟</span>
            </el-form-item>
            
            <el-form-item label="会话超时">
              <el-input-number 
                v-model="securitySettings.sessionTimeout" 
                :min="30" 
                :max="1440"
                controls-position="right"
              />
              <span class="form-unit">分钟</span>
            </el-form-item>
            
            <el-form-item>
              <el-button type="primary" @click="saveSecuritySettings">保存设置</el-button>
            </el-form-item>
          </el-form>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { 
  Setting, 
  Bell, 
  CreditCard, 
  DocumentChecked, 
  Lock, 
  Plus 
} from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'

// 当前激活的标签
const activeTab = ref('basic')

// 基本设置
const basicSettings = reactive({
  siteName: '宠物领养管理系统',
  siteDescription: '专业的宠物领养平台，为流浪动物寻找温暖的家',
  contactPhone: '400-123-4567',
  contactEmail: 'contact@petadoption.com',
  logoUrl: '',
  maintenanceMode: false
})

// 通知设置
const notificationSettings = reactive({
  smtpHost: '',
  smtpPort: '587',
  fromEmail: '',
  emailPassword: '',
  smsProvider: 'aliyun',
  smsAccessKey: '',
  smsSecretKey: ''
})

// 支付设置
const paymentSettings = reactive({
  enabled: false,
  wechat: {
    enabled: false,
    mchId: '',
    apiKey: ''
  },
  alipay: {
    enabled: false,
    appId: '',
    privateKey: ''
  }
})

// 审核设置
const auditSettings = reactive({
  animalAudit: true,
  realnameAudit: true,
  adoptionAudit: true,
  autoAuditHours: 72
})

// 安全设置
const securitySettings = reactive({
  loginCaptcha: true,
  passwordStrength: 'medium',
  maxLoginAttempts: 5,
  lockoutMinutes: 30,
  sessionTimeout: 120
})

// 切换标签
function handleTabChange(key: string) {
  activeTab.value = key
}

// 上传Logo前的检查
function beforeLogoUpload(file: File) {
  const isJPG = file.type === 'image/jpeg' || file.type === 'image/png'
  const isLt2M = file.size / 1024 / 1024 < 2

  if (!isJPG) {
    ElMessage.error('Logo只能是 JPG/PNG 格式!')
    return false
  }
  if (!isLt2M) {
    ElMessage.error('Logo大小不能超过 2MB!')
    return false
  }
  return true
}

// 保存基本设置
function saveBasicSettings() {
  ElMessage.success('基本设置保存成功')
}

// 保存通知设置
function saveNotificationSettings() {
  ElMessage.success('通知设置保存成功')
}

// 保存支付设置
function savePaymentSettings() {
  ElMessage.success('支付设置保存成功')
}

// 保存审核设置
function saveAuditSettings() {
  ElMessage.success('审核设置保存成功')
}

// 保存安全设置
function saveSecuritySettings() {
  ElMessage.success('安全设置保存成功')
}

// 测试邮件
function testEmail() {
  ElMessage.info('正在发送测试邮件...')
  setTimeout(() => {
    ElMessage.success('测试邮件发送成功')
  }, 2000)
}

// 测试短信
function testSms() {
  ElMessage.info('正在发送测试短信...')
  setTimeout(() => {
    ElMessage.success('测试短信发送成功')
  }, 2000)
}
</script>

<style scoped>
.settings-page {
  padding: 20px;
  background: #f5f7fa;
  min-height: 100vh;
}

.page-header {
  margin-bottom: 24px;
}

.page-header h2 {
  margin: 0 0 8px 0;
  color: #303133;
  font-size: 24px;
  font-weight: 600;
}

.page-header p {
  margin: 0;
  color: #909399;
  font-size: 14px;
}

.menu-card,
.content-card {
  border-radius: 12px;
  border: none;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
}

.settings-form {
  max-width: 600px;
}

.form-tip {
  font-size: 12px;
  color: #909399;
  margin-top: 4px;
}

.form-unit {
  margin-left: 8px;
  color: #909399;
  font-size: 14px;
}

.logo-uploader {
  border: 1px dashed #d9d9d9;
  border-radius: 6px;
  cursor: pointer;
  position: relative;
  overflow: hidden;
  transition: border-color 0.3s;
}

.logo-uploader:hover {
  border-color: #409eff;
}

.logo-uploader-icon {
  font-size: 28px;
  color: #8c939d;
  width: 178px;
  height: 178px;
  text-align: center;
  line-height: 178px;
}

.logo {
  width: 178px;
  height: 178px;
  display: block;
  object-fit: cover;
}

:deep(.el-card__header) {
  padding: 16px 20px;
  border-bottom: 1px solid #f0f0f0;
  font-weight: 600;
  color: #303133;
}

:deep(.el-card__body) {
  padding: 20px;
}

:deep(.el-menu) {
  border-right: none;
}

:deep(.el-menu-item) {
  border-radius: 8px;
  margin-bottom: 4px;
}

:deep(.el-menu-item.is-active) {
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
  color: white;
}

:deep(.el-divider__text) {
  font-weight: 600;
  color: #303133;
}
</style>