<template>
  <div class="dashboard">
    <!-- 页面标题 -->
    <div class="page-header">
      <h1>仪表盘</h1>
      <p>宠物领养平台管理概览</p>
    </div>

    <!-- 统计卡片 -->
    <el-row :gutter="24" class="stats-row">
      <el-col :xs="24" :sm="12" :md="6">
        <el-card class="stat-card" shadow="hover">
          <div class="stat-content">
            <div class="stat-icon animals">
              <el-icon><PetIcon /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-number">{{ stats.totalAnimals }}</div>
              <div class="stat-label">待领养宠物</div>
            </div>
          </div>
        </el-card>
      </el-col>
      
      <el-col :xs="24" :sm="12" :md="6">
        <el-card class="stat-card" shadow="hover">
          <div class="stat-content">
            <div class="stat-icon users">
              <el-icon><User /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-number">{{ stats.totalUsers }}</div>
              <div class="stat-label">注册用户</div>
            </div>
          </div>
        </el-card>
      </el-col>
      
      <el-col :xs="24" :sm="12" :md="6">
        <el-card class="stat-card" shadow="hover">
          <div class="stat-content">
            <div class="stat-icon orders">
              <el-icon><DocumentChecked /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-number">{{ stats.totalOrders }}</div>
              <div class="stat-label">领养订单</div>
            </div>
          </div>
        </el-card>
      </el-col>
      
      <el-col :xs="24" :sm="12" :md="6">
        <el-card class="stat-card" shadow="hover">
          <div class="stat-content">
            <div class="stat-icon success">
              <el-icon><SuccessFilled /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-number">{{ stats.adoptedAnimals }}</div>
              <div class="stat-label">成功领养</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 功能区域 -->
    <el-row :gutter="24" class="content-row">
      <!-- 快捷操作 -->
      <el-col :xs="24" :lg="12">
        <el-card class="function-card" shadow="hover">
          <template #header>
            <div class="card-header">
              <h3>快捷操作</h3>
              <p>常用功能快速入口</p>
            </div>
          </template>
          
          <div class="quick-actions">
            <div class="action-item" @click="$router.push('/animals')">
              <div class="action-icon">
                <el-icon><Collection /></el-icon>
              </div>
              <div class="action-info">
                <div class="action-title">动物管理</div>
                <div class="action-desc">管理宠物信息</div>
              </div>
              <el-icon class="action-arrow"><ArrowRight /></el-icon>
            </div>
            
            <div class="action-item" @click="$router.push('/orders')">
              <div class="action-icon">
                <el-icon><Document /></el-icon>
              </div>
              <div class="action-info">
                <div class="action-title">订单管理</div>
                <div class="action-desc">处理领养申请</div>
              </div>
              <el-icon class="action-arrow"><ArrowRight /></el-icon>
            </div>
            
            <div class="action-item" @click="$router.push('/users')">
              <div class="action-icon">
                <el-icon><UserFilled /></el-icon>
              </div>
              <div class="action-info">
                <div class="action-title">用户管理</div>
                <div class="action-desc">管理用户信息</div>
              </div>
              <el-icon class="action-arrow"><ArrowRight /></el-icon>
            </div>
            
            <div class="action-item" @click="$router.push('/checkin')">
              <div class="action-icon">
                <el-icon><Calendar /></el-icon>
              </div>
              <div class="action-info">
                <div class="action-title">签到管理</div>
                <div class="action-desc">查看签到记录</div>
              </div>
              <el-icon class="action-arrow"><ArrowRight /></el-icon>
            </div>
          </div>
        </el-card>
      </el-col>

      <!-- 系统信息 -->
      <el-col :xs="24" :lg="12">
        <el-card class="function-card" shadow="hover">
          <template #header>
            <div class="card-header">
              <h3>系统信息</h3>
              <p>平台运行状态</p>
            </div>
          </template>
          
          <div class="system-info">
            <div class="info-item">
              <span class="info-label">系统版本</span>
              <span class="info-value">v1.0.0</span>
            </div>
            <div class="info-item">
              <span class="info-label">运行时间</span>
              <span class="info-value">{{ uptime }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">数据库状态</span>
              <el-tag type="success" size="small">正常</el-tag>
            </div>
            <div class="info-item">
              <span class="info-label">服务状态</span>
              <el-tag type="success" size="small">运行中</el-tag>
            </div>
          </div>
          
          <div class="welcome-message">
            <el-icon class="welcome-icon"><House /></el-icon>
            <p>欢迎使用宠物领养平台管理系统！让我们一起为小动物们找到温暖的家。</p>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { 
  Collection, 
  User, 
  Document, 
  DocumentChecked,
  SuccessFilled,
  ArrowRight,
  UserFilled,
  Calendar,
  House
} from '@element-plus/icons-vue'

// 创建一个宠物图标组件
const PetIcon = {
  render() {
    return '🐾'
  }
}

// 统计数据
const stats = ref({
  totalAnimals: 0,
  totalUsers: 0,
  totalOrders: 0,
  adoptedAnimals: 0
})

// 系统运行时间
const uptime = ref('0天')

// 模拟获取统计数据
const fetchStats = async () => {
  // 这里可以调用实际的API
  stats.value = {
    totalAnimals: 156,
    totalUsers: 1248,
    totalOrders: 89,
    adoptedAnimals: 67
  }
}

// 计算运行时间
const calculateUptime = () => {
  const startTime = new Date('2024-01-01')
  const now = new Date()
  const diffTime = Math.abs(now.getTime() - startTime.getTime())
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24))
  uptime.value = `${diffDays}天`
}

onMounted(() => {
  fetchStats()
  calculateUptime()
})
</script>

<style scoped>
.dashboard {
  padding: 24px;
  background: #f5f7fa;
  min-height: calc(100vh - 60px);
}

/* 页面标题 */
.page-header {
  margin-bottom: 32px;
}

.page-header h1 {
  margin: 0 0 8px 0;
  font-size: 28px;
  font-weight: 600;
  color: #303133;
}

.page-header p {
  margin: 0;
  font-size: 16px;
  color: #909399;
}

/* 统计卡片 */
.stats-row {
  margin-bottom: 24px;
}

.stat-card {
  border: none;
  border-radius: 12px;
  transition: all 0.3s ease;
}

.stat-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
}

.stat-content {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 8px 0;
}

.stat-icon {
  width: 56px;
  height: 56px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  color: white;
}

.stat-icon.animals {
  background: linear-gradient(135deg, #ff9a9e 0%, #fecfef 100%);
}

.stat-icon.users {
  background: linear-gradient(135deg, #a8edea 0%, #fed6e3 100%);
}

.stat-icon.orders {
  background: linear-gradient(135deg, #ffecd2 0%, #fcb69f 100%);
}

.stat-icon.success {
  background: linear-gradient(135deg, #c3f0ca 0%, #faf8cc 100%);
}

.stat-info {
  flex: 1;
}

.stat-number {
  font-size: 32px;
  font-weight: 700;
  color: #303133;
  line-height: 1;
  margin-bottom: 4px;
}

.stat-label {
  font-size: 14px;
  color: #909399;
  font-weight: 500;
}

/* 功能卡片 */
.content-row {
  margin-bottom: 24px;
}

.function-card {
  border: none;
  border-radius: 12px;
  height: 100%;
}

.function-card :deep(.el-card__header) {
  padding: 24px 24px 16px 24px;
  border-bottom: 1px solid #f0f2f5;
}

.function-card :deep(.el-card__body) {
  padding: 24px;
}

.card-header h3 {
  margin: 0 0 4px 0;
  font-size: 18px;
  font-weight: 600;
  color: #303133;
}

.card-header p {
  margin: 0;
  font-size: 14px;
  color: #909399;
}

/* 快捷操作 */
.quick-actions {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.action-item {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 16px;
  border-radius: 8px;
  background: #fafbfc;
  border: 1px solid #f0f2f5;
  cursor: pointer;
  transition: all 0.3s ease;
}

.action-item:hover {
  background: #f0f9ff;
  border-color: #409eff;
  transform: translateX(4px);
}

.action-icon {
  width: 40px;
  height: 40px;
  border-radius: 8px;
  background: linear-gradient(135deg, #409eff 0%, #36cfc9 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 18px;
}

.action-info {
  flex: 1;
}

.action-title {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
  margin-bottom: 2px;
}

.action-desc {
  font-size: 13px;
  color: #909399;
}

.action-arrow {
  color: #c0c4cc;
  font-size: 16px;
  transition: all 0.3s ease;
}

.action-item:hover .action-arrow {
  color: #409eff;
  transform: translateX(4px);
}

/* 系统信息 */
.system-info {
  margin-bottom: 24px;
}

.info-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 0;
  border-bottom: 1px solid #f0f2f5;
}

.info-item:last-child {
  border-bottom: none;
}

.info-label {
  font-size: 14px;
  color: #606266;
  font-weight: 500;
}

.info-value {
  font-size: 14px;
  color: #303133;
  font-weight: 600;
}

/* 欢迎信息 */
.welcome-message {
  padding: 20px;
  background: linear-gradient(135deg, #f0f9ff 0%, #e6f7ff 100%);
  border-radius: 8px;
  border: 1px solid #b3d8ff;
  text-align: center;
}

.welcome-icon {
  font-size: 24px;
  color: #409eff;
  margin-bottom: 8px;
}

.welcome-message p {
  margin: 0;
  font-size: 14px;
  color: #606266;
  line-height: 1.6;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .dashboard {
    padding: 16px;
  }
  
  .page-header h1 {
    font-size: 24px;
  }
  
  .stat-number {
    font-size: 28px;
  }
  
  .action-item {
    padding: 12px;
  }
  
  .action-icon {
    width: 36px;
    height: 36px;
    font-size: 16px;
  }
}

@media (max-width: 480px) {
  .stats-row {
    margin-bottom: 16px;
  }
  
  .content-row {
    margin-bottom: 16px;
  }
  
  .stat-content {
    gap: 12px;
  }
  
  .stat-icon {
    width: 48px;
    height: 48px;
    font-size: 20px;
  }
  
  .stat-number {
    font-size: 24px;
  }
}
</style>