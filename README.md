# 🐾 宠物领养平台 - 完整项目说明文档

> 基于 HarmonyOS + Spring Boot + Vue.js 构建的全栈宠物领养管理系统

## 📋 项目概述

宠物领养平台是一个完整的全栈应用系统，旨在为宠物领养提供便捷的数字化解决方案。系统采用现代化的技术架构，包含移动端应用、后端API服务和管理后台三个核心模块。

### 🎯 项目愿景
- **连接爱心**：为有爱心的人们和需要家庭的宠物搭建桥梁
- **数字化管理**：提供完整的宠物信息管理和领养流程数字化
- **用户体验**：打造直观易用的移动端和管理端界面
- **数据安全**：确保用户信息和宠物数据的安全性

## 🏗️ 系统架构

```
宠物领养平台系统架构
├── 移动端应用 (HarmonyOS)
│   ├── 用户注册登录
│   ├── 宠物浏览和搜索
│   ├── 领养申请管理
│   ├── 个人中心功能
│   └── 寻宠发布管理
├── 后端API服务 (Spring Boot)
│   ├── RESTful API接口
│   ├── 数据库管理
│   ├── 用户认证授权
│   └── 业务逻辑处理
└── 管理后台 (Vue.js)
    ├── 宠物信息管理
    ├── 用户管理
    ├── 订单管理
    └── 数据统计分析
```

## 📱 移动端应用 (HarmonyOS)

### 技术栈
- **开发框架**：HarmonyOS Next
- **编程语言**：ArkTS (TypeScript)
- **UI框架**：ArkUI
- **状态管理**：本地状态管理
- **网络请求**：@ohos.net.http

### 核心功能模块

#### 1. 🔐 用户认证模块
- **登录注册**：`Auth/Login.ets`, `Auth/Register.ets`
- **密码管理**：`Profile/ChangePassword.ets`
- **实名认证**：`Profile/RealNameAuth.ets`

#### 2. 🏠 首页模块
- **宠物展示**：`Home/Home.ets` - 宠物列表和搜索
- **宠物详情**：`Home/AnimalDetail.ets` - 详细信息展示
- **领养申请**：`Home/AdoptApply.ets` - 领养申请流程
- **城市选择**：`Home/CitySelect.ets` - 地区筛选
- **寻宠功能**：`Home/MissingPets.ets`, `Home/MissingPetDetail.ets`

#### 3. 👤 个人中心模块
- **个人资料**：`Profile/Individual.ets`, `Profile/EditProfile.ets`
- **地址管理**：`Profile/MyAddress.ets`, `Profile/AddAddress.ets`
- **我的订单**：`Profile/MyOrders.ets` - 领养订单管理
- **我的发布**：`Profile/MyFoster.ets` - 送养宠物管理
- **我的寻宠**：`Profile/MyMissingPets.ets` - 寻宠信息管理
- **签到功能**：`Profile/Checkin.ets` - 每日签到
- **收藏功能**：`Collection/Collection.ets` - 宠物收藏

#### 4. 🐕 宠物管理模块
- **发布送养**：`Profile/EditRehomePet.ets` - 发布宠物送养信息
- **发布寻宠**：`Profile/EditMissingPet.ets` - 发布寻宠信息
- **宠物数据**：`animalData.ets` - 宠物基础数据

### 项目结构
```
entry/src/main/ets/
├── common/                    # 公共模块
│   ├── services/             # API服务
│   ├── models/               # 数据模型
│   ├── database/             # 本地数据库
│   └── data/                 # 静态数据
├── pages/                    # 页面组件
│   ├── Auth/                 # 认证页面
│   ├── Home/                 # 首页模块
│   ├── Profile/              # 个人中心
│   ├── Collection/           # 收藏页面
│   └── PersonalCenter/       # 设置页面
└── entryability/             # 应用入口
```

## 🚀 后端API服务 (Spring Boot)

### 技术栈
- **框架版本**：Spring Boot 3.2.0
- **编程语言**：Java 17
- **数据库**：MySQL 8.0+
- **ORM框架**：Spring Data JPA
- **安全框架**：Spring Security
- **构建工具**：Maven

### 核心功能模块

#### 1. 🔐 认证与安全
- **用户认证**：`AuthController.java` - 登录验证
- **安全配置**：`SecurityConfig.java` - Spring Security配置
- **密码加密**：BCrypt加密算法

#### 2. 🐕 宠物管理
- **宠物CRUD**：`AnimalController.java` - 完整的宠物信息管理
- **状态管理**：上架/下架、领养状态管理
- **图片处理**：`UploadController.java` - 宠物图片上传

#### 3. 👥 用户管理
- **用户信息**：`UserController.java` - 用户基本信息管理
- **实名认证**：`UserRealNameController.java` - 实名认证管理
- **地址管理**：`UserAddressController.java` - 用户地址信息
- **收藏功能**：`UserFavoriteController.java` - 用户收藏管理

#### 4. 📋 订单管理
- **领养订单**：`AdoptionOrderController.java` - 领养订单全流程
- **状态跟踪**：订单状态变更和通知
- **事件驱动**：`AdoptionOrderEventListener.java` - 异步事件处理

#### 5. 📊 签到系统
- **签到管理**：`UserCheckinController.java` - 用户签到功能
- **统计分析**：签到数据统计和连续签到计算

#### 6. 🏙️ 地区管理
- **省市数据**：`ProvinceController.java`, `CityController.java`
- **地区查询**：省市联动查询接口

#### 7. 🔍 寻宠功能
- **寻宠管理**：`MissingPetController.java` - 走失宠物信息管理
- **状态跟踪**：寻宠信息状态管理

### 数据模型
```
核心实体关系
├── UserInfo (用户信息)
├── Animal (宠物信息)
├── AdoptionOrder (领养订单)
├── MissingPet (寻宠信息)
├── UserCheckin (签到记录)
├── UserFavorite (收藏记录)
└── ProvinceCity (省市数据)
```

## 💻 管理后台 (Vue.js)

### 技术栈
- **框架版本**：Vue 3.5.10
- **开发语言**：TypeScript 5.5.4
- **构建工具**：Vite 5.4.3
- **UI组件库**：Element Plus 2.8.7
- **状态管理**：Pinia 2.2.6
- **路由管理**：Vue Router 4.4.5

### 核心功能模块

#### 1. 🐕 宠物管理
- **宠物列表**：`AnimalsList.vue` - 宠物信息管理
- **高级筛选**：多条件筛选和搜索
- **状态管理**：宠物上下架管理
- **收藏统计**：宠物收藏数据统计

#### 2. 👥 用户管理
- **用户列表**：用户信息查看和管理
- **用户搜索**：按用户名快速查找
- **账户操作**：用户账户管理

#### 3. 📋 订单管理
- **订单列表**：`AdoptionOrders.vue` - 领养订单管理
- **状态跟踪**：订单状态实时更新
- **数据筛选**：多维度订单筛选

#### 4. 📊 签到管理
- **签到记录**：`CheckinPage.vue` - 用户签到数据管理
- **数据统计**：签到统计和分析
- **用户筛选**：按用户和日期筛选

#### 5. 🔍 寻宠管理
- **寻宠列表**：`LostPetsList.vue` - 寻宠信息管理
- **状态跟踪**：寻宠信息状态管理

## 🔧 开发环境搭建

### 环境要求
- **HarmonyOS开发**：DevEco Studio 4.0+
- **后端开发**：JDK 17+, Maven 3.6+, MySQL 8.0+
- **前端开发**：Node.js 16+, npm 8+

### 启动步骤

#### 1. 后端服务启动
```bash
cd SpringBoot
./mvnw.cmd spring-boot:run
# 访问: http://localhost:8080/api   使用自己的IP比较好
```

#### 2. 管理后台启动
```bash
cd vue
npm install
npm run dev
# 访问: http://localhost:5173
```

#### 3. HarmonyOS应用
```bash
# 使用DevEco Studio打开entry模块
# 配置签名和设备
# 运行到设备或模拟器
```

## 🔌 API接口规范

### 统一响应格式
```json
{
  "success": true,
  "data": {...},
  "message": "操作成功"
}
```

### 主要接口列表
- **认证接口**：`POST /api/auth/login`
- **宠物管理**：`GET|POST|PUT|DELETE /api/animals`
- **用户管理**：`GET|POST|PUT|DELETE /api/users`
- **订单管理**：`GET|POST|PUT /api/orders`
- **签到功能**：`POST /api/checkin`
- **收藏功能**：`POST|DELETE /api/favorites`
- **地区查询**：`GET /api/provinces`, `GET /api/cities`

## 🚀 部署说明

### 生产环境部署
1. **数据库配置**：配置MySQL生产环境
2. **后端部署**：打包Spring Boot应用
3. **前端构建**：构建Vue.js管理后台
4. **应用发布**：HarmonyOS应用商店发布

### 配置管理
- **数据库连接**：环境变量配置
- **API地址**：不同环境API地址配置
- **安全配置**：生产环境安全策略

## 📊 项目特色

### 技术亮点
- **全栈TypeScript**：前端到移动端的TypeScript开发
- **现代化架构**：微服务架构设计
- **响应式设计**：适配多种设备屏幕
- **事件驱动**：异步事件处理机制
- **数据安全**：完整的安全认证体系

### 业务特色
- **用户体验**：直观的移动端操作界面
- **管理效率**：强大的后台管理功能
- **数据统计**：完整的业务数据分析
- **扩展性**：模块化设计，易于扩展

## 🤝 开发团队

- **移动端开发**：HarmonyOS原生应用开发
- **后端开发**：Spring Boot企业级开发
- **前端开发**：Vue.js现代化前端开发
- **UI/UX设计**：用户体验设计优化

---

**技术架构** | HarmonyOS + Spring Boot + Vue.js  
**最后更新** | 2025年8月30日
