# 🐾 宠物领养平台 · 管理后台

> 基于 Vue 3 + TypeScript + Vite + Element Plus 构建的现代化宠物领养管理系统

## 📋 项目简介

宠物领养平台管理后台是一个功能完善的宠物领养管理系统，为管理员提供了全面的宠物信息管理、用户管理、订单处理等功能。系统采用现代化的前端技术栈，提供了直观易用的管理界面。

### 🎯 核心特性

- **🔐 安全认证**：完整的登录认证体系
- **🐕 宠物管理**：全面的宠物信息管理功能
- **👥 用户管理**：用户账户和权限管理
- **📋 订单管理**：领养订单处理和状态跟踪
- **📊 签到管理**：用户签到记录查看和管理
- **🏙️ 地区管理**：省市地区信息管理
- **🔍 寻宠管理**：走失宠物信息管理
- **📱 响应式设计**：完美适配各种设备屏幕

## 🚀 技术栈

### 前端框架
- **Vue 3.5.10** - 渐进式 JavaScript 框架
- **TypeScript 5.5.4** - JavaScript 的超集，提供类型安全
- **Vite 5.4.3** - 下一代前端构建工具

### UI 组件库
- **Element Plus 2.8.7** - 基于 Vue 3 的桌面端组件库
- **@element-plus/icons-vue 2.3.1** - Element Plus 图标库

### 状态管理与路由
- **Pinia 2.2.6** - Vue 的状态管理库
- **Vue Router 4.4.5** - Vue.js 官方路由管理器

### HTTP 客户端
- **Axios 1.7.7** - 基于 Promise 的 HTTP 库

## 📁 项目结构

```
vue/
├── public/                     # 静态资源
├── src/
│   ├── layouts/               # 布局组件
│   │   └── AdminLayout.vue    # 管理后台主布局
│   ├── router/                # 路由配置
│   │   └── index.ts          # 路由定义
│   ├── services/              # API 服务层
│   │   ├── http.ts           # HTTP 请求配置
│   │   ├── auth.ts           # 认证相关 API
│   │   ├── animals.ts        # 宠物管理 API
│   │   ├── users.ts          # 用户管理 API
│   │   ├── orders.ts         # 订单管理 API
│   │   ├── cities.ts         # 城市管理 API
│   │   └── provinces.ts      # 省份管理 API
│   ├── stores/                # 状态管理
│   │   └── auth.ts           # 认证状态管理
│   ├── views/                 # 页面组件
│   │   ├── Login.vue         # 登录页面
│   │   ├── Dashboard.vue     # 仪表盘
│   │   ├── animals/          # 宠物管理模块
│   │   │   └── AnimalsList.vue
│   │   ├── users/            # 用户管理模块
│   │   │   └── UsersList.vue
│   │   ├── orders/           # 订单管理模块
│   │   │   └── AdoptionOrders.vue
│   │   ├── checkin/          # 签到管理模块
│   │   │   └── CheckinPage.vue
│   │   ├── cities/           # 城市管理模块
│   │   │   └── CitiesList.vue
│   │   └── lost/             # 寻宠管理模块
│   │       └── LostPetsList.vue
│   ├── App.vue               # 根组件
│   └── main.ts               # 应用入口
├── index.html                # HTML 模板
├── vite.config.ts           # Vite 配置
├── tsconfig.json            # TypeScript 配置
└── package.json             # 项目依赖
```

## 🔧 功能模块详解

### 1. 🔐 认证系统
- **登录功能**：支持用户名密码登录
- **会话管理**：基于 Token 的身份验证
- **权限控制**：路由级别的权限验证

**默认管理员账户：**
- 用户名：`admin`
- 密码：`123456`

### 2. 🐕 宠物管理 (AnimalsList.vue)
- **宠物列表**：分页展示所有宠物信息，支持表格形式展示
- **高级筛选**：
  - 按领养状态筛选（已领养/未领养）
  - 按上架状态筛选（已上架/未上架）
  - 按省份地区筛选
  - 按收藏用户ID筛选
- **宠物详情**：弹窗形式展示详细的宠物信息
- **CRUD 操作**：
  - 创建新宠物信息
  - 编辑现有宠物信息
  - 删除宠物记录
- **状态管理**：一键切换宠物上下架状态
- **收藏功能**：支持用户收藏/取消收藏宠物
- **省市联动**：智能的省市选择器，支持数据缓存
- **图片管理**：宠物头像展示和管理
- **用户信息关联**：显示发布宠物的用户信息

### 3. 👥 用户管理
- **用户列表**：查看所有注册用户
- **用户搜索**：按用户名快速查找
- **用户信息**：详细的用户资料管理
- **账户操作**：创建、编辑、删除用户账户

### 4. 📋 订单管理 (AdoptionOrders.vue)
- **订单列表**：领养订单的统一管理
- **状态跟踪**：订单状态实时更新和管理
- **多维度筛选**：
  - 按订单状态筛选
  - 按省份地区筛选
  - 关键词搜索（宠物名或地区）
- **订单详情**：完整的订单信息展示
- **新建订单**：支持手动创建领养订单

### 5. 📊 签到管理 (CheckinPage.vue)
- **签到记录**：用户签到历史查看和管理
- **数据筛选**：
  - 按用户ID筛选
  - 按用户名筛选
  - 按签到日期筛选
- **实时刷新**：支持数据实时刷新
- **统计分析**：签到数据统计和分析

### 6. 🏙️ 地区管理
- **省市数据**：完整的省市信息管理
- **数据缓存**：智能的数据缓存机制（24小时缓存）
- **快速搜索**：地区信息快速检索

### 7. 🔍 寻宠管理 (LostPetsList.vue)
- **走失宠物信息管理**：管理走失宠物的发布信息
- **状态跟踪**：跟踪寻宠信息的处理状态
- **信息筛选**：支持多种条件筛选走失宠物信息

## 🛠️ 开发环境搭建

### 环境要求
- Node.js >= 16.0.0
- npm >= 8.0.0 或 yarn >= 1.22.0

### 安装步骤

1. **进入前端目录**
```bash
cd vue
```

2. **安装依赖**
```bash
npm install
# 或
yarn install
```

3. **启动开发服务器**
```bash
npm run dev
# 或
yarn dev
```

4. **访问应用**
浏览器自动打开：http://localhost:5173

### 构建部署

```bash
# 构建生产版本
npm run build

# 预览构建结果
npm run preview

# 类型检查
npm run type-check
```

## ⚙️ 配置说明

### 开发代理配置
项目已配置 Vite 开发代理，将 `/api` 请求自动代理到后端服务：

```typescript
// vite.config.ts
export default defineConfig({
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:8080',
        changeOrigin: true
      }
    }
  }
})
```

### 后端服务要求
- 后端 Spring Boot 服务需要在 8080 端口运行
- 确保后端服务已启动并可访问

## 🎨 UI/UX 设计特色

### 设计原则
- **简洁直观**：清晰的信息层次和操作流程
- **响应式设计**：完美适配桌面端和移动端
- **一致性**：统一的设计语言和交互模式
- **可访问性**：符合 Web 可访问性标准

### 主要特性
- **现代化界面**：采用 Element Plus 设计系统
- **卡片式布局**：清晰的信息分组和展示
- **动画效果**：流畅的页面切换和交互动画
- **加载状态**：完善的加载和错误状态处理
- **表格优化**：条纹表格、固定列、响应式表格设计

## 🔌 API 接口

### 认证接口
- `POST /api/auth/login` - 用户登录

### 宠物管理接口
- `GET /api/animals` - 获取宠物列表
- `POST /api/animals` - 创建宠物
- `PUT /api/animals/:id` - 更新宠物信息
- `DELETE /api/animals/:id` - 删除宠物
- `PUT /api/animals/:id/listed` - 更新上架状态

### 用户管理接口
- `GET /api/users` - 获取用户列表
- `GET /api/users/:id` - 获取用户详情
- `POST /api/users` - 创建用户
- `PUT /api/users/:id` - 更新用户信息
- `DELETE /api/users/:id` - 删除用户

### 订单管理接口
- `GET /api/orders` - 获取订单列表
- `POST /api/orders` - 创建订单
- `PUT /api/orders/:id` - 更新订单状态

### 地区管理接口
- `GET /api/cities` - 获取城市列表
- `GET /api/provinces` - 获取省份列表
- `GET /api/cities/province/:province` - 获取指定省份的城市列表

### 收藏功能接口
- `POST /api/favorites` - 添加收藏
- `DELETE /api/favorites` - 取消收藏
- `POST /api/favorites/batch-check` - 批量检查收藏状态

## 🚀 性能优化

### 代码分割
- 路由级别的代码分割
- 组件懒加载
- 第三方库按需引入

### 缓存策略
- HTTP 缓存配置
- 本地存储缓存（localStorage）
- 省市数据智能缓存（24小时有效期）

### 网络优化
- API 请求去重
- 并发请求优化（省市数据并行加载）
- 错误重试机制

## 🔒 安全特性

- **XSS 防护**：输入内容自动转义
- **CSRF 防护**：请求令牌验证
- **权限控制**：基于角色的访问控制
- **数据验证**：前后端双重数据验证

## 📱 浏览器兼容性

- Chrome >= 88
- Firefox >= 85
- Safari >= 14
- Edge >= 88

## 🤝 开发规范

### 代码规范
- 使用 TypeScript 进行类型检查
- 遵循 Vue 3 Composition API 最佳实践
- 统一的代码格式化和 ESLint 规则
- 组件化开发，单一职责原则

### 组件设计规范
- 响应式设计，支持移动端适配
- 统一的错误处理和加载状态
- 完善的用户交互反馈
- 可复用的组件设计

## 🛠️ 开发工具

### 推荐 IDE
- **VS Code** - 推荐安装以下插件：
  - Vue Language Features (Volar)
  - TypeScript Vue Plugin (Volar)
  - ESLint
  - Prettier

### 调试工具
- Vue DevTools
- Chrome DevTools
- Network 面板用于 API 调试

## 📞 技术支持

如需技术支持或有任何问题，请：

1. 查看项目文档和代码注释
2. 检查浏览器控制台错误信息
3. 确认后端服务运行状态
4. 提交 Issue 到项目仓库

## 🔄 更新日志

### 当前版本特性
- ✅ 完整的宠物管理功能
- ✅ 用户管理和认证系统
- ✅ 订单管理和状态跟踪
- ✅ 签到记录管理
- ✅ 省市联动和数据缓存
- ✅ 收藏功能
- ✅ 响应式设计
- ✅ TypeScript 类型安全

---

**最后更新** | 2024年8月30日
