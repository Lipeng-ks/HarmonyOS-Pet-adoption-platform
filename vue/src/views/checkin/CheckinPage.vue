<template>
  <div class="checkin-page">
    <!-- 页面标题 -->
    <div class="page-header">
      <h2>🎯 签到管理</h2>
      <p>查看和管理用户签到记录</p>
    </div>

    <!-- 筛选器 -->
    <el-card class="filter-card" shadow="never">
      <div class="filter-container">
        <el-row :gutter="16" align="middle">
          <el-col :span="5">
            <el-input 
              v-model="filters.userId" 
              placeholder="用户ID"
              clearable
              @input="applyFilters"
            />
          </el-col>
          
          <el-col :span="5">
            <el-input 
              v-model="filters.username" 
              placeholder="用户名"
              clearable
              @input="applyFilters"
            />
          </el-col>
          
          <el-col :span="8">
            <el-date-picker
              v-model="filters.dateRange"
              type="daterange"
              range-separator="至"
              start-placeholder="开始日期"
              end-placeholder="结束日期"
              style="width: 100%"
              @change="applyFilters"
            />
          </el-col>
          
          <el-col :span="4">
            <el-select 
              v-model="filters.todayStatus" 
              placeholder="今日状态"
              style="width: 100%"
              @change="applyFilters"
            >
              <el-option label="全部" value="" />
              <el-option label="已签到" value="checked" />
              <el-option label="未签到" value="unchecked" />
            </el-select>
          </el-col>
          
          <el-col :span="2">
            <el-button type="primary" @click="refreshData" :loading="loading">
              刷新
            </el-button>
          </el-col>
        </el-row>
      </div>
    </el-card>

    <!-- 统计卡片 -->
    <div class="stats-grid">
      <el-card class="stat-card">
        <div class="stat-content">
          <div class="stat-number">{{ todayCheckedCount }}</div>
          <div class="stat-label">今日签到</div>
        </div>
      </el-card>

      <el-card class="stat-card">
        <div class="stat-content">
          <div class="stat-number">{{ filteredRecords.length }}</div>
          <div class="stat-label">总记录数</div>
        </div>
      </el-card>

      <el-card class="stat-card">
        <div class="stat-content">
          <div class="stat-number">{{ uniqueUsersCount }}</div>
          <div class="stat-label">活跃用户</div>
        </div>
      </el-card>
    </div>

    <!-- 签到记录表格 -->
    <el-card class="table-card" shadow="never">
      <el-table 
        :data="paginatedRecords" 
        v-loading="loading"
        empty-text="暂无签到记录"
        :default-sort="{ prop: 'date', order: 'descending' }"
        class="simple-table"
      >
        <el-table-column type="index" label="#" width="60" align="center" />
        <el-table-column prop="userId" label="用户ID" width="100" sortable />
        <el-table-column prop="username" label="用户名" min-width="120" sortable />
        <el-table-column prop="date" label="签到日期" min-width="150" sortable>
          <template #default="{ row }">
            <span>{{ formatDate(row.date) }}</span>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination-wrapper">
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
import { ElMessage } from 'element-plus'
import { 
  getAllCheckins,
  type CheckinRecord
} from '@/services/checkin'

// 响应式数据
const loading = ref(false)
const allCheckinRecords = ref<CheckinRecord[]>([])

// 筛选条件
const filters = ref({
  userId: '',
  username: '',
  dateRange: null as [Date, Date] | null,
  todayStatus: ''
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
  
  try {
    const result = await getAllCheckins()
    
    if (result.success && result.records && result.records.length > 0) {
      const recordsWithId = result.records.map((record, index) => ({
        ...record,
        id: `${record.username}-${index}`
      }))
      
      allCheckinRecords.value = recordsWithId
      ElMessage.success(`成功加载 ${recordsWithId.length} 条签到记录`)
    } else {
      // 生成模拟数据
      const testRecords: CheckinRecord[] = []
      const usernames = ['admin', 'user1', 'user2', 'test']
      
      usernames.forEach((username, userIndex) => {
        for (let i = 0; i < 15; i++) {
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
      ElMessage.success(`生成了 ${testRecords.length} 条模拟签到记录`)
    }
  } catch (error) {
    console.error('加载签到数据失败:', error)
    ElMessage.error('加载签到数据失败')
    
    // 备用数据
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
  currentPage.value = 1
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

onMounted(() => {
  loadAllCheckinData()
})
</script>

<style scoped>
.checkin-page {
  padding: 24px;
  background: #f8f9fa;
  min-height: 100vh;
}

.page-header {
  margin-bottom: 24px;
}

.page-header h2 {
  margin: 0 0 8px 0;
  color: #1f2937;
  font-size: 28px;
  font-weight: 600;
}

.page-header p {
  margin: 0;
  color: #6b7280;
  font-size: 16px;
}

.filter-card {
  margin-bottom: 24px;
  border: none;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.filter-container {
  padding: 8px 0;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 20px;
  margin-bottom: 24px;
}

.stat-card {
  border: none;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  transition: transform 0.2s;
}

.stat-card:hover {
  transform: translateY(-2px);
}

.stat-content {
  text-align: center;
  padding: 8px 0;
}

.stat-number {
  font-size: 32px;
  font-weight: 700;
  color: #059669;
  margin-bottom: 4px;
}

.stat-label {
  font-size: 14px;
  color: #6b7280;
  font-weight: 500;
}

.table-card {
  border: none;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.simple-table {
  border-radius: 8px;
  overflow: hidden;
}

.pagination-wrapper {
  margin-top: 24px;
  display: flex;
  justify-content: center;
}

:deep(.el-table) {
  border: none;
}

:deep(.el-table th) {
  background: #f9fafb;
  color: #374151;
  font-weight: 600;
  border-bottom: 1px solid #e5e7eb;
}

:deep(.el-table td) {
  border-bottom: 1px solid #f3f4f6;
}

:deep(.el-table__row):hover {
  background: #f9fafb;
}

:deep(.el-card__body) {
  padding: 20px;
}
</style>