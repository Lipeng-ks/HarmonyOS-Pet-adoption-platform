# 🐾 宠物领养平台 · Spring Boot 后端服务

> 基于 Spring Boot 3.2.0 + Java 17 + MySQL 构建的企业级宠物领养管理系统后端服务

## 📋 项目简介

宠物领养平台后端服务是一个基于Spring Boot框架开发的企业级RESTful API服务，为宠物领养平台提供完整的后端支持。系统采用分层架构设计，具备高可用性、高性能和高安全性特点。

### 🎯 核心特性

- **🔐 安全认证**：Spring Security + BCrypt 密码加密
- **🐕 宠物管理**：完整的宠物信息CRUD操作
- **👥 用户管理**：用户注册、认证、资料管理
- **📋 订单管理**：领养订单全生命周期管理
- **📊 签到系统**：用户签到记录和统计
- **🏙️ 地区管理**：省市数据管理和查询
- **🔍 寻宠功能**：走失宠物信息发布和管理
- **❤️ 收藏功能**：用户宠物收藏管理
- **📱 跨域支持**：完整的CORS配置
- **🔄 事件驱动**：基于Spring Events的异步处理

## 🚀 技术栈

### 核心框架
- **Spring Boot 3.2.0** - 企业级Java应用框架
- **Spring Data JPA** - 数据持久化框架
- **Spring Security** - 安全认证框架
- **Spring Web MVC** - Web应用框架

### 数据库
- **MySQL 8.0+** - 主数据库
- **H2 Database** - 开发测试数据库
- **HikariCP** - 高性能数据库连接池

### 开发工具
- **Java 17** - 编程语言
- **Maven 3.6+** - 项目构建工具
- **Lombok** - 代码简化工具
- **Jackson** - JSON处理库

### 安全与验证
- **Spring Security Crypto** - 密码加密
- **Bean Validation** - 数据验证
- **BCrypt** - 密码哈希算法

## 📁 项目架构

```
src/main/java/com/example/springboot/
├── PetAdoptionApplication.java          # 应用启动类
├── config/                              # 配置类
│   ├── AsyncConfig.java                 # 异步配置
│   ├── DataInitializer.java             # 数据初始化
│   ├── SecurityConfig.java              # 安全配置
│   └── WebMvcConfig.java                # Web MVC配置
├── controller/                          # 控制器层
│   ├── AdoptionOrderController.java     # 领养订单控制器
│   ├── AnimalController.java            # 宠物管理控制器
│   ├── AuthController.java              # 认证控制器
│   ├── CityController.java              # 城市管理控制器
│   ├── HealthController.java            # 健康检查控制器
│   ├── MissingPetController.java        # 寻宠控制器
│   ├── ProvinceController.java          # 省份控制器
│   ├── UploadController.java            # 文件上传控制器
│   ├── UserAddressController.java       # 用户地址控制器
│   ├── UserCheckinController.java       # 用户签到控制器
│   ├── UserController.java              # 用户管理控制器
│   ├── UserFavoriteController.java      # 用户收藏控制器
│   └── UserRealNameController.java      # 用户实名控制器
├── entity/                              # 实体类
│   ├── AdoptionOrder.java               # 领养订单实体
│   ├── Animal.java                      # 宠物实体
│   ├── City.java                        # 城市实体
│   ├── MissingPet.java                  # 寻宠实体
│   ├── ProvinceCity.java                # 省市实体
│   ├── UserAddress.java                 # 用户地址实体
│   ├── UserCheckin.java                 # 用户签到实体
│   ├── UserCheckinSummary.java          # 签到统计实体
│   ├── UserFavorite.java                # 用户收藏实体
│   ├── UserInfo.java                    # 用户信息实体
│   └── UserRealName.java                # 用户实名实体
├── repository/                          # 数据访问层
│   ├── AdoptionOrderRepository.java     # 领养订单仓库
│   ├── AnimalRepository.java            # 宠物仓库
│   ├── CityRepository.java              # 城市仓库
│   ├── MissingPetRepository.java        # 寻宠仓库
│   ├── ProvinceCityRepository.java      # 省市仓库
│   ├── UserAddressRepository.java       # 用户地址仓库
│   ├── UserCheckinRepository.java       # 用户签到仓库
│   ├── UserCheckinSummaryRepository.java # 签到统计仓库
│   ├── UserFavoriteRepository.java      # 用户收藏仓库
│   ├── UserInfoRepository.java          # 用户信息仓库
│   └── UserRealNameRepository.java      # 用户实名仓库
├── service/                             # 服务层
│   ├── AnimalService.java               # 宠物服务
│   ├── UserService.java                 # 用户服务
│   └── [其他服务类]
├── domain/                              # 领域层
│   ├── event/                           # 领域事件
│   │   └── AdoptionOrderStatusChangedEvent.java
│   └── listener/                        # 事件监听器
│       └── AdoptionOrderStatusChangedListener.java
└── listener/                            # 应用监听器
    └── AdoptionOrderEventListener.java
```

## 🔧 功能模块详解

### 1. 🔐 认证与安全模块

#### AuthController.java
- **用户登录**：`POST /api/auth/login`
- **密码验证**：BCrypt加密验证
- **会话管理**：基于Spring Security的会话管理

#### SecurityConfig.java
- **CORS配置**：支持跨域请求
- **密码加密**：BCrypt密码编码器
- **安全策略**：HTTP安全配置

### 2. 🐕 宠物管理模块

#### AnimalController.java
- **宠物列表**：`GET /api/animals` - 支持多条件筛选
- **宠物详情**：`GET /api/animals/{id}` - 获取单个宠物信息
- **创建宠物**：`POST /api/animals` - 新增宠物信息
- **更新宠物**：`PUT /api/animals/{id}` - 更新宠物信息
- **删除宠物**：`DELETE /api/animals/{id}` - 删除宠物记录
- **上架管理**：`PUT /api/animals/{id}/listed` - 宠物上下架

#### 筛选功能
- 按领养状态筛选（adopted）
- 按上架状态筛选（listed）
- 支持组合条件查询

### 3. 👥 用户管理模块

#### UserController.java
- **用户列表**：`GET /api/users` - 获取用户列表
- **用户详情**：`GET /api/users/{id}` - 获取用户详细信息
- **创建用户**：`POST /api/users` - 用户注册
- **更新用户**：`PUT /api/users/{id}` - 更新用户信息
- **删除用户**：`DELETE /api/users/{id}` - 删除用户账户

#### UserRealNameController.java
- **实名认证**：用户实名信息管理
- **认证状态**：实名认证状态查询和更新

### 4. 📋 订单管理模块

#### AdoptionOrderController.java
- **订单列表**：`GET /api/orders` - 获取领养订单列表
- **订单详情**：`GET /api/orders/{id}` - 获取订单详细信息
- **创建订单**：`POST /api/orders` - 创建领养订单
- **更新状态**：`PUT /api/orders/{id}/status` - 更新订单状态
- **订单统计**：订单数据统计和分析

#### 事件驱动架构
- **状态变更事件**：`AdoptionOrderStatusChangedEvent`
- **事件监听器**：`AdoptionOrderEventListener`
- **异步处理**：订单状态变更的异步通知

### 5. 📊 签到管理模块

#### UserCheckinController.java
- **签到记录**：`POST /api/checkin` - 用户签到
- **签到历史**：`GET /api/checkin/history` - 获取签到历史
- **签到统计**：`GET /api/checkin/summary` - 签到数据统计
- **连续签到**：连续签到天数计算

#### UserCheckinSummary.java
- **统计数据**：签到次数、连续天数统计
- **月度统计**：按月统计签到数据

### 6. 🏙️ 地区管理模块

#### ProvinceController.java
- **省份列表**：`GET /api/provinces` - 获取所有省份
- **省市关联**：省份与城市的关联查询

#### CityController.java
- **城市列表**：`GET /api/cities` - 获取城市列表
- **按省筛选**：`GET /api/cities/province/{province}` - 按省份获取城市

### 7. 🔍 寻宠管理模块

#### MissingPetController.java
- **发布寻宠**：`POST /api/missing-pets` - 发布走失宠物信息
- **寻宠列表**：`GET /api/missing-pets` - 获取寻宠信息列表
- **更新状态**：`PUT /api/missing-pets/{id}` - 更新寻宠状态
- **地区筛选**：按地区筛选寻宠信息

### 8. ❤️ 收藏功能模块

#### UserFavoriteController.java
- **添加收藏**：`POST /api/favorites` - 收藏宠物
- **取消收藏**：`DELETE /api/favorites` - 取消收藏
- **收藏列表**：`GET /api/favorites/{userId}` - 获取用户收藏列表
- **批量检查**：`POST /api/favorites/batch-check` - 批量检查收藏状态

### 9. 📁 文件管理模块

#### UploadController.java
- **文件上传**：`POST /api/upload` - 文件上传接口
- **图片处理**：图片格式验证和处理
- **文件存储**：本地文件存储管理

## 🛠️ 开发环境搭建

### 环境要求
- **Java 17+** - JDK环境
- **Maven 3.6+** - 项目构建工具
- **MySQL 8.0+** - 数据库服务
- **IDE** - IntelliJ IDEA 或 Eclipse

### 数据库配置

1. **创建数据库**
```sql
CREATE DATABASE adoption_platform CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci; //可以使用SQL文件来添加数据库
```

2. **配置数据库连接**
```properties
# application.properties
spring.datasource.url=jdbc:mysql://127.0.0.1:3306/adoption_platform?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Shanghai&useSSL=false&allowPublicKeyRetrieval=true
spring.datasource.username=root
spring.datasource.password=admin
```

### 启动步骤

1. **克隆项目**
```bash
git clone <repository-url>
cd SpringBoot
```

2. **安装依赖**
```bash
mvn clean install
```

3. **启动应用**
```bash
# 方式一：Maven命令
mvn spring-boot:run

# 方式二：Windows批处理
./mvnw.cmd spring-boot:run

# 方式三：打包运行
mvn clean package
java -jar target/pet-adoption-server-1.0.0.jar
```

4. **验证启动**
访问：http://localhost:8080/api/ping

## ⚙️ 配置详解

### 数据库配置
```properties
# MySQL数据库配置
spring.datasource.url=jdbc:mysql://${MYSQL_HOST:127.0.0.1}:${MYSQL_PORT:3306}/${MYSQL_DB:adoption_platform}
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver
spring.datasource.username=${MYSQL_USER:root}
spring.datasource.password=${MYSQL_PASSWORD:admin}

# JPA配置
spring.jpa.database-platform=org.hibernate.dialect.MySQL8Dialect
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true
```

### 连接池配置
```properties
# HikariCP连接池优化
spring.datasource.hikari.maximum-pool-size=20
spring.datasource.hikari.minimum-idle=5
spring.datasource.hikari.connection-timeout=20000
spring.datasource.hikari.idle-timeout=300000
spring.datasource.hikari.max-lifetime=1800000
spring.datasource.hikari.leak-detection-threshold=60000
```

### 安全配置
```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {
    
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
    
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        // CORS配置
    }
}
```

## 🔌 API 接口文档

### 认证接口
| 方法 | 路径 | 描述 | 参数 |
|------|------|------|------|
| POST | `/api/auth/login` | 用户登录 | username, password |

### 宠物管理接口
| 方法 | 路径 | 描述 | 参数 |
|------|------|------|------|
| GET | `/api/animals` | 获取宠物列表 | adopted, listed |
| GET | `/api/animals/{id}` | 获取宠物详情 | id |
| POST | `/api/animals` | 创建宠物 | Animal对象 |
| PUT | `/api/animals/{id}` | 更新宠物 | id, Animal对象 |
| DELETE | `/api/animals/{id}` | 删除宠物 | id |
| PUT | `/api/animals/{id}/listed` | 更新上架状态 | id, listed |

### 用户管理接口
| 方法 | 路径 | 描述 | 参数 |
|------|------|------|------|
| GET | `/api/users` | 获取用户列表 | - |
| GET | `/api/users/{id}` | 获取用户详情 | id |
| POST | `/api/users` | 创建用户 | UserInfo对象 |
| PUT | `/api/users/{id}` | 更新用户 | id, UserInfo对象 |
| DELETE | `/api/users/{id}` | 删除用户 | id |

### 订单管理接口
| 方法 | 路径 | 描述 | 参数 |
|------|------|------|------|
| GET | `/api/orders` | 获取订单列表 | status, province |
| GET | `/api/orders/{id}` | 获取订单详情 | id |
| POST | `/api/orders` | 创建订单 | AdoptionOrder对象 |
| PUT | `/api/orders/{id}/status` | 更新订单状态 | id, status |

### 签到管理接口
| 方法 | 路径 | 描述 | 参数 |
|------|------|------|------|
| POST | `/api/checkin` | 用户签到 | userId |
| GET | `/api/checkin/history` | 签到历史 | userId, date |
| GET | `/api/checkin/summary` | 签到统计 | userId |

### 收藏功能接口
| 方法 | 路径 | 描述 | 参数 |
|------|------|------|------|
| POST | `/api/favorites` | 添加收藏 | userId, animalId |
| DELETE | `/api/favorites` | 取消收藏 | userId, animalId |
| GET | `/api/favorites/{userId}` | 收藏列表 | userId |
| POST | `/api/favorites/batch-check` | 批量检查收藏 | userId, animalIds |

### 地区管理接口
| 方法 | 路径 | 描述 | 参数 |
|------|------|------|------|
| GET | `/api/provinces` | 获取省份列表 | - |
| GET | `/api/cities` | 获取城市列表 | - |
| GET | `/api/cities/province/{province}` | 按省份获取城市 | province |

## 📊 数据模型

### 核心实体关系
```
UserInfo (用户信息)
├── UserAddress (用户地址)
├── UserRealName (实名信息)
├── UserCheckin (签到记录)
├── UserFavorite (收藏记录)
└── AdoptionOrder (领养订单)

Animal (宠物信息)
├── AdoptionOrder (领养订单)
└── UserFavorite (收藏记录)

ProvinceCity (省市信息)
├── Animal (宠物地区)
└── MissingPet (寻宠地区)
```

### 主要实体字段

#### Animal (宠物实体)
```java
@Entity
public class Animal {
    private Long id;              // 宠物ID
    private String name;          // 宠物名称
    private String type;          // 宠物类型
    private Integer age;          // 宠物年龄
    private String city;          // 所在城市
    private String description;   // 描述信息
    private String image;         // 宠物图片
    private Boolean adopted;      // 是否已领养
    private Boolean listed;       // 是否上架
    private Boolean isFree;       // 是否免费
    private Long userId;          // 发布用户ID
}
```

#### UserInfo (用户实体)
```java
@Entity
public class UserInfo {
    private Long id;              // 用户ID
    private String username;      // 用户名
    private String password;      // 密码
    private String email;         // 邮箱
    private String phone;         // 手机号
    private String avatar;        // 头像
    private Date createdAt;       // 创建时间
}
```

## 🚀 性能优化

### 数据库优化
- **连接池配置**：HikariCP高性能连接池
- **索引优化**：关键字段建立索引
- **查询优化**：JPA查询优化和懒加载
- **分页查询**：大数据量分页处理

### 缓存策略
- **JPA二级缓存**：实体缓存配置
- **查询结果缓存**：频繁查询结果缓存
- **静态资源缓存**：图片等静态资源缓存

### 异步处理
- **事件驱动**：Spring Events异步事件处理
- **异步配置**：`@Async`注解异步方法执行
- **线程池配置**：自定义线程池配置

## 🔒 安全特性

### 认证与授权
- **Spring Security**：完整的安全框架集成
- **BCrypt加密**：密码安全加密存储
- **会话管理**：安全的会话管理机制

### 数据安全
- **SQL注入防护**：JPA参数化查询
- **XSS防护**：输入数据验证和转义
- **CSRF防护**：跨站请求伪造防护

### 接口安全
- **CORS配置**：跨域请求安全配置
- **参数验证**：Bean Validation数据验证
- **异常处理**：统一异常处理机制

## 📱 兼容性说明

### 前端兼容
- **API格式兼容**：与Node.js版本API格式完全兼容
- **响应格式统一**：`{"success": true, "data": {...}}`
- **错误处理统一**：`{"success": false, "message": "错误信息"}`

### 数据库兼容
- **MySQL 8.0+**：完全支持MySQL 8.0及以上版本
- **H2数据库**：开发环境支持H2内存数据库
- **字符集支持**：UTF-8字符集，支持中文

## 🛠️ 开发工具推荐

### IDE配置
- **IntelliJ IDEA** - 推荐安装插件：
  - Lombok Plugin
  - Spring Boot Helper
  - JPA Buddy
  - Database Navigator

### 调试工具
- **Spring Boot Actuator** - 应用监控和管理
- **MySQL Workbench** - 数据库管理工具
- **Postman** - API接口测试工具

## 📞 技术支持

### 常见问题
1. **数据库连接失败**：检查MySQL服务状态和连接配置
2. **端口占用**：确认8080端口未被占用
3. **依赖冲突**：使用`mvn dependency:tree`检查依赖
4. **编码问题**：确保数据库和应用都使用UTF-8编码

### 日志调试
```properties
# 开启SQL日志
logging.level.org.hibernate.SQL=DEBUG
logging.level.org.hibernate.type.descriptor.sql.BasicBinder=TRACE

# 开启Spring Security日志
logging.level.org.springframework.security=DEBUG
```

## 🔄 版本更新

### 当前版本特性 (v1.0.0)
- ✅ 完整的宠物管理功能
- ✅ 用户认证和权限管理
- ✅ 领养订单管理系统
- ✅ 用户签到功能
- ✅ 省市地区数据管理
- ✅ 寻宠信息发布
- ✅ 用户收藏功能
- ✅ 文件上传功能
- ✅ 事件驱动架构
- ✅ 完整的API文档

### 后续规划
- 🔄 Redis缓存集成
- 🔄 消息队列支持
- 🔄 微服务架构改造
- 🔄 Docker容器化部署
- 🔄 API限流和熔断
- 🔄 分布式事务支持

---

**技术架构** | Spring Boot + MySQL + JPA  
**最后更新** | 2025年8月30日
