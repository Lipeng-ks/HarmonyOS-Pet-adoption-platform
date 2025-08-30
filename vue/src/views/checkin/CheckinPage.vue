<template>
  <div class="checkin-page">
    <div class="page-header">
      <h2>用户签到管理</h2>
      <p>查看和管理所有用户签到记录</p>
    </div>

    <!-- 筛选器 -->
    <el-card class="filter-card" shadow="never">
      <template #header>
        <div class="card-header">
          <span>筛选条件</span>
          <el-button type="primary" size="small" @click="refreshData" :loading="loading">
            <el-icon><Refresh /></el-icon>
            刷新数据
          </el-button>
        </div>
      </template>
      <div class="filter-container">
        <el-row :gutter="20" align="middle">
          <el-col :span="6">
            <div class="filter-item">
              <label class="filter-label">用户ID</label>
              <el-input 
                v-model="filters.userId" 
                placeholder="输入用户ID"
                clearable
                size="default"
                @input="applyFilters"
              />
            </div>
          </el-col>
          
          <el-col :span="6">
            <div class="filter-item">
              <label class="filter-label">用户名</label>
              <el-input 
                v-model="filters.username" 
                placeholder="输入用户名"
                clearable
                size="default"
                @input="applyFilters"
              />
            </div>
          </el-col>
          
          <el-col :span="8">
            <div class="filter-item">
              <label class="filter-label">签到日期</label>
              <el-date-picker
                v-model="filters.dateRange"
                type="daterange"
                range-separator="至"
                start-placeholder="开始日期"
                end-placeholder="结束日期"
                size="default"
                style="width: 100%"
                @change="applyFilters"
              />
            </div>
          </el-col>
          
          <el-col :span="4">
            <div class="filter-item">
              <label class="filter-label">今日状态</label>
              <el-select 
                v-model="filters.todayStatus" 
                placeholder="全部"
                size="default"
                style="width: 100%"
                @change="applyFilters"
              >
                <el-option label="全部" value="" />
                <el-option label="已签到" value="checked" />
                <el-option label="未签到" value="unchecked" />
              </el-select>
            </div>
          </el-col>
        </el-row>
      </div>
    </el-card>

    <!-- 签到统计卡片 -->
    <div class="stats-cards">
      <el-card class="stat-card" shadow="hover">
        <div class="stat-content">
          <div class="stat-icon today-icon">
            <el-icon><Calendar /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-value">{{ todayCheckedCount }}</div>
            <div class="stat-label">今日已签到用户</div>
          </div>
        </div>
      </el-card>

      <el-card class="stat-card" shadow="hover">
        <div class="stat-content">
          <div class="stat-icon total-icon">
            <el-icon><DataLine /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-value">{{ filteredRecords.length }}</div>
            <div class="stat-label">总签到记录</div>
          </div>
        </div>
      </el-card>

      <el-card class="stat-card" shadow="hover">
        <div class="stat-content">
          <div class="stat-icon user-icon">
            <el-icon><User /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-value">{{ uniqueUsersCount }}</div>
            <div class="stat-label">活跃用户数</div>
          </div>
        </div>
      </el-card>
    </div>

    <!-- 签到记录表格 -->
    <el-card class="records-card" shadow="never">
      <template #header>
        <div class="card-header">
          <span>签到记录列表</span>
        </div>
      </template>

      <el-table 
        :data="paginatedRecords" 
        v-loading="loading"
        empty-text="暂无签到记录"
        :default-sort="{ prop: 'date', order: 'descending' }"
        class="checkin-table"
        size="large"
      >
        <el-table-column type="index" label="序号" width="80" align="center" />
        
        <el-table-column prop="userId" label="用户ID" width="120" sortable />
        <el-table-column prop="username" label="用户名" min-width="150" sortable />
        
        <el-table-column prop="date" label="签到日期" min-width="200" sortable>
          <template #default="{ row }">
            <span class="date-text">
              {{ formatDate(row.date) }}
            </span>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination-container">
        <el-pagination
          v-model:current-page="currentPage"
          v-model:page-size="pageSize"
          :page-sizes="[10, 20, 50, 100]"
          :total="filteredRecords.length"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        />
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { 
  Search, 
  Refresh 
} from '@element-plus/icons-vue'
import { 
  getCheckinDates, 
  getCheckins,
  checkin,
  getAllCheckins,
  type CheckinRecord,
  type CheckinSummary
} from '@/services/checkin'

// 响应式数据
const loading = ref(false)

// 签到数据
const allCheckinRecords = ref<CheckinRecord[]>([])

// 筛选条件
const filters = ref({
  userId: '',
  username: '',
  dateRange: null as [Date, Date] | null,
  todayStatus: '' // 'checked' | 'unchecked' | ''
})

// 分页
const currentPage = ref(1)
const pageSize = ref(20)

// 计算属性 - 筛选后的记录
const filteredRecords = computed(() => {
  let records = [...allCheckinRecords.value]

  // 按用户ID筛选
  if (filters.value.userId) {
    const userId = parseInt(filters.value.userId)
    if (!isNaN(userId)) {
      records = records.filter(record => record.userId === userId)
    }
  }

  // 按用户名筛选
  if (filters.value.username) {
    records = records.filter(record => 
      record.username.toLowerCase().includes(filters.value.username.toLowerCase())
    )
  }

  // 按日期范围筛选
  if (filters.value.dateRange && filters.value.dateRange.length === 2) {
    const [startDate, endDate] = filters.value.dateRange
    records = records.filter(record => {
      const recordDate = new Date(record.date)
      return recordDate >= startDate && recordDate <= endDate
    })
  }

  // 按今日状态筛选
  if (filters.value.todayStatus) {
    const today = new Date().toDateString()
    if (filters.value.todayStatus === 'checked') {
      records = records.filter(record => {
        const recordDate = new Date(record.date).toDateString()
        return recordDate === today
      })
    } else if (filters.value.todayStatus === 'unchecked') {
      records = records.filter(record => {
        const recordDate = new Date(record.date).toDateString()
        return recordDate !== today
      })
    }
  }

  // 按签到时间倒序排列
  return records.sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime())
})

// 分页后的记录
const paginatedRecords = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value
  const end = start + pageSize.value
  return filteredRecords.value.slice(start, end)
})

// 统计数据
const todayCheckedCount = computed(() => {
  const today = new Date().toDateString()
  const todayRecords = allCheckinRecords.value.filter(record => {
    const recordDate = new Date(record.date).toDateString()
    return recordDate === today
  })
  return new Set(todayRecords.map(r => r.userId)).size
})

const uniqueUsersCount = computed(() => {
  return new Set(filteredRecords.value.map(r => r.userId)).size
})

// 获取所有用户的签到记录
const loadAllCheckinData = async () => {
  loading.value = true
  console.log('开始加载签到数据...')
  
  try {
    // 首先尝试使用新的获取所有用户签到记录的接口
    console.log('尝试获取所有用户签到数据...')
    const result = await getAllCheckins()
    console.log('获取所有用户签到数据结果:', result)
    
    if (result.success && result.records && result.records.length > 0) {
      // 为每条记录添加ID
      const recordsWithId = result.records.map((record, index) => ({
        ...record,
        id: `${record.username}-${index}`
      }))
      
      allCheckinRecords.value = recordsWithId
      console.log('成功加载真实签到数据:', recordsWithId)
      ElMessage.success(`成功加载 ${recordsWithId.length} 条签到记录`)
    } else {
      console.log('后端没有签到数据，生成模拟数据用于展示')
      ElMessage.warning('暂无签到记录，生成模拟数据用于展示')
      
      // 生成多用户的模拟签到数据
      const testRecords: CheckinRecord[] = []
      const usernames = ['admin', 'user1', 'user2', 'test']
      
      usernames.forEach((username, userIndex) => {
        // 为每个用户生成最近15天的签到记录（随机缺少一些天）
        for (let i = 0; i < 15; i++) {
          // 随机跳过一些天，模拟真实签到情况
          if (Math.random() > 0.3) {
            const date = new Date()
            date.setDate(date.getDate() - i)
            testRecords.push({
              id: `${username}-${i}`,
              date: date.toISOString().split('T')[0],
              username: username,
              userId: userIndex + 1
            })
          }
        }
      })
      
      allCheckinRecords.value = testRecords
      console.log('添加多用户测试数据:', testRecords)
      ElMessage.success(`生成了 ${testRecords.length} 条模拟签到记录`)
    }
  } catch (error) {
    console.error('加载签到数据失败:', error)
    ElMessage.error('加载签到数据失败，请稍后重试')
    
    // 如果接口调用失败，也生成模拟数据
    const testRecords: CheckinRecord[] = []
    const usernames = ['admin', 'user1', 'user2', 'test']
    
    usernames.forEach((username, userIndex) => {
      for (let i = 0; i < 10; i++) {
        if (Math.random() > 0.4) {
          const date = new Date()
          date.setDate(date.getDate() - i)
          testRecords.push({
            id: `${username}-${i}`,
            date: date.toISOString().split('T')[0],
            username: username,
            userId: userIndex + 1
          })
        }
      }
    })
    
    allCheckinRecords.value = testRecords
    console.log('接口失败，使用备用测试数据:', testRecords)
  } finally {
    loading.value = false
  }
}

// 刷新数据
const refreshData = () => {
  loadAllCheckinData()
}

// 应用筛选
const applyFilters = () => {
  currentPage.value = 1 // 重置到第一页
}

// 分页处理
const handleSizeChange = (val: number) => {
  pageSize.value = val
  currentPage.value = 1
}

const handleCurrentChange = (val: number) => {
  currentPage.value = val
}

// 工具函数
const formatDate = (dateStr: string) => {
  if (!dateStr) return '-'
  return new Date(dateStr).toLocaleDateString('zh-CN')
}

const formatDateTime = (dateStr: string) => {
  if (!dateStr) return '-'
  return new Date(dateStr).toLocaleString('zh-CN')
}

const isToday = (dateStr: string) => {
  if (!dateStr) return false
  const today = new Date().toDateString()
  const checkDate = new Date(dateStr).toDateString()
  return today === checkDate
}

const isYesterday = (dateStr: string) => {
  if (!dateStr) return false
  const yesterday = new Date()
  yesterday.setDate(yesterday.getDate() - 1)
  const checkDate = new Date(dateStr).toDateString()
  return yesterday.toDateString() === checkDate
}

const getRelativeDate = (dateStr: string) => {
  if (!dateStr) return ''
  const date = new Date(dateStr)
  const today = new Date()
  const diffTime = today.getTime() - date.getTime()
  const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24))
  
  if (diffDays === 0) return '今天'
  if (diffDays === 1) return '昨天'
  if (diffDays === 2) return '前天'
  if (diffDays < 7) return `${diffDays}天前`
  if (diffDays < 30) return `${Math.floor(diffDays / 7)}周前`
  return `${Math.floor(diffDays / 30)}个月前`
}

onMounted(() => {
  loadAllCheckinData()
})
</script>

<style scoped>
.checkin-page {
  padding: 20px;
  background-color: #f5f7fa;
  min-height: calc(100vh - 60px);
}

.page-header {
  margin-bottom: 20px;
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

.filter-card {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: 600;
}

.filter-container {
  margin-bottom: 24px;
}

.filter-item {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.filter-label {
  font-weight: 500;
  color: #606266;
  font-size: 14px;
  margin-bottom: 8px;
  display: block;
}

.stats-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 20px;
  margin-bottom: 20px;
}

.stat-card {
  border-radius: 8px;
  transition: transform 0.2s;
}

.stat-card:hover {
  transform: translateY(-2px);
}

.stat-content {
  display: flex;
  align-items: center;
  padding: 10px 0;
}

.stat-icon {
  width: 60px;
  height: 60px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 16px;
  font-size: 24px;
  color: white;
}

.today-icon {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.streak-icon {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
}

.total-icon {
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
}

.user-icon {
  background: linear-gradient(135deg, #a8edea 0%, #fed6e3 100%);
}

.stat-info {
  flex: 1;
}

.stat-value {
  font-size: 28px;
  font-weight: 700;
  color: #303133;
  line-height: 1;
  margin-bottom: 4px;
}

.stat-label {
  font-size: 14px;
  color: #909399;
}

.records-card {
  border-radius: 8px;
}

.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: center;
}

/* 表格简约样式 */
.checkin-table {
  background: #ffffff;
  border: 1px solid #e4e7ed;
  border-radius: 6px;
}

/* 表格头部样式 */
.checkin-table :deep(.el-table__header-wrapper) {
  background: #f8f9fa;
}

.checkin-table :deep(.el-table__header th) {
  background: transparent;
  color: #606266;
  font-weight: 500;
  font-size: 14px;
  padding: 12px;
  border-bottom: 1px solid #e4e7ed;
}

/* 表格单元格样式 */
.checkin-table :deep(.el-table td) {
  padding: 12px;
  border-bottom: 1px solid #f0f2f5;
  color: #606266;
}

/* 表格行悬停效果 */
.checkin-table :deep(.el-table__row):hover {
  background-color: #f5f7fa;
}

/* 序号列样式 */
.checkin-table :deep(.el-table__column--type-index .cell) {
  color: #909399;
}

/* 日期文本样式 */
.date-text {
  color: #303133;
  font-weight: 500;
}

.text-muted {
  color: #909399;
  font-size: 13px;
}

:deep(.el-table) {
  border-radius: 8px;
}

:deep(.el-card__body) {
  padding: 20px;
}

:deep(.el-empty) {
  padding: 60px 0;
}
</style>
