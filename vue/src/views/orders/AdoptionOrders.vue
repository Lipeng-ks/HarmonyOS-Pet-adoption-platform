<template>
  <div class="orders-page">
    <!-- 页面标题 -->
    <div class="page-header">
      <div class="header-content">
        <h1>订单管理</h1>
        <p>管理宠物领养订单和申请</p>
      </div>
      <el-button type="primary" @click="openCreate">
        <el-icon><Plus /></el-icon>
        新建订单
      </el-button>
    </div>

    <!-- 筛选区域 -->
    <el-card class="filter-card" shadow="never">
      <el-row :gutter="16" align="middle">
        <el-col :xs="24" :sm="6" :md="4">
          <div class="filter-item">
            <label>订单状态</label>
            <el-select v-model="filters.status" clearable placeholder="全部状态" @change="onFilterChange">
              <el-option v-for="s in statuses" :key="s" :value="s" :label="s" />
            </el-select>
          </div>
        </el-col>
        <el-col :xs="24" :sm="6" :md="4">
          <div class="filter-item">
            <label>省份筛选</label>
            <el-select v-model="filters.province" clearable placeholder="全部省份" @change="onFilterChange">
              <el-option v-for="p in provinces" :key="p" :value="p" :label="p" />
            </el-select>
          </div>
        </el-col>
        <el-col :xs="24" :sm="8" :md="6">
          <div class="filter-item">
            <label>关键词搜索</label>
            <el-input 
              v-model="filters.keyword" 
              placeholder="搜索宠物名或地区" 
              clearable
              @clear="onFilterChange"
              @keyup.enter="onFilterChange"
            >
              <template #prefix>
                <el-icon><Search /></el-icon>
              </template>
            </el-input>
          </div>
        </el-col>
        <el-col :xs="24" :sm="4" :md="4">
          <div class="filter-actions">
            <el-button @click="onFilterChange" :loading="loading">
              <el-icon><Refresh /></el-icon>
              刷新
            </el-button>
          </div>
        </el-col>
      </el-row>
    </el-card>

    <!-- 数据表格 -->
    <el-card class="table-card" shadow="never">
      <el-table :data="list" v-loading="loading" stripe>
        <el-table-column prop="id" label="订单ID" width="80" />
        <el-table-column prop="userId" label="用户ID" width="80" />
        <el-table-column prop="animalId" label="动物ID" width="80" />
        <el-table-column prop="petName" label="宠物名" min-width="120" />
        <el-table-column label="省份" width="100">
          <template #default="{ row }">
            {{ getCityProvince(row.petAddress) || '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="petAddress" label="所在地区" min-width="140" show-overflow-tooltip />
        <el-table-column prop="applicationTime" label="申请时间" width="160">
          <template #default="{ row }">
            {{ formatDate(row.applicationTime) }}
          </template>
        </el-table-column>
        <el-table-column label="状态" width="140">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)" size="small">
              {{ row.status }}
            </el-tag>
            <el-dropdown 
              trigger="click" 
              style="margin-left: 8px" 
              @command="(s: OrderStatus) => changeStatus(row, s)"
            >
              <el-button size="small" type="primary" link>
                变更
              </el-button>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item 
                    v-for="s in statuses" 
                    :key="s" 
                    :command="s"
                    :disabled="s === row.status"
                  >
                    {{ s }}
                  </el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="160" fixed="right">
          <template #default="{ row }">
            <div class="action-buttons">
              <el-button size="small" @click="openEdit(row)">
                <el-icon><Edit /></el-icon>
                编辑
              </el-button>
              <el-popconfirm title="确认删除该订单？" @confirm="onDelete(row)">
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

      <!-- 分页 -->
      <div class="pagination-wrapper" v-if="pager.total > 0">
        <el-pagination
          background
          layout="prev, pager, next, sizes, total"
          :total="pager.total"
          :current-page="pager.page"
          :page-size="pager.size"
          :page-sizes="[10, 20, 30, 50]"
          @current-change="onPageChange"
          @size-change="onSizeChange"
        />
      </div>

      <el-empty v-if="!loading && list.length === 0" description="暂无订单数据" />
    </el-card>

    <!-- 新建/编辑订单弹窗 -->
    <el-dialog v-model="dialog.visible" :title="dialog.isEdit ? '编辑订单' : '新建订单'" width="600px">
      <el-form :model="dialog.form" label-width="100px" label-position="top">
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="用户ID" required>
              <el-input-number 
                v-model="dialog.form.userId" 
                :min="1" 
                style="width: 100%"
                placeholder="请输入用户ID"
              />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="动物ID">
              <el-input-number 
                v-model="dialog.form.animalId" 
                :min="1" 
                :controls="false" 
                style="width: 100%"
                placeholder="可选，精确关联动物"
              />
            </el-form-item>
          </el-col>
        </el-row>
        
        <el-form-item label="宠物名称" required>
          <el-input v-model="dialog.form.petName" placeholder="请输入宠物名称" />
        </el-form-item>
        
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="省份" required>
              <el-select 
                v-model="dialogProvince" 
                placeholder="请选择省份" 
                style="width: 100%" 
                @change="onDialogProvinceChange"
              >
                <el-option v-for="p in provinces" :key="p" :value="p" :label="p" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="城市" required>
              <el-select 
                v-model="dialogCity" 
                placeholder="请选择城市" 
                style="width: 100%"
                :disabled="!dialogProvince"
              >
                <el-option v-for="c in dialogCities" :key="c" :value="c" :label="c" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        
        <el-form-item label="收货地址">
          <el-input v-model="dialog.form.shippingAddress" placeholder="请输入收货地址" />
        </el-form-item>
        
        <el-form-item label="养宠经验">
          <el-input 
            v-model="dialog.form.petExperience" 
            type="textarea" 
            :rows="3"
            placeholder="请描述您的养宠经验"
          />
        </el-form-item>
        
        <el-form-item label="申请理由">
          <el-input 
            v-model="dialog.form.applicationReason" 
            type="textarea" 
            :rows="3"
            placeholder="请说明申请领养的理由"
          />
        </el-form-item>
        
        <el-form-item label="订单状态" v-if="dialog.isEdit">
          <el-select v-model="dialog.form.status" style="width: 200px">
            <el-option v-for="s in statuses" :key="s" :value="s" :label="s" />
          </el-select>
        </el-form-item>
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
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { 
  Search, 
  Refresh, 
  Edit, 
  Delete, 
  Plus 
} from '@element-plus/icons-vue'
import { getOrdersPage, listOrders, updateOrderStatus, createOrder, updateOrder, deleteOrder, type AdoptionOrder, type OrderStatus } from '@/services/orders'
import { listProvinces, listCitiesByProvince } from '@/services/provinces'

// 与后端一致的订单状态
const statuses: OrderStatus[] = ['审核中', '已发货', '完成', '评价']
const loading = ref(false)
const list = ref<AdoptionOrder[]>([])
const filters = reactive<{ status?: OrderStatus | null; keyword: string; province?: string | null }>({ 
  status: null, 
  keyword: '', 
  province: null 
})

// 省份城市数据
const provinces = ref<string[]>([])
const cityProvinceMap = ref<Record<string, string>>({})
const dialogProvince = ref<string>('')
const dialogCity = ref<string>('')
const dialogCities = ref<string[]>([])
const pager = reactive<{ page: number; size: number; total: number }>({ page: 1, size: 10, total: 0 })

const dialog = reactive<{ 
  visible: boolean; 
  isEdit: boolean;
  form: { 
    id?: number;
    userId: number | null; 
    animalId: number | null; 
    petName: string; 
    petAddress: string; 
    shippingAddress?: string | null;
    petExperience?: string | null;
    applicationReason?: string | null;
    status?: OrderStatus;
  } 
}>({
  visible: false,
  isEdit: false,
  form: { 
    userId: null, 
    animalId: null, 
    petName: '', 
    petAddress: '', 
    shippingAddress: '', 
    petExperience: '', 
    applicationReason: '', 
    status: '审核中' 
  }
})
const submitting = ref(false)

// 获取状态标签类型
function getStatusType(status: string) {
  const typeMap: Record<string, string> = {
    '审核中': 'warning',
    '已发货': 'primary',
    '完成': 'success',
    '评价': 'info'
  }
  return typeMap[status] || 'info'
}

// 格式化日期
function formatDate(date?: string | null) {
  if (!date) return '-'
  try {
    return new Date(date).toLocaleString('zh-CN', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    })
  } catch {
    return date
  }
}

async function fetchData() {
  loading.value = true
  try {
    const params = {
      page: pager.page - 1,
      size: pager.size,
      status: filters.status || undefined,
      keyword: filters.keyword || undefined
    }
    
    const res = await getOrdersPage(params)
    const data = res as any
    
    if (data.success !== false) {
      const pagePayload = data.records !== undefined ? data : (data.data || {})
      let items = pagePayload.records || pagePayload.content || pagePayload.list || []
      
      // 省份筛选
      if (filters.province && Array.isArray(items)) {
        items = items.filter((order: AdoptionOrder) => {
          const extractedProvince = getCityProvince(order.petAddress)
          return extractedProvince === filters.province
        })
      }
      
      list.value = Array.isArray(items) ? items : []
      pager.total = Array.isArray(items) ? items.length : (pagePayload.total || pagePayload.totalElements || 0)
      
      if (typeof pagePayload.page === 'number') {
        pager.page = pagePayload.page + 1
      }
      if (typeof pagePayload.size === 'number') {
        pager.size = pagePayload.size
      }
    } else {
      throw new Error(data.message || '获取数据失败')
    }
    
  } catch (e: any) {
    console.error('getOrdersPage 调用失败：', e?.message)
    ElMessage.error(e.message || '加载订单数据失败')
    
    // 备选方案：使用非分页接口
    try {
      const res2 = await listOrders()
      const data2 = res2 as any
      
      if (data2.success !== false) {
        let allOrders = data2.data || data2 || []
        
        // 前端筛选
        if (filters.status) {
          allOrders = allOrders.filter((order: AdoptionOrder) => order.status === filters.status)
        }
        if (filters.keyword) {
          const keyword = filters.keyword.toLowerCase()
          allOrders = allOrders.filter((order: AdoptionOrder) => 
            order.petName?.toLowerCase().includes(keyword) || 
            order.petAddress?.toLowerCase().includes(keyword)
          )
        }
        if (filters.province) {
          allOrders = allOrders.filter((order: AdoptionOrder) => 
            getCityProvince(order.petAddress) === filters.province
          )
        }
        
        // 手动分页
        const startIndex = (pager.page - 1) * pager.size
        const endIndex = startIndex + pager.size
        list.value = allOrders.slice(startIndex, endIndex)
        pager.total = allOrders.length
      }
    } catch (e2: any) {
      console.error('备选接口也失败：', e2?.message)
      list.value = []
      pager.total = 0
    }
  } finally {
    loading.value = false
  }
}

async function changeStatus(row: AdoptionOrder, s: OrderStatus) {
  if (!row.id) {
    ElMessage.error('订单ID不存在')
    return
  }
  
  try {
    const res = await updateOrderStatus(row.id, s)
    if ((res as any).success !== false) {
      row.status = s
      ElMessage.success('状态已更新')
    } else {
      ElMessage.error((res as any).message || '更新失败')
    }
  } catch (e: any) {
    ElMessage.error(e.message || '更新失败')
  }
}

async function onDelete(row: AdoptionOrder) {
  if (!row.id) {
    ElMessage.error('订单ID不存在')
    return
  }
  
  try {
    const res = await deleteOrder(row.id)
    if ((res as any).success !== false) {
      ElMessage.success('删除成功')
      fetchData()
    } else {
      ElMessage.error((res as any).message || '删除失败')
    }
  } catch (e: any) {
    ElMessage.error(e.message || '删除失败')
  }
}

// 对话框省份变更处理
async function onDialogProvinceChange() {
  try {
    dialogCities.value = []
    dialogCity.value = ''
    if (!dialogProvince.value) return
    const res = await listCitiesByProvince(dialogProvince.value)
    dialogCities.value = (res as any).data || res || []
  } catch (e) {
    console.error('加载城市数据失败:', e)
  }
}

// 从地址解析省份和城市
function parseAddress(address: string) {
  if (!address) return { province: '', city: '' }
  
  // 先尝试从缓存的城市-省份映射中查找
  for (const [city, province] of Object.entries(cityProvinceMap.value)) {
    if (address.includes(city)) {
      return { province, city }
    }
  }
  
  // 简单的省份提取逻辑
  const provinceMatch = address.match(/(\S+?省|\S+?市|\S+?自治区|\S+?特别行政区)/)
  const cityMatch = address.match(/(\S+?市|\S+?县|\S+?区)/)
  
  return {
    province: provinceMatch ? provinceMatch[1] : '',
    city: cityMatch ? cityMatch[1] : ''
  }
}

function openCreate() {
  dialog.isEdit = false
  dialog.form = { 
    userId: null, 
    animalId: null, 
    petName: '', 
    petAddress: '', 
    shippingAddress: '', 
    petExperience: '', 
    applicationReason: '', 
    status: '审核中' 
  }
  dialogProvince.value = ''
  dialogCity.value = ''
  dialogCities.value = []
  dialog.visible = true
}

async function openEdit(row: AdoptionOrder) {
  dialog.isEdit = true
  dialog.form = {
    id: row.id,
    userId: row.userId,
    animalId: row.animalId || null,
    petName: row.petName,
    petAddress: row.petAddress,
    shippingAddress: row.shippingAddress || '',
    petExperience: row.petExperience || '',
    applicationReason: row.applicationReason || '',
    status: row.status || '审核中'
  }
  
  // 解析现有地址
  const { province, city } = parseAddress(row.petAddress)
  dialogProvince.value = province
  dialogCity.value = city
  
  // 加载对应省份的城市列表
  if (province) {
    await onDialogProvinceChange()
    dialogCity.value = city
  }
  
  dialog.visible = true
}

async function onSubmit() {
  submitting.value = true
  try {
    if (!dialog.form.userId) throw new Error('请填写用户ID')
    if (!dialog.form.petName.trim()) throw new Error('请填写宠物名')
    
    // 构建完整地址
    const fullAddress = dialogProvince.value && dialogCity.value 
      ? `${dialogProvince.value}${dialogCity.value}`
      : dialog.form.petAddress.trim()
    
    if (!fullAddress) throw new Error('请选择省份和城市')
    
    const payload: any = {
      userId: dialog.form.userId,
      petName: dialog.form.petName,
      petAddress: fullAddress,
      shippingAddress: dialog.form.shippingAddress || undefined,
      petExperience: dialog.form.petExperience || undefined,
      applicationReason: dialog.form.applicationReason || undefined
    }
    
    if (dialog.form.animalId) payload.animalId = dialog.form.animalId
    if (dialog.isEdit && dialog.form.status) payload.status = dialog.form.status
    
    let res
    if (dialog.isEdit) {
      if (!dialog.form.id) {
        throw new Error('订单ID不存在')
      }
      res = await updateOrder(dialog.form.id, payload)
    } else {
      res = await createOrder(payload)
    }
    
    if ((res as any).success !== false) {
      ElMessage.success(dialog.isEdit ? '更新成功' : '创建成功')
      dialog.visible = false
      fetchData()
    }
  } catch (e: any) {
    ElMessage.error(e.message || (dialog.isEdit ? '更新失败' : '创建失败'))
  } finally {
    submitting.value = false
  }
}

function onPageChange(p: number) {
  pager.page = p
  fetchData()
}

function onSizeChange(s: number) {
  pager.size = s
  pager.page = 1
  fetchData()
}

function onFilterChange() {
  pager.page = 1
  fetchData()
}

// 从地址中提取省份信息
function getCityProvince(address: string): string {
  if (!address) return ''
  
  // 先检查缓存的城市-省份映射
  for (const [city, province] of Object.entries(cityProvinceMap.value)) {
    if (address.includes(city)) {
      return province
    }
  }
  
  // 简单的省份提取逻辑
  const provinceMatch = address.match(/(\S+?省|\S+?市|\S+?自治区|\S+?特别行政区)/)
  return provinceMatch ? provinceMatch[1] : ''
}

// 加载省份数据
async function loadProvinces() {
  try {
    const res = await listProvinces()
    provinces.value = (res as any).data || res || []
    
    // 并行加载所有省份的城市数据
    const cityPromises = provinces.value.map(async (province) => {
      try {
        const cityRes = await listCitiesByProvince(province)
        const cities = (cityRes as any).data || cityRes || []
        return { province, cities }
      } catch {
        return { province, cities: [] }
      }
    })
    
    const results = await Promise.all(cityPromises)
    const newMap: Record<string, string> = {}
    
    results.forEach(({ province, cities }) => {
      cities.forEach((city: string) => {
        newMap[city] = province
      })
    })
    
    cityProvinceMap.value = newMap
  } catch (e) {
    console.error('加载省份数据失败:', e)
  }
}

onMounted(async () => {
  fetchData()
  loadProvinces()
})
</script>

<style scoped>
.orders-page {
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

/* 分页 */
.pagination-wrapper {
  display: flex;
  justify-content: flex-end;
  margin-top: 16px;
  padding: 16px 24px;
  border-top: 1px solid #f0f2f5;
}

/* 弹窗样式 */
.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .orders-page {
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

  .pagination-wrapper {
    justify-content: center;
    padding: 16px;
  }

  .pagination-wrapper :deep(.el-pagination) {
    flex-wrap: wrap;
    justify-content: center;
  }
}

@media (max-width: 480px) {
  .filter-actions .el-button {
    width: 100%;
  }
}
</style>