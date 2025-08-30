<template>
  <div>
    <el-card>
      <template #header>
        <div class="card-header">
          <div class="left">
            <h3>城市列表</h3>
          </div>
          <div class="right">
            <el-space>
              <el-input
                v-model="searchKeyword"
                placeholder="搜索城市名称"
                style="width: 200px"
                clearable
                @input="onSearch"
              >
                <template #prefix>
                  <el-icon><Search /></el-icon>
                </template>
              </el-input>
              <el-select
                v-model="selectedProvince"
                placeholder="选择省份"
                style="width: 150px"
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
            </el-space>
          </div>
        </div>
      </template>

      <el-table :data="list" v-loading="loading" stripe>
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="name" label="城市名称" min-width="160" />
        <el-table-column prop="province" label="所属省份" min-width="140" />
        <el-table-column prop="code" label="编码" width="120" />
      </el-table>

      <el-empty v-if="!loading && list.length===0" description="暂无匹配的城市数据" />
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
  } catch (e: any) {
    ElMessage.error(e.message || '加载失败')
  } finally {
    loading.value = false
  }
}

onMounted(fetchData)
</script>

<style scoped>
.card-header { 
  display: flex; 
  align-items: center; 
  justify-content: space-between; 
}

.left h3 {
  margin: 0;
  color: #303133;
}

.right {
  display: flex;
  align-items: center;
}
</style>
