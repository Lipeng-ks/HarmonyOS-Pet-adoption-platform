<template>
  <div class="layout">
    <el-container class="full">
      <el-aside width="220px" class="aside">
        <div class="brand">宠物领养 · 管理</div>
        <el-menu :default-active="active" router>
          <el-menu-item index="/dashboard">
            <el-icon><Odometer /></el-icon>
            <span>仪表板</span>
          </el-menu-item>
          
          <el-sub-menu index="business">
            <template #title>
              <el-icon><House /></el-icon>
              <span>业务管理</span>
            </template>
            <el-menu-item index="/animals">
              <el-icon><Collection /></el-icon>
              <span>动物管理</span>
            </el-menu-item>
            <el-menu-item index="/orders">
              <el-icon><Document /></el-icon>
              <span>订单管理</span>
            </el-menu-item>
            <el-menu-item index="/lost">
              <el-icon><Search /></el-icon>
              <span>寻宠管理</span>
            </el-menu-item>
            <el-menu-item index="/adoption">
              <el-icon><House /></el-icon>
              <span>宠物领养</span>
            </el-menu-item>
          </el-sub-menu>

          <el-sub-menu index="user">
            <template #title>
              <el-icon><User /></el-icon>
              <span>用户管理</span>
            </template>
            <el-menu-item index="/users">
              <el-icon><User /></el-icon>
              <span>用户列表</span>
            </el-menu-item>
            <el-menu-item index="/realname">
              <el-icon><CreditCard /></el-icon>
              <span>实名认证</span>
            </el-menu-item>
            <el-menu-item index="/checkin">
              <el-icon><Calendar /></el-icon>
              <span>签到管理</span>
            </el-menu-item>
          </el-sub-menu>

          <el-menu-item index="/analytics">
            <el-icon><DataAnalysis /></el-icon>
            <span>数据分析</span>
          </el-menu-item>



          <el-sub-menu index="system">
            <template #title>
              <el-icon><Setting /></el-icon>
              <span>系统管理</span>
            </template>
            <el-menu-item index="/cities">
              <el-icon><Location /></el-icon>
              <span>城市管理</span>
            </el-menu-item>
            <el-menu-item index="/permissions">
              <el-icon><Lock /></el-icon>
              <span>权限管理</span>
            </el-menu-item>
            <el-menu-item index="/settings">
              <el-icon><Tools /></el-icon>
              <span>系统设置</span>
            </el-menu-item>
          </el-sub-menu>
        </el-menu>
      </el-aside>

      <el-container>
        <el-header class="header">
          <div />
          <div class="right">
            <el-button link @click="onLogout">
              <el-icon><SwitchButton /></el-icon>
              退出登录
            </el-button>
          </div>
        </el-header>
        <el-main>
          <router-view />
        </el-main>
      </el-container>
    </el-container>
  </div>
</template>

<script setup lang="ts">
import { useRoute, useRouter } from 'vue-router'
import { 
  User, 
  Search, 
  Location, 
  Setting, 
  House, 
  Calendar,
  Collection,
  Document,
  DataAnalysis,
  CreditCard,
  Lock,
  Tools,
  Odometer,
  SwitchButton
} from '@element-plus/icons-vue'
import { computed } from 'vue'
import { useAuthStore } from '@/stores/auth'

const route = useRoute()
const router = useRouter()
const auth = useAuthStore()

const active = computed(() => route.path)

function onLogout() {
  auth.logout()
  router.replace({ name: 'login' })
}
</script>

<style scoped>
.full { height: 100vh; }
.aside { border-right: 1px solid #eee; display: flex; flex-direction: column; }
.brand { height: 56px; display: flex; align-items: center; padding: 0 16px; font-weight: 600; }
.header { border-bottom: 1px solid #eee; display: flex; align-items: center; justify-content: space-between; }
.right { display: flex; align-items: center; gap: 8px; }
</style>
