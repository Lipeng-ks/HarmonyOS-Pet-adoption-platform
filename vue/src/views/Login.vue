<template>
  <div class="login-wrap">
    <div class="login-container">
      <div class="login-header">
        <div class="logo">
          <div class="logo-icon">🐾</div>
          <div class="logo-text">
            <h1>宠物领养平台</h1>
            <p>管理后台</p>
          </div>
        </div>
      </div>
      
      <el-card class="login-card" shadow="hover">
        <el-form :model="form" :rules="rules" ref="formRef" class="login-form">
          <el-form-item prop="username">
            <el-input 
              v-model="form.username" 
              size="large"
              @keyup.enter="onSubmit"
            >
              <template #prefix>
                <el-icon><User /></el-icon>
              </template>
            </el-input>
          </el-form-item>
          
          <el-form-item prop="password">
            <el-input 
              v-model="form.password" 
              type="password" 
              size="large"
              show-password
              @keyup.enter="onSubmit"
            >
              <template #prefix>
                <el-icon><Lock /></el-icon>
              </template>
            </el-input>
          </el-form-item>
          
          <el-form-item>
            <el-button 
              type="primary" 
              size="large"
              :loading="loading" 
              @click="onSubmit" 
              class="login-btn"
            >
              <span v-if="!loading">登录</span>
              <span v-else>登录中...</span>
            </el-button>
          </el-form-item>
        </el-form>
      </el-card>
    </div>
  </div>
</template>

<script setup lang="ts">
import { reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { User, Lock } from '@element-plus/icons-vue'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const route = useRoute()
const auth = useAuthStore()

const loading = ref(false)
const formRef = ref()
const form = reactive({ username: '', password: '' })

const rules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
}

async function onSubmit() {
  await formRef.value?.validate()
  loading.value = true
  try {
    const res = await auth.login(form.username, form.password)
    if ((res as any)?.success) {
      ElMessage.success('登录成功')
      const redirect = (route.query.redirect as string) || '/'
      router.replace(redirect)
    } else {
      ElMessage.error((res as any)?.message || '登录失败')
    }
  } catch (e: any) {
    ElMessage.error(e.message || '登录失败')
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.login-wrap {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
}

.login-container {
  width: 100%;
  max-width: 400px;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.login-header {
  margin-bottom: 40px;
  text-align: center;
}

.logo {
  display: flex;
  flex-direction: column;
  align-items: center;
  color: white;
}

.logo-icon {
  font-size: 48px;
  margin-bottom: 16px;
  animation: bounce 2s infinite;
}

.logo-text h1 {
  margin: 0 0 8px 0;
  font-size: 28px;
  font-weight: 600;
  text-shadow: 0 2px 4px rgba(0,0,0,0.3);
}

.logo-text p {
  margin: 0;
  font-size: 16px;
  opacity: 0.9;
  font-weight: 300;
}

.login-card {
  width: 100%;
  border-radius: 16px;
  border: none;
  box-shadow: 0 20px 40px rgba(0,0,0,0.1);
  backdrop-filter: blur(10px);
  background: rgba(255,255,255,0.95);
}

.login-form {
  padding: 20px;
}

.login-form .el-form-item {
  margin-bottom: 24px;
}

.login-form .el-input {
  border-radius: 8px;
}

.login-form .el-input__wrapper {
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  border: 1px solid #e4e7ed;
  transition: all 0.3s ease;
}

.login-form .el-input__wrapper:hover {
  box-shadow: 0 4px 12px rgba(0,0,0,0.15);
  border-color: #409eff;
}

.login-form .el-input.is-focus .el-input__wrapper {
  box-shadow: 0 4px 12px rgba(64,158,255,0.2);
  border-color: #409eff;
}

.login-btn {
  width: 100%;
  height: 48px;
  border-radius: 8px;
  font-size: 16px;
  font-weight: 500;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
  transition: all 0.3s ease;
}

.login-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 20px rgba(102,126,234,0.4);
}

.login-btn:active {
  transform: translateY(0);
}

@keyframes bounce {
  0%, 20%, 50%, 80%, 100% {
    transform: translateY(0);
  }
  40% {
    transform: translateY(-10px);
  }
  60% {
    transform: translateY(-5px);
  }
}

/* 响应式设计 */
@media (max-width: 480px) {
  .login-container {
    max-width: 320px;
  }
  
  .logo-text h1 {
    font-size: 24px;
  }
  
  .logo-icon {
    font-size: 40px;
  }
}
</style>
