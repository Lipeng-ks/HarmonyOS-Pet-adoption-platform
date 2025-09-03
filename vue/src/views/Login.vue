<template>
  <div class="login-wrap">
    <!-- 背景装饰 -->
    <div class="background-decoration">
      <div class="floating-shapes">
        <div class="shape shape-1"></div>
        <div class="shape shape-2"></div>
        <div class="shape shape-3"></div>
        <div class="shape shape-4"></div>
      </div>
    </div>

    <div class="login-container">
      <!-- 品牌区域 -->
      <div class="brand-header">
        <div class="logo-section">
          <div class="logo-icon">🐾</div>
          <div class="brand-info">
            <h1>宠物领养平台</h1>
            <p>管理后台系统</p>
          </div>
        </div>
      </div>

      <!-- 登录卡片 -->
      <el-card class="login-card" shadow="never">
        <template #header>
          <div class="card-header">
            <h2>🔐 管理员登录</h2>
            <p>请输入您的管理员凭据以访问系统</p>
          </div>
        </template>

        <el-form 
          :model="form" 
          :rules="rules" 
          ref="formRef" 
          class="login-form"
          label-position="top"
          @submit.prevent="onSubmit"
        >
          <el-form-item label="用户名" prop="username">
            <el-input 
              v-model="form.username" 
              size="large"
              placeholder="请输入管理员用户名"
              @keyup.enter="onSubmit"
            >
              <template #prefix>
                <el-icon><User /></el-icon>
              </template>
            </el-input>
          </el-form-item>
          
          <el-form-item label="密码" prop="password">
            <el-input 
              v-model="form.password" 
              type="password" 
              size="large"
              placeholder="请输入登录密码"
              show-password
              @keyup.enter="onSubmit"
            >
              <template #prefix>
                <el-icon><Lock /></el-icon>
              </template>
            </el-input>
          </el-form-item>

          <div class="form-options">
            <el-checkbox v-model="rememberMe">记住用户名</el-checkbox>
            <el-link type="primary" :underline="false">忘记密码？</el-link>
          </div>
          
          <el-form-item>
            <el-button 
              type="primary" 
              size="large"
              :loading="loading" 
              @click="onSubmit" 
              class="login-btn"
            >
              <el-icon v-if="!loading"><Key /></el-icon>
              {{ loading ? '登录中...' : '立即登录' }}
            </el-button>
          </el-form-item>
        </el-form>

        <!-- 底部信息 -->
        <div class="login-footer">
          <div class="footer-stats">
            <div class="stat-item">
              <el-icon><House /></el-icon>
              <span>让每个小生命都能找到温暖的家</span>
            </div>
          </div>
        </div>
      </el-card>

      <!-- 系统信息 -->
      <div class="system-info">
        <p>© 2025 宠物领养管理平台 - 专业的宠物救助管理系统</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { reactive, ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { User, Lock, House, Key } from '@element-plus/icons-vue'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const route = useRoute()
const auth = useAuthStore()

const loading = ref(false)
const formRef = ref()
const rememberMe = ref(false)
const form = reactive({ 
  username: '', 
  password: '' 
})

// 表单验证规则
const rules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 2, max: 20, message: '用户名长度在 2 到 20 个字符', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 4, message: '密码长度不能少于 4 个字符', trigger: 'blur' }
  ]
}

// 登录提交
async function onSubmit() {
  if (!formRef.value) return
  
  try {
    const valid = await formRef.value.validate()
    if (!valid) return
  } catch (error) {
    return
  }

  loading.value = true
  
  try {
    const res = await auth.login(form.username, form.password)
    
    if ((res as any)?.success) {
      ElMessage.success('登录成功，欢迎回来！')
      
      // 记住用户名
      if (rememberMe.value) {
        localStorage.setItem('rememberedUsername', form.username)
      } else {
        localStorage.removeItem('rememberedUsername')
      }
      
      // 跳转到目标页面
      const redirect = (route.query.redirect as string) || '/'
      router.replace(redirect)
      
    } else {
      ElMessage.error((res as any)?.message || '登录失败，请检查用户名和密码')
    }
  } catch (error: any) {
    console.error('Login error:', error)
    ElMessage.error(error.message || '网络错误，请稍后重试')
  } finally {
    loading.value = false
  }
}

// 组件挂载时的初始化
onMounted(() => {
  // 恢复记住的用户名
  const rememberedUsername = localStorage.getItem('rememberedUsername')
  if (rememberedUsername) {
    form.username = rememberedUsername
    rememberMe.value = true
  }
})
</script>

<style scoped>
/* 主容器 */
.login-wrap {
  min-height: 100vh;
  background: #f5f7fa;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 24px;
  position: relative;
  overflow: hidden;
}

/* 背景装饰 */
.background-decoration {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
  z-index: 1;
}

.floating-shapes {
  position: relative;
  width: 100%;
  height: 100%;
}

.shape {
  position: absolute;
  border-radius: 50%;
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
  opacity: 0.05;
  animation: gentleFloat 20s infinite linear;
}

.shape-1 {
  width: 120px;
  height: 120px;
  top: 10%;
  left: 10%;
  animation-delay: 0s;
}

.shape-2 {
  width: 80px;
  height: 80px;
  top: 20%;
  right: 15%;
  animation-delay: -5s;
}

.shape-3 {
  width: 100px;
  height: 100px;
  bottom: 20%;
  left: 20%;
  animation-delay: -10s;
}

.shape-4 {
  width: 60px;
  height: 60px;
  bottom: 30%;
  right: 25%;
  animation-delay: -15s;
}

@keyframes gentleFloat {
  0%, 100% {
    transform: translateY(0px) rotate(0deg);
  }
  25% {
    transform: translateY(-20px) rotate(90deg);
  }
  50% {
    transform: translateY(0px) rotate(180deg);
  }
  75% {
    transform: translateY(20px) rotate(270deg);
  }
}

/* 登录容器 */
.login-container {
  width: 100%;
  max-width: 420px;
  position: relative;
  z-index: 2;
}

/* 品牌区域 */
.brand-header {
  margin-bottom: 32px;
  text-align: center;
  animation: fadeInDown 0.6s ease-out;
}

.logo-section {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16px;
}

.logo-icon {
  font-size: 56px;
  animation: bounce 2s infinite;
  filter: drop-shadow(0 4px 12px rgba(79, 172, 254, 0.3));
}

.brand-info {
  color: #303133;
}

.brand-info h1 {
  margin: 0 0 8px 0;
  font-size: 32px;
  font-weight: 600;
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  letter-spacing: -0.5px;
}

.brand-info p {
  margin: 0;
  font-size: 16px;
  color: #909399;
  font-weight: 400;
}

/* 登录卡片 */
.login-card {
  width: 100%;
  border-radius: 16px;
  border: none;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.08);
  animation: fadeInUp 0.6s ease-out 0.2s both;
  overflow: hidden;
}

.login-card :deep(.el-card__header) {
  padding: 32px 32px 24px 32px;
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
  color: white;
  border-bottom: none;
}

.login-card :deep(.el-card__body) {
  padding: 32px;
  background: white;
}

.card-header {
  text-align: center;
}

.card-header h2 {
  margin: 0 0 12px 0;
  font-size: 24px;
  font-weight: 600;
  color: white;
}

.card-header p {
  margin: 0;
  color: rgba(255, 255, 255, 0.9);
  font-size: 14px;
  line-height: 1.5;
}

/* 表单样式 */
.login-form {
  width: 100%;
}

.login-form :deep(.el-form-item) {
  margin-bottom: 24px;
}

.login-form :deep(.el-form-item__label) {
  font-weight: 600;
  color: #303133;
  font-size: 14px;
  line-height: 20px;
  padding-bottom: 8px;
}

.login-form :deep(.el-input__wrapper) {
  border-radius: 12px;
  box-shadow: none;
  border: 2px solid #e4e7ed;
  transition: all 0.3s ease;
  background-color: #fafafa;
}

.login-form :deep(.el-input__wrapper:hover) {
  border-color: #4facfe;
  background-color: white;
}

.login-form :deep(.el-input.is-focus .el-input__wrapper) {
  border-color: #4facfe;
  background-color: white;
  box-shadow: 0 0 0 3px rgba(79, 172, 254, 0.1);
}

.login-form :deep(.el-input__inner) {
  font-size: 15px;
  color: #303133;
  font-weight: 400;
}

.login-form :deep(.el-input__inner::placeholder) {
  color: #c0c4cc;
}

.login-form :deep(.el-input__prefix) {
  color: #909399;
}

/* 表单选项 */
.form-options {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 32px;
  font-size: 14px;
}

.form-options :deep(.el-checkbox__label) {
  color: #606266;
  font-size: 14px;
  font-weight: 500;
}

.form-options :deep(.el-link) {
  font-size: 14px;
  font-weight: 500;
}

/* 登录按钮 */
.login-btn {
  width: 100%;
  height: 52px;
  border-radius: 12px;
  font-size: 16px;
  font-weight: 600;
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
  border: none;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.login-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 12px 24px rgba(79, 172, 254, 0.4);
}

.login-btn:active {
  transform: translateY(0);
}

/* 底部信息 */
.login-footer {
  margin-top: 24px;
  padding-top: 24px;
  border-top: 1px solid #f0f0f0;
}

.footer-stats {
  display: flex;
  justify-content: center;
}

.stat-item {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  color: #909399;
}

.stat-item .el-icon {
  color: #f56c6c;
  font-size: 16px;
}

/* 系统信息 */
.system-info {
  margin-top: 24px;
  text-align: center;
  animation: fadeIn 0.6s ease-out 0.4s both;
}

.system-info p {
  margin: 0;
  font-size: 12px;
  color: #c0c4cc;
  line-height: 1.5;
}

/* 动画效果 */
@keyframes fadeInDown {
  from {
    opacity: 0;
    transform: translateY(-30px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(30px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes fadeIn {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}

@keyframes bounce {
  0%, 20%, 50%, 80%, 100% {
    transform: translateY(0);
  }
  40% {
    transform: translateY(-8px);
  }
  60% {
    transform: translateY(-4px);
  }
}

/* 响应式设计 */
@media (max-width: 768px) {
  .login-wrap {
    padding: 16px;
  }
  
  .login-container {
    max-width: 380px;
  }
  
  .brand-info h1 {
    font-size: 28px;
  }
  
  .logo-icon {
    font-size: 48px;
  }
  
  .login-card :deep(.el-card__header),
  .login-card :deep(.el-card__body) {
    padding: 24px;
  }
}

@media (max-width: 480px) {
  .login-container {
    max-width: 340px;
  }
  
  .brand-info h1 {
    font-size: 24px;
  }
  
  .logo-icon {
    font-size: 42px;
  }
  
  .login-card :deep(.el-card__header),
  .login-card :deep(.el-card__body) {
    padding: 20px;
  }
  
  .form-options {
    flex-direction: column;
    gap: 12px;
    align-items: flex-start;
  }
}

/* 减少动画模式 */
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
  
  .floating-shapes {
    display: none;
  }
}
</style>