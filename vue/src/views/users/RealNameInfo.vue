<template>
  <div class="realname-page">
    <!-- 页面标题 -->
    <div class="page-header">
      <h2>🆔 实名认证管理</h2>
      <p>查看和管理用户实名认证信息</p>
    </div>

    <!-- 统计信息 -->
    <div class="stats-card">
      <el-card shadow="never">
        <div class="stats-content">
          <div class="stat-item">
            <div class="stat-number">{{ realNameList.length }}</div>
            <div class="stat-label">认证用户数</div>
          </div>
          <el-button type="primary" @click="fetchData" :loading="loading">
            刷新数据
          </el-button>
        </div>
      </el-card>
    </div>

    <!-- 实名认证信息表格 -->
    <el-card class="table-card" shadow="never">
      <el-table 
        :data="realNameList" 
        v-loading="loading"
        empty-text="暂无实名认证数据"
        class="simple-table"
      >
        <el-table-column type="index" label="#" width="60" align="center" />
        <el-table-column prop="userId" label="用户ID" width="100" />
        <el-table-column prop="fullName" label="真实姓名" min-width="120" />
        <el-table-column label="身份证号" min-width="200">
          <template #default="{ row }">
            <span class="id-number">{{ maskIdNumber(row.idNumber) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="120">
          <template #default="{ row }">
            <el-button size="small" type="primary" @click="showDetail(row)">
              查看详情
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <el-empty 
        v-if="!loading && realNameList.length === 0" 
        description="暂无实名认证数据"
        :image-size="120"
      />
    </el-card>

    <!-- 详情对话框 -->
    <el-dialog 
      v-model="detailVisible" 
      title="实名认证详情" 
      width="450px"
      :close-on-click-modal="false"
    >
      <div v-if="selectedRecord" class="detail-content">
        <el-descriptions :column="1" border size="default">
          <el-descriptions-item label="记录ID">
            <span class="record-id">{{ selectedRecord.id }}</span>
          </el-descriptions-item>
          <el-descriptions-item label="用户ID">
            <span class="user-id">{{ selectedRecord.userId }}</span>
          </el-descriptions-item>
          <el-descriptions-item label="真实姓名">
            <span class="full-name">{{ selectedRecord.fullName }}</span>
          </el-descriptions-item>
          <el-descriptions-item label="身份证号">
            <div class="id-info">
              <span class="masked-id">{{ maskIdNumber(selectedRecord.idNumber) }}</span>
              <el-button 
                size="small" 
                type="warning" 
                @click="showFullId = !showFullId"
                style="margin-left: 8px"
              >
                {{ showFullId ? '隐藏' : '显示' }}
              </el-button>
            </div>
            <div v-if="showFullId" class="full-id">
              <el-alert 
                :title="selectedRecord.idNumber" 
                type="warning" 
                :closable="false"
                show-icon
              />
            </div>
          </el-descriptions-item>
        </el-descriptions>
      </div>
      
      <template #footer>
        <el-button @click="detailVisible = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { getAllRealNames, type RealNameRecord } from '@/services/realname'

const loading = ref(false)
const realNameList = ref<RealNameRecord[]>([])
const detailVisible = ref(false)
const selectedRecord = ref<RealNameRecord | null>(null)
const showFullId = ref(false)

// 获取所有实名认证信息
async function fetchData() {
  loading.value = true
  try {
    const res = await getAllRealNames()
    if (res.success) {
      realNameList.value = res.data || []
      ElMessage.success(`成功加载 ${realNameList.value.length} 条认证记录`)
    } else {
      ElMessage.error(res.message || '获取数据失败')
    }
  } catch (error: any) {
    ElMessage.error(error.message || '获取数据失败')
  } finally {
    loading.value = false
  }
}

// 身份证号掩码处理
function maskIdNumber(idNumber: string): string {
  if (!idNumber || idNumber.length < 5) {
    return '****'
  }
  return idNumber.substring(0, 3) + '****' + idNumber.substring(idNumber.length - 2)
}

// 显示详情
function showDetail(record: RealNameRecord) {
  selectedRecord.value = record
  detailVisible.value = true
  showFullId.value = false // 重置显示状态
}

// 页面加载时获取数据
onMounted(fetchData)
</script>

<style scoped>
.realname-page {
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

.stats-card {
  margin-bottom: 24px;
}

.stats-card .el-card {
  border: none;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.stats-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.stat-item {
  display: flex;
  flex-direction: column;
  align-items: center;
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

.id-number {
  font-family: 'Courier New', monospace;
  color: #374151;
  font-weight: 500;
}

.detail-content {
  padding: 8px 0;
}

.record-id {
  color: #6b7280;
  font-family: monospace;
}

.user-id {
  color: #059669;
  font-weight: 600;
}

.full-name {
  color: #1f2937;
  font-weight: 600;
}

.id-info {
  display: flex;
  align-items: center;
}

.masked-id {
  font-family: 'Courier New', monospace;
  color: #374151;
  font-weight: 500;
}

.full-id {
  margin-top: 8px;
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

:deep(.el-empty) {
  padding: 60px 0;
}

:deep(.el-descriptions__label) {
  font-weight: 600;
  color: #374151;
}

:deep(.el-alert) {
  margin: 0;
}
</style>