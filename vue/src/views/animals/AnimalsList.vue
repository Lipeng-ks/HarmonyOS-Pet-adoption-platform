<template>
  <div class="animals-page">
    <!-- 页面标题 -->
    <div class="page-header">
      <div class="header-content">
        <h1>动物管理</h1>
        <p>管理宠物信息和领养状态</p>
      </div>
      <el-button type="primary" @click="openCreate">
        <el-icon><Plus /></el-icon>
        新增动物
      </el-button>
    </div>

    <!-- 筛选区域 -->
    <el-card class="filter-card" shadow="never">
      <el-row :gutter="16" align="middle">
        <el-col :xs="24" :sm="6" :md="4">
          <div class="filter-item">
            <label>领养状态</label>
            <el-select v-model="filters.adopted" clearable placeholder="全部" @change="fetchData">
              <el-option :value="true" label="已领养" />
              <el-option :value="false" label="未领养" />
            </el-select>
          </div>
        </el-col>
        <el-col :xs="24" :sm="6" :md="4">
          <div class="filter-item">
            <label>上架状态</label>
            <el-select v-model="filters.listed" clearable placeholder="全部" @change="fetchData">
              <el-option :value="true" label="已上架" />
              <el-option :value="false" label="未上架" />
            </el-select>
          </div>
        </el-col>
        <el-col :xs="24" :sm="6" :md="4">
          <div class="filter-item">
            <label>省份</label>
            <el-select v-model="filters.province" clearable placeholder="全部省份" @change="fetchData">
              <el-option v-for="p in provinces" :key="p" :value="p" :label="p" />
            </el-select>
          </div>
        </el-col>
        <el-col :xs="24" :sm="6" :md="5">
          <div class="filter-item">
            <label>收藏用户ID</label>
            <el-input 
              v-model.number="favUserId" 
              placeholder="输入用户ID" 
              clearable 
              @change="refreshFavorites" 
            />
          </div>
        </el-col>
        <el-col :xs="24" :sm="12" :md="7">
          <div class="filter-actions">
            <el-button @click="resetFilters">重置</el-button>
            <el-button type="primary" @click="fetchData" :loading="loading">
              <el-icon><Search /></el-icon>
              搜索
            </el-button>
          </div>
        </el-col>
      </el-row>
    </el-card>

    <!-- 数据表格 -->
    <el-card class="table-card" shadow="never">
      <el-table :data="list" stripe v-loading="loading">
        <el-table-column label="图片" width="80">
          <template #default="{ row }">
            <el-avatar :src="renderImage(row.image)" :size="40">
              🐾
            </el-avatar>
          </template>
        </el-table-column>
        <el-table-column prop="name" label="名称" min-width="120" />
        <el-table-column prop="type" label="类型" width="100">
          <template #default="{ row }">
            {{ getTypeLabel(row.type) }}
          </template>
        </el-table-column>
        <el-table-column label="省份" width="100">
          <template #default="{ row }">
            {{ cityProvinceMap[row.city] || '' }}
          </template>
        </el-table-column>
        <el-table-column prop="city" label="城市" width="120" />
        <el-table-column prop="age" label="年龄" width="80">
          <template #default="{ row }">
            {{ row.age }}岁
          </template>
        </el-table-column>
        <el-table-column prop="userId" label="用户ID" width="100" />
        <el-table-column label="上架" width="80">
          <template #default="{ row }">
            <el-switch 
              :model-value="!!row.listed" 
              @change="(v: boolean) => toggleListed(row, v)" 
            />
          </template>
        </el-table-column>
        <el-table-column label="操作" width="240" fixed="right">
          <template #default="{ row }">
            <div class="action-buttons">
              <el-button size="small" @click="openEdit(row)">
                <el-icon><Edit /></el-icon>
                编辑
              </el-button>
              <el-button size="small" @click="openDetail(row)">
                <el-icon><View /></el-icon>
                详情
              </el-button>
              <el-button 
                size="small" 
                type="warning" 
                :disabled="!favUserId" 
                @click="toggleFavorite(row)"
              >
                <el-icon><Star /></el-icon>
                {{ isFav[row.id!] ? '取消' : '收藏' }}
              </el-button>
              <el-popconfirm title="确认删除？" @confirm="onDelete(row)">
                <template #reference>
                  <el-button size="small" type="danger">
                    <el-icon><Delete /></el-icon>
                    删除
                  </el-button>
                </template>
              </el-popconfirm>
            </div>
          </template>
        </el-table-column>
      </el-table>

      <el-empty v-if="!loading && list.length === 0" description="暂无数据" />
    </el-card>

    <!-- 新增/编辑弹窗 -->
    <el-dialog v-model="dialog.visible" :title="dialog.isEdit ? '编辑动物' : '新增动物'" width="500px">
      <el-form :model="dialog.form" label-width="80px" label-position="top">
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="名称">
              <el-input v-model="dialog.form.name" placeholder="请输入动物名称" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="类型">
              <el-select v-model="dialog.form.type" placeholder="选择类型" style="width: 100%">
                <el-option value="dog" label="狗狗" />
                <el-option value="cat" label="猫咪" />
                <el-option value="bird" label="鸟类" />
                <el-option value="rabbit" label="兔子" />
                <el-option value="hamster" label="仓鼠" />
                <el-option value="fish" label="鱼类" />
                <el-option value="other" label="其他" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="省份">
              <el-select v-model="dialogProvince" placeholder="选择省份" style="width: 100%" @change="onDialogProvinceChange">
                <el-option v-for="p in provinces" :key="p" :value="p" :label="p" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="城市">
              <el-select v-model="dialog.form.city" placeholder="选择城市" style="width: 100%">
                <el-option v-for="c in cities" :key="c" :value="c" :label="c" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="年龄">
              <el-input-number v-model="dialog.form.age" :min="0" :max="50" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="图片">
              <el-input v-model="dialog.form.image" placeholder="图片链接或文件名" />
            </el-form-item>
          </el-col>
        </el-row>
        
        <el-form-item label="描述">
          <el-input v-model="dialog.form.description" type="textarea" :rows="3" placeholder="请输入动物描述" />
        </el-form-item>
        
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="免费送养">
              <el-switch v-model="dialog.form.isFree" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="立即上架">
              <el-switch v-model="dialog.form.listed" />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
      
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="dialog.visible = false">取消</el-button>
          <el-button type="primary" :loading="submitting" @click="onSubmit">
            {{ dialog.isEdit ? '更新' : '创建' }}
          </el-button>
        </div>
      </template>
    </el-dialog>

    <!-- 详情弹窗 -->
    <el-dialog v-model="detail.visible" title="动物详情" width="600px">
      <div class="detail-content" v-if="detail.row">
        <div class="detail-header">
          <div class="animal-info">
            <h3>{{ detail.row.name }}</h3>
            <div class="tags">
              <el-tag :type="detail.row.listed ? 'success' : 'info'" size="small">
                {{ detail.row.listed ? '已上架' : '未上架' }}
              </el-tag>
              <el-tag v-if="detail.row.adopted" type="warning" size="small">已领养</el-tag>
              <el-tag v-if="detail.row.isFree" type="success" size="small">免费送养</el-tag>
            </div>
          </div>
        </div>

        <div class="detail-info">
          <div class="info-row">
            <span class="label">动物ID：</span>
            <span class="value">{{ detail.row.id }}</span>
          </div>
          <div class="info-row">
            <span class="label">类型：</span>
            <span class="value">{{ getTypeLabel(detail.row.type) }}</span>
          </div>
          <div class="info-row">
            <span class="label">年龄：</span>
            <span class="value">{{ detail.row.age }}岁</span>
          </div>
          <div class="info-row">
            <span class="label">地区：</span>
            <span class="value">
              {{ detail.row.city ? (cityProvinceMap[detail.row.city] || '') + detail.row.city : '未知' }}
            </span>
          </div>
          <div class="info-row">
            <span class="label">发布用户：</span>
            <span class="value" v-if="detail.loadingUser">加载中...</span>
            <span class="value" v-else-if="detail.userInfo">
              {{ detail.userInfo.realName || detail.userInfo.username || '未知用户' }}
              <span class="user-id">(ID: {{ detail.row.userId }})</span>
            </span>
            <span class="value" v-else>用户 #{{ detail.row.userId }}</span>
          </div>
          <div class="info-row">
            <span class="label">领养状态：</span>
            <span class="value">{{ detail.row.adopted ? '已领养' : '待领养' }}</span>
          </div>
          <div class="info-row">
            <span class="label">送养方式：</span>
            <span class="value">{{ detail.row.isFree ? '免费送养' : '付费领养' }}</span>
          </div>
          
          <div class="info-row" v-if="detail.row.description">
            <span class="label">详细描述：</span>
            <div class="description">{{ detail.row.description }}</div>
          </div>
        </div>
      </div>

      <template #footer>
        <div class="dialog-footer">
          <el-button @click="detail.visible = false">关闭</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { 
  Plus, 
  Search, 
  Edit, 
  View, 
  Star, 
  Delete 
} from '@element-plus/icons-vue'
import { listAnimals, createAnimal, updateAnimal, deleteAnimal, updateListed, type Animal } from '@/services/animals'
import { addFavorite, removeFavorite, batchCheckFavorites } from '@/services/favorites'
import { listProvinces, listCitiesByProvince } from '@/services/provinces'
import { getUserById, type UserInfo } from '@/services/users'

const loading = ref(false)
const list = ref<Animal[]>([])
const filters = reactive<{ adopted?: boolean | null; listed?: boolean | null; province?: string | null }>({ 
  adopted: null, 
  listed: null, 
  province: null 
})
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
  if (val.startsWith('app.media.')) return ''
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
  dialogProvince.value = ''
  cities.value = []
  dialog.visible = true
}

function openEdit(row: Animal) {
  dialog.isEdit = true
  dialog.form = { ...row }
  // 设置省份和城市
  if (row.city && cityProvinceMap.value[row.city]) {
    dialogProvince.value = cityProvinceMap.value[row.city]
    onDialogProvinceChange()
  }
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
    const res = await listProvinces()
    provinces.value = (res as any).data || res || []
    
    // 并行获取所有省份的城市数据
    const cityPromises = provinces.value.map(async (province) => {
      try {
        const citiesRes = await listCitiesByProvince(province)
        const citiesList = (citiesRes as any).data || citiesRes || []
        return { province, cities: citiesList }
      } catch {
        return { province, cities: [] }
      }
    })
    
    const results = await Promise.all(cityPromises)
    
    // 构建省市映射
    results.forEach(({ province, cities }) => {
      provinceCityMap.value[province] = cities
      cities.forEach((city: string) => {
        cityProvinceMap.value[city] = province
      })
    })
  } catch {
    // 忽略错误
  }
}

async function onDialogProvinceChange() {
  try {
    cities.value = []
    if (!dialogProvince.value) return
    const res = await listCitiesByProvince(dialogProvince.value)
    cities.value = (res as any).data || res || []
  } catch {
    // 忽略错误
  }
}

// 重置筛选条件
function resetFilters() {
  filters.adopted = null
  filters.listed = null
  filters.province = null
  favUserId.value = null
  Object.keys(isFav).forEach(key => {
    delete isFav[parseInt(key)]
  })
  fetchData()
}

onMounted(async () => {
  fetchData()
  loadProvinces()
})
</script>

<style scoped>
.animals-page {
  padding: 24px;
  background: #f5f7fa;
  min-height: calc(100vh - 60px);
}

/* 页面标题 */
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.header-content h1 {
  margin: 0 0 4px 0;
  font-size: 28px;
  font-weight: 600;
  color: #303133;
}

.header-content p {
  margin: 0;
  font-size: 16px;
  color: #909399;
}

/* 筛选卡片 */
.filter-card {
  margin-bottom: 16px;
  border: none;
  border-radius: 12px;
}

.filter-item {
  margin-bottom: 16px;
}

.filter-item label {
  display: block;
  margin-bottom: 8px;
  font-size: 14px;
  font-weight: 500;
  color: #606266;
}

.filter-item .el-select,
.filter-item .el-input {
  width: 100%;
}

.filter-actions {
  display: flex;
  gap: 12px;
  margin-top: 24px;
}

/* 表格卡片 */
.table-card {
  border: none;
  border-radius: 12px;
}

.table-card :deep(.el-card__body) {
  padding: 0;
}

.table-card :deep(.el-table) {
  border-radius: 12px;
}

.table-card :deep(.el-table th) {
  background-color: #fafafa;
  color: #606266;
  font-weight: 600;
  border: none;
}

.table-card :deep(.el-table td) {
  border: none;
  padding: 16px 12px;
}

.action-buttons {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.action-buttons .el-button {
  margin: 0;
}

/* 弹窗样式 */
.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

/* 详情内容 */
.detail-content {
  .detail-header {
    padding: 20px;
    background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
    border-radius: 8px;
    margin-bottom: 20px;
  }

  .animal-info h3 {
    margin: 0 0 12px 0;
    font-size: 20px;
    font-weight: 600;
    color: #303133;
  }

  .tags {
    display: flex;
    gap: 8px;
    flex-wrap: wrap;
  }

  .detail-info {
    .info-row {
      display: flex;
      align-items: flex-start;
      padding: 12px 0;
      border-bottom: 1px solid #f0f2f5;
    }

    .info-row:last-child {
      border-bottom: none;
    }

    .label {
      min-width: 100px;
      font-weight: 500;
      color: #606266;
    }

    .value {
      flex: 1;
      color: #303133;
    }

    .user-id {
      color: #909399;
      font-size: 12px;
      margin-left: 8px;
    }

    .description {
      flex: 1;
      line-height: 1.6;
      color: #303133;
      white-space: pre-wrap;
      word-break: break-word;
    }
  }
}

/* 响应式设计 */
@media (max-width: 768px) {
  .animals-page {
    padding: 16px;
  }

  .page-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 16px;
  }

  .header-content h1 {
    font-size: 24px;
  }

  .filter-actions {
    margin-top: 16px;
  }

  .action-buttons {
    flex-direction: column;
    gap: 4px;
  }

  .action-buttons .el-button {
    width: 100%;
    justify-content: flex-start;
  }
}

@media (max-width: 480px) {
  .filter-actions {
    flex-direction: column;
  }

  .filter-actions .el-button {
    width: 100%;
  }
}
</style>