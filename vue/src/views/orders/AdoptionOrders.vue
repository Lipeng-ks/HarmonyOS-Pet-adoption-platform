<template>
  <div>
    <el-card>
      <template #header>
        <div class="card-header">
          <div class="left">
            <el-space>
              <el-select v-model="filters.status" clearable placeholder="订单状态" style="width: 160px" @change="onFilterChange">
                <el-option v-for="s in statuses" :key="s" :value="s" :label="s" />
              </el-select>
              <el-select v-model="filters.province" clearable placeholder="省份筛选" style="width: 140px" @change="onFilterChange">
                <el-option v-for="(p, index) in provinces" :key="index" :value="p" :label="p" />
              </el-select>
              <el-input 
                v-model="filters.keyword" 
                placeholder="搜索宠物名或地区" 
                style="width: 200px"
                clearable
                @clear="onFilterChange"
                @keyup.enter="onFilterChange"
              >
                <template #prefix>
                  <el-icon><Search /></el-icon>
                </template>
              </el-input>
              <el-button @click="onFilterChange" :loading="loading">
                <el-icon><Refresh /></el-icon>
                刷新
              </el-button>
            </el-space>
          </div>
          <div class="right">
            <el-button type="primary" @click="openCreate">新建订单</el-button>
          </div>
        </div>
      </template>

      <el-table :data="list" stripe>
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="userId" label="用户ID" width="100" />
        <el-table-column prop="animalId" label="动物ID" width="100" />
        <el-table-column prop="petName" label="宠物名" min-width="160" />
        <el-table-column label="省份" width="100">
          <template #default="{ row }">
            {{ getCityProvince(row.petAddress) || '' }}
          </template>
        </el-table-column>
        <el-table-column prop="petAddress" label="所在地区" min-width="160" />
        <el-table-column prop="applicationTime" label="申请时间" width="180" />
        <el-table-column label="状态" width="180">
          <template #default="{ row }">
            <el-tag type="info">{{ row.status }}</el-tag>
            <el-dropdown trigger="click" style="margin-left:8px" @command="(s)=>changeStatus(row, s)">
              <span class="el-dropdown-link">变更</span>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item v-for="s in statuses" :key="s" :command="s">{{ s }}</el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button size="small" @click="openEdit(row)">
              <el-icon><Edit /></el-icon>
              编辑
            </el-button>
            <el-popconfirm title="确认删除该订单？" @confirm="onDelete(row)">
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

      <div style="margin-top: 12px; display:flex; justify-content:flex-end">
        <el-pagination
          background
          layout="prev, pager, next, sizes, total"
          :total="pager.total"
          :current-page="pager.page"
          :page-size="pager.size"
          :page-sizes="[10,20,30,50]"
          @current-change="onPageChange"
          @size-change="onSizeChange"
        />
      </div>

      <el-empty v-if="!loading && list.length===0" description="暂无数据" />
    </el-card>

    <el-dialog v-model="dialog.visible" :title="dialog.isEdit ? '编辑订单' : '新建订单'" width="600px">
      <el-form :model="dialog.form" label-width="120px">
        <el-form-item label="用户ID"><el-input-number v-model="dialog.form.userId" :min="1" /></el-form-item>
        <el-form-item label="动物ID"><el-input-number v-model="dialog.form.animalId" :min="1" :controls="false" placeholder="可选，填写则精确关联" /></el-form-item>
        <el-form-item label="宠物名"><el-input v-model="dialog.form.petName" /></el-form-item>
        <el-form-item label="所在地区">
          <div style="display:flex; gap:8px; width:100%">
            <el-select v-model="dialogProvince" placeholder="省份" style="width: 160px" @change="onDialogProvinceChange">
              <el-option v-for="p in provinces" :key="p" :value="p" :label="p" />
            </el-select>
            <el-select v-model="dialogCity" placeholder="城市" style="flex:1">
              <el-option v-for="c in dialogCities" :key="c" :value="c" :label="c" />
            </el-select>
          </div>
        </el-form-item>
        <el-form-item label="收货地址"><el-input v-model="dialog.form.shippingAddress" placeholder="收货地址" /></el-form-item>
        <el-form-item label="养宠经验"><el-input v-model="dialog.form.petExperience" type="textarea" :rows="2" placeholder="请描述您的养宠经验" /></el-form-item>
        <el-form-item label="申请理由"><el-input v-model="dialog.form.applicationReason" type="textarea" :rows="3" placeholder="请说明申请领养的理由" /></el-form-item>
        <el-form-item label="订单状态" v-if="dialog.isEdit">
          <el-select v-model="dialog.form.status" style="width: 160px">
            <el-option v-for="s in statuses" :key="s" :value="s" :label="s" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialog.visible=false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="onSubmit">{{ dialog.isEdit ? '保存' : '创建' }}</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Refresh, Edit, Delete } from '@element-plus/icons-vue'
import { getOrdersPage, listOrders, updateOrderStatus, createOrder, updateOrder, deleteOrder, type AdoptionOrder, type OrderStatus } from '@/services/orders'
import { listProvinces, listCitiesByProvince } from '@/services/provinces'

// 与后端一致的订单状态
const statuses: OrderStatus[] = ['审核中', '已发货', '完成', '评价']
const loading = ref(false)
const list = ref<AdoptionOrder[]>([])
const filters = reactive<{ status?: OrderStatus | null; keyword?: string; province?: string | null }>({ status: null, keyword: '', province: null })

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
  form: { userId: null, animalId: null, petName: '', petAddress: '', shippingAddress: '', petExperience: '', applicationReason: '', status: '审核中' }
})
const submitting = ref(false)

async function fetchData() {
  loading.value = true
  try {
    // 构建查询参数，确保页码从0开始（后端可能使用0基索引）
    const params = {
      page: pager.page - 1, // 转换为0基索引
      size: pager.size,
      status: filters.status || undefined,
      keyword: filters.keyword || undefined
    }
    
    // 省份筛选逻辑：总是先获取所有数据，然后在前端进行省份筛选
    // 这样可以确保筛选的准确性，因为后端关键词搜索可能无法精确匹配省份
    
    console.log('请求参数:', params) // 调试日志
    
    const res = await getOrdersPage(params)
    console.log('接口返回:', res) // 调试日志
    
    const data = res as any
    
    // 处理返回数据结构
    if (data.success !== false) {
      // 兼容多种返回结构
      const pagePayload = data.records !== undefined ? data : (data.data || {})
      let items = pagePayload.records || pagePayload.content || pagePayload.list || []
      
      // 如果有省份筛选，在前端进行省份筛选
      if (filters.province && Array.isArray(items)) {
        console.log('开始省份筛选，目标省份:', filters.province)
        console.log('筛选前数据:', items.map(item => ({ id: item.id, address: item.petAddress, extractedProvince: getCityProvince(item.petAddress) })))
        
        items = items.filter((order: AdoptionOrder) => {
          const extractedProvince = getCityProvince(order.petAddress)
          const match = extractedProvince === filters.province
          console.log(`地址: ${order.petAddress}, 提取省份: ${extractedProvince}, 匹配: ${match}`)
          return match
        })
        
        console.log('筛选后数据:', items.length)
      }
      
      list.value = Array.isArray(items) ? items : []
      pager.total = Array.isArray(items) ? items.length : (pagePayload.total || pagePayload.totalElements || 0)
      
      // 同步分页信息
      if (typeof pagePayload.page === 'number') {
        pager.page = pagePayload.page + 1 // 转换回1基索引
      }
      if (typeof pagePayload.size === 'number') {
        pager.size = pagePayload.size
      }
      
      console.log('处理后的数据:', { list: list.value, total: pager.total })
    } else {
      throw new Error(data.message || '获取数据失败')
    }
    
  } catch (e: any) {
    console.error('getOrdersPage 调用失败：', e?.message)
    ElMessage.error(e.message || '加载订单数据失败')
    
    // 如果分页接口失败，尝试使用非分页接口作为备选
    try {
      const res2 = await listOrders()
      const data2 = res2 as any
      
      if (data2.success !== false) {
        let allOrders = data2.data || data2 || []
        
        // 在前端进行筛选
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
        
        console.log('使用备选接口，筛选后数据:', { list: list.value, total: pager.total })
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
  try {
    const res = await updateOrderStatus(row.id!, s)
    if (res.success) {
      row.status = s
      ElMessage.success('状态已更新')
    }
  } catch (e: any) {
    ElMessage.error(e.message || '更新失败')
  }
}

async function onDelete(row: AdoptionOrder) {
  try {
    const res = await deleteOrder(row.id!)
    if (res.success) {
      ElMessage.success('删除成功')
      fetchData()
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
  dialog.form = { userId: null, animalId: null, petName: '', petAddress: '', shippingAddress: '', petExperience: '', applicationReason: '', status: '审核中' }
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
    dialogCity.value = city // 重新设置城市值
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
      res = await updateOrder(dialog.form.id!, payload)
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
    
    // 加载省份-城市映射缓存
    const cacheKey = 'cityProvinceMap'
    const cacheExpiry = 'cityProvinceMapExpiry'
    const cached = localStorage.getItem(cacheKey)
    const expiry = localStorage.getItem(cacheExpiry)
    
    if (cached && expiry && Date.now() < parseInt(expiry)) {
      cityProvinceMap.value = JSON.parse(cached)
    } else {
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
      
      // 缓存24小时
      localStorage.setItem(cacheKey, JSON.stringify(newMap))
      localStorage.setItem(cacheExpiry, (Date.now() + 24 * 60 * 60 * 1000).toString())
    }
    console.log('省份数据加载完成:', provinces.value)
    console.log('省份数据长度:', provinces.value.length)
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
.card-header { display: flex; align-items: center; justify-content: space-between; }
</style>
