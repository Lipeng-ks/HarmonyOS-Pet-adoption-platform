<template>
  <div>
    <el-card>
      <template #header>
        <div class="card-header">
          <el-space>
            <el-input v-model="queryUsername" placeholder="输入用户名查询" clearable style="width: 240px" @keyup.enter="onSearch" />
            <el-button type="primary" @click="onSearch">查询</el-button>
            <el-button @click="openCreate">新增用户</el-button>
            <el-button @click="fetchAll" :loading="loading">刷新全部</el-button>
          </el-space>
        </div>
      </template>

      <el-table :data="tableData" v-loading="loading" stripe>
        <el-table-column prop="username" label="用户名" min-width="120" />
        <el-table-column prop="email" label="邮箱" min-width="160" />
        <el-table-column prop="phone" label="电话" width="120" />
        <el-table-column prop="address" label="地址" min-width="160" />
        <el-table-column label="操作" width="360" fixed="right">
          <template #default="{ row }">
            <el-button size="small" @click="openEdit(row)">编辑</el-button>
            <el-popconfirm title="确认删除该用户？" @confirm="onDelete(row)">
              <template #reference>
                <el-button size="small" type="danger">删除</el-button>
              </template>
            </el-popconfirm>
            <el-button size="small" type="success" @click="onCheckin(row)" :loading="checkinLoading[row.username]">打卡</el-button>
            <el-button size="small" @click="openAddressManager(row)">地址管理</el-button>
          </template>
        </el-table-column>
      </el-table>

      <el-empty v-if="!loading && tableData.length===0" description="通过用户名查询用户" />
    </el-card>

    <el-dialog v-model="dialog.visible" :title="dialog.isEdit ? '编辑用户' : '新增用户'" width="520px">
      <el-form :model="dialog.form" label-width="88px">
        <el-form-item label="用户名"><el-input v-model="dialog.form.username" :disabled="dialog.isEdit" /></el-form-item>
        <el-form-item v-if="!dialog.isEdit" label="密码"><el-input v-model="dialog.form.password" type="password" /></el-form-item>
        <el-form-item label="邮箱"><el-input v-model="dialog.form.email" /></el-form-item>
        <el-form-item label="电话"><el-input v-model="dialog.form.phone" /></el-form-item>
        <el-form-item label="地址"><el-input v-model="dialog.form.address" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialog.visible=false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="onSubmit">保存</el-button>
      </template>
    </el-dialog>

    <!-- 地址管理对话框 -->
    <el-dialog v-model="addrDlg.visible" :title="`地址管理 - ${addrDlg.username}`" width="900px" :close-on-click-modal="false">
      <div class="address-manager">
        <!-- 地址列表区域 -->
        <div class="address-list-section">
          <div class="section-header">
            <h4>已有地址</h4>
            <el-button size="small" type="primary" @click="startAddNew">
              <el-icon><Plus /></el-icon>
              新增地址
            </el-button>
          </div>
          
          <el-table :data="addrDlg.list" v-loading="addrDlg.loading" class="address-table">
            <el-table-column prop="name" label="收件人" width="100" />
            <el-table-column prop="phone" label="电话" width="120" />
            <el-table-column prop="city" label="城市" width="100" />
            <el-table-column prop="detail" label="详细地址" min-width="200" show-overflow-tooltip />
            <el-table-column prop="isDefault" label="默认" width="70" align="center">
              <template #default="{ row }">
                <el-tag v-if="row.isDefault" type="success" size="small">默认</el-tag>
                <span v-else class="text-muted">-</span>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="140" align="center">
              <template #default="{ row }">
                <el-button size="small" type="primary" link @click="editAddress(row)">
                  <el-icon><Edit /></el-icon>
                  编辑
                </el-button>
                <el-popconfirm 
                  title="确认删除该地址？" 
                  @confirm="removeAddress(row)"
                  confirm-button-text="删除"
                  cancel-button-text="取消"
                >
                  <template #reference>
                    <el-button size="small" type="danger" link>
                      <el-icon><Delete /></el-icon>
                      删除
                    </el-button>
                  </template>
                </el-popconfirm>
              </template>
            </el-table-column>
          </el-table>
          
          <el-empty v-if="!addrDlg.loading && addrDlg.list.length === 0" description="暂无地址信息" />
        </div>

        <!-- 表单区域 -->
        <div v-if="addrDlg.showForm" class="address-form-section">
          <el-divider>
            <span class="form-title">
              {{ addrDlg.isEdit ? '编辑地址' : '新增地址' }}
            </span>
          </el-divider>
          
          <el-form 
            :model="addrDlg.form" 
            :rules="addressRules" 
            ref="addressFormRef"
            label-width="90px"
            class="address-form"
          >
            <el-row :gutter="16">
              <el-col :span="12">
                <el-form-item label="收件人" prop="name">
                  <el-input 
                    v-model="addrDlg.form.name" 
                    placeholder="请输入收件人姓名"
                    maxlength="50"
                    show-word-limit
                  />
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="联系电话" prop="phone">
                  <el-input 
                    v-model="addrDlg.form.phone" 
                    placeholder="请输入手机号码"
                    maxlength="11"
                  />
                </el-form-item>
              </el-col>
            </el-row>
            
            <el-form-item label="所在地区" prop="city">
              <div class="region-selector">
                <el-select 
                  v-model="addrProvince" 
                  placeholder="请选择省份" 
                  style="width: 180px" 
                  @change="onAddrProvinceChange"
                  clearable
                >
                  <el-option v-for="p in provinces" :key="p" :value="p" :label="p" />
                </el-select>
                <el-select 
                  v-model="addrDlg.form.city" 
                  placeholder="请选择城市" 
                  style="width: 180px"
                  :disabled="!addrProvince"
                  clearable
                >
                  <el-option v-for="c in cities" :key="c" :value="c" :label="c" />
                </el-select>
              </div>
            </el-form-item>
            
            <el-form-item label="详细地址" prop="detail">
              <el-input 
                v-model="addrDlg.form.detail" 
                type="textarea" 
                :rows="3"
                placeholder="请输入详细地址，如街道、门牌号等"
                maxlength="200"
                show-word-limit
              />
            </el-form-item>
            
            <el-form-item label="设为默认">
              <el-switch 
                v-model="addrDlg.form.isDefault" 
                active-text="是" 
                inactive-text="否"
              />
              <span class="form-tip">设为默认地址后，其他地址的默认状态将被取消</span>
            </el-form-item>
            
            <el-form-item class="form-actions">
              <el-button @click="cancelAddressEdit">取消</el-button>
              <el-button type="primary" :loading="addrDlg.saving" @click="submitAddress">
                {{ addrDlg.isEdit ? '更新地址' : '保存地址' }}
              </el-button>
            </el-form-item>
          </el-form>
        </div>
      </div>
      
      <template #footer>
        <el-button @click="closeAddressManager">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { getUser, listAllUsers, createUser, updateUser, deleteUser, type UserInfo } from '@/services/users'
import { checkin } from '@/services/checkin'
import { listUserAddresses, addUserAddress, updateUserAddress, deleteUserAddress, type UserAddress } from '@/services/addresses'
import { listProvinces, listCitiesByProvince } from '@/services/provinces'

const loading = ref(false)
const queryUsername = ref('')
const tableData = ref<UserInfo[]>([])

const dialog = reactive<{ visible: boolean; isEdit: boolean; form: UserInfo }>({
  visible: false,
  isEdit: false,
  form: { username: '', password: '' }
})
const submitting = ref(false)

// 打卡 loading 状态映射（按用户名区分）
const checkinLoading = reactive<Record<string, boolean>>({})

// 地址管理对话框状态
const addrDlg = reactive<{
  visible: boolean
  username: string
  list: UserAddress[]
  loading: boolean
  showForm: boolean
  isEdit: boolean
  editingId?: number | null
  form: UserAddress
  saving: boolean
}>(
  {
    visible: false,
    username: '',
    list: [],
    loading: false,
    showForm: false,
    isEdit: false,
    editingId: null,
    form: { name: '', phone: '', city: '', detail: '', isDefault: false },
    saving: false
  }
)

// 地址表单引用和验证规则
const addressFormRef = ref()
const addressRules = {
  name: [
    { required: true, message: '请输入收件人姓名', trigger: 'blur' },
    { min: 2, max: 50, message: '姓名长度在2到50个字符', trigger: 'blur' }
  ],
  phone: [
    { required: true, message: '请输入联系电话', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号码', trigger: 'blur' }
  ],
  city: [
    { required: true, message: '请选择城市', trigger: 'change' }
  ],
  detail: [
    { required: true, message: '请输入详细地址', trigger: 'blur' },
    { min: 5, max: 200, message: '详细地址长度在5到200个字符', trigger: 'blur' }
  ]
}

// 省市联动（地址管理）
const provinces = ref<string[]>([])
const cities = ref<string[]>([])
const addrProvince = ref<string>('')
const citiesCache = reactive<Record<string, string[]>>({})

async function fetchAll() {
  loading.value = true
  try {
    const res = await listAllUsers()
    tableData.value = res.data || []
  } catch (e: any) {
    ElMessage.error(e.message || '加载全部用户失败')
  } finally {
    loading.value = false
  }
}

async function onSearch() {
  if (!queryUsername.value) {
    // 查询为空时回退到全部
    fetchAll()
    return
  }
  loading.value = true
  try {
    const res = await getUser(queryUsername.value)
    if (res.data) {
      tableData.value = [res.data]
    } else {
      tableData.value = []
    }
  } catch (e: any) {
    ElMessage.error(e.message || '查询失败')
  } finally {
    loading.value = false
  }
}

function openCreate() {
  dialog.isEdit = false
  dialog.form = { username: '', password: '' }
  dialog.visible = true
}

function openEdit(row: UserInfo) {
  dialog.isEdit = true
  dialog.form = { ...row }
  dialog.visible = true
}

async function onSubmit() {
  submitting.value = true
  try {
    if (dialog.isEdit) {
      const res = await updateUser(dialog.form.username, dialog.form)
      if (res.success) ElMessage.success('更新成功')
    } else {
      const res = await createUser(dialog.form)
      if (res.affectedRows === 1 || res.success) ElMessage.success('创建成功')
    }
    dialog.visible = false
    onSearch()
  } catch (e: any) {
    ElMessage.error(e.message || '保存失败')
  } finally {
    submitting.value = false
  }
}

async function onDelete(row: UserInfo) {
  try {
    const res = await deleteUser(row.username)
    if (res.success || res.affectedRows === 1) {
      ElMessage.success('删除成功')
      onSearch()
    }
  } catch (e: any) {
    ElMessage.error(e.message || '删除失败')
  }
}

onMounted(() => {
  fetchAll()
})

// 打卡
async function onCheckin(row: UserInfo) {
  if (!row.username) return
  checkinLoading[row.username] = true
  try {
    const res = await checkin(row.username)
    if ((res as any).success) {
      ElMessage.success('打卡成功')
    } else {
      ElMessage.warning((res as any).message || '打卡未成功')
    }
  } catch (e: any) {
    ElMessage.error(e.message || '打卡失败')
  } finally {
    checkinLoading[row.username] = false
  }
}

// 地址管理
async function openAddressManager(row: UserInfo) {
  if (!row.username) return
  addrDlg.username = row.username
  addrDlg.visible = true
  // 初始化省列表
  if (!provinces.value.length) {
    try {
      const res = await listProvinces()
      provinces.value = (res as any).data || res || []
    } catch {}
  }
  await loadAddresses()
}

async function loadAddresses() {
  if (!addrDlg.username) return
  addrDlg.loading = true
  try {
    const res = await listUserAddresses(addrDlg.username)
    addrDlg.list = (res.data as UserAddress[]) || []
  } catch (e: any) {
    ElMessage.error(e.message || '加载地址失败')
  } finally {
    addrDlg.loading = false
  }
}

// 开始新增地址
function startAddNew() {
  addrDlg.showForm = true
  addrDlg.isEdit = false
  addrDlg.editingId = null
  addrDlg.form = { name: '', phone: '', city: '', detail: '', isDefault: false }
  addrProvince.value = ''
  cities.value = []
  // 清除表单验证
  if (addressFormRef.value) {
    addressFormRef.value.clearValidate()
  }
}

function editAddress(row: UserAddress) {
  addrDlg.showForm = true
  addrDlg.isEdit = true
  addrDlg.editingId = row.id || null
  addrDlg.form = { ...row }
  // 根据已有城市回填省份并加载城市
  if (addrDlg.form.city) {
    inferProvinceByCity(addrDlg.form.city)
  }
  // 清除表单验证
  if (addressFormRef.value) {
    addressFormRef.value.clearValidate()
  }
}

// 取消编辑
function cancelAddressEdit() {
  addrDlg.showForm = false
  addrDlg.isEdit = false
  addrDlg.editingId = null
  addrDlg.form = { name: '', phone: '', city: '', detail: '', isDefault: false }
  addrProvince.value = ''
  cities.value = []
}

// 关闭地址管理器
function closeAddressManager() {
  addrDlg.visible = false
  cancelAddressEdit()
}

async function submitAddress() {
  if (!addrDlg.username) return
  
  // 表单验证
  if (addressFormRef.value) {
    try {
      await addressFormRef.value.validate()
    } catch {
      return
    }
  }
  
  addrDlg.saving = true
  try {
    if (addrDlg.isEdit && addrDlg.editingId) {
      const res = await updateUserAddress(addrDlg.username, addrDlg.editingId, addrDlg.form)
      if ((res as any).success !== false) {
        ElMessage.success('地址更新成功')
      }
    } else {
      const res = await addUserAddress(addrDlg.username, addrDlg.form)
      if ((res as any).success !== false) {
        ElMessage.success('地址新增成功')
      }
    }
    
    // 重置表单并隐藏
    cancelAddressEdit()
    await loadAddresses()
  } catch (e: any) {
    ElMessage.error(e.message || '保存地址失败')
  } finally {
    addrDlg.saving = false
  }
}

async function removeAddress(row: UserAddress) {
  if (!addrDlg.username || !row.id) return
  try {
    const res = await deleteUserAddress(addrDlg.username, row.id)
    if ((res as any).success !== false) {
      ElMessage.success('删除成功')
      await loadAddresses()
    }
  } catch (e: any) {
    ElMessage.error(e.message || '删除失败')
  }
}

async function onAddrProvinceChange() {
  try {
    cities.value = []
    if (!addrProvince.value) return
    if (citiesCache[addrProvince.value]) {
      cities.value = citiesCache[addrProvince.value]
      return
    }
    const res = await listCitiesByProvince(addrProvince.value)
    const list = (res as any).data || res || []
    citiesCache[addrProvince.value] = list
    cities.value = list
  } catch {}
}

async function inferProvinceByCity(city: string) {
  if (!city) return
  for (const p of provinces.value) {
    if (!citiesCache[p]) {
      try {
        const res = await listCitiesByProvince(p)
        citiesCache[p] = (res as any).data || res || []
      } catch { citiesCache[p] = [] }
    }
    if (citiesCache[p].includes(city)) {
      addrProvince.value = p
      cities.value = citiesCache[p]
      return
    }
  }
}
</script>

<style scoped>
.card-header { 
  display: flex; 
  align-items: center; 
  justify-content: space-between; 
}

.address-manager {
  min-height: 400px;
}

.address-list-section {
  margin-bottom: 20px;
}

.section-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 16px;
}

.section-header h4 {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.address-table {
  border: 1px solid #ebeef5;
  border-radius: 4px;
}

.text-muted {
  color: #909399;
}

.address-form-section {
  background: #fafafa;
  padding: 20px;
  border-radius: 6px;
  border: 1px solid #ebeef5;
}

.form-title {
  font-weight: 600;
  color: #409eff;
}

.address-form {
  max-width: 100%;
}

.region-selector {
  display: flex;
  gap: 12px;
}

.form-tip {
  margin-left: 12px;
  font-size: 12px;
  color: #909399;
}

.form-actions {
  margin-top: 24px;
  margin-bottom: 0;
}

.form-actions .el-form-item__content {
  justify-content: flex-end;
}
</style>
