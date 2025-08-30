import { router } from '@kit.ArkUI';
import prompt from '@system.prompt';
import { ApiService, AdoptionOrder, OrderStatus } from '../../common/services/ApiService';
import { UserService } from '../../common/database/UserService';
import { UserInfo } from '../../common/models/UserInfo';

@Entry
@Component
struct MyOrders {
  @State orders: AdoptionOrder[] = [];
  @State allOrders: AdoptionOrder[] = [];
  @State isLoading: boolean = true;
  @State currentTab: number = 0;
  
  private apiService: ApiService = ApiService.getInstance();
  private userService: UserService = UserService.getInstance();
  
  async aboutToAppear(): Promise<void> {
    // 登录校验（仅当不存在同类校验时添加）
    const isLoggedIn = AppStorage.Get('isLoggedIn') as boolean | undefined;
    if (!isLoggedIn) {
      prompt.showToast({ message: '请先登录后查看订单', duration: 1500 });
      try {
        router.replaceUrl({ url: 'pages/Auth/Login' });
      } catch (_) {
        router.pushUrl({ url: 'pages/Auth/Login' });
      }
      return;
    }
    await this.loadOrders();
  }
  
  onPageShow(): void {
    // 从详情页返回时，若设置了刷新标志，则自动刷新订单
    try {
      // 若存在已删除的订单ID，先从本地移除，保证即时反馈
      const deletedId = AppStorage.Get('deletedOrderId') as number | undefined;
      if (typeof deletedId === 'number') {
        this.allOrders = this.allOrders.filter(o => o.id !== deletedId);
        this.orders = this.orders.filter(o => o.id !== deletedId);
        try { AppStorage.Set('deletedOrderId', undefined); } catch (_) {}
      }

      // 清理刷新标志（不论其是否为 true，我们都刷新一次）
      try { AppStorage.Set('ordersShouldRefresh', false); } catch (_) {}
      // 无条件刷新，确保每次进入页面都更新数据
      this.loadOrders();
    } catch {
      console.warn('检测 ordersShouldRefresh 失败');
    }
  }
  
  // 加载订单数据
  async loadOrders(): Promise<void> {
    this.isLoading = true;
    try {
      // 优先按当前登录用户查询订单
      const userInfo = AppStorage.Get('userInfo') as UserInfo | undefined;
      const username = userInfo?.username;

      let orders: AdoptionOrder[] = [];
      if (username && username.trim().length > 0) {
        // 确保 UserService 初始化
        try {
          await this.userService.init();
        } catch {
          // 初始化失败则回退
          console.warn('UserService 初始化失败，回退全量订单');
        }

        try {
          const userIdStr = await this.userService.getUserIdByUsername(username);
          const userId = userIdStr ? Number(userIdStr) : NaN;
          if (!isNaN(userId)) {
            orders = await this.apiService.getAdoptionOrdersByUser(userId);
          } else {
            console.warn('未能解析用户ID，回退全量订单');
            orders = await this.apiService.getAllAdoptionOrders();
          }
        } catch {
          console.warn('按用户查询订单失败，回退全量订单');
          orders = await this.apiService.getAllAdoptionOrders();
        }
      } else {
        console.warn('未找到已登录用户信息，使用全量订单');
        orders = await this.apiService.getAllAdoptionOrders();
      }
      // 统一过滤“已取消”或包含“取消/删除”字样的订单，不在列表中展示
      this.allOrders = orders.filter(o => {
        const st: string = String(o.status || '');
        return st !== '已取消' && !st.includes('取消') && !st.includes('删除');
      });
      this.filterOrdersByTab(this.currentTab);
    } catch {
      console.error('加载订单失败');
      prompt.showToast({ message: '加载订单失败', duration: 1500 });
    } finally {
      this.isLoading = false;
    }
  }
  
  // 根据标签页过滤订单
  filterOrdersByTab(tabIndex: number): void {
    switch (tabIndex) {
      case 0: // 全部
        this.orders = this.allOrders;
        break;
      case 1: // 审核中
        this.orders = this.allOrders.filter(order => order.status === '审核中');
        break;
      case 2: // 已发货
        this.orders = this.allOrders.filter(order => order.status === '已发货');
        break;
      case 3: // 完成
        this.orders = this.allOrders.filter(order => order.status === '完成');
        break;
      case 4: // 评价
        this.orders = this.allOrders.filter(order => order.status === '评价');
        break;
    }
  }
  
  // 根据订单状态获取对应的颜色
  getStatusColor(status: OrderStatus): ResourceColor {
    switch (status) {
      case '审核中':
        return Color.Orange;
      case '已发货':
        return Color.Green;
      case '完成':
        return Color.Blue;
      case '评价':
        return '#9B59B6';
      case '已取消':
        return Color.Red;
      default:
        return Color.Gray;
    }
  }
  
  // 根据订单状态获取显示文本
  getStatusText(status: OrderStatus): string {
    switch (status) {
      case '审核中':
        return '等待审核';
      case '已发货':
        return '已发货';
      case '完成':
        return '已完成';
      case '评价':
        return '待评价';
      case '已取消':
        return '已取消';
      default:
        return status;
    }
  }
  
  // 构建标签页内容
  @Builder
  buildTabContent(): void {
    if (this.isLoading) {
      Column() {
        Text('加载中...')
          .fontSize(16)
          .fontColor('#666')
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
    } else if (this.orders.length > 0) {
      List() {
        ForEach(this.orders, (order: AdoptionOrder) => {
          ListItem() {
            // 订单条容器，保证水平居中
            Column() {
              Row() {
              // 左侧宠物图标
              Image($r(order.image))
                .width(80)
                .height(80)
                .margin({ right: 5 })

              // 中间信息区域
              Column() {
                Text(order.petName)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333')
                  .alignSelf(ItemAlign.Start)
                  .margin({ bottom: 4 })
                
                Text(`地区:${order.petAddress}`)
                  .fontSize(14)
                  .fontColor('#666')
                  .alignSelf(ItemAlign.Start)
                  .margin({ bottom: 4 })
                
                Text(`状态:${order.status}`)
                  .fontSize(14)
                  .fontColor('#666')
                  .alignSelf(ItemAlign.Start)
                  .margin({ bottom: 4 })
                
                Text(`申请时间:${order.applicationTime}`)
                  .fontSize(14)
                  .fontColor('#666')
                  .alignSelf(ItemAlign.Start)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              
              // 右侧状态
              Text(this.getStatusText(order.status))
                .fontSize(14)
                .fontColor(this.getStatusColor(order.status))
                .fontWeight(FontWeight.Medium)
              }
              .width('92%')
              .padding(16)
              .backgroundColor(Color.White)
              .borderRadius(12)
              .margin({ bottom: 10 })
              .alignSelf(ItemAlign.Center)
              .onClick(() => {
                // 点击跳转到申请详情页面
                router.pushUrl({
                  url: 'pages/Home/AdoptApplicationDetail',
                  params: {
                    orderId: order.id,
                    orderData: order
                  }
                });
              })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Center)
          }
          .padding({ left: 0, right: 0 })
          .backgroundColor(Color.Transparent)
        }, (order: AdoptionOrder) => order.id.toString())
      }
      .scrollBar(BarState.Off)
      .padding({ left: 0, right: 0 })
      .width('100%')
      .height('100%')
    } else {
      Column() {
        Image($r('app.media.shopping'))
          .width(120)
          .height(120)
          .margin({ top: 60, bottom: 20 })
        Text('暂无订单')
          .fontSize(18)
          .fontColor('#888')
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
    }
  }
  
  // 确认完成领养的方法 - 使用静态数据更新
  completeAdoption(orderId: number): void {
    // 更新本地数据
    this.orders = this.orders.map(order => {
      if (order.id === orderId) {
        // 仅按接口字段构造，修正状态为“完成”
        const updatedOrder: AdoptionOrder = {
          id: order.id,
          petName: order.petName,
          petAddress: order.petAddress,
          status: '完成',
          applicationTime: order.applicationTime,
          createdAt: order.createdAt,
          updatedAt: order.updatedAt,
          completedAt: new Date().toISOString().slice(0, 19).replace('T', ' ') // 设置当前时间为完成时间
        };
        return updatedOrder;
      }
      return order;
    });
    
    prompt.showToast({
      message: '已确认完成领养',
      duration: 2000
    });
  }
  
  build(): void {
    Column() {
      // 顶部栏
      Row() {
        Stack(){
          Row(){
            Image($r('app.media.arrow_left'))
              .width(24)
              .height(24)
              .onClick(() => router.back())
              .margin({ right:340 })
          }
          .zIndex(2)
          Row(){
            Text('我的领养申请')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .layoutWeight(1)
              .textAlign(TextAlign.Center)
          }
          .zIndex(1)
        }
      }
      .width('100%')
      .height(56)
      .backgroundColor('#fff')
      .borderRadius({ bottomLeft: 16, bottomRight: 16 })

      // 标签页
      Tabs() {
        TabContent() { this.buildTabContent() }.tabBar("全部")
        TabContent() { this.buildTabContent() }.tabBar("审核中")
        TabContent() { this.buildTabContent() }.tabBar("已发货")
        TabContent() { this.buildTabContent() }.tabBar("完成")
        TabContent() { this.buildTabContent() }.tabBar("评价")
      }
      .onChange((index: number) => {
        this.currentTab = index;
        this.filterOrdersByTab(index);
      })
      .width('100%')
      .layoutWeight(1)
      }
      .height('100%')
    .width('100%')
    .backgroundColor('#f5f6fa')
  }
}