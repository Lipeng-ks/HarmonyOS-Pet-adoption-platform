<template>
  <div class="lost-pets-page">
    <!-- 页面标题 -->
    <div class="page-header">
      <h2>🔍 寻宠管理</h2>
      <p>管理丢失宠物信息和寻找状态</p>
    </div>

    <!-- 筛选器 -->
    <el-card class="filter-card" shadow="never">
      <div class="filter-container">
        <el-row :gutter="16" align="middle">
          <el-col :span="4">
            <el-select 
              v-model="filters.status" 
              clearable 
              placeholder="状态筛选" 
              @change="fetchData"
            >
              <el-option value="ACTIVE" label="寻宠中" />
              <el-option value="FOUND" label="已找到" />
              <el-option value="CLOSED" label="已关闭" />
            </el-select>
          </el-col>
          
          <el-col :span="4">
            <el-input 
              v-model.number="filters.userId" 
              placeholder="用户ID" 
              clearable 
              @change="fetchData" 
            />
          </el-col>
          
          <el-col :span="4">
            <el-select 
              v-model="filters.province" 
              clearable 
              placeholder="省份筛选" 
              @change="fetchData"
            >
              <el-option v-for="p in provinces" :key="p" :value="p" :label="p" />
            </el-select>
          </el-col>
          
          <el-col :span="8">
            <div class="stats-info">
              共 {{ pagination.total }} 条记录
            </div>
          </el-col>
          
          <el-col :span="4">
            <el-button type="primary" @click="openCreate">
              新增寻宠
            </el-button>
          </el-col>
        </el-row>
      </div>
    </el-card>

    <!-- 寻宠列表 -->
    <el-card class="table-card" shadow="never">
      <el-table 
        :data="list" 
        v-loading="loading"
        empty-text="暂无寻宠信息"
        class="simple-table"
      >
        <el-table-column label="宠物" width="100">
          <template #default="{ row }">
            <div class="pet-info">
              <el-avatar :src="renderImage(row.image)" :size="40">
                {{ row.petName?.charAt(0) || '宠' }}
              </el-avatar>
            </div>
          </template>
        </el-table-column>
        
        <el-table-column label="基本信息" min-width="200">
          <template #default="{ row }">
            <div class="pet-details">
              <div class="pet-name">{{ row.petName || '未命名' }}</div>
              <div class="pet-type">{{ row.type }} · {{ row.age }}岁</div>
            </div>
          </template>
        </el-table-column>
        
        <el-table-column label="地区" width="150">
          <template #default="{ row }">
            <div class="location">
              <div>{{ cityProvinceMap[row.city] || '' }}</div>
              <div class="city">{{ row.city }}</div>
            </div>
          </template>
        </el-table-column>
        
        <el-table-column label="悬赏" width="100" align="center">
          <template #default="{ row }">
            <div v-if="row.reward && row.reward > 0" class="reward">
              ¥{{ row.reward }}
            </div>
            <div v-else class="no-reward">-</div>
          </template>
        </el-table-column>
        
        <el-table-column prop="lostTime" label="走失时间" width="120">
          <template #default="{ row }">
            <div class="lost-time">{{ formatDate(row.lostTime) }}</div>
          </template>
        </el-table-column>
        
        <el-table-column label="状态" width="120">
          <template #default="{ row }">
            <el-tag 
              :type="row.status === 'ACTIVE' ? 'warning' : row.status === 'FOUND' ? 'success' : 'info'"
              size="small"
            >
              {{ statusLabel(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button size="small" @click="openEdit(row)">
              编辑
            </el-button>
            <el-dropdown 
              trigger="click" 
              @command="(s: 'ACTIVE' | 'FOUND' | 'CLOSED') => changeStatus(row, s)"
            >
              <el-button size="small" type="primary">
                状态
              </el-button>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item command="ACTIVE">寻宠中</el-dropdown-item>
                  <el-dropdown-item command="FOUND">已找到</el-dropdown-item>
                  <el-dropdown-item command="CLOSED">已关闭</el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
            <el-popconfirm title="确认删除？" @confirm="onDelete(row)">
              <template #reference>
                <el-button size="small" type="danger">删除</el-button>
              </template>
            </el-popconfirm>
          </template>
        </el-table-column>
      </el-table>

      <el-empty 
        v-if="!loading && list.length === 0" 
        description="暂无寻宠信息"
        :image-size="120"
      />
      
      <!-- 分页 -->
      <div class="pagination-wrapper" v-if="list.length > 0">
        <el-pagination
          v-model:current-page="pagination.currentPage"
          v-model:page-size="pagination.pageSize"
          :page-sizes="[10, 20, 50, 100]"
          :total="pagination.total"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        />
      </div>
    </el-card>

    <!-- 编辑对话框 -->
    <el-dialog 
      v-model="dialog.visible" 
      :title="dialog.isEdit ? '编辑寻宠' : '新增寻宠'" 
      width="600px"
      :close-on-click-modal="false"
    >
      <el-form :model="dialog.form" label-width="100px" class="dialog-form">
        <el-form-item label="标题">
          <el-input v-model="dialog.form.title" placeholder="请输入寻宠标题" />
        </el-form-item>
        
        <el-form-item label="宠物名">
          <el-input v-model="dialog.form.petName" placeholder="请输入宠物名字" />
        </el-form-item>
        
        <el-form-item label="类型">
          <el-select v-model="dialog.form.type" placeholder="选择宠物类型" style="width: 100%">
            <el-option value="dog" label="狗狗" />
            <el-option value="cat" label="猫咪" />
            <el-option value="other" label="其他" />
          </el-select>
        </el-form-item>
        
        <el-form-item label="省市">
          <el-row :gutter="8">
            <el-col :span="10">
              <el-select 
                v-model="dialogProvince" 
                placeholder="省份" 
                @change="onDialogProvinceChange"
              >
                <el-option v-for="p in provinces" :key="p" :value="p" :label="p" />
              </el-select>
            </el-col>
            <el-col :span="14">
              <el-select v-model="dialog.form.city" placeholder="城市">
                <el-option v-for="c in cities" :key="c" :value="c" :label="c" />
              </el-select>
            </el-col>
          </el-row>
        </el-form-item>
        
        <el-form-item label="年龄">
          <el-input-number 
            v-model="dialog.form.age" 
            :min="0" 
            :max="50" 
            placeholder="宠物年龄"
          />
        </el-form-item>
        
        <el-form-item label="图片">
          <div class="image-upload">
            <el-upload
              :http-request="onFileUpload"
              :show-file-list="false"
              accept="image/*"
            >
              <el-button>上传图片</el-button>
            </el-upload>
            <el-input 
              v-model="dialog.form.image" 
              placeholder="或输入图片链接" 
              style="margin-left: 8px; flex: 1"
            />
          </div>
          <div v-if="dialog.form.image" class="image-preview">
            <el-image 
              :src="renderImage(dialog.form.image) || ''" 
              style="width: 100px; height: 100px" 
              fit="cover" 
            />
          </div>
        </el-form-item>
        
        <el-form-item label="走失时间">
          <el-date-picker 
            v-model="dialog.form.lostTime" 
            type="datetime" 
            value-format="YYYY-MM-DDTHH:mm:ss" 
            placeholder="选择走失时间" 
            style="width: 100%"
          />
        </el-form-item>
        
        <el-form-item label="走失地址">
          <el-input v-model="dialog.form.lostAddress" placeholder="详细走失地址" />
        </el-form-item>
        
        <el-form-item label="联系人">
          <el-input v-model="dialog.form.contactName" placeholder="联系人姓名" />
        </el-form-item>
        
        <el-form-item label="联系电话">
          <el-input v-model="dialog.form.contactPhone" placeholder="联系电话" />
        </el-form-item>
        
        <el-form-item label="悬赏金额">
          <el-input-number 
            v-model="dialog.form.reward" 
            :min="0" 
            :max="999999" 
            :precision="2"
            :step="100"
            placeholder="悬赏金额"
            style="width: 200px"
          />
          <span style="margin-left: 8px; color: #909399;">元</span>
        </el-form-item>
        
        <el-form-item label="描述">
          <el-input 
            v-model="dialog.form.description" 
            type="textarea" 
            :rows="3" 
            placeholder="详细描述宠物特征"
          />
        </el-form-item>
        
        <el-form-item label="状态">
          <el-select v-model="dialog.form.status" style="width: 160px">
            <el-option value="ACTIVE" label="寻宠中" />
            <el-option value="FOUND" label="已找到" />
            <el-option value="CLOSED" label="已关闭" />
          </el-select>
        </el-form-item>
      </el-form>
      
      <template #footer>
        <el-button @click="dialog.visible = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="onSubmit">
          保存
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { 
  listLostPets, 
  listLostPetsByUser, 
  createLostPet, 
  updateLostPet, 
  deleteLostPet, 
  updateStatus, 
  type LostPet 
} from '@/services/lostpets'
import { uploadFile } from '@/services/upload'
import { listProvinces, listCitiesByProvince } from '@/services/provinces'

const loading = ref(false)
const list = ref<LostPet[]>([])
const filters = reactive<{ 
  status?: 'ACTIVE' | 'FOUND' | 'CLOSED' | null
  userId?: number | null
  province?: string | null 
}>({ 
  status: null, 
  userId: null, 
  province: null 
})

// 分页数据
const pagination = reactive({
  currentPage: 1,
  pageSize: 20,
  total: 0
})

const dialog = reactive<{ visible: boolean; isEdit: boolean; form: LostPet }>({
  visible: false,
  isEdit: false,
  form: { 
    title: '', 
    petName: '', 
    type: '', 
    city: '', 
    age: 0, 
    image: '', 
    lostTime: '', 
    lostAddress: '', 
    contactName: '', 
    contactPhone: '', 
    status: 'ACTIVE' 
  }
})
const submitting = ref(false)

// 省市联动
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

async function fetchData() {
  loading.value = true
  try {
    const params: any = {}
    if (filters.status) params.status = filters.status
    let res
    if (filters.userId) {
      res = await listLostPetsByUser(filters.userId)
    } else {
      res = await listLostPets(params)
    }
    let data = res.data || []
    
    // 如果有省份筛选，进行前端过滤
    if (filters.province) {
      data = data.filter((item: LostPet) => item.city && cityProvinceMap.value[item.city] === filters.province)
    }
    
    // 更新分页信息
    pagination.total = data.length
    
    // 分页处理
    const startIndex = (pagination.currentPage - 1) * pagination.pageSize
    const endIndex = startIndex + pagination.pageSize
    list.value = data.slice(startIndex, endIndex)
  } catch (e: any) {
    ElMessage.error(e.message || '加载失败')
  } finally {
    loading.value = false
  }
}

function openCreate() {
  dialog.isEdit = false
  dialog.form = { 
    title: '', 
    petName: '', 
    type: '', 
    city: '', 
    age: 0, 
    image: '', 
    lostTime: '', 
    lostAddress: '', 
    contactName: '', 
    contactPhone: '', 
    status: 'ACTIVE' 
  }
  dialog.visible = true
  dialogProvince.value = ''
  cities.value = []
}

function openEdit(row: LostPet) {
  dialog.isEdit = true
  dialog.form = { ...row }
  dialog.visible = true
  if (dialog.form.city) {
    inferProvinceByCity(dialog.form.city)
  }
}

async function onSubmit() {
  submitting.value = true
  try {
    if (dialog.isEdit && dialog.form.id) {
      const res = await updateLostPet(dialog.form.id, dialog.form)
      if (res.success) ElMessage.success('更新成功')
    } else {
      const res = await createLostPet(dialog.form)
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

async function onDelete(row: LostPet) {
  try {
    const res = await deleteLostPet(row.id!)
    if (res.success) {
      ElMessage.success('删除成功')
      fetchData()
    }
  } catch (e: any) {
    ElMessage.error(e.message || '删除失败')
  }
}

async function onFileUpload(opts: any) {
  try {
    const res = await uploadFile(opts.file as File)
    if (res.success && res.data?.url) {
      dialog.form.image = res.data.url
      ElMessage.success('上传成功')
      opts.onSuccess?.(res)
    } else {
      throw new Error(res.message || '上传失败')
    }
  } catch (e: any) {
    ElMessage.error(e.message || '上传失败')
    opts.onError?.(e)
  }
}

function statusLabel(s?: string) {
  if (s === 'FOUND') return '已找到'
  if (s === 'CLOSED') return '已关闭'
  return '寻宠中'
}

async function changeStatus(row: LostPet, s: 'ACTIVE' | 'FOUND' | 'CLOSED') {
  try {
    const res = await updateStatus(row.id!, s)
    if (res.success) {
      ElMessage.success('状态已更新')
      row.status = s
    }
  } catch (e: any) {
    ElMessage.error(e.message || '更新失败')
  }
}

async function onDialogProvinceChange() {
  try {
    cities.value = []
    if (!dialogProvince.value) return
    const res = await listCitiesByProvince(dialogProvince.value)
    cities.value = (res as any).data || res || []
  } catch {}
}

async function loadProvinces() {
  try {
    const res = await listProvinces()
    provinces.value = (res as any).data || res || []
    
    // 构建省市映射
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
    
    results.forEach(({ province, cities }) => {
      provinceCityMap.value[province] = cities
      cities.forEach((city: string) => {
        cityProvinceMap.value[city] = province
      })
    })
  } catch {}
}

async function inferProvinceByCity(city: string) {
  if (!city) return
  for (const p of provinces.value) {
    try {
      const res = await listCitiesByProvince(p)
      const list = (res as any).data || res || []
      if (Array.isArray(list) && list.includes(city)) {
        dialogProvince.value = p
        cities.value = list
        return
      }
    } catch {}
  }
}

function handleSizeChange(newSize: number) {
  pagination.pageSize = newSize
  pagination.currentPage = 1
  fetchData()
}

function handleCurrentChange(newPage: number) {
  pagination.currentPage = newPage
  fetchData()
}

function formatDate(dateStr: string) {
  if (!dateStr) return '-'
  return new Date(dateStr).toLocaleDateString('zh-CN')
}

onMounted(async () => {
  fetchData()
  loadProvinces()
})
</script>

<style scoped>
.lost-pets-page {
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

.table-card {
  border: none;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.simple-table {
  border-radius: 8px;
  overflow: hidden;
}

.pet-info {
  display: flex;
  align-items: center;
}

.pet-details {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.pet-name {
  font-weight: 600;
  color: #1f2937;
}

.pet-type {
  font-size: 12px;
  color: #6b7280;
}

.location {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.city {
  font-size: 12px;
  color: #6b7280;
}

.reward {
  color: #dc2626;
  font-weight: 600;
}

.no-reward {
  color: #9ca3af;
}

.lost-time {
  font-size: 12px;
  color: #6b7280;
}

.pagination-wrapper {
  margin-top: 24px;
  display: flex;
  justify-content: center;
}

.dialog-form {
  padding: 0 8px;
}

.image-upload {
  display: flex;
  align-items: center;
  gap: 8px;
  width: 100%;
}

.image-preview {
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
</style>