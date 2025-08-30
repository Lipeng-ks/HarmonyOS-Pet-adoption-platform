<template>
  <div class="adoption-page">
    <el-card>
      <template #header>
        <div class="card-header">
          <div class="left">
            <h2>已领养宠物</h2>
            <p class="subtitle">查看已经找到温暖家庭的宠物们</p>
          </div>
          <div class="right">
            <el-space>
              <el-select v-model="filters.type" clearable placeholder="动物类型" style="width: 120px" @change="onFilterChange">
                <el-option label="猫" value="猫" />
                <el-option label="狗" value="狗" />
                <el-option label="兔子" value="兔子" />
                <el-option label="其他" value="其他" />
              </el-select>
              <el-select v-model="filters.city" clearable placeholder="所在城市" style="width: 120px" @change="onFilterChange">
                <el-option v-for="city in cities" :key="city" :value="city" :label="city" />
              </el-select>
              <el-switch
                v-model="filters.isFree"
                :active-value="true"
                :inactive-value="null"
                active-text="免费领养"
                @change="onFilterChange"
              />
              <el-button @click="onFilterChange" :loading="loading">
                <el-icon><Refresh /></el-icon>
                刷新
              </el-button>
            </el-space>
          </div>
        </div>
      </template>

      <!-- 动物卡片网格 -->
      <div v-loading="loading" class="animals-grid">
        <div v-if="list.length === 0 && !loading" class="empty-state">
          <el-empty description="暂无已领养的宠物记录" />
        </div>
        
        <div v-for="animal in list" :key="animal.id" class="animal-card">
          <el-card shadow="hover" class="pet-card-no-image">
            <div class="pet-header">
              <div class="pet-name-section">
                <h3 class="pet-name">{{ animal.name }}</h3>
                <div class="status-badges">
                  <el-tag type="success" size="small">已领养</el-tag>
                </div>
              </div>
              <div class="pet-actions">
                <el-button type="primary" size="small" @click="viewDetails(animal)">
                  <el-icon><View /></el-icon>
                  查看详情
                </el-button>
              </div>
            </div>
            
            <div class="pet-info">
              <div class="pet-content">
                <div class="pet-basic-info">
                  <div class="info-item">
                    <el-icon><Male /></el-icon>
                    <span>{{ animal.gender ? '雄性' : '雌性' }}</span>
                  </div>
                  <div class="info-item">
                    <el-icon><Clock /></el-icon>
                    <span>{{ animal.age || '未知' }}岁</span>
                  </div>
                  <div class="info-item">
                    <el-icon><Location /></el-icon>
                    <span>{{ animal.city || '未知' }}</span>
                  </div>
                  <div v-if="animal.type" class="info-item">
                    <span class="info-label">类型：</span>
                    <span>{{ animal.type }}</span>
                  </div>
                </div>
                
                <div v-if="animal.description" class="pet-description">
                  <span class="description-label">描述：</span>
                  {{ animal.description.length > 80 ? animal.description.substring(0, 80) + '...' : animal.description }}
                </div>
              </div>
              
              <div class="health-info">
                <div class="health-tags">
                  <el-tag :type="animal.vaccinated ? 'success' : 'info'" size="small">
                    疫苗：{{ animal.vaccinated ? '已接种' : '未接种' }}
                  </el-tag>
                  <el-tag :type="animal.dewormed ? 'success' : 'info'" size="small">
                    驱虫：{{ animal.dewormed ? '已驱虫' : '未驱虫' }}
                  </el-tag>
                  <el-tag :type="animal.neutered ? 'success' : 'info'" size="small">
                    绝育：{{ animal.neutered ? '已绝育' : '未绝育' }}
                  </el-tag>
                  <el-tag v-if="animal.isFree !== null" :type="animal.isFree ? 'success' : 'warning'" size="small">
                    {{ animal.isFree ? '免费领养' : '需要费用' }}
                  </el-tag>
                </div>
              </div>
            </div>
          </el-card>
        </div>
      </div>

      <!-- 分页 -->
      <div class="pagination-wrapper">
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
    </el-card>

    <!-- 详情弹窗 -->
    <el-dialog v-model="detailDialog.visible" title="已领养宠物详情" width="600px">
      <div v-if="detailDialog.animal" class="pet-detail-no-image">
        <div class="detail-header">
          <h2>{{ detailDialog.animal.name }}</h2>
          <el-tag type="success" size="large">已领养</el-tag>
        </div>
        
        <el-descriptions :column="2" border>
          <el-descriptions-item label="性别">
            {{ detailDialog.animal.gender ? '雄性' : '雌性' }}
          </el-descriptions-item>
          <el-descriptions-item label="年龄">
            {{ detailDialog.animal.age || '未知' }}岁
          </el-descriptions-item>
          <el-descriptions-item label="类型">
            {{ detailDialog.animal.type || '未知' }}
          </el-descriptions-item>
          <el-descriptions-item label="所在城市">
            {{ detailDialog.animal.city || '未知' }}
          </el-descriptions-item>
          <el-descriptions-item label="疫苗接种">
            <el-tag :type="detailDialog.animal.vaccinated ? 'success' : 'danger'">
              {{ detailDialog.animal.vaccinated ? '已接种' : '未接种' }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="驱虫情况">
            <el-tag :type="detailDialog.animal.dewormed ? 'success' : 'danger'">
              {{ detailDialog.animal.dewormed ? '已驱虫' : '未驱虫' }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="绝育情况">
            <el-tag :type="detailDialog.animal.neutered ? 'success' : 'info'">
              {{ detailDialog.animal.neutered ? '已绝育' : '未绝育' }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="领养费用">
            <el-tag :type="detailDialog.animal.isFree ? 'success' : 'warning'">
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
import { Refresh, Male, Clock, Location, View } from '@element-plus/icons-vue'
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
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.left h2 {
  margin: 0 0 5px 0;
  color: #409eff;
}

.subtitle {
  margin: 0;
  color: #909399;
  font-size: 14px;
}

.animals-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 16px;
  margin: 20px 0;
  min-height: 200px;
}

.animal-card {
  height: 100%;
}

.pet-card-no-image {
  height: 100%;
  transition: all 0.3s ease;
}

.pet-card-no-image:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.pet-card-no-image :deep(.el-card__body) {
  padding: 16px;
}

.pet-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 12px;
  padding-bottom: 12px;
  border-bottom: 1px solid #f0f0f0;
}

.pet-name-section {
  flex: 1;
}

.pet-name {
  margin: 0 0 8px 0;
  font-size: 18px;
  font-weight: bold;
  color: #303133;
}

.status-badges {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
  margin-bottom: 4px;
}

.pet-actions {
  margin-left: 12px;
}

.pet-info {
  display: flex;
  flex-direction: column;
  height: 100%;
}

.pet-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.pet-basic-info {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 8px;
}

.info-item {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 14px;
  color: #606266;
}

.info-label {
  font-weight: 500;
  color: #303133;
}

.pet-description {
  font-size: 14px;
  color: #606266;
  line-height: 1.5;
  background: #f8f9fa;
  padding: 8px 12px;
  border-radius: 4px;
  border-left: 3px solid #409eff;
}

.description-label {
  font-weight: 500;
  color: #303133;
}

.health-info {
  margin-top: auto;
  padding-top: 12px;
  border-top: 1px solid #f0f0f0;
}

.health-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  align-items: center;
  min-height: 24px; /* 确保健康标签有固定高度 */
}

.pagination-wrapper {
  display: flex;
  justify-content: center;
  margin-top: 30px;
}

.empty-state {
  grid-column: 1 / -1;
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 300px;
}

/* 详情弹窗样式 */
.pet-detail-no-image {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.detail-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-bottom: 16px;
  border-bottom: 2px solid #f0f0f0;
}

.detail-header h2 {
  margin: 0;
  color: #409eff;
  font-size: 24px;
}

.description-section {
  margin-top: 20px;
}

.description-section h4 {
  margin: 0 0 10px 0;
  color: #303133;
}

.description-section p {
  margin: 0;
  line-height: 1.6;
  color: #606266;
}

@media (max-width: 768px) {
  .card-header {
    flex-direction: column;
    gap: 15px;
    align-items: flex-start;
  }
  
  .animals-grid {
    grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
    gap: 15px;
  }
}
</style>
