<template>
  <div class="permissions-page">
    <!-- 页面标题 -->
    <div class="page-header">
      <h2>🔐 权限管理</h2>
      <p>管理系统角色和权限配置</p>
    </div>

    <el-row :gutter="20">
      <!-- 角色管理 -->
      <el-col :span="12">
        <el-card class="role-card">
          <template #header>
            <div class="card-header">
              <span>👥 角色管理</span>
              <el-button type="primary" size="small" @click="showRoleDialog = true">
                <el-icon><Plus /></el-icon>
                新增角色
              </el-button>
            </div>
          </template>

          <el-table :data="roles" stripe>
            <el-table-column prop="name" label="角色名称" width="120" />
            <el-table-column prop="description" label="描述" />
            <el-table-column prop="userCount" label="用户数" width="80" align="center" />
            <el-table-column label="状态" width="80" align="center">
              <template #default="{ row }">
                <el-tag :type="row.enabled ? 'success' : 'danger'">
                  {{ row.enabled ? '启用' : '禁用' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="160" align="center">
              <template #default="{ row }">
                <el-button size="small" @click="editRole(row)">编辑</el-button>
                <el-button size="small" type="primary" @click="setPermissions(row)">权限</el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>

      <!-- 权限树 -->
      <el-col :span="12">
        <el-card class="permission-card">
          <template #header>
            <div class="card-header">
              <span>🌳 权限配置</span>
              <el-select v-model="selectedRoleId" placeholder="选择角色" size="small" style="width: 150px">
                <el-option 
                  v-for="role in roles" 
                  :key="role.id" 
                  :label="role.name" 
                  :value="role.id" 
                />
              </el-select>
            </div>
          </template>

          <el-tree
            ref="permissionTree"
            :data="permissionTreeData"
            :props="treeProps"
            show-checkbox
            node-key="id"
            :default-checked-keys="checkedPermissions"
            @check="handlePermissionCheck"
          >
            <template #default="{ node, data }">
              <span class="tree-node">
                <el-icon class="node-icon">
                  <component :is="data.icon" />
                </el-icon>
                <span>{{ data.label }}</span>
              </span>
            </template>
          </el-tree>

          <div class="permission-actions" v-if="selectedRoleId">
            <el-button type="primary" @click="savePermissions">保存权限</el-button>
            <el-button @click="resetPermissions">重置</el-button>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 操作日志 -->
    <el-card class="log-card">
      <template #header>
        <div class="card-header">
          <span>📋 操作日志</span>
          <div class="header-actions">
            <el-date-picker
              v-model="logDateRange"
              type="daterange"
              range-separator="至"
              start-placeholder="开始日期"
              end-placeholder="结束日期"
              size="small"
            />
            <el-button size="small" @click="refreshLogs">刷新</el-button>
          </div>
        </div>
      </template>

      <el-table :data="operationLogs" stripe>
        <el-table-column prop="time" label="时间" width="180" />
        <el-table-column prop="operator" label="操作人" width="120" />
        <el-table-column prop="action" label="操作" width="120" />
        <el-table-column prop="target" label="目标" width="150" />
        <el-table-column prop="description" label="描述" />
        <el-table-column prop="ip" label="IP地址" width="120" />
        <el-table-column label="结果" width="80" align="center">
          <template #default="{ row }">
            <el-tag :type="row.success ? 'success' : 'danger'">
              {{ row.success ? '成功' : '失败' }}
            </el-tag>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-wrapper">
        <el-pagination
          v-model:current-page="logPagination.page"
          v-model:page-size="logPagination.size"
          :page-sizes="[10, 20, 50, 100]"
          :total="logPagination.total"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleLogSizeChange"
          @current-change="handleLogPageChange"
        />
      </div>
    </el-card>

    <!-- 角色编辑对话框 -->
    <el-dialog
      v-model="showRoleDialog"
      :title="roleForm.id ? '编辑角色' : '新增角色'"
      width="500px"
    >
      <el-form :model="roleForm" :rules="roleRules" ref="roleFormRef" label-width="80px">
        <el-form-item label="角色名称" prop="name">
          <el-input v-model="roleForm.name" placeholder="请输入角色名称" />
        </el-form-item>
        
        <el-form-item label="角色描述" prop="description">
          <el-input 
            v-model="roleForm.description" 
            type="textarea" 
            :rows="3"
            placeholder="请输入角色描述"
          />
        </el-form-item>
        
        <el-form-item label="状态">
          <el-switch 
            v-model="roleForm.enabled"
            active-text="启用"
            inactive-text="禁用"
          />
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="showRoleDialog = false">取消</el-button>
        <el-button type="primary" @click="saveRole">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { 
  Plus, 
  User, 
  Setting, 
  Document, 
  DataAnalysis,
  House,
  Location,
  Bell,
  Lock
} from '@element-plus/icons-vue'
import { ElMessage, ElTree } from 'element-plus'

// 响应式数据
const showRoleDialog = ref(false)
const selectedRoleId = ref<number>()
const checkedPermissions = ref<number[]>([])
const logDateRange = ref<[Date, Date]>()
const permissionTree = ref<InstanceType<typeof ElTree>>()
const roleFormRef = ref()

// 角色数据
const roles = ref([
  { id: 1, name: '超级管理员', description: '拥有所有权限', userCount: 1, enabled: true },
  { id: 2, name: '管理员', description: '拥有大部分管理权限', userCount: 3, enabled: true },
  { id: 3, name: '审核员', description: '负责内容审核', userCount: 5, enabled: true },
  { id: 4, name: '客服', description: '处理用户问题', userCount: 8, enabled: true }
])

// 角色表单
const roleForm = reactive({
  id: null as number | null,
  name: '',
  description: '',
  enabled: true
})

// 表单验证规则
const roleRules = {
  name: [
    { required: true, message: '请输入角色名称', trigger: 'blur' },
    { min: 2, max: 20, message: '长度在 2 到 20 个字符', trigger: 'blur' }
  ],
  description: [
    { required: true, message: '请输入角色描述', trigger: 'blur' }
  ]
}

// 权限树配置
const treeProps = {
  children: 'children',
  label: 'label'
}

// 权限树数据
const permissionTreeData = ref([
  {
    id: 1,
    label: '系统管理',
    icon: 'Setting',
    children: [
      { id: 11, label: '用户管理', icon: 'User' },
      { id: 12, label: '角色权限', icon: 'Lock' },
      { id: 13, label: '系统设置', icon: 'Setting' }
    ]
  },
  {
    id: 2,
    label: '宠物管理',
    icon: 'House',
    children: [
      { id: 21, label: '宠物列表', icon: 'Document' },
      { id: 22, label: '宠物审核', icon: 'Document' },
      { id: 23, label: '宠物分类', icon: 'Document' }
    ]
  },
  {
    id: 3,
    label: '订单管理',
    icon: 'Document',
    children: [
      { id: 31, label: '订单列表', icon: 'Document' },
      { id: 32, label: '订单审核', icon: 'Document' },
      { id: 33, label: '退款处理', icon: 'Document' }
    ]
  },
  {
    id: 4,
    label: '数据统计',
    icon: 'DataAnalysis',
    children: [
      { id: 41, label: '数据报表', icon: 'DataAnalysis' },
      { id: 42, label: '统计分析', icon: 'DataAnalysis' }
    ]
  }
])

// 操作日志数据
const operationLogs = ref([
  {
    time: '2024-01-15 14:30:25',
    operator: '张三',
    action: '编辑角色',
    target: '管理员',
    description: '修改角色权限配置',
    ip: '192.168.1.100',
    success: true
  },
  {
    time: '2024-01-15 14:25:18',
    operator: '李四',
    action: '新增用户',
    target: '王五',
    description: '创建新用户账号',
    ip: '192.168.1.101',
    success: true
  },
  {
    time: '2024-01-15 14:20:12',
    operator: '赵六',
    action: '删除权限',
    target: '客服',
    description: '移除部分操作权限',
    ip: '192.168.1.102',
    success: false
  }
])

// 日志分页
const logPagination = reactive({
  page: 1,
  size: 10,
  total: 100
})

// 编辑角色
function editRole(role: any) {
  roleForm.id = role.id
  roleForm.name = role.name
  roleForm.description = role.description
  roleForm.enabled = role.enabled
  showRoleDialog.value = true
}

// 设置权限
function setPermissions(role: any) {
  selectedRoleId.value = role.id
  // 模拟加载该角色的权限
  checkedPermissions.value = [11, 12, 21, 22, 31]
}

// 处理权限选择
function handlePermissionCheck(data: any, checked: any) {
  console.log('权限变更:', data, checked)
}

// 保存角色
function saveRole() {
  roleFormRef.value?.validate((valid: boolean) => {
    if (valid) {
      if (roleForm.id) {
        ElMessage.success('角色更新成功')
      } else {
        ElMessage.success('角色创建成功')
      }
      showRoleDialog.value = false
      resetRoleForm()
    }
  })
}

// 重置角色表单
function resetRoleForm() {
  roleForm.id = null
  roleForm.name = ''
  roleForm.description = ''
  roleForm.enabled = true
}

// 保存权限
function savePermissions() {
  const checkedKeys = permissionTree.value?.getCheckedKeys()
  console.log('保存权限:', checkedKeys)
  ElMessage.success('权限保存成功')
}

// 重置权限
function resetPermissions() {
  permissionTree.value?.setCheckedKeys([])
}

// 刷新日志
function refreshLogs() {
  ElMessage.success('日志刷新成功')
}

// 处理日志分页
function handleLogPageChange(page: number) {
  logPagination.page = page
  refreshLogs()
}

function handleLogSizeChange(size: number) {
  logPagination.size = size
  refreshLogs()
}

onMounted(() => {
  // 初始化数据
})
</script>

<style scoped>
.permissions-page {
  padding: 20px;
  background: #f5f7fa;
  min-height: 100vh;
}

.page-header {
  margin-bottom: 24px;
}

.page-header h2 {
  margin: 0 0 8px 0;
  color: #303133;
  font-size: 24px;
  font-weight: 600;
}

.page-header p {
  margin: 0;
  color: #909399;
  font-size: 14px;
}

.role-card,
.permission-card,
.log-card {
  border-radius: 12px;
  border: none;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: 600;
  color: #303133;
}

.header-actions {
  display: flex;
  gap: 8px;
  align-items: center;
}

.tree-node {
  display: flex;
  align-items: center;
  gap: 8px;
}

.node-icon {
  color: #409eff;
}

.permission-actions {
  margin-top: 20px;
  padding-top: 20px;
  border-top: 1px solid #f0f0f0;
  text-align: right;
}

.pagination-wrapper {
  margin-top: 20px;
  text-align: right;
}

:deep(.el-card__header) {
  padding: 16px 20px;
  border-bottom: 1px solid #f0f0f0;
}

:deep(.el-card__body) {
  padding: 20px;
}

:deep(.el-tree-node__content) {
  height: 36px;
}

:deep(.el-tree-node__expand-icon) {
  color: #409eff;
}

:deep(.el-checkbox__input.is-checked .el-checkbox__inner) {
  background-color: #409eff;
  border-color: #409eff;
}
</style>