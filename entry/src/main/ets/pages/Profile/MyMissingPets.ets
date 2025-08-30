import { router } from '@kit.ArkUI';
import prompt from '@system.prompt';
import { ApiService } from '../../common/services/ApiService';
import { MissingPet, MissingPetStatus } from '../../common/models/MissingPet';
import { UserService } from '../../common/database/UserService';
import { UserInfo } from '../../common/models/UserInfo';

// 状态常量
const STATUS_ALL: string = '全部'
const STATUS_ACTIVE: string = '寻找中'
const STATUS_FOUND: string = '已找到'
const STATUS_CLOSED: string = '已关闭'

// 按当前登录用户显示其发布的寻宠信息

@Entry
@Component
struct MyMissingPets {
  @State tabs: string[] = ['全部', '寻找中', '已找到', '已关闭']
  @State currentTab: number = 0
  @State isLoading: boolean = true
  @State errorMessage: string = ''
  @State allPosts: MissingPet[] = []
  @State posts: MissingPet[] = []
  
  private apiService: ApiService = ApiService.getInstance()
  private userService: UserService = UserService.getInstance()

  async aboutToAppear(): Promise<void> {
    // 检查登录状态
    const isLoggedIn = AppStorage.Get('isLoggedIn') as boolean | undefined
    if (!isLoggedIn) {
      prompt.showToast({ message: '请先登录后查看我的寻宠', duration: 1500 })
      try { 
        router.replaceUrl({ url: 'pages/Auth/Login' }) 
      } catch (_) { 
        router.pushUrl({ url: 'pages/Auth/Login' }) 
      }
      return
    }
    
    await this.loadMyMissingPets()
  }

  onPageShow(): void {
    // 页面显示时刷新数据
    this.loadMyMissingPets()
  }

  // 加载用户的寻宠数据
  async loadMyMissingPets(): Promise<void> {
    this.isLoading = true
    this.errorMessage = ''
    
    try {
      const params = router.getParams() as Record<string, number | string | undefined> | undefined
      const paramUserId = params && typeof params['userId'] === 'number' ? (params['userId'] as number) : undefined
      const userInfo = AppStorage.Get('userInfo') as UserInfo | undefined
      const storedUserId = (userInfo && typeof userInfo.id === 'number') ? userInfo.id : undefined
      const fallbackUserId = AppStorage.Get('userId') as number | undefined
      const username = (userInfo && userInfo.username) ? userInfo.username : (AppStorage.Get('currentUsername') as string | undefined)

      let userId: number | undefined = undefined
      if (typeof paramUserId === 'number') {
        userId = paramUserId
        console.info(`[MyMissingPets] 使用路由参数 userId: ${userId}`)
      } else if (typeof storedUserId === 'number') {
        userId = storedUserId
        console.info(`[MyMissingPets] 使用存储的用户ID: ${userId}`)
      } else if (typeof fallbackUserId === 'number') {
        userId = fallbackUserId
        console.info(`[MyMissingPets] 使用 AppStorage.userId: ${userId}`)
      } else if (username) {
        // 初始化 UserService 并通过用户名查询ID
        await this.userService.init()
        const userIdStr = await this.userService.getUserIdByUsername(username)
        userId = userIdStr ? Number(userIdStr) : undefined
        console.info(`[MyMissingPets] 通过用户名查得用户ID: ${userId}`)
      }

      if (typeof userId !== 'number' || isNaN(userId)) {
        this.errorMessage = '未登录或无法识别用户，请先登录'
        this.allPosts = []
        this.posts = []
        prompt.showToast({ message: this.errorMessage, duration: 1500 })
        return
      }

      // 获取当前用户的寻宠列表（严格按用户显示）
      const missingPets = await this.apiService.getMissingPetsByUser(userId)
      this.allPosts = missingPets

      console.info(`成功加载 ${this.allPosts.length} 条寻宠记录`)
      this.filterByTab(this.currentTab)
      
    } catch (error) {
      console.error(`加载我的寻宠失败: ${error}`)
      this.errorMessage = '加载数据失败，请重试'
      this.allPosts = []
      this.posts = []
    } finally {
      this.isLoading = false
    }
  }

  // 根据标签筛选数据
  filterByTab(index: number): void {
    this.currentTab = index
    const label = this.tabs[index]
    
    if (label === STATUS_ALL) {
      this.posts = this.allPosts
    } else if (label === STATUS_ACTIVE) {
      this.posts = this.allPosts.filter(p => p.status === 'ACTIVE')
    } else if (label === STATUS_FOUND) {
      this.posts = this.allPosts.filter(p => p.status === 'FOUND')
    } else if (label === STATUS_CLOSED) {
      this.posts = this.allPosts.filter(p => p.status === 'CLOSED')
    }
  }

  // 更新寻宠状态
  async updateStatus(id: number, newStatus: MissingPetStatus): Promise<void> {
    try {
      const result = await this.apiService.updateMissingPetStatus(id, newStatus)
      if (result) {
        // 更新本地数据
        this.allPosts = this.allPosts.map((p: MissingPet) => {
          if (p.id === id) {
            const updated: MissingPet = {
              id: p.id,
              userId: p.userId,
              title: p.title,
              petName: p.petName,
              type: p.type,
              gender: p.gender,
              age: p.age,
              lostTime: p.lostTime,
              city: p.city,
              lostAddress: p.lostAddress,
              description: p.description,
              contactName: p.contactName,
              contactPhone: p.contactPhone,
              status: newStatus,
              reward: p.reward,
              image: p.image,
              createdAt: p.createdAt,
              updatedAt: p.updatedAt,
              foundAt: p.foundAt
            }
            return updated
          }
          return p
        })
        this.filterByTab(this.currentTab)
        
        const statusText = newStatus === 'FOUND' ? '已找到' : newStatus === 'CLOSED' ? '已关闭' : '寻找中'
        prompt.showToast({ message: `状态已更新为：${statusText}`, duration: 1500 })
      } else {
        prompt.showToast({ message: '更新状态失败，请重试', duration: 1500 })
      }
    } catch (error) {
      console.error('更新状态异常:', error)
      prompt.showToast({ message: '更新状态失败，请检查网络', duration: 1500 })
    }
  }

  // 获取状态颜色
  getStatusColor(status: MissingPetStatus): string {
    switch (status) {
      case 'ACTIVE':
        return '#FF9500' // 橙色 - 寻找中
      case 'FOUND':
        return '#34C759' // 绿色 - 已找到  
      case 'CLOSED':
        return '#8E8E93' // 灰色 - 已关闭
      default:
        return '#8E8E93'
    }
  }

  // 获取状态文本
  getStatusText(status: MissingPetStatus): string {
    switch (status) {
      case 'ACTIVE':
        return '寻找中'
      case 'FOUND':
        return '已找到'
      case 'CLOSED':
        return '已关闭'
      default:
        return '未知'
    }
  }

  // 格式化时间显示
  formatTime(timeStr?: string | null): string {
    if (!timeStr || typeof timeStr !== 'string') {
      return '刚刚发布'
    }
    
    try {
      const normalized = timeStr.includes('T') ? timeStr : timeStr.replace(' ', 'T')
      const date = new Date(normalized)
      const now = new Date()
      const diffMs = now.getTime() - date.getTime()
      const diffHours = Math.floor(diffMs / (1000 * 60 * 60))
      const diffDays = Math.floor(diffHours / 24)
      
      if (diffHours < 1) {
        return '刚刚发布'
      } else if (diffHours < 24) {
        return `${diffHours}小时前发布`
      } else {
        return `${diffDays}天前发布`
      }
    } catch (error) {
      console.error('时间格式化失败:', error)
      return timeStr || '未知时间'
    }
  }

  // 格式化走失时间
  formatLostTime(timeStr?: string | null): string {
    if (!timeStr || typeof timeStr !== 'string') {
      return '未知'
    }
    
    try {
      const date = new Date(timeStr)
      const year = date.getFullYear()
      const month = String(date.getMonth() + 1).padStart(2, '0')
      const day = String(date.getDate()).padStart(2, '0')
      const hour = String(date.getHours()).padStart(2, '0')
      const minute = String(date.getMinutes()).padStart(2, '0')
      
      return `${year}-${month}-${day} ${hour}:${minute}`
    } catch (e) {
      return timeStr
    }
  }

  // 顶部导航栏
  @Builder TopBar(): void {
    Row() {
      // 左侧返回，固定宽度容器，保证中间标题绝对居中
      Row() {
        Button() {
          Image($r('app.media.arrow_left'))
            .width(24)
            .height(24)
            .fillColor('#1C1C1E')
        }
        .type(ButtonType.Normal)
        .backgroundColor(Color.Transparent)
        .onClick(() => router.back())
      }
      .width(64)
      .height(32)
      .alignItems(VerticalAlign.Center)

      // 中间标题
      Text('我的寻宠')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1C1C1E')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      // 右侧发布按钮，使用与左侧相同宽度容器，保持对称
      Row() {
        Button() {
          Text('发布')
            .fontSize(14)
            .fontColor(Color.White)
        }
        .type(ButtonType.Normal)
        .height(32)
        .backgroundColor('#FF9500')
        .padding({ left: 12, right: 12, top: 0, bottom: 0 })
        .borderRadius(16)
        .onClick(() => {
          router.pushUrl({
            url: 'pages/Profile/EditMissingPet',
            params: { mode: 'create' }
          })
        })
      }
      .width(64)
      .height(32)
      .justifyContent(FlexAlign.End)
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(56)
    .backgroundColor(Color.White)
    .padding({ left: 16, right: 16, top: 8 })
    .border({ width: { bottom: 0.5 }, color: '#E5E5EA' })
  }

  // 筛选标签栏
  @Builder TabsBar(): void {
    Tabs() {
      ForEach(this.tabs, (tab: string, index: number) => {
        TabContent() {
          this.ContentBuilder()
        }
        .tabBar(tab)
      })
    }
    .onChange((index: number) => this.filterByTab(index))
    .barMode(BarMode.Fixed)
    .barHeight(44)
    .width('100%')
    .layoutWeight(1)
  }

  // 寻宠卡片
  @Builder MissingPetCard(pet: MissingPet): void {
    Column() {
      // 顶部状态条
      Row() {
        // 编号显示
        Text(`编号: ${String(pet.id).padStart(6, '0')}`)
          .fontSize(12)
          .fontColor('#8E8E93')
          .backgroundColor('#F2F2F7')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderRadius(8)

        Blank()

        // 状态标签
        Text(this.getStatusText(pet.status))
          .fontSize(12)
          .fontColor(Color.White)
          .backgroundColor(this.getStatusColor(pet.status))
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .borderRadius(12)
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 宠物信息行
      Row() {
        // 宠物图片
        Image($r(pet.image || 'app.media.person'))
          .width(88)
          .height(88)
          .borderRadius(16)
          .objectFit(ImageFit.Cover)
          .backgroundColor('#F2F2F7')
          .border({ width: 1, color: '#E5E5EA' })

        // 宠物详情
        Column() {
          // 标题和宠物名
          Text(pet.title)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1C1C1E')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
            .margin({ bottom: 6 })

          // 宠物基本信息
          Row() {
            Text(pet.petName)
              .fontSize(14)
              .fontColor('#1C1C1E')
              .fontWeight(FontWeight.Medium)
            Image($r(pet.gender ? 'app.media.Animalgender' : 'app.media.Animalgenderf'))
              .width(16)
              .height(16)
              .margin({ left: 6 })
            Text(`${pet.age}岁`)
              .fontSize(14)
              .fontColor('#8E8E93')
              .margin({ left: 8 })
            Text('·')
              .fontSize(14)
              .fontColor('#8E8E93')
              .margin({ left: 4, right: 4 })
            Text(pet.type)
              .fontSize(14)
              .fontColor('#8E8E93')
          }
          .margin({ bottom: 6 })

          // 走失信息
          Row() {
            Image($r('app.media.local_fill2'))
              .width(14)
              .height(14)
              .margin({ right: 4 })
            Text(pet.city + ' ' + pet.lostAddress)
              .fontSize(13)
              .fontColor('#8E8E93')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)
          }
          .width('100%')
          .margin({ bottom: 6 })

          // 悬赏金额
          if (pet.reward && pet.reward > 0) {
            Row() {
              Text(`悬赏 ¥${pet.reward}`)
                .fontSize(14)
                .fontColor('#FF6B35')
                .fontWeight(FontWeight.Bold)
                .backgroundColor('#FFF3E0')
                .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                .borderRadius(4)
            }
          }
        }
        .layoutWeight(1)
        .margin({ left: 16 })
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      // 分割线
      Divider()
        .margin({ top: 12, bottom: 12 })
        .color('#E5E5EA')

      // 时间信息
      Row() {
        Column() {
          Text(`走失时间：${this.formatLostTime(pet.lostTime)}`)
            .fontSize(12)
            .fontColor('#8E8E93')
            .margin({ bottom: 4 })
          Text(`发布时间：${this.formatTime(pet.createdAt)}`)
            .fontSize(12)
            .fontColor('#8E8E93')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        // 联系信息
        Text(`${pet.contactName} ${pet.contactPhone}`)
          .fontSize(12)
          .fontColor('#8E8E93')
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 操作按钮
      Row() {
        // 详情按钮
        Button('详情')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .backgroundColor('#E6F0FF')
          .fontColor('#007AFF')
          .border({ width: 1, color: '#B3D7FF' })
          .height(32)
          .padding({ left: 10, right: 10, top: 0, bottom: 0 })
          .borderRadius(16)
          .onClick(() => {
            router.pushUrl({
              url: 'pages/Home/MissingPetDetail',
              params: { id: pet.id }
            })
          })

        // 编辑按钮
        if (pet.status === 'ACTIVE') {
            Button('编辑')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .backgroundColor('#E6F0FF')
              .fontColor('#007AFF')
              .border({ width: 1, color: '#B3D7FF' })
              .height(32)
              .padding({ left: 16, right: 16, top: 0, bottom: 0 })
              .borderRadius(16)
              .margin({ left: 8 })
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/Profile/EditMissingPet',
                  params: { id: pet.id, mode: 'edit' }
                })
              })
        }

        Blank()

        // 状态更新按钮
        if (pet.status === 'ACTIVE') {
          Row() {
            Button('标记已找到')
              .fontSize(14)
              .fontColor('#212529')
              .backgroundColor('#ffe7e7e7')
              .border({ width: 1, color: '#34C75930' })
              .height(32)
              .padding({ left: 16, right: 16, top: 0, bottom: 0 })
              .borderRadius(16)
              .onClick(() => this.updateStatus(pet.id, 'FOUND'))

            Button('关闭')
              .fontSize(14)
              .fontColor(Color.White)
              .backgroundColor('#dc3545')
              .border({ width: 1, color: '#8E8E9330' })
              .height(32)
              .padding({ left: 16, right: 16, top: 0, bottom: 0 })
              .borderRadius(16)
              .margin({ left: 5 })
              .onClick(() => this.updateStatus(pet.id, 'CLOSED'))
          }
          .margin({ left:5 })
        } else if (pet.status === 'FOUND') {
          Button('重新发布')
            .fontSize(14)
            .fontColor('#FF9500')
            .backgroundColor('#FF950015')
            .border({ width: 1, color: '#FF950030' })
            .height(32)
            .padding({ left: 16, right: 16, top: 0, bottom: 0 })
            .borderRadius(16)
            .onClick(() => this.updateStatus(pet.id, 'ACTIVE'))
        } else if (pet.status === 'CLOSED') {
          Button('重新发布')
            .fontSize(14)
            .fontColor('#FF9500')
            .backgroundColor('#FF950015')
            .border({ width: 1, color: '#FF950030' })
            .height(32)
            .padding({ left: 16, right: 16, top: 0, bottom: 0 })
            .borderRadius(16)
            .onClick(() => this.updateStatus(pet.id, 'ACTIVE'))
        }
      }
      .width('100%')
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(18)
    .padding(20)
    .margin({ bottom: 16 })
    .shadow({ radius: 8, color: '#00000008', offsetY: 4 })
  }

  // 内容构建器
  @Builder ContentBuilder(): void {
    if (this.isLoading) {
      // 加载状态
      Column() {
        LoadingProgress()
          .width(40)
          .height(40)
          .color('#007AFF')
        
        Text('加载中...')
          .fontSize(14)
          .fontColor('#8E8E93')
          .margin({ top: 12 })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
    } else if (this.errorMessage) {
      // 错误状态
      Column() {
        Text('😕')
          .fontSize(60)
          .margin({ top: 60 })
        
        Text(this.errorMessage)
          .fontSize(16)
          .fontColor('#FF3B30')
          .fontWeight(FontWeight.Medium)
          .margin({ top: 20 })
        
        Button('重新加载')
          .fontSize(15)
          .fontColor('#007AFF')
          .backgroundColor('#007AFF15')
          .borderRadius(24)
          .height(48)
          .width(160)
          .margin({ top: 32 })
          .onClick(() => {
            this.loadMyMissingPets()
          })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
    } else {
      // 正常内容
      List() {
        if (this.posts.length === 0) {
          // 空状态
          ListItem() {
            Column() {
              Text(this.currentTab === 2 ? '🎉' : this.currentTab === 3 ? '📦' : '🔍')
                .fontSize(60)
                .margin({ top: 60 })
              
              Text(
                this.currentTab === 2 ? '暂无已找到的宠物' :
                  this.currentTab === 3 ? '暂无已关闭的寻宠' :
                    this.currentTab === 1 ? '暂无正在寻找的宠物' :
                      '暂无寻宠发布'
              )
                .fontSize(18)
                .fontColor('#8E8E93')
                .fontWeight(FontWeight.Medium)
                .margin({ top: 20 })
              
              Text(
                this.currentTab === 2 ? '找到走失的宠物后记录会显示在这里' :
                  this.currentTab === 3 ? '关闭的寻宠记录会显示在这里' :
                    '发布寻宠信息，让更多人帮您寻找走失的爱宠'
              )
                .fontSize(14)
                .fontColor('#C7C7CC')
                .textAlign(TextAlign.Center)
                .lineHeight(20)
                .margin({ top: 12, left: 32, right: 32 })
              
              if (this.currentTab === 0 || this.currentTab === 1) {
                Button('去发布')
                  .fontSize(15)
                  .fontColor('#007AFF')
                  .backgroundColor('#007AFF15')
                  .borderRadius(24)
                  .height(48)
                  .width(160)
                  .margin({ top: 32 })
                  .onClick(() => {
                    router.pushUrl({
                      url: 'pages/Profile/EditMissingPet',
                      params: { mode: 'create' }
                    })
                  })
              }
            }
            .width('100%')
            .height(500)
            .justifyContent(FlexAlign.Center)
          }
        } else {
          // 数据列表
          ForEach(
            this.posts,
            (pet: MissingPet) => {
              ListItem() {
                this.MissingPetCard(pet)
              }
            },
            (pet: MissingPet) => `${pet.id}-${pet.status}`
          )
        }
      }
      .width('100%')
      .height('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 16 })
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
  }

  build() {
    Column() {
      this.TopBar()
      this.TabsBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F2F2F7')
  }
}
