<template>
  <div class="analytics-page">
    <!-- 页面标题 -->
    <div class="page-header">
      <h2>📊 数据分析</h2>
      <p>宠物领养平台数据统计与分析</p>
    </div>

    <!-- 核心指标卡片 -->
    <el-row :gutter="20" class="metrics-row">
      <el-col :span="6">
        <el-card class="metric-card">
          <div class="metric-content">
            <div class="metric-icon adoption">🏠</div>
            <div class="metric-info">
              <div class="metric-value">{{ metrics.totalAdoptions }}</div>
              <div class="metric-label">总领养数</div>
              <div class="metric-change positive">+{{ metrics.adoptionGrowth }}%</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card class="metric-card">
          <div class="metric-content">
            <div class="metric-icon animals">🐾</div>
            <div class="metric-info">
              <div class="metric-value">{{ metrics.totalAnimals }}</div>
              <div class="metric-label">在册宠物</div>
              <div class="metric-change positive">+{{ metrics.animalGrowth }}%</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card class="metric-card">
          <div class="metric-content">
            <div class="metric-icon users">👥</div>
            <div class="metric-info">
              <div class="metric-value">{{ metrics.totalUsers }}</div>
              <div class="metric-label">注册用户</div>
              <div class="metric-change positive">+{{ metrics.userGrowth }}%</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card class="metric-card">
          <div class="metric-content">
            <div class="metric-icon success">✅</div>
            <div class="metric-info">
              <div class="metric-value">{{ metrics.successRate }}%</div>
              <div class="metric-label">成功率</div>
              <div class="metric-change positive">+{{ metrics.rateGrowth }}%</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 统计图表区域 -->
    <el-row :gutter="20" class="charts-row">
      <!-- 领养趋势 -->
      <el-col :span="12">
        <el-card class="chart-card">
          <template #header>
            <div class="card-header">
              <span>📈 领养趋势</span>
              <el-select v-model="trendPeriod" size="small" style="width: 120px">
                <el-option label="最近7天" value="7d" />
                <el-option label="最近30天" value="30d" />
                <el-option label="最近3个月" value="3m" />
              </el-select>
            </div>
          </template>
          <div class="trend-chart">
            <div class="chart-item" v-for="(item, index) in trendData" :key="index">
              <div class="chart-bar">
                <div class="bar-fill" :style="{ height: (item.value / maxTrendValue * 100) + '%' }"></div>
              </div>
              <div class="chart-label">{{ item.label }}</div>
              <div class="chart-value">{{ item.value }}</div>
            </div>
          </div>
        </el-card>
      </el-col>

      <!-- 宠物类型分布 -->
      <el-col :span="12">
        <el-card class="chart-card">
          <template #header>
            <span>🐕 宠物类型分布</span>
          </template>
          <div class="pie-chart">
            <div class="pie-item" v-for="(item, index) in typeData" :key="index">
              <div class="pie-color" :style="{ backgroundColor: item.color }"></div>
              <div class="pie-info">
                <span class="pie-name">{{ item.name }}</span>
                <span class="pie-value">{{ item.value }}只 ({{ item.percentage }}%)</span>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20" class="charts-row">
      <!-- 城市分布 -->
      <el-col :span="12">
        <el-card class="chart-card">
          <template #header>
            <span>🏙️ 城市分布</span>
          </template>
          <div class="city-chart">
            <div class="city-item" v-for="(item, index) in cityData" :key="index">
              <div class="city-name">{{ item.city }}</div>
              <div class="city-bar">
                <div class="city-fill" :style="{ width: (item.count / maxCityValue * 100) + '%' }"></div>
              </div>
              <div class="city-count">{{ item.count }}</div>
            </div>
          </div>
        </el-card>
      </el-col>

      <!-- 用户活跃度 -->
      <el-col :span="12">
        <el-card class="chart-card">
          <template #header>
            <span>📊 用户活跃度</span>
          </template>
          <div class="activity-chart">
            <div class="activity-item" v-for="(item, index) in activityData" :key="index">
              <div class="activity-day">{{ item.day }}</div>
              <div class="activity-bars">
                <div class="activity-bar new">
                  <div class="bar-fill" :style="{ height: (item.newUsers / maxActivityValue * 100) + '%' }"></div>
                </div>
                <div class="activity-bar active">
                  <div class="bar-fill" :style="{ height: (item.activeUsers / maxActivityValue * 100) + '%' }"></div>
                </div>
              </div>
              <div class="activity-values">
                <span class="new-users">新用户: {{ item.newUsers }}</span>
                <span class="active-users">活跃: {{ item.activeUsers }}</span>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 数据表格 -->
    <el-card class="table-card">
      <template #header>
        <div class="card-header">
          <span>📋 详细数据</span>
          <div class="header-actions">
            <el-button type="primary" size="small" @click="exportData">
              <el-icon><Download /></el-icon>
              导出报表
            </el-button>
          </div>
        </div>
      </template>
      
      <el-table :data="detailData" stripe>
        <el-table-column prop="date" label="日期" width="120" />
        <el-table-column prop="adoptions" label="领养数" width="100" />
        <el-table-column prop="newAnimals" label="新增宠物" width="100" />
        <el-table-column prop="newUsers" label="新增用户" width="100" />
        <el-table-column prop="successRate" label="成功率" width="100">
          <template #default="{ row }">
            <el-tag :type="row.successRate > 80 ? 'success' : row.successRate > 60 ? 'warning' : 'danger'">
              {{ row.successRate }}%
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="revenue" label="收入" width="120">
          <template #default="{ row }">
            ¥{{ row.revenue.toLocaleString() }}
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted, watch } from 'vue'
import { Download } from '@element-plus/icons-vue'
import { ElMessage, ElLoading } from 'element-plus'
import analyticsService from '@/services/analytics'
import type { 
  MetricsData, 
  TrendData, 
  TypeDistribution, 
  CityDistribution, 
  ActivityData, 
  DetailData 
} from '@/services/analytics'

// 响应式数据
const trendPeriod = ref('30d')
const loading = ref(false)

// 核心指标数据
const metrics = reactive<MetricsData>({
  totalAdoptions: 0,
  adoptionGrowth: 0,
  totalAnimals: 0,
  animalGrowth: 0,
  totalUsers: 0,
  userGrowth: 0,
  successRate: 0,
  rateGrowth: 0
})

// 各种数据
const trendData = ref<TrendData[]>([])
const typeData = ref<TypeDistribution[]>([])
const cityData = ref<CityDistribution[]>([])
const activityData = ref<ActivityData[]>([])
const detailData = ref<DetailData[]>([])

// 计算最大值用于图表比例
const maxTrendValue = computed(() => {
  if (trendData.value.length === 0) return 1
  return Math.max(...trendData.value.map(item => item.value))
})

const maxCityValue = computed(() => {
  if (cityData.value.length === 0) return 1
  return Math.max(...cityData.value.map(item => item.count))
})

const maxActivityValue = computed(() => {
  if (activityData.value.length === 0) return 1
  return Math.max(...activityData.value.map(item => Math.max(item.newUsers, item.activeUsers)))
})

// 加载所有数据
async function loadAllData() {
  loading.value = true
  try {
    // 并行加载所有数据
    const [
      metricsRes,
      trendRes,
      typeRes,
      cityRes,
      activityRes,
      detailRes
    ] = await Promise.all([
      analyticsService.getMetrics(),
      analyticsService.getTrendData(trendPeriod.value),
      analyticsService.getTypeDistribution(),
      analyticsService.getCityDistribution(),
      analyticsService.getActivityData(),
      analyticsService.getDetailData()
    ])

    // 更新数据
    Object.assign(metrics, metricsRes)
    trendData.value = trendRes
    typeData.value = typeRes
    cityData.value = cityRes
    activityData.value = activityRes
    detailData.value = detailRes

    ElMessage.success('数据加载成功')
  } catch (error) {
    console.error('加载数据失败:', error)
    ElMessage.error('数据加载失败，请稍后重试')
    
    // 加载失败时使用默认数据
    loadDefaultData()
  } finally {
    loading.value = false
  }
}

// 加载默认数据（作为后备方案）
function loadDefaultData() {
  Object.assign(metrics, {
    totalAdoptions: 1248,
    adoptionGrowth: 12.5,
    totalAnimals: 856,
    animalGrowth: 8.3,
    totalUsers: 3420,
    userGrowth: 15.2,
    successRate: 78.5,
    rateGrowth: 3.2
  })

  trendData.value = [
    { label: '1月', value: 120 },
    { label: '2月', value: 132 },
    { label: '3月', value: 101 },
    { label: '4月', value: 134 },
    { label: '5月', value: 90 },
    { label: '6月', value: 230 }
  ]

  typeData.value = [
    { name: '狗狗', value: 45, percentage: 45, color: '#409EFF' },
    { name: '猫咪', value: 32, percentage: 32, color: '#67C23A' },
    { name: '兔子', value: 15, percentage: 15, color: '#E6A23C' },
    { name: '其他', value: 8, percentage: 8, color: '#F56C6C' }
  ]

  cityData.value = [
    { city: '北京', count: 220 },
    { city: '上海', count: 182 },
    { city: '广州', count: 191 },
    { city: '深圳', count: 234 },
    { city: '杭州', count: 290 },
    { city: '成都', count: 330 }
  ]

  activityData.value = [
    { day: '周一', newUsers: 120, activeUsers: 60 },
    { day: '周二', newUsers: 200, activeUsers: 120 },
    { day: '周三', newUsers: 150, activeUsers: 100 },
    { day: '周四', newUsers: 80, activeUsers: 40 },
    { day: '周五', newUsers: 70, activeUsers: 35 },
    { day: '周六', newUsers: 110, activeUsers: 55 },
    { day: '周日', newUsers: 130, activeUsers: 65 }
  ]

  detailData.value = [
    { date: '2024-01-01', adoptions: 45, newAnimals: 32, newUsers: 128, successRate: 82, revenue: 15600 },
    { date: '2024-01-02', adoptions: 38, newAnimals: 28, newUsers: 95, successRate: 76, revenue: 12800 },
    { date: '2024-01-03', adoptions: 52, newAnimals: 35, newUsers: 142, successRate: 85, revenue: 18200 },
    { date: '2024-01-04', adoptions: 41, newAnimals: 30, newUsers: 108, successRate: 79, revenue: 14300 },
    { date: '2024-01-05', adoptions: 47, newAnimals: 33, newUsers: 125, successRate: 81, revenue: 16500 }
  ]
}

// 导出数据
async function exportData() {
  try {
    const result = await analyticsService.exportReport(trendPeriod.value)
    ElMessage.success(result.message || '报表导出成功')
  } catch (error) {
    console.error('导出失败:', error)
    ElMessage.error('报表导出失败，请稍后重试')
  }
}

// 监听周期变化，重新加载趋势数据
watch(trendPeriod, async (newPeriod) => {
  try {
    const newTrendData = await analyticsService.getTrendData(newPeriod)
    trendData.value = newTrendData
  } catch (error) {
    console.error('加载趋势数据失败:', error)
    ElMessage.error('加载趋势数据失败')
  }
})

// 组件挂载时加载数据
onMounted(() => {
  loadAllData()
})
</script>

<style scoped>
.analytics-page {
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

.metrics-row {
  margin-bottom: 24px;
}

.metric-card {
  border-radius: 12px;
  border: none;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
}

.metric-content {
  display: flex;
  align-items: center;
  gap: 16px;
}

.metric-icon {
  width: 60px;
  height: 60px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
}

.metric-icon.adoption {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.metric-icon.animals {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
}

.metric-icon.users {
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
}

.metric-icon.success {
  background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
}

.metric-info {
  flex: 1;
}

.metric-value {
  font-size: 28px;
  font-weight: 700;
  color: #303133;
  line-height: 1;
  margin-bottom: 4px;
}

.metric-label {
  font-size: 14px;
  color: #909399;
  margin-bottom: 4px;
}

.metric-change {
  font-size: 12px;
  font-weight: 600;
}

.metric-change.positive {
  color: #67c23a;
}

.charts-row {
  margin-bottom: 24px;
}

.chart-card,
.table-card {
  border-radius: 12px;
  border: none;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: 600;
  color: #303133;
}

.header-actions {
  display: flex;
  gap: 8px;
}

/* 趋势图表样式 */
.trend-chart {
  display: flex;
  align-items: end;
  gap: 20px;
  height: 200px;
  padding: 20px 0;
}

.chart-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
}

.chart-bar {
  width: 30px;
  height: 150px;
  background: #f0f0f0;
  border-radius: 4px;
  position: relative;
  display: flex;
  align-items: end;
}

.bar-fill {
  width: 100%;
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
  border-radius: 4px;
  transition: height 0.3s ease;
}

.chart-label {
  font-size: 12px;
  color: #909399;
}

.chart-value {
  font-size: 14px;
  font-weight: 600;
  color: #303133;
}

/* 饼图样式 */
.pie-chart {
  padding: 20px 0;
}

.pie-item {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 16px;
}

.pie-color {
  width: 16px;
  height: 16px;
  border-radius: 50%;
}

.pie-info {
  flex: 1;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.pie-name {
  font-weight: 500;
  color: #303133;
}

.pie-value {
  font-size: 14px;
  color: #909399;
}

/* 城市图表样式 */
.city-chart {
  padding: 20px 0;
}

.city-item {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 16px;
}

.city-name {
  width: 60px;
  font-size: 14px;
  color: #303133;
}

.city-bar {
  flex: 1;
  height: 20px;
  background: #f0f0f0;
  border-radius: 10px;
  position: relative;
}

.city-fill {
  height: 100%;
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
  border-radius: 10px;
  transition: width 0.3s ease;
}

.city-count {
  width: 40px;
  text-align: right;
  font-size: 14px;
  font-weight: 600;
  color: #303133;
}

/* 活跃度图表样式 */
.activity-chart {
  display: flex;
  justify-content: space-between;
  align-items: end;
  height: 200px;
  padding: 20px 0;
}

.activity-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
}

.activity-day {
  font-size: 12px;
  color: #909399;
}

.activity-bars {
  display: flex;
  gap: 4px;
  align-items: end;
}

.activity-bar {
  width: 20px;
  height: 120px;
  background: #f0f0f0;
  border-radius: 2px;
  position: relative;
  display: flex;
  align-items: end;
}

.activity-bar.new .bar-fill {
  background: #4facfe;
}

.activity-bar.active .bar-fill {
  background: #00f2fe;
}

.activity-values {
  display: flex;
  flex-direction: column;
  gap: 2px;
  font-size: 10px;
  text-align: center;
}

.new-users {
  color: #4facfe;
}

.active-users {
  color: #00f2fe;
}

:deep(.el-card__header) {
  padding: 16px 20px;
  border-bottom: 1px solid #f0f0f0;
}

:deep(.el-card__body) {
  padding: 20px;
}
</style>