<template>
  <div>
    <el-card>
      <template #header>
        <div class="card-header">
          <h3>用户实名认证信息</h3>
          <el-button type="primary" @click="fetchData" :loading="loading">
            <el-icon><Refresh /></el-icon>
            刷新数据
          </el-button>
        </div>
      </template>

      <!-- 实名认证信息表格 -->
      <el-table :data="realNameList" stripe v-loading="loading">
        <el-table-column prop="id" label="记录ID" width="100" />
        <el-table-column prop="userId" label="用户ID" width="120" />
        <el-table-column prop="fullName" label="真实姓名" min-width="120" />
        <el-table-column prop="idNumber" label="身份证号" min-width="200">
          <template #default="{ row }">
            <span>{{ maskIdNumber(row.idNumber) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="120">
          <template #default="{ row }">
            <el-button size="small" @click="showDetail(row)">查看详情</el-button>
          </template>
        </el-table-column>
      </el-table>

      <el-empty v-if="!loading && realNameList.length === 0" description="暂无实名认证数据" />
    </el-card>

    <!-- 详情对话框 -->
    <el-dialog v-model="detailVisible" title="实名认证详情" width="500px">
      <el-descriptions v-if="selectedRecord" :column="1" border>
        <el-descriptions-item label="记录ID">{{ selectedRecord.id }}</el-descriptions-item>
        <el-descriptions-item label="用户ID">{{ selectedRecord.userId }}</el-descriptions-item>
        <el-descriptions-item label="真实姓名">{{ selectedRecord.fullName }}</el-descriptions-item>
        <el-descriptions-item label="身份证号">{{ selectedRecord.idNumber }}</el-descriptions-item>
      </el-descriptions>
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

// 获取所有实名认证信息
async function fetchData() {
  loading.value = true
  try {
    const res = await getAllRealNames()
    if (res.success) {
      realNameList.value = res.data || []
      ElMessage.success('数据加载成功')
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
}

// 页面加载时获取数据
onMounted(fetchData)
</script>

<style scoped>
.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
</style>
