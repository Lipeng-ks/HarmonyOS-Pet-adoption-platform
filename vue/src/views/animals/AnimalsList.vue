<template>
  <div>
    <el-card>
      <template #header>
        <div class="card-header">
          <div class="header-title">
            <h3>动物管理</h3>
            <p>管理宠物信息和领养状态</p>
          </div>
          <div class="header-actions">
            <el-button type="primary" @click="openCreate">
              <el-icon><Plus /></el-icon>
              新增动物
            </el-button>
          </div>
        </div>
        
        <!-- 筛选条件区域 -->
        <div class="filter-section">
          <el-row :gutter="16" align="middle">
            <el-col :span="4">
              <div class="filter-item">
                <label>领养状态</label>
                <el-select v-model="filters.adopted" clearable placeholder="全部" size="default" @change="fetchData">
                  <el-option :value="true" label="已领养" />
                  <el-option :value="false" label="未领养" />
                </el-select>
              </div>
            </el-col>
            <el-col :span="4">
              <div class="filter-item">
                <label>上架状态</label>
                <el-select v-model="filters.listed" clearable placeholder="全部" size="default" @change="fetchData">
                  <el-option :value="true" label="已上架" />
                  <el-option :value="false" label="未上架" />
                </el-select>
              </div>
            </el-col>
            <el-col :span="4">
              <div class="filter-item">
                <label>省份</label>
                <el-select v-model="filters.province" clearable placeholder="全部省份" size="default" @change="fetchData">
                  <el-option v-for="p in provinces" :key="p" :value="p" :label="p" />
                </el-select>
              </div>
            </el-col>
            <el-col :span="5">
              <div class="filter-item">
                <label>收藏用户ID</label>
                <el-input 
                  v-model.number="favUserId" 
                  placeholder="输入用户ID" 
                  size="default"
                  clearable 
                  @change="refreshFavorites" 
                />
              </div>
            </el-col>
            <el-col :span="7">
              <div class="filter-actions">
                <el-button @click="resetFilters" size="default">重置</el-button>
                <el-button type="primary" @click="fetchData" size="default" :loading="loading">
                  <el-icon><Search /></el-icon>
                  搜索
                </el-button>
              </div>
            </el-col>
          </el-row>
        </div>
      </template>

      <el-table :data="list" stripe>
        <el-table-column label="图片" width="80">
          <template #default="{ row }">
            <el-avatar :src="renderImage(row.image)" :size="40">宠</el-avatar>
          </template>
        </el-table-column>
        <el-table-column prop="name" label="名称" min-width="120" />
        <el-table-column prop="type" label="类型" width="100" />
        <el-table-column label="省份" width="100">
          <template #default="{ row }">
            {{ cityProvinceMap[row.city] || '' }}
          </template>
        </el-table-column>
        <el-table-column prop="city" label="城市" width="120" />
        <el-table-column prop="age" label="年龄" width="80" />
        <el-table-column prop="userId" label="用户ID" width="100" />
        <el-table-column label="上架" width="100">
          <template #default="{ row }">
            <el-switch :model-value="!!row.listed" @change="(v: boolean)=>toggleListed(row, v)" />
          </template>
        </el-table-column>
        <el-table-column label="操作" width="280" fixed="right">
          <template #default="{ row }">
            <el-button-group>
              <el-button size="small" @click="openEdit(row)">
                <el-icon><Edit /></el-icon>
                编辑
              </el-button>
              <el-button size="small" @click="openDetail(row)">
                <el-icon><View /></el-icon>
                详情
              </el-button>
            </el-button-group>
            <el-button 
              size="small" 
              type="warning" 
              :disabled="!favUserId" 
              @click="toggleFavorite(row)"
              style="margin-left: 8px;"
            >
              <el-icon><Star /></el-icon>
              {{ isFav[row.id!] ? '取消收藏' : '收藏' }}
            </el-button>
            <el-popconfirm title="确认删除？" @confirm="onDelete(row)">
              <template #reference>
                <el-button size="small" type="danger" style="margin-left: 8px;">
                  <el-icon><Delete /></el-icon>
                  删除
                </el-button>
              </template>
            </el-popconfirm>
          </template>
        </el-table-column>
      </el-table>

      <el-empty v-if="!loading && list.length===0" description="暂无数据" />
    </el-card>

    <el-dialog v-model="dialog.visible" :title="dialog.isEdit ? '编辑动物' : '新增动物'" width="520px">
      <el-form :model="dialog.form" label-width="88px">
        <el-form-item label="名称"><el-input v-model="dialog.form.name" /></el-form-item>
        <el-form-item label="类型"><el-input v-model="dialog.form.type" placeholder="dog/cat/other" /></el-form-item>
        <el-form-item label="省市">
          <div style="display:flex; gap:8px; width:100%">
            <el-select v-model="dialogProvince" placeholder="省份" style="width: 160px" @change="onDialogProvinceChange">
              <el-option v-for="p in provinces" :key="p" :value="p" :label="p" />
            </el-select>
            <el-select v-model="dialog.form.city" placeholder="城市" style="flex:1">
              <el-option v-for="c in cities" :key="c" :value="c" :label="c" />
            </el-select>
          </div>
        </el-form-item>
        <el-form-item label="年龄"><el-input-number v-model="dialog.form.age" :min="0" :max="50" /></el-form-item>
        <el-form-item label="图片"><el-input v-model="dialog.form.image" placeholder="app.media.person 或 http(s) 链接 或 文件名" /></el-form-item>
        <el-form-item label="描述"><el-input v-model="dialog.form.description" type="textarea" :rows="3" /></el-form-item>
        <el-form-item label="免费送养"><el-switch v-model="dialog.form.isFree" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialog.visible=false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="onSubmit">保存</el-button>
      </template>
    </el-dialog>

    <el-dialog 
      v-model="detail.visible" 
      title="动物详情" 
      width="680px"
      :close-on-click-modal="false"
      class="animal-detail-dialog"
    >
      <div class="animal-detail-content" v-if="detail.row">
        <!-- 头部信息卡片 -->
        <div class="detail-header">
          <div class="animal-basic-info">
            <div class="animal-name">
              <h2>{{ detail.row.name }}</h2>
              <div class="status-tags">
                <el-tag :type="detail.row.listed ? 'success' : 'info'" size="small">
                  {{ detail.row.listed ? '已上架' : '未上架' }}
                </el-tag>
                <el-tag v-if="detail.row.adopted" type="warning" size="small">已领养</el-tag>
                <el-tag v-if="detail.row.isFree" type="success" size="small">免费送养</el-tag>
              </div>
            </div>
            <div class="basic-stats">
              <div class="stat-item">
                <span class="stat-label">类型</span>
                <span class="stat-value">{{ getTypeLabel(detail.row.type) }}</span>
              </div>
              <div class="stat-item">
                <span class="stat-label">年龄</span>
                <span class="stat-value">{{ detail.row.age }}岁</span>
              </div>
              <div class="stat-item">
                <span class="stat-label">地区</span>
                <span class="stat-value">
                  {{ detail.row.city ? (cityProvinceMap[detail.row.city] || '') + detail.row.city : '未知' }}
                </span>
              </div>
            </div>
          </div>
        </div>

        <!-- 详细信息卡片 -->
        <div class="detail-cards">
          <el-card class="info-card" shadow="never">
            <template #header>
              <div class="card-header">
                <el-icon><InfoFilled /></el-icon>
                <span>基本信息</span>
              </div>
            </template>
            <div class="info-grid">
              <div class="info-item">
                <label>动物ID</label>
                <span>{{ detail.row.id }}</span>
              </div>
              <div class="info-item">
                <label>发布用户</label>
                <span v-if="detail.loadingUser">加载中...</span>
                <span v-else-if="detail.userInfo">
                  {{ detail.userInfo.realName || detail.userInfo.username || '未知用户' }}
                  <span style="color: #909399; font-size: 12px; margin-left: 8px;">(ID: {{ detail.row.userId }})</span>
                </span>
                <span v-else>用户 #{{ detail.row.userId }}</span>
              </div>
              <div class="info-item">
                <label>领养状态</label>
                <span>{{ detail.row.adopted ? '已领养' : '待领养' }}</span>
              </div>
              <div class="info-item">
                <label>送养方式</label>
                <span>{{ detail.row.isFree ? '免费送养' : '付费领养' }}</span>
              </div>
            </div>
          </el-card>

          <el-card class="info-card" shadow="never" v-if="detail.row.description">
            <template #header>
              <div class="card-header">
                <el-icon><Document /></el-icon>
                <span>详细描述</span>
              </div>
            </template>
            <div class="description-content">
              {{ detail.row.description }}
            </div>
          </el-card>
        </div>
      </div>

      <template #footer>
        <div class="dialog-footer">
          <el-button @click="detail.visible=false">
            <el-icon><Close /></el-icon>
            关闭
          </el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { listAnimals, createAnimal, updateAnimal, deleteAnimal, updateListed, type Animal } from '@/services/animals'
import { addFavorite, removeFavorite, batchCheckFavorites } from '@/services/favorites'
import { listProvinces, listCitiesByProvince } from '@/services/provinces'
import { getUserById, type UserInfo } from '@/services/users'

const loading = ref(false)
const list = ref<Animal[]>([])
const filters = reactive<{ adopted?: boolean | null; listed?: boolean | null; province?: string | null }>({ adopted: null, listed: null, province: null })
const favUserId = ref<number | null>(null)
const isFav = reactive<Record<number, boolean>>({})

const dialog = reactive<{ visible: boolean; isEdit: boolean; form: Animal }>({
  visible: false,
  isEdit: false,
  form: { name: '', type: '', city: '', age: 0, image: 'app.media.person', isFree: true, listed: true }
})
const submitting = ref(false)

// 详情对话框
const detail = reactive<{ visible: boolean; row: Animal | null; userInfo: UserInfo | null; loadingUser: boolean }>({ 
  visible: false, 
  row: null, 
  userInfo: null, 
  loadingUser: false 
})

// 省市联动数据
const provinces = ref<string[]>([])
const cities = ref<string[]>([])
const dialogProvince = ref<string>('')

// 省市映射缓存
const provinceCityMap = ref<Record<string, string[]>>({})
const cityProvinceMap = ref<Record<string, string>>({})

function renderImage(val?: string | null) {
  if (!val) return ''
  if (val.startsWith('app.media.')) return '' // 交给前端占位，或可映射本地图标
  return val
}

// 获取动物类型标签
function getTypeLabel(type?: string | null) {
  const typeMap: Record<string, string> = {
    'dog': '狗狗',
    'cat': '猫咪',
    'bird': '鸟类',
    'rabbit': '兔子',
    'hamster': '仓鼠',
    'fish': '鱼类',
    'other': '其他'
  }
  return typeMap[type || ''] || type || '未知'
}

// 格式化日期
function formatDate(date?: string | null) {
  if (!date) return '暂无'
  try {
    return new Date(date).toLocaleString('zh-CN', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    })
  } catch {
    return '格式错误'
  }
}

async function fetchData() {
  loading.value = true
  try {
    const params: any = {}
    if (filters.adopted !== null && filters.adopted !== undefined) params.adopted = filters.adopted
    if (filters.listed !== null && filters.listed !== undefined) params.listed = filters.listed
    const res = await listAnimals(params)
    let data = res.data || []
    
    // 如果有省份筛选，进行前端过滤
    if (filters.province) {
      data = data.filter((item: Animal) => item.city && cityProvinceMap.value[item.city] === filters.province)
    }
    
    list.value = data
    await refreshFavorites()
  } catch (e: any) {
    ElMessage.error(e.message || '加载失败')
  } finally {
    loading.value = false
  }
}

function openCreate() {
  dialog.isEdit = false
  dialog.form = { name: '', type: '', city: '', age: 0, image: 'app.media.person', isFree: true, listed: true }
  dialog.visible = true
}

function openEdit(row: Animal) {
  dialog.isEdit = true
  dialog.form = { ...row }
  dialog.visible = true
}

async function openDetail(row: Animal) {
  detail.row = { ...row }
  detail.userInfo = null
  detail.visible = true
  
  // 获取用户信息
  if (row.userId) {
    detail.loadingUser = true
    try {
      const res = await getUserById(row.userId)
      if (res.success && res.data) {
        detail.userInfo = res.data
      }
    } catch (e: any) {
      console.error('获取用户信息失败:', e)
    } finally {
      detail.loadingUser = false
    }
  }
}

async function onSubmit() {
  submitting.value = true
  try {
    if (dialog.isEdit && dialog.form.id) {
      const res = await updateAnimal(dialog.form.id, dialog.form)
      if (res.success) ElMessage.success('更新成功')
    } else {
      const res = await createAnimal(dialog.form)
      if (res.success) ElMessage.success('创建成功')
    }
    dialog.visible = false
    fetchData()
  } catch (e: any) {
    ElMessage.error(e.message || '操作失败')
  } finally {
    submitting.value = false
  }
}

async function onDelete(row: Animal) {
  try {
    const res = await deleteAnimal(row.id!)
    if (res.success) {
      ElMessage.success('删除成功')
      fetchData()
    }
  } catch (e: any) {
    ElMessage.error(e.message || '删除失败')
  }
}

async function toggleListed(row: Animal, v: boolean) {
  try {
    const res = await updateListed(row.id!, v)
    if (res.success) {
      ElMessage.success('已更新')
      row.listed = v
    }
  } catch (e: any) {
    ElMessage.error(e.message || '更新失败')
  }
}

// 收藏相关
async function refreshFavorites() {
  if (!favUserId.value) return
  if (!list.value.length) return
  try {
    const ids = list.value.map(it => it.id!).filter(Boolean)
    const res = await batchCheckFavorites(favUserId.value, ids)
    const data = (res as any).data as number[] | Set<number>
    const set = new Set<number>(Array.isArray(data) ? data : Array.from(data || []))
    ids.forEach(id => { isFav[id] = set.has(id) })
  } catch {
    // 忽略错误
  }
}

async function toggleFavorite(row: Animal) {
  if (!favUserId.value || !row.id) return
  try {
    if (isFav[row.id]) {
      const res = await removeFavorite(favUserId.value, row.id)
      if ((res as any).success !== false) {
        isFav[row.id] = false
        ElMessage.success('已取消收藏')
      }
    } else {
      const res = await addFavorite(favUserId.value, row.id)
      if ((res as any).success !== false) {
        isFav[row.id] = true
        ElMessage.success('已收藏')
      }
    }
  } catch (e: any) {
    ElMessage.error(e.message || '操作失败')
  }
}

// 省市联动
async function loadProvinces() {
  try {
    // 检查缓存
    const cachedData = localStorage.getItem('province_city_cache')
    const cacheTime = localStorage.getItem('province_city_cache_time')
    const now = Date.now()
    
    // 如果缓存存在且未过期（24小时），直接使用缓存
    if (cachedData && cacheTime && (now - parseInt(cacheTime)) < 24 * 60 * 60 * 1000) {
      const cached = JSON.parse(cachedData)
      provinces.value = cached.provinces
      provinceCityMap.value = cached.provinceCityMap
      cityProvinceMap.value = cached.cityProvinceMap
      return
    }
    
    const res = await listProvinces()
    provinces.value = (res as any).data || res || []
    
    // 并行获取所有省份的城市数据，提升性能
    const cityPromises = provinces.value.map(async (province) => {
      try {
        const citiesRes = await listCitiesByProvince(province)
        const citiesList = (citiesRes as any).data || citiesRes || []
        return { province, cities: citiesList }
      } catch {
        return { province, cities: [] }
      }
    })
    
    // 等待所有请求完成
    const results = await Promise.all(cityPromises)
    
    // 构建省市映射
    results.forEach(({ province, cities }) => {
      provinceCityMap.value[province] = cities
      
      // 构建城市到省份的反向映射
      cities.forEach((city: string) => {
        cityProvinceMap.value[city] = province
      })
    })
    
    // 缓存数据到localStorage
    const cacheData = {
      provinces: provinces.value,
      provinceCityMap: provinceCityMap.value,
      cityProvinceMap: cityProvinceMap.value
    }
    localStorage.setItem('province_city_cache', JSON.stringify(cacheData))
    localStorage.setItem('province_city_cache_time', now.toString())
  } catch {}
}

async function onDialogProvinceChange() {
  try {
    cities.value = []
    if (!dialogProvince.value) return
    const res = await listCitiesByProvince(dialogProvince.value)
    cities.value = (res as any).data || res || []
  } catch {}
}

// 重置筛选条件
function resetFilters() {
  filters.adopted = null
  filters.listed = null
  filters.province = null
  favUserId.value = null
  // 清空收藏状态
  Object.keys(isFav).forEach(key => {
    delete isFav[parseInt(key)]
  })
  fetchData()
}

onMounted(async () => {
  // 先加载数据，省市映射可以异步加载
  fetchData()
  loadProvinces()
})
</script>

<style scoped>
.card-header { 
  display: flex; 
  align-items: center; 
  justify-content: space-between; 
  padding-bottom: 16px;
  border-bottom: 1px solid #f0f0f0;
  margin-bottom: 20px;
}

.header-title h3 {
  margin: 0 0 4px 0;
  font-size: 18px;
  font-weight: 600;
  color: #303133;
}

.header-title p {
  margin: 0;
  font-size: 14px;
  color: #909399;
}

.header-actions {
  display: flex;
  gap: 12px;
}

.filter-section {
  background: #f8f9fa;
  padding: 20px;
  border-radius: 8px;
  margin-bottom: 20px;
}

.filter-item {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.filter-item label {
  font-size: 14px;
  font-weight: 500;
  color: #606266;
  margin: 0;
}

.filter-item .el-select,
.filter-item .el-input {
  width: 100%;
}

.filter-actions {
  display: flex;
  gap: 12px;
  align-items: flex-end;
  height: 100%;
  padding-top: 24px;
}

/* 表格样式优化 */
:deep(.el-table) {
  border-radius: 8px;
  overflow: hidden;
}

:deep(.el-table th) {
  background-color: #fafafa;
  color: #606266;
  font-weight: 600;
}

:deep(.el-table td) {
  padding: 12px 0;
}

:deep(.el-button-group) {
  display: inline-flex;
}

:deep(.el-button-group .el-button) {
  margin-left: 0 !important;
}

/* 动物详情弹窗样式 */
:deep(.animal-detail-dialog) {
  .el-dialog__body {
    padding: 20px 24px;
  }
}

.animal-detail-content {
  .detail-header {
    margin-bottom: 24px;
    padding: 20px;
    background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
    border-radius: 12px;
    border: 1px solid #e9ecef;
  }

  .animal-basic-info {
    display: flex;
    flex-direction: column;
    gap: 16px;
  }

  .animal-name {
    h2 {
      margin: 0 0 12px 0;
      font-size: 24px;
      font-weight: 600;
      color: #303133;
      line-height: 1.2;
    }
    
    .status-tags {
      display: flex;
      gap: 8px;
      flex-wrap: wrap;
    }
  }

  .basic-stats {
    display: flex;
    gap: 24px;
    margin-top: 16px;
    
    .stat-item {
      display: flex;
      flex-direction: column;
      gap: 4px;
      
      .stat-label {
        font-size: 12px;
        color: #909399;
        font-weight: 500;
      }
      
      .stat-value {
        font-size: 16px;
        color: #303133;
        font-weight: 600;
      }
    }
  }

  .detail-cards {
    display: flex;
    flex-direction: column;
    gap: 16px;
  }

  .info-card {
    border: 1px solid #e4e7ed;
    border-radius: 8px;
    
    :deep(.el-card__header) {
      padding: 16px 20px;
      background: #fafafa;
      border-bottom: 1px solid #e4e7ed;
      
      .card-header {
        display: flex;
        align-items: center;
        gap: 8px;
        font-weight: 600;
        color: #303133;
        
        .el-icon {
          color: #409eff;
        }
      }
    }
    
    :deep(.el-card__body) {
      padding: 20px;
    }
  }

  .info-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 16px 24px;
    
    .info-item {
      display: flex;
      flex-direction: column;
      gap: 6px;
      
      label {
        font-size: 13px;
        color: #909399;
        font-weight: 500;
      }
      
      span {
        font-size: 14px;
        color: #303133;
        font-weight: 500;
      }
    }
  }

  .description-content {
    line-height: 1.6;
    color: #606266;
    font-size: 14px;
    white-space: pre-wrap;
    word-break: break-word;
  }
}

.dialog-footer {
  display: flex;
  justify-content: center;
  align-items: center;
}

/* 响应式设计 */
@media (max-width: 1200px) {
  .filter-section .el-col {
    margin-bottom: 16px;
  }
  
  .filter-actions {
    padding-top: 0;
  }
}

@media (max-width: 768px) {
  :deep(.animal-detail-dialog) {
    width: 95% !important;
    margin: 0 auto;
  }
  
  .animal-detail-content {
    .basic-stats {
      justify-content: center;
      gap: 16px;
    }
    
    .info-grid {
      grid-template-columns: 1fr;
      gap: 12px;
    }
  }
}
</style>
