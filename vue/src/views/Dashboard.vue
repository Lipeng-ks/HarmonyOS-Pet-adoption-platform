<template>
  <div class="dash">
    <el-row :gutter="16">
      <el-col :span="8">
        <el-card shadow="hover">
          <div class="card-title">快捷入口</div>
          <div class="quick">
            <el-button type="primary" @click="$router.push('/animals')">
              <el-icon><Collection /></el-icon>
              动物管理
            </el-button>
            <el-button @click="$router.push('/users')">
              <el-icon><User /></el-icon>
              用户管理
            </el-button>
            <el-button @click="$router.push('/cities')">
              <el-icon><Location /></el-icon>
              城市管理
            </el-button>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts"></script>

<style scoped>
.card-title { font-weight: 600; margin-bottom: 8px; }
.quick { display: flex; gap: 8px; flex-wrap: wrap; }
</style>
