<template>
  <div class="adoption-page">
    <!-- 页面标题 -->
    <div class="page-header">
      <h2>🏠 已领养宠物</h2>
      <p>查看已经找到温暖家庭的宠物们</p>
    </div>

    <!-- 筛选器 -->
    <el-card class="filter-card" shadow="never">
      <div class="filter-container">
        <el-row :gutter="16" align="middle">
          <el-col :span="4">
            <el-select 
              v-model="filters.type" 
              clearable 
              placeholder="动物类型" 
              @change="onFilterChange"
            >
              <el-option label="猫" value="猫" />
              <el-option label="狗" value="狗" />
              <el-option label="兔子" value="兔子" />
              <el-option label="其他" value="其他" />
            </el-select>
          </el-col>
          
          <el-col :span="4">
            <el-select 
              v-model="filters.city" 
              clearable 
              placeholder="所在城市" 
              @change="onFilterChange"
            >
              <el-option v-for="city in cities" :key="city" :value="city" :label="city" />
            </el-select>
          </el-col>
          
          <el-col :span="4">
            <el-switch
              v-model="filters.isFree"
              :active-value="true"
              :inactive-value="null"
              active-text="免费领养"
              @change="onFilterChange"
            />
          </el-col>
          
          <el-col :span="8">
            <div class="stats-info">
              共 {{ pager.total }} 只已领养宠物
            </div>
          </el-col>
          
          <el-col :span="4">
            <el-button @click="onFilterChange" :loading="loading">
              刷新
            </el-button>
          </el-col>
        </el-row>
      </div>
    </el-card>

    <!-- 宠物卡片网格 -->
    <div v-loading="loading" class="pets-grid">
      <el-empty 
        v-if="list.length === 0 && !loading" 
        description="暂无已领养的宠物记录"
        :image-size="120"
      />
      
      <div v-for="animal in list" :key="animal.id" class="pet-card">
        <el-card shadow="hover" class="card-content">
          <div class="pet-header">
            <div class="pet-info">
              <h3 class="pet-name">{{ animal.name }}</h3>
              <el-tag type="success" size="small">已领养</el-tag>
            </div>
            <el-button type="primary" size="small" @click="viewDetails(animal)">
              查看详情
            </el-button>
          </div>
          
          <div class="pet-details">
            <div class="basic-info">
              <div class="info-row">
                <span class="label">性别:</span>
                <span>{{ animal.gender ? '雄性' : '雌性' }}</span>
              </div>
              <div class="info-row">
                <span class="label">年龄:</span>
                <span>{{ animal.age || '未知' }}岁</span>
              </div>
              <div class="info-row">
                <span class="label">类型:</span>
                <span>{{ animal.type || '未知' }}</span>
              </div>
              <div class="info-row">
                <span class="label">城市:</span>
                <span>{{ animal.city || '未知' }}</span>
              </div>
            </div>
            
            <div v-if="animal.description" class="description">
              {{ animal.description.length > 60 ? animal.description.substring(0, 60) + '...' : animal.description }}
            </div>
            
            <div class="health-tags">
              <el-tag 
                :type="animal.vaccinated ? 'success' : 'info'" 
                size="small"
              >
                疫苗{{ animal.vaccinated ? '✓' : '✗' }}
              </el-tag>
              <el-tag 
                :type="animal.dewormed ? 'success' : 'info'" 
                size="small"
              >
                驱虫{{ animal.dewormed ? '✓' : '✗' }}
              </el-tag>
              <el-tag 
                :type="animal.neutered ? 'success' : 'info'" 
                size="small"
              >
                绝育{{ animal.neutered ? '✓' : '✗' }}
              </el-tag>
              <el-tag 
                v-if="animal.isFree !== null" 
                :type="animal.isFree ? 'success' : 'warning'" 
                size="small"
              >
                {{ animal.isFree ? '免费' : '付费' }}
              </el-tag>
            </div>
          </div>
        </el-card>
      </div>
    </div>

    <!-- 分页 -->
    <div class="pagination-wrapper" v-if="list.length > 0">
      <el-pagination
        v-model:current-page="pager.page"
        v-model:page-size="pager.size"
        :page-sizes="[12, 24, 48]"
        :total="pager.total"
        layout="total, sizes, prev, pager, next, jumper"
        @size-change="fetchData"
        @current-change="fetchData"
      />
    </div>

    <!-- 详情弹窗 -->
    <el-dialog 
      v-model="detailDialog.visible" 
      title="已领养宠物详情" 
      width="500px"
      :close-on-click-modal="false"
    >
      <div v-if="detailDialog.animal" class="pet-detail">
        <div class="detail-header">
          <h3>{{ detailDialog.animal.name }}</h3>
          <el-tag type="success">已领养</el-tag>
        </div>
        
        <el-descriptions :column="2" border size="small">
          <el-descriptions-item label="性别">
            {{ detailDialog.animal.gender ? '雄性' : '雌性' }}
          </el-descriptions-item>
          <el-descriptions-item label="年龄">
            {{ detailDialog.animal.age || '未知' }}岁
          </el-descriptions-item>
          <el-descriptions-item label="类型">
            {{ detailDialog.animal.type || '未知' }}
          </el-descriptions-item>
          <el-descriptions-item label="城市">
            {{ detailDialog.animal.city || '未知' }}
          </el-descriptions-item>
          <el-descriptions-item label="疫苗">
            <el-tag :type="detailDialog.animal.vaccinated ? 'success' : 'danger'" size="small">
              {{ detailDialog.animal.vaccinated ? '已接种' : '未接种' }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="驱虫">
            <el-tag :type="detailDialog.animal.dewormed ? 'success' : 'danger'" size="small">
              {{ detailDialog.animal.dewormed ? '已驱虫' : '未驱虫' }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="绝育">
            <el-tag :type="detailDialog.animal.neutered ? 'success' : 'info'" size="small">
              {{ detailDialog.animal.neutered ? '已绝育' : '未绝育' }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="费用">
            <el-tag :type="detailDialog.animal.isFree ? 'success' : 'warning'" size="small">
              {{ detailDialog.animal.isFree ? '免费领养' : '需要费用' }}
            </el-tag>
          </el-descriptions-item>
        </el-descriptions>
        
        <div v-if="detailDialog.animal.description" class="description-section">
          <h4>详细描述</h4>
          <p>{{ detailDialog.animal.description }}</p>
        </div>
      </div>
      
      <template #footer>
        <el-button @click="detailDialog.visible = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, computed } from 'vue'
import { ElMessage } from 'element-plus'
import { getAnimalsPage, type Animal } from '@/services/animals'

const loading = ref(false)
const list = ref<Animal[]>([])

const filters = reactive<{
  type?: string | null
  city?: string | null
  isFree?: boolean | null
}>({
  type: null,
  city: null,
  isFree: null
})

const pager = reactive({
  page: 1,
  size: 12,
  total: 0
})

const detailDialog = reactive<{
  visible: boolean
  animal: Animal | null
}>({
  visible: false,
  animal: null
})

// 从动物列表中提取城市选项
const cities = computed(() => {
  const citySet = new Set<string>()
  list.value.forEach(animal => {
    if (animal.city) {
      citySet.add(animal.city)
    }
  })
  return Array.from(citySet).sort()
})

async function fetchData() {
  loading.value = true
  try {
    const params = {
      page: pager.page - 1,
      size: pager.size,
      adopted: true,  // 显示已被领养的动物
      listed: false   // 显示已下架的动物
    }
    
    const res = await getAnimalsPage(params)
    
    if (res.success) {
      let animals = res.records || []
      
      // 前端筛选
      if (filters.type) {
        animals = animals.filter((animal: Animal) => animal.type === filters.type)
      }
      if (filters.city) {
        animals = animals.filter((animal: Animal) => animal.city === filters.city)
      }
      if (filters.isFree !== null) {
        animals = animals.filter((animal: Animal) => animal.isFree === filters.isFree)
      }
      
      list.value = animals
      pager.total = res.total || 0
    } else {
      throw new Error(res.message || '获取数据失败')
    }
  } catch (error: any) {
    console.error('获取动物数据失败:', error)
    ElMessage.error(error.message || '获取动物数据失败')
    list.value = []
    pager.total = 0
  } finally {
    loading.value = false
  }
}

function onFilterChange() {
  pager.page = 1
  fetchData()
}

function viewDetails(animal: Animal) {
  detailDialog.animal = animal
  detailDialog.visible = true
}

onMounted(() => {
  fetchData()
})
</script>

<style scoped>
.adoption-page {
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

.stats-info {
  color: #6b7280;
  font-size: 14px;
  font-weight: 500;
}

.pets-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
  margin-bottom: 24px;
  min-height: 200px;
}

.pet-card {
  height: 100%;
}

.card-content {
  height: 100%;
  border: none;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  transition: all 0.2s;
}

.card-content:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.pet-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid #e5e7eb;
}

.pet-info {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.pet-name {
  margin: 0;
  font-size: 18px;
  font-weight: 600;
  color: #1f2937;
}

.pet-details {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.basic-info {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 8px;
}

.info-row {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
}

.label {
  font-weight: 500;
  color: #374151;
  min-width: 40px;
}

.description {
  font-size: 14px;
  color: #6b7280;
  line-height: 1.5;
  background: #f9fafb;
  padding: 12px;
  border-radius: 6px;
  border-left: 3px solid #10b981;
}

.health-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.pagination-wrapper {
  display: flex;
  justify-content: center;
  margin-top: 24px;
}

.pet-detail {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.detail-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-bottom: 16px;
  border-bottom: 1px solid #e5e7eb;
}

.detail-header h3 {
  margin: 0;
  color: #1f2937;
  font-size: 20px;
  font-weight: 600;
}

.description-section {
  margin-top: 16px;
}

.description-section h4 {
  margin: 0 0 8px 0;
  color: #374151;
  font-size: 16px;
  font-weight: 600;
}

.description-section p {
  margin: 0;
  line-height: 1.6;
  color: #6b7280;
}

:deep(.el-card__body) {
  padding: 20px;
}

:deep(.el-empty) {
  padding: 60px 0;
  grid-column: 1 / -1;
}

@media (max-width: 768px) {
  .pets-grid {
    grid-template-columns: 1fr;
    gap: 16px;
  }
  
  .basic-info {
    grid-template-columns: 1fr;
  }
}
</style>