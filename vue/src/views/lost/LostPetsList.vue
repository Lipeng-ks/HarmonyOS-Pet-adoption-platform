<template>
  <div>
    <el-card>
      <template #header>
        <div class="card-header">
          <div class="left">
            <el-space>
              <el-select v-model="filters.status" clearable placeholder="状态" style="width: 140px" @change="fetchData">
                <el-option value="ACTIVE" label="寻宠中" />
                <el-option value="FOUND" label="已找到" />
                <el-option value="CLOSED" label="已关闭" />
              </el-select>
              <el-input v-model.number="filters.userId" placeholder="用户ID筛选" style="width: 160px" clearable @change="fetchData" />
              <el-select v-model="filters.province" clearable placeholder="省份筛选" style="width: 140px" @change="fetchData">
                <el-option v-for="p in provinces" :key="p" :value="p" :label="p" />
              </el-select>
            </el-space>
          </div>
          <div class="right">
            <el-button type="primary" @click="openCreate">新增寻宠</el-button>
          </div>
        </div>
      </template>

      <el-table :data="list" stripe>
        <el-table-column label="图片" width="80">
          <template #default="{ row }">
            <el-avatar :src="renderImage(row.image)" :size="40">寻</el-avatar>
          </template>
        </el-table-column>
        <el-table-column prop="userId" label="用户ID" width="100" />
        <el-table-column prop="petName" label="宠物名" min-width="120" />
        <el-table-column prop="type" label="类型" width="100" />
        <el-table-column label="省份" width="100">
          <template #default="{ row }">
            {{ cityProvinceMap[row.city] || '' }}
          </template>
        </el-table-column>
        <el-table-column prop="city" label="城市" width="120" />
        <el-table-column label="悬赏金额" width="120">
          <template #default="{ row }">
            <span v-if="row.reward && row.reward > 0" style="color: #f56c6c; font-weight: 600;">
              ¥{{ row.reward }}
            </span>
            <span v-else style="color: #909399;">-</span>
          </template>
        </el-table-column>
        <el-table-column prop="lostTime" label="走失时间" width="160" />
        <el-table-column label="状态" width="160">
          <template #default="{ row }">
            <el-tag :type="row.status==='ACTIVE' ? 'warning' : row.status==='FOUND' ? 'success' : 'info'">
              {{ statusLabel(row.status) }}
            </el-tag>
            <el-dropdown trigger="click" style="margin-left:8px" @command="(s: 'ACTIVE' | 'FOUND' | 'CLOSED')=>changeStatus(row, s)">
              <span class="el-dropdown-link">变更</span>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item command="ACTIVE">寻宠中</el-dropdown-item>
                  <el-dropdown-item command="FOUND">已找到</el-dropdown-item>
                  <el-dropdown-item command="CLOSED">已关闭</el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button size="small" @click="openEdit(row)">编辑</el-button>
            <el-popconfirm title="确认删除？" @confirm="onDelete(row)">
              <template #reference>
                <el-button size="small" type="danger">删除</el-button>
              </template>
            </el-popconfirm>
          </template>
        </el-table-column>
      </el-table>

      <el-empty v-if="!loading && list.length===0" description="暂无数据" />
      
      <!-- 分页组件 -->
      <div class="pagination-container" v-if="list.length > 0">
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

    <el-dialog v-model="dialog.visible" :title="dialog.isEdit ? '编辑寻宠' : '新增寻宠'" width="640px">
      <el-form :model="dialog.form" label-width="108px">
        <el-form-item label="标题"><el-input v-model="dialog.form.title" /></el-form-item>
        <el-form-item label="宠物名"><el-input v-model="dialog.form.petName" /></el-form-item>
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
        <el-form-item label="图片">
          <div style="display:flex; gap:12px; align-items:flex-start; width:100%">
            <el-upload
              :http-request="onFileUpload"
              :show-file-list="false"
              :accept="'image/*'"
            >
              <el-button>上传图片</el-button>
            </el-upload>
            <el-input v-model="dialog.form.image" placeholder="支持粘贴 http(s) 链接或保留 app.media.person" />
          </div>
          <div v-if="dialog.form.image" style="margin-top:8px">
            <el-image :src="renderImage(dialog.form.image) || ''" style="width:120px;height:120px" fit="cover" />
          </div>
        </el-form-item>
        <el-form-item label="走失时间"><el-date-picker v-model="dialog.form.lostTime" type="datetime" value-format="YYYY-MM-DDTHH:mm:ss" placeholder="选择时间" /></el-form-item>
        <el-form-item label="走失地址"><el-input v-model="dialog.form.lostAddress" /></el-form-item>
        <el-form-item label="联系人"><el-input v-model="dialog.form.contactName" /></el-form-item>
        <el-form-item label="联系电话"><el-input v-model="dialog.form.contactPhone" /></el-form-item>
        <el-form-item label="描述"><el-input v-model="dialog.form.description" type="textarea" :rows="3" /></el-form-item>
        <el-form-item label="悬赏金额">
          <el-input-number 
            v-model="dialog.form.reward" 
            :min="0" 
            :max="999999" 
            :precision="2"
            :step="100"
            placeholder="请输入悬赏金额"
            style="width: 200px"
          />
          <span style="margin-left: 8px; color: #909399; font-size: 14px;">元</span>
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
        <el-button @click="dialog.visible=false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="onSubmit">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { listLostPets, listLostPetsByUser, createLostPet, updateLostPet, deleteLostPet, updateStatus, type LostPet } from '@/services/lostpets'
import { uploadFile } from '@/services/upload'
import { listProvinces, listCitiesByProvince } from '@/services/provinces'

const loading = ref(false)
const list = ref<LostPet[]>([])
const filters = reactive<{ status?: 'ACTIVE' | 'FOUND' | 'CLOSED' | null; userId?: number | null; province?: string | null }>({ status: null, userId: null, province: null })

// 分页数据
const pagination = reactive({
  currentPage: 1,
  pageSize: 20,
  total: 0
})

const dialog = reactive<{ visible: boolean; isEdit: boolean; form: LostPet }>({
  visible: false,
  isEdit: false,
  form: { title: '', petName: '', type: '', city: '', age: 0, image: 'app.media.person', lostTime: '', lostAddress: '', contactName: '', contactPhone: '', status: 'ACTIVE' }
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
  dialog.form = { title: '', petName: '', type: '', city: '', age: 0, image: 'app.media.person', lostTime: '', lostAddress: '', contactName: '', contactPhone: '', status: 'ACTIVE' }
  dialog.visible = true
  // 重置省市
  dialogProvince.value = ''
  cities.value = []
}

function openEdit(row: LostPet) {
  dialog.isEdit = true
  dialog.form = { ...row }
  dialog.visible = true
  // 根据已有城市回填省份并加载城市
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

// 分页处理函数
function handleSizeChange(newSize: number) {
  pagination.pageSize = newSize
  pagination.currentPage = 1
  fetchData()
}

function handleCurrentChange(newPage: number) {
  pagination.currentPage = newPage
  fetchData()
}

onMounted(async () => {
  // 先加载数据，省市映射可以异步加载
  fetchData()
  loadProvinces()
})
</script>

<style scoped>
.card-header { display: flex; align-items: center; justify-content: space-between; }
.pagination-container { 
  display: flex; 
  justify-content: center; 
  margin-top: 20px; 
  padding: 20px 0; 
}
</style>
