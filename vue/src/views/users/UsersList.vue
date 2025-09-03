<template>
  <div class="users-page">
    <!-- 页面标题 -->
    <div class="page-header">
      <div class="header-content">
        <h1>用户管理</h1>
        <p>管理系统用户信息和地址</p>
      </div>
    </div>

    <!-- 操作区域 -->
    <el-card class="action-card" shadow="never">
      <div class="action-bar">
        <div class="search-area">
          <el-input 
            v-model="queryUsername" 
            placeholder="输入用户名查询" 
            clearable 
            style="width: 240px" 
            @keyup.enter="onSearch"
          >
            <template #append>
              <el-button @click="onSearch" :loading="loading">
                <el-icon><Search /></el-icon>
              </el-button>
            </template>
          </el-input>
        </div>
        <div class="button-group">
          <el-button type="primary" @click="openCreate">
            <el-icon><Plus /></el-icon>
            新增用户
          </el-button>
          <el-button @click="fetchAll" :loading="loading">
            <el-icon><Refresh /></el-icon>
            刷新全部
          </el-button>
        </div>
      </div>
    </el-card>

    <!-- 数据表格 -->
    <el-card class="table-card" shadow="never">
      <el-table :data="tableData" v-loading="loading" stripe>
        <el-table-column prop="username" label="用户名" min-width="120" />
        <el-table-column prop="email" label="邮箱" min-width="160" />
        <el-table-column prop="phone" label="电话" width="120" />
        <el-table-column prop="address" label="地址" min-width="160" show-overflow-tooltip />
        <el-table-column label="操作" width="240" fixed="right">
          <template #default="{ row }">
            <div class="action-buttons">
              <el-button size="small" @click="openEdit(row)">
                <el-icon><Edit /></el-icon>
                编辑
              </el-button>
              <el-button size="small" type="primary" @click="openAddressManager(row)">
                <el-icon><Location /></el-icon>
                地址管理
              </el-button>
              <el-popconfirm title="确认删除该用户？" @confirm="onDelete(row)">
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

      <el-empty v-if="!loading && tableData.length === 0" description="暂无用户数据" />
    </el-card>

    <!-- 新增/编辑用户弹窗 -->
    <el-dialog v-model="dialog.visible" :title="dialog.isEdit ? '编辑用户' : '新增用户'" width="500px">
      <el-form :model="dialog.form" label-width="80px" label-position="top">
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="用户名">
              <el-input 
                v-model="dialog.form.username" 
                :disabled="dialog.isEdit" 
                placeholder="请输入用户名"
              />
            </el-form-item>
          </el-col>
          <el-col :span="12" v-if="!dialog.isEdit">
            <el-form-item label="密码">
              <el-input 
                v-model="dialog.form.password" 
                type="password" 
                placeholder="请输入密码"
                show-password
              />
            </el-form-item>
          </el-col>
        </el-row>
        
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="邮箱">
              <el-input v-model="dialog.form.email" placeholder="请输入邮箱" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="电话">
              <el-input v-model="dialog.form.phone" placeholder="请输入电话" />
            </el-form-item>
          </el-col>
        </el-row>
        
        <el-form-item label="地址">
          <el-input v-model="dialog.form.address" placeholder="请输入地址" />
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

    <!-- 地址管理弹窗 -->
    <el-dialog 
      v-model="addrDlg.visible" 
      :title="`地址管理 - ${addrDlg.username}`" 
      width="900px"
      :close-on-click-modal="false"
      class="address-dialog"
    >
      <div class="address-manager">
        <!-- 顶部操作栏 -->
        <div class="manager-header">
          <div class="header-info">
            <h3>📍 地址列表</h3>
            <p>管理用户的收货地址信息</p>
          </div>
          <el-button type="primary" @click="startAddNew" :disabled="addrDlg.showForm">
            <el-icon><Plus /></el-icon>
            新增地址
          </el-button>
        </div>

        <!-- 地址列表 -->
        <div class="address-list-section">
          <el-table 
            :data="addrDlg.list" 
            v-loading="addrDlg.loading" 
            class="address-table"
            empty-text="暂无地址信息"
          >
            <el-table-column type="index" label="#" width="50" align="center" />
            <el-table-column prop="name" label="收件人" width="100" />
            <el-table-column prop="phone" label="联系电话" width="130" />
            <el-table-column label="地区" width="150">
              <template #default="{ row }">
                <span class="location-text">{{ row.city }}</span>
              </template>
            </el-table-column>
            <el-table-column prop="detail" label="详细地址" min-width="200" show-overflow-tooltip />
            <el-table-column label="默认地址" width="90" align="center">
              <template #default="{ row }">
                <el-tag v-if="row.isDefault" type="success" size="small">默认</el-tag>
                <span v-else class="text-muted">-</span>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="140" align="center">
              <template #default="{ row }">
                <div class="table-actions">
                  <el-button size="small" @click="editAddress(row)" :disabled="addrDlg.showForm">
                    编辑
                  </el-button>
                  <el-popconfirm title="确认删除该地址？" @confirm="removeAddress(row)">
                    <template #reference>
                      <el-button size="small" type="danger" :disabled="addrDlg.showForm">
                        删除
                      </el-button>
                    </template>
                  </el-popconfirm>
                </div>
              </template>
            </el-table-column>
          </el-table>
          
          <el-empty 
            v-if="!addrDlg.loading && addrDlg.list.length === 0" 
            description="暂无地址信息"
            :image-size="100"
          />
        </div>

        <!-- 地址表单 -->
        <div v-if="addrDlg.showForm" class="address-form-section">
          <div class="form-header">
            <h4>{{ addrDlg.isEdit ? '✏️ 编辑地址' : '➕ 新增地址' }}</h4>
          </div>
          
          <el-form 
            :model="addrDlg.form" 
            :rules="addressRules" 
            ref="addressFormRef"
            label-width="100px"
            class="address-form"
          >
            <el-row :gutter="20">
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
                    placeholder="请输入11位手机号码"
                    maxlength="11"
                  />
                </el-form-item>
              </el-col>
            </el-row>
            
            <el-row :gutter="20">
              <el-col :span="12">
                <el-form-item label="省份">
                  <el-select 
                    v-model="addrProvince" 
                    placeholder="请选择省份" 
                    style="width: 100%" 
                    @change="onAddrProvinceChange"
                    clearable
                    filterable
                  >
                    <el-option v-for="p in provinces" :key="p" :value="p" :label="p" />
                  </el-select>
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="城市" prop="city">
                  <el-select 
                    v-model="addrDlg.form.city" 
                    placeholder="请选择城市" 
                    style="width: 100%"
                    :disabled="!addrProvince"
                    clearable
                    filterable
                  >
                    <el-option v-for="c in cities" :key="c" :value="c" :label="c" />
                  </el-select>
                </el-form-item>
              </el-col>
            </el-row>
            
            <el-form-item label="详细地址" prop="detail">
              <el-input 
                v-model="addrDlg.form.detail" 
                type="textarea" 
                :rows="3"
                placeholder="请输入详细地址，如街道、门牌号、楼栋单元等"
                maxlength="200"
                show-word-limit
              />
            </el-form-item>
            
            <el-form-item label="默认地址">
              <div class="default-switch">
                <el-switch 
                  v-model="addrDlg.form.isDefault" 
                  active-text="设为默认" 
                  inactive-text="普通地址"
                  :active-value="true"
                  :inactive-value="false"
                />
                <span class="switch-tip">设为默认地址后，其他地址的默认状态将被取消</span>
              </div>
            </el-form-item>
            
            <el-form-item class="form-actions">
              <div class="action-buttons">
                <el-button @click="cancelAddressEdit" size="default">
                  取消
                </el-button>
                <el-button 
                  type="primary" 
                  :loading="addrDlg.saving" 
                  @click="submitAddress"
                  size="default"
                >
                  {{ addrDlg.isEdit ? '更新地址' : '保存地址' }}
                </el-button>
              </div>
            </el-form-item>
          </el-form>
        </div>
      </div>
      
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="closeAddressManager" size="default">关闭</el-button>
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
  Plus, 
  Refresh, 
  Edit, 
  Location, 
  Delete 
} from '@element-plus/icons-vue'
import { getUser, listAllUsers, createUser, updateUser, deleteUser, type UserInfo } from '@/services/users'
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
}>({
  visible: false,
  username: '',
  list: [],
  loading: false,
  showForm: false,
  isEdit: false,
  editingId: null,
  form: { name: '', phone: '', city: '', detail: '', isDefault: false },
  saving: false
})

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
    } catch {
      // 忽略错误
    }
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
  } catch {
    // 忽略错误
  }
}

async function inferProvinceByCity(city: string) {
  if (!city) return
  for (const p of provinces.value) {
    if (!citiesCache[p]) {
      try {
        const res = await listCitiesByProvince(p)
        citiesCache[p] = (res as any).data || res || []
      } catch { 
        citiesCache[p] = [] 
      }
    }
    if (citiesCache[p].includes(city)) {
      addrProvince.value = p
      cities.value = citiesCache[p]
      return
    }
  }
}

onMounted(() => {
  fetchAll()
})
</script>

<style scoped>
.users-page {
  padding: 24px;
  background: #f5f7fa;
  min-height: calc(100vh - 60px);
}

/* 页面标题 */
.page-header {
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

/* 操作卡片 */
.action-card {
  margin-bottom: 16px;
  border: none;
  border-radius: 12px;
}

.action-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 16px;
}

.button-group {
  display: flex;
  gap: 12px;
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

/* 地址管理弹窗优化 */
.address-dialog :deep(.el-dialog__body) {
  padding: 20px 24px;
}

.address-manager {
  min-height: 500px;
}

/* 顶部操作栏 */
.manager-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 24px;
  padding: 20px;
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
  border-radius: 12px;
  color: white;
}

.header-info h3 {
  margin: 0 0 8px 0;
  font-size: 20px;
  font-weight: 600;
}

.header-info p {
  margin: 0;
  font-size: 14px;
  opacity: 0.9;
}

.manager-header .el-button {
  background: rgba(255, 255, 255, 0.2);
  border: 1px solid rgba(255, 255, 255, 0.3);
  color: white;
}

.manager-header .el-button:hover {
  background: rgba(255, 255, 255, 0.3);
}

/* 地址列表区域 */
.address-list-section {
  margin-bottom: 24px;
}

.address-table {
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.address-table :deep(.el-table__header) {
  background-color: #f8f9fa;
}

.address-table :deep(.el-table th) {
  background-color: #f8f9fa;
  color: #495057;
  font-weight: 600;
  border: none;
}

.address-table :deep(.el-table td) {
  border: none;
  padding: 16px 12px;
}

.location-text {
  color: #409eff;
  font-weight: 500;
}

.table-actions {
  display: flex;
  gap: 8px;
  justify-content: center;
}

.text-muted {
  color: #909399;
}

/* 地址表单区域 */
.address-form-section {
  background: #f8f9fa;
  border-radius: 12px;
  padding: 24px;
  border: 1px solid #e9ecef;
}

.form-header {
  margin-bottom: 20px;
  padding-bottom: 12px;
  border-bottom: 2px solid #e9ecef;
}

.form-header h4 {
  margin: 0;
  font-size: 18px;
  font-weight: 600;
  color: #495057;
}

.address-form :deep(.el-form-item__label) {
  color: #495057;
  font-weight: 500;
}

.address-form :deep(.el-input__wrapper) {
  border-radius: 8px;
}

.address-form :deep(.el-select) {
  width: 100%;
}

.address-form :deep(.el-textarea__inner) {
  border-radius: 8px;
}

/* 默认地址开关 */
.default-switch {
  display: flex;
  align-items: center;
  gap: 12px;
}

.switch-tip {
  font-size: 12px;
  color: #909399;
  line-height: 1.4;
}

/* 表单操作按钮 */
.form-actions {
  margin-top: 32px;
  margin-bottom: 0;
  padding-top: 20px;
  border-top: 1px solid #e9ecef;
}

.form-actions .action-buttons {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .users-page {
    padding: 16px;
  }

  .header-content h1 {
    font-size: 24px;
  }

  .action-bar {
    flex-direction: column;
    align-items: stretch;
  }

  .search-area {
    width: 100%;
  }

  .search-area .el-input {
    width: 100% !important;
  }

  .button-group {
    justify-content: center;
  }

  .action-buttons {
    flex-direction: column;
    gap: 4px;
  }

  .action-buttons .el-button {
    width: 100%;
    justify-content: flex-start;
  }

  .manager-header {
    flex-direction: column;
    gap: 16px;
    text-align: center;
  }

  .address-form-section {
    padding: 16px;
  }

  .form-actions .action-buttons {
    flex-direction: column;
  }

  .form-actions .action-buttons .el-button {
    width: 100%;
  }
}

@media (max-width: 480px) {
  .button-group {
    flex-direction: column;
  }

  .button-group .el-button {
    width: 100%;
  }

  .table-actions {
    flex-direction: column;
    gap: 4px;
  }

  .table-actions .el-button {
    width: 100%;
  }
}
</style>