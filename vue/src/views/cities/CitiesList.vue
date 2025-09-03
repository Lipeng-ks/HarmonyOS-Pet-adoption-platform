<template>
  <div class="cities-page">
    <!-- 页面标题 -->
    <div class="page-header">
      <h2>🏙️ 城市管理</h2>
      <p>查看和管理城市信息</p>
    </div>

    <!-- 搜索筛选 -->
    <el-card class="filter-card" shadow="never">
      <div class="filter-container">
        <el-row :gutter="16" align="middle">
          <el-col :span="8">
            <el-input
              v-model="searchKeyword"
              placeholder="搜索城市名称"
              clearable
              @input="onSearch"
            >
              <template #prefix>
                <el-icon><Search /></el-icon>
              </template>
            </el-input>
          </el-col>
          
          <el-col :span="6">
            <el-select
              v-model="selectedProvince"
              placeholder="选择省份"
              style="width: 100%"
              clearable
              @change="onProvinceChange"
            >
              <el-option
                v-for="province in provinces"
                :key="province"
                :value="province"
                :label="province"
              />
            </el-select>
          </el-col>
          
          <el-col :span="4">
            <div class="result-count">
              共 {{ list.length }} 个城市
            </div>
          </el-col>
        </el-row>
      </div>
    </el-card>

    <!-- 城市列表 -->
    <el-card class="table-card" shadow="never">
      <el-table 
        :data="list" 
        v-loading="loading" 
        empty-text="暂无匹配的城市数据"
        class="simple-table"
      >
        <el-table-column type="index" label="#" width="60" align="center" />
        <el-table-column prop="name" label="城市名称" min-width="160" />
        <el-table-column prop="province" label="所属省份" min-width="140" />
        <el-table-column prop="code" label="城市编码" width="120" />
      </el-table>

      <el-empty 
        v-if="!loading && list.length === 0" 
        description="暂无匹配的城市数据"
        :image-size="120"
      />
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { ElMessage } from 'element-plus'
import { Search } from '@element-plus/icons-vue'
import { listCities, type City } from '@/services/cities'

const loading = ref(false)
const searchKeyword = ref('')
const selectedProvince = ref('')
const allCities = ref<City[]>([])

// 获取所有省份列表
const provinces = computed(() => {
  const provinceSet = new Set<string>()
  allCities.value.forEach(city => {
    if (city.province) {
      provinceSet.add(city.province)
    }
  })
  return Array.from(provinceSet).sort()
})

// 过滤后的城市列表
const list = computed(() => {
  let filtered = allCities.value
  
  // 按城市名称搜索
  if (searchKeyword.value) {
    filtered = filtered.filter(city => 
      city.name.toLowerCase().includes(searchKeyword.value.toLowerCase())
    )
  }
  
  // 按省份筛选
  if (selectedProvince.value) {
    filtered = filtered.filter(city => city.province === selectedProvince.value)
  }
  
  return filtered
})

// 搜索处理函数
function onSearch() {
  // 搜索逻辑由computed自动处理
}

function onProvinceChange() {
  // 省份筛选逻辑由computed自动处理
}

async function fetchData() {
  loading.value = true
  try {
    const res = await listCities()
    allCities.value = res.data || []
    ElMessage.success(`成功加载 ${allCities.value.length} 个城市`)
  } catch (e: any) {
    ElMessage.error(e.message || '加载城市数据失败')
  } finally {
    loading.value = false
  }
}

onMounted(fetchData)
</script>

<style scoped>
.cities-page {
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

.result-count {
  color: #6b7280;
  font-size: 14px;
  font-weight: 500;
  text-align: center;
}

.table-card {
  border: none;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.simple-table {
  border-radius: 8px;
  overflow: hidden;
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
</style>