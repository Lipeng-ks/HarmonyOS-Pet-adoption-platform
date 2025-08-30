import { router } from '@kit.ArkUI';
import { Animal, ApiService, AdoptionOrder } from '../../common/services/ApiService';
import { AdoptionRecord } from '../../common/models/AdoptionRecord';
import prompt from '@system.prompt';
import { UserService } from '../../common/database/UserService';
import { UserInfo } from '../../common/models/UserInfo';

@Entry
@Component
struct Adopt {
  @State AnimalColor2: string = '#ffdbdbdb'
  @State adoptionRecords: AdoptionRecord[] = [];
  @State isLoading: boolean = false;
  @State errorMessage: string = '';
  private apiService = ApiService.getInstance();
  private userService?: UserService;

  async onPageShow() {
    console.info('[Adopt] onPageShow - 页面显示');
    await this.loadCompletedOrders();
  }

  // 加载已完成的订单数据
  async loadCompletedOrders() {
    console.info('[Adopt] loadCompletedOrders - 开始加载已完成订单');
    
    try {
      this.isLoading = true;
      this.errorMessage = '';
      
      // 获取当前登录的用户信息（优先从 AppStorage 中读取完整 userInfo）
      const storedUser = AppStorage.Get<UserInfo>('userInfo') as UserInfo | undefined;
      const username = (storedUser && storedUser.username) || AppStorage.Get<string>('currentUsername');
      console.info(`[Adopt] loadCompletedOrders - 当前用户: ${username}`);
      
      let orders: AdoptionOrder[] = [];
      
      if (username && username.trim().length > 0) {
        // 确保 UserService 初始化
        try {
          if (!this.userService) {
            this.userService = UserService.getInstance();
          }
          await this.userService.init();
        } catch (e) {
          console.warn(`UserService 初始化失败，回退全量订单: ${e}`);
        }

        try {
          if (this.userService) {
            const userIdStr = await this.userService.getUserIdByUsername(username);
            const userId = userIdStr ? Number(userIdStr) : NaN;
            if (!isNaN(userId)) {
              // 获取该用户的所有订单（后端按用户查询）
              const allUserOrders = await this.apiService.getAdoptionOrdersByUser(userId);
              orders = allUserOrders.filter(order => order.status === '完成');
              console.info(`[Adopt] loadCompletedOrders - 用户${userId}有${allUserOrders.length}个订单，其中${orders.length}个已完成`);
            } else {
              console.warn('未能解析用户ID，使用后端按状态查询已完成订单');
              // 直接按状态从后端查询，避免拉取全量数据再过滤
              orders = await this.apiService.getAdoptionOrdersByStatus('完成');
            }
          } else {
            console.warn('UserService 未初始化，使用后端按状态查询已完成订单');
            orders = await this.apiService.getAdoptionOrdersByStatus('完成');
          }
        } catch (e) {
          console.warn(`按用户查询订单失败，回退全量订单: ${e}`);
          const allOrders = await this.apiService.getAllAdoptionOrders();
          orders = allOrders.filter(order => order.status === '完成');
        }
      } else {
        console.warn('未找到已登录用户信息，使用后端按状态查询已完成订单');
        orders = await this.apiService.getAdoptionOrdersByStatus('完成');
      }
      
      console.info(`[Adopt] loadCompletedOrders - 最终获取到 ${orders.length} 个已完成订单`);

      // 转换为AdoptionRecord格式：订单数据保持为 AdoptionOrder，展示数据统一封装为 AdoptionRecord
      this.adoptionRecords = orders.map(order => this.convertOrderToRecord(order));

      // 补全动物详情：若 adoption record 中 animal.id 可用，调用后端获取完整 animal 对象
      const localResources = [
        'app.media.jdfogpd',
        'app.media.lhmsdf',
        'app.media.dfghidg',
        'app.media.xjzxmm',
        'app.media.ilsdnvldfg',
        'app.media.lsdrhgd',
        'app.media.xmxmm',
        'app.media.tyikjgch',
        'app.media.ksdhf',
        'app.media.ddfchjbd'
      ];

      // 先尝试拉取所有动物作为回退匹配源（避免对每条记录重复请求）
      let allAnimalsCache: Animal[] = [];
      try {
        allAnimalsCache = await this.apiService.getAnimals();
      } catch (e) {
        console.warn('[Adopt] 获取全部动物作为匹配源失败', e);
      }

      await Promise.all(this.adoptionRecords.map(async (rec, idx) => {
        try {
          const animalId = rec.animal && rec.animal.id ? rec.animal.id : undefined;
          if (typeof animalId === 'number' && animalId > 0) {
            const full = await this.apiService.getAnimalById(animalId);
            if (full) {
              rec.animal = full;
            }
          } else if (rec.animal && rec.animal.name) {
            // 回退匹配：按名称（忽略大小写/空白）和城市尝试在缓存中查找
            const norm = (s: string) => (s || '').toString().trim().toLowerCase();
            const targetName = norm(rec.animal.name);
            const targetCity = norm(rec.animal.city || '');
            const matched = allAnimalsCache.find(a => {
              const an = norm(a.name);
              const ac = norm(a.city || '');
              if (an !== targetName) return false;
              if (targetCity && ac !== targetCity) return false;
              return true;
            });
            if (matched) {
              rec.animal = matched;
            }
          }

          // 图片回退：确保展示使用本地 app.media 资源，避免远程为空
          const img = rec.animal && rec.animal.image ? rec.animal.image : '';
          if (!img || typeof img !== 'string' || !img.startsWith || !img.startsWith('app.media.')) {
            rec.animal.image = localResources[idx % localResources.length] || 'app.media.pet';
          }
        } catch (e) {
          console.warn('[Adopt] 补全动物详情失败', e);
        }
      }));
      
    } catch (error) {
      console.error('[Adopt] loadCompletedOrders - 加载失败:', JSON.stringify(error));
      this.errorMessage = '加载数据失败，请重试';
      this.adoptionRecords = [];
    } finally {
      this.isLoading = false;
    }
  }

  // 将后端订单数据转换为前端显示格式
  convertOrderToRecord(order: AdoptionOrder): AdoptionRecord {
    // 确保 order 对象存在
    if (!order) {
      console.warn('[Adopt] convertOrderToRecord - 订单对象为空');
      return this.createEmptyRecord();
    }

    console.info(`[Adopt] convertOrderToRecord - 转换订单 ID: ${order.id}, 申请理由: ${order.applicationReason || '无'}`);

    // 构建 AdoptionRecord：保证 animal 字段总是存在（优先使用 order.animal，若无则构造最小占位）
    const animalData: Animal = order.animal ? order.animal as Animal : {
      id: 0,
      name: order.petName || '未知宠物',
      gender: true,
      age: 0,
      type: '宠物',
      description: order.applicationReason || '',
      vaccinated: false,
      dewormed: false,
      neutered: false,
      image: order.image || 'app.media.pet',
      city: order.petAddress || '',
      isFree: true
    };

    return {
      id: order.id || 0,
      orderNo: order.orderNo,
      userId: order.userId,
      animal: animalData,
      shippingAddress: order.shippingAddress,
      petExperience: order.petExperience,
      applicationReason: order.applicationReason,
      status: order.status || '审核中',
      applicationTime: order.applicationTime || '',
      createdAt: order.createdAt,
      updatedAt: order.updatedAt,
      completedAt: order.completedAt,
      contactInfo: order.shippingAddress || '',
      adoptionFee: order.adoptionFee || 0,
      urgencyLevel: order.urgencyLevel || 'low'
    };
  }

  // 创建空记录
  createEmptyRecord(): AdoptionRecord {
    return {
      id: 0,
      orderNo: undefined,
      userId: undefined,
      animal: {
        id: 0,
        name: '未知宠物',
        gender: true,
        age: 0,
        type: '宠物',
        description: '可爱的宠物',
        vaccinated: false,
        dewormed: false,
        neutered: false,
        image: 'app.media.pet',
        city: '未知地址',
        isFree: true
      },
      shippingAddress: undefined,
      petExperience: undefined,
      applicationReason: undefined,
      status: '审核中',
      applicationTime: '',
      createdAt: undefined,
      updatedAt: undefined,
      completedAt: undefined,
      contactInfo: undefined,
      adoptionFee: 0,
      urgencyLevel: 'low'
    };
  }

  // 获取状态颜色
  getStatusColor(status: string): string {
    // 仅对“完成”状态返回高亮颜色，其余统一灰色
    return status === '完成' ? '#5AC8FA' : '#8E8E93';
  }
  
  // 获取紧急程度颜色
  getUrgencyColor(urgencyLevel?: string): string {
    switch (urgencyLevel) {
      case 'high':
        return '#FF3B30'; // 红色
      case 'medium':
        return '#FF9500'; // 橙色
      case 'low':
        return '#34C759'; // 绿色
      default:
        return '#8E8E93'; // 灰色
    }
  }

  // 领养记录卡片组件
  @Builder
  AdoptionRecordCard(record: AdoptionRecord) {
    Column() {
      // 顶部状态条
      Row() {
        // 编号显示（所有状态都显示）
        Text(`编号: ${String(record.id).padStart(6, '0')}`)
          .fontSize(12)
          .fontColor('#8E8E93')
          .backgroundColor('#F2F2F7')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderRadius(8)
        
        // 紧急程度标识
        if (record.urgencyLevel && record.status === '审核中') {
          Row() {
            Circle({ width: 6, height: 6 })
              .fill(this.getUrgencyColor(record.urgencyLevel))
            Text(record.urgencyLevel === 'high' ? '紧急' : record.urgencyLevel === 'medium' ? '一般' : '普通')
              .fontSize(11)
              .fontColor(this.getUrgencyColor(record.urgencyLevel))
              .margin({ left: 4 })
          }
          .margin({ left: 8 })
        }
        
        Blank()
        if (record.status === '完成') {
          Button('详情')
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .backgroundColor('#E6F0FF')
            .fontColor('#007AFF')
            .border({ width: 1, color: '#B3D7FF' })
            .height(28)
            .padding({ left: 12, right: 12, top: 0, bottom: 0 })
            .borderRadius(14)
            .margin({ right: 8 })
            .onClick(() => {
              router.pushUrl({
                url: 'pages/Home/AdoptApplicationDetail',
                params: { orderId: record.id }
              });
            })
        }

        // 状态标签
        Text(record.status)
          .fontSize(12)
          .fontColor(Color.White)
          .backgroundColor(this.getStatusColor(record.status))
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .borderRadius(12)
      }
      .width('100%')
      .margin({ bottom: 12 })
      
      // 动物信息行
      Row() {
        // 动物图片（使用 order.animal.image，如无则使用占位图）
        Image($r(record.animal.image || 'app.media.pet'))
          .width(88)
          .height(88)
          .borderRadius(16)
          .objectFit(ImageFit.Cover)
          .backgroundColor('#F2F2F7')
          .border({ width: 1, color: '#E5E5EA' })
        
        // 动物详情
        Column() {
          Row() {
            Text(record.animal.name)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1C1C1E')
          }
          .width('100%')
          .margin({ bottom: 8 })
          
          Row() {
            Text(record.animal && typeof record.animal.age !== 'undefined' ? `${record.animal.age}岁` : '')
              .fontSize(14)
              .fontColor('#8E8E93')
            Text('·')
              .fontSize(14)
              .fontColor('#8E8E93')
              .margin({ left: 4, right: 4 })
            Text(typeof record.animal.gender === 'boolean' ? (record.animal.gender ? '雄性' : '雌性') : '')
              .fontSize(14)
              .fontColor('#8E8E93')
          }
          .margin({ bottom: 6 })
          
          Row() {
            Text(record.animal.city || '')
              .fontSize(13)
              .fontColor('#8E8E93')
              .margin({ left: 4 })
          }
          .margin({ bottom: 8 })
          
          // 健康状态标签
          Row() {
            Row() {
              Text(record.animal?.neutered ? '已绝育' : '未绝育')
                .fontSize(12)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Bold)
            }
            .borderRadius(5)
            .padding(5)
            .backgroundColor(record.animal?.neutered ? Color.Orange : this.AnimalColor2)
            Row() {
              Text(record.animal?.vaccinated ? '已免疫' : '未免疫')
                .fontSize(12)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Bold)
            }
            .margin({ left: 5 })
            .borderRadius(5)
            .padding(5)
            .backgroundColor(record.animal?.vaccinated ? Color.Orange : this.AnimalColor2)
            Row() {
              Text(record.animal?.dewormed ? '已驱虫' : '未驱虫')
                .fontSize(12)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Bold)
            }
            .margin({ left: 5 })
            .borderRadius(5)
            .padding(5)
            .backgroundColor(record.animal?.dewormed ? Color.Orange : this.AnimalColor2)
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
        .margin({ top: 8, bottom: 8 })
        .color('#E5E5EA')
      
      // 时间信息
      Column() {
        Row() {
          Text(`申请时间：${this.formatTime(record.applicationTime)}`)
            .fontSize(12)
            .fontColor('#8E8E93')
            .margin({ left: 4 })
        }
        .margin({ bottom: 4 })
        
        if (record.completedAt) {
          Row() {
            Text(`完成时间：${this.formatTime(record.completedAt)}`)
              .fontSize(12)
              .fontColor('#8E8E93')
              .margin({ left: 4 })
          }
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: 12 })
      
      // 申请原因
      Column() {
        Text('申请原因')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1C1C1E')
          .margin({ bottom: 6 })
        
        Text(record.applicationReason)
          .fontSize(13)
          .fontColor('#3C3C43')
          .lineHeight(18)
          .maxLines(3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ bottom:10 })

        Column(){}.width("100%").height("1").backgroundColor(Color.Black).opacity(0.3).margin({ bottom:10 }) 

        Text('收货地址')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1C1C1E')
          .margin({ bottom: 6 })

        Text(record.shippingAddress)
          .fontSize(13)
          .fontColor('#3C3C43')
          .lineHeight(18)
          .maxLines(3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      
      // 联系信息
      if (record.contactInfo && record.status === '已发货') {
        Column() {
          Text('联系信息')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1C1C1E')
            .margin({ bottom: 6, top: 12 })
          
          Text(record.contactInfo)
            .fontSize(13)
            .fontColor('#007AFF')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
      
      // 领养费用
      if (record.adoptionFee !== undefined && record.adoptionFee > 0) {
        Row() {
          Text('领养费用：')
            .fontSize(13)
            .fontColor('#8E8E93')
          Text(`￥${record.adoptionFee}`)
            .fontSize(14)
            .fontColor('#FF9500')
            .fontWeight(FontWeight.Medium)
        }
        .margin({ top: 8 })
      }
      
      // 操作按钮（只有已完成状态才显示）
      if (record.status === '完成') {
        Button('联系管理员')
          .fontSize(14)
          .fontColor('#007AFF')
          .backgroundColor('#007AFF15')
          .borderRadius(20)
          .height(40)
          .width('100%')
          .margin({ top: 16 })
          .onClick(() => {
            prompt.showToast({ message: `联系 ${record.contactInfo || '管理员'}，咨询领养后续事宜`, duration: 2000 });
          })
      }
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(18)
    .padding(20)
    .margin({ bottom: 16 })
    .shadow({ radius: 8, color: '#00000008', offsetY: 4 })
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button() {
          Image($r('app.media.arrow_left'))
            .width(24)
            .height(24)
            .fillColor('#1C1C1E')
        }
        .type(ButtonType.Normal)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          router.back();
        })
        
        Text('我的领养')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1C1C1E')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        // 占位，保持标题居中
        Row()
          .width(24)
          .height(24)
      }
      .width('100%')
      .height(56)
      .backgroundColor(Color.White)
      .padding({ left: 16, right: 16 })
      .border({ width: { bottom: 0.5 }, color: '#E5E5EA' })
      
      // 内容区域
      this.ContentBuilder()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F2F2F7')
  }

  // 获取已完成的领养记录
  getCompletedRecords(): AdoptionRecord[] {
    return this.adoptionRecords.filter(record => record.status === '完成');
  }
  
  // 格式化时间显示
  formatTime(timeStr: string): string {
    if (!timeStr) return '暂无';
    
    try {
      // 处理标准格式："2024-08-24 14:30:00" 或 "2024-08-24T14:30:00"
      if (timeStr.includes('-') && (timeStr.includes(' ') || timeStr.includes('T'))) {
        const standardTime = timeStr.replace('T', ' ').substring(0, 19);
        return standardTime;
      }
      
      // 处理ISO格式
      const date = new Date(timeStr);
      if (!isNaN(date.getTime())) {
        return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')} ${String(date.getHours()).padStart(2, '0')}:${String(date.getMinutes()).padStart(2, '0')}:${String(date.getSeconds()).padStart(2, '0')}`;
      }
      
      return timeStr;
    } catch (error) {
      console.error('[Adopt] formatTime - 时间格式化失败:', error);
      return timeStr;
    }
  }

  // 内容构建器
  @Builder
  ContentBuilder() {
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
            this.loadCompletedOrders();
          })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
    } else {
      List() {
        ForEach(
          this.getCompletedRecords(),
          (record: AdoptionRecord) => {
            ListItem() {
              this.AdoptionRecordCard(record)
            }
          },
          (record: AdoptionRecord) => `${record.id}`
        )
        
        // 空状态
        if (this.getCompletedRecords().length === 0) {
          ListItem() {
            Column() {
              Text('🏆')
                .fontSize(60)
                .margin({ top: 60 })
              
              Text('暂无已完成的领养记录')
                .fontSize(18)
                .fontColor('#8E8E93')
                .fontWeight(FontWeight.Medium)
                .margin({ top: 20 })
              
              Text('完成领养后的记录会显示在这里\n感谢您为小动物们提供温暖的家')
                .fontSize(14)
                .fontColor('#C7C7CC')
                .textAlign(TextAlign.Center)
                .lineHeight(20)
                .margin({ top: 12 })
              
              Button('去首页看看')
                .fontSize(15)
                .fontColor('#007AFF')
                .backgroundColor('#007AFF15')
                .borderRadius(24)
                .height(48)
                .width(160)
                .margin({ top: 32 })
                .onClick(() => {
                  router.pushUrl({ url: 'pages/Home/Home' });
                })
            }
            .width('100%')
            .height(500)
            .justifyContent(FlexAlign.Center)
          }
        }
      }
      .width('100%')
      .height('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 16 })
      .scrollBar(BarState.Off)
    }
  }
}