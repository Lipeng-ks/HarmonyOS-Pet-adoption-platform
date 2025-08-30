import { router } from '@kit.ArkUI';
import { ApiService, AdoptionOrder, OrderStatus, Animal } from '../../common/services/ApiService';
import { UserInfo } from '../../common/models/UserInfo';
import prompt from '@system.prompt';

interface ApplicationDetailParams {
  orderId?: number;
  orderData?: AdoptionOrder;
}

// 扩展的申请详情接口，包含更多详细信息
interface ExtendedAdoptionOrder extends AdoptionOrder {
  applicantName?: string;
  applicantPhone?: string;
  animalDetails?: Animal;
  applicantDetails?: UserInfo;
  shippingAddress?: string;
  petExperience?: string;
  applicationReason?: string;
}

@Entry
@Component
struct AdoptApplicationDetailPage {
  @State orderDetail: ExtendedAdoptionOrder = {
    id: 0,
    userId: 0,
    petName: '',
    petAddress: '',
    image: '',
    status: '审核中',
    applicationTime: '',
    createdAt: '',
    updatedAt: '',
    completedAt: '',
    shippingAddress: '',
    petExperience: '',
    applicationReason: ''
  };

  @State AnimalColor2: string = '#ffdbdbdb'
  @State isLoading: boolean = true;
  @State loadError: boolean = false;
  @State resolvedImage: string = '';
  
  private apiService: ApiService = ApiService.getInstance();

  aboutToAppear() {
    let params = router.getParams() as ApplicationDetailParams;
    
    if (params && params.orderData) {
      // 如果传入了订单数据，直接使用并加载关联数据
      this.orderDetail = params.orderData as ExtendedAdoptionOrder;
      this.loadAdditionalData().then(() => {
        this.isLoading = false;
      });
    } else if (params && params.orderId) {
      // 如果只传入ID，需要从后端加载
      this.loadOrderDetail(params.orderId);
    } else {
      // 无参数时显示错误状态
      this.loadError = true;
      this.isLoading = false;
      prompt.showToast({
        message: '缺少必要的参数',
        duration: 2000
      });
    }
  }

  // 加载订单详情（使用真实的后端API）
  async loadOrderDetail(orderId: number) {
    this.isLoading = true;
    this.loadError = false;
    
    try {
      // 调用API获取订单详情
      const order = await this.apiService.getAdoptionOrderById(orderId);
      if (order) {
        this.orderDetail = order as ExtendedAdoptionOrder;
        // 加载相关数据（动物详情、用户信息）
        await this.loadAdditionalData();
        console.info(`成功加载订单ID为${orderId}的详情`);
      } else {
        this.loadError = true;
        prompt.showToast({
          message: '未找到该申请记录',
          duration: 2000
        });
      }
    } catch (error) {
      console.error(`加载订单详情失败: ${error}`);
      this.loadError = true;
      prompt.showToast({
        message: '加载申请详情失败',
        duration: 2000
      });
    } finally {
      this.isLoading = false;
    }
  }

  // 加载额外数据（动物详情、用户信息）
  async loadAdditionalData() {
    try {
      console.info(`开始加载额外数据 - 宠物名: ${this.orderDetail.petName}, 用户ID: ${this.orderDetail.userId}`);
      
      // 分别加载动物详情和用户信息
      let animalDetails: Animal | null = null;
      let userDetails: UserInfo | null = null;
      
      // 根据宠物名称获取动物详情
      if (this.orderDetail.petName) {
        console.info(`正在根据宠物名称加载动物详情: ${this.orderDetail.petName}`);
        animalDetails = await this.getAnimalByName(this.orderDetail.petName);
        this.orderDetail.animalDetails = animalDetails || undefined;
        console.info(`动物详情加载结果:`, animalDetails);
      }
      
      // 根据用户ID获取用户信息
      if (this.orderDetail.userId) {
        console.info(`正在根据用户ID加载用户信息: ${this.orderDetail.userId}`);
        userDetails = await this.apiService.getUserInfoById(this.orderDetail.userId as number);
        this.orderDetail.applicantDetails = userDetails || undefined;
        if (userDetails) {
          this.orderDetail.applicantName = userDetails.username || '未知';
          this.orderDetail.applicantPhone = userDetails.phone || '未提供';
          console.info(`用户信息加载成功: ${userDetails.username}`);
        } else {
          console.warn('未能加载用户信息');
        }
      }
      
      // 解析图片URL
      this.resolveImageUrl();
      
      console.info('额外数据加载完成');
      
    } catch (error) {
      console.error(`加载额外数据失败: ${error}`);
    }
  }

  // 根据宠物名称获取动物详情
  async getAnimalByName(petName: string): Promise<Animal | null> {
    try {
      const animals = await this.apiService.getAnimals();
      return animals.find(animal => animal.name === petName) || null;
    } catch (error) {
      console.error(`获取动物详情失败: ${error}`);
      return null;
    }
  }

  // 解析图片URL
  resolveImageUrl() {
    let imageUrl = '';
    
    // 优先使用订单中的图片
    if (this.orderDetail.image && typeof this.orderDetail.image === 'string') {
      imageUrl = this.orderDetail.image;
    }
    // 其次使用动物详情中的图片
    else if (this.orderDetail.animalDetails && this.orderDetail.animalDetails.image) {
      imageUrl = this.orderDetail.animalDetails.image;
    }
    
    // 处理不同类型的图片URL
    if (imageUrl) {
      if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
        // 使用完整的HTTP/HTTPS URL
        this.resolvedImage = imageUrl;
      } else if (imageUrl.startsWith('/')) {
        // 使用服务器相对路径，拼接完整URL
        this.resolvedImage = `http://localhost:8080${imageUrl}`;
      } else if (imageUrl.startsWith('app.media.')) {
        // 使用本地资源
        this.resolvedImage = imageUrl;
      } else {
        // 默认处理：假设是本地资源ID
        this.resolvedImage = imageUrl;
      }
    } else {
      // 无图片时使用默认图片
      this.resolvedImage = 'app.media.jdfogpd';
    }
  }

  // 获取状态颜色
  getStatusColor(status: OrderStatus): string {
    switch (status) {
      case '审核中': return '#FF9500';
      case '已发货': return '#007AFF';
      case '完成': return '#34C759';
      case '评价': return '#AF52DE';
      default: return '#8E8E93';
    }
  }

  // 获取状态背景色
  getStatusBackgroundColor(status: OrderStatus): string {
    switch (status) {
      case '审核中': return '#FFF3E0';
      case '已发货': return '#E3F2FD';
      case '完成': return '#E8F5E8';
      case '评价': return '#F3E5F5';
      default: return '#F2F2F7';
    }
  }

  // 格式化时间 - 直接使用数据库时间，无需时区转换
  formatTime(timeStr: string): string {
    try {
      if (!timeStr) {
        console.warn('时间字符串为空');
        return '';
      }
      
      console.info(`原始时间字符串: ${timeStr}`);
      
      // 直接使用后端返回的时间，只做简单的格式化处理
      let result = '';
      
      // 处理标准时间格式: 2025-08-24 09:18:27 或 2025-08-24T09:18:27
      if (timeStr.includes(' ') && timeStr.includes(':')) {
        // 标准格式: 2025-08-24 09:18:27
        const parts = timeStr.split(' ');
        if (parts.length >= 2) {
          const datePart = parts[0]; // 2025-08-24
          const timePart = parts[1].substring(0, 5); // 09:18
          result = `${datePart} ${timePart}`;
        } else {
          result = timeStr;
        }
      } else if (timeStr.includes('T')) {
        // ISO格式: 2025-08-24T09:18:27
        const parts = timeStr.split('T');
        if (parts.length >= 2) {
          const datePart = parts[0]; // 2025-08-24
          const timePart = parts[1].split('.')[0].substring(0, 5); // 09:18
          result = `${datePart} ${timePart}`;
        } else {
          result = timeStr;
        }
      } else {
        // 其他格式直接返回
        result = timeStr;
      }
      
      console.info(`格式化后的时间: ${result}`);
      return result;
      
    } catch (e) {
      console.error(`时间格式化错误: ${e}`);
      return timeStr || '';
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Image($r('app.media.arrow_left'))
          .width(24)
          .height(24)
          .margin({ left: 16 })
          .onClick(() => router.back())
        
        Text('申请详情')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Blank()
          .width(24)
          .margin({ right: 16 })
      }
      .width('100%')
      .height(56)
      .backgroundColor(Color.White)

      if (this.isLoading) {
        // 加载状态
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
          Text('正在加载申请详情...')
            .fontSize(16)
            .margin({ top: 20 })
            .fontColor('#666')
        }
        .width('100%')
        .height('80%')
        .justifyContent(FlexAlign.Center)
      } else if (this.loadError) {
        // 加载错误状态
        Column() {
          Image($r('app.media.xmark_circle_fill'))
            .width(64)
            .height(64)
            .margin({ bottom: 20 })
          Text('加载申请详情失败')
            .fontSize(18)
            .fontColor('#666')
          Button('重新加载')
            .type(ButtonType.Capsule)
            .backgroundColor(Color.Orange)
            .fontColor(Color.White)
            .fontSize(16)
            .width(120)
            .height(40)
            .margin({ top: 30 })
            .onClick(() => {
              let params = router.getParams() as ApplicationDetailParams;
              if (params && params.orderId) {
                this.loadOrderDetail(params.orderId);
              } else if (params && params.orderData) {
                this.orderDetail = params.orderData as ExtendedAdoptionOrder;
                this.loadAdditionalData().then(() => {
                  this.isLoading = false;
                });
              } else {
                prompt.showToast({
                  message: '无法重新加载，缺少参数',
                  duration: 2000
                });
              }
            })
        }
        .width('100%')
        .height('80%')
        .justifyContent(FlexAlign.Center)
      } else {
        // 正常内容
        Scroll() {
          Column({ space: 12 }) {
            // 申请状态卡片
            Column() {
              Row() {
                Text('申请状态')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                Text(this.orderDetail.status)
                  .fontSize(14)
                  .fontColor(this.getStatusColor(this.orderDetail.status))
                  .backgroundColor(this.getStatusBackgroundColor(this.orderDetail.status))
                  .padding({ left: 12, right: 12, top: 4, bottom: 4 })
                  .borderRadius(12)
              }
              .width('100%')
              .margin({ bottom: 8 })

              Text(`申请编号：${this.orderDetail.id}`)
                .fontSize(14)
                .fontColor('#666')
                .width('100%')
                .textAlign(TextAlign.Start)
                .margin({ bottom: 4 })

              Text(`申请时间：${this.formatTime(this.orderDetail.applicationTime)}`)
                .fontSize(14)
                .fontColor('#666')
                .width('100%')
                .textAlign(TextAlign.Start)
            }
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(12)
            .width('100%')

            // 宠物信息卡片
            Column() {
              Text('宠物信息')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .width('100%')
                .textAlign(TextAlign.Start)
                .margin({ bottom: 12 })

              Row() {
                // 宠物图片
                if (this.resolvedImage && typeof this.resolvedImage === 'string' && this.resolvedImage.startsWith('app.media.')) {
                  Image($r(this.resolvedImage))
                    .width(80)
                    .height(80)
                    .borderRadius(12)
                    .margin({ right: 12 })
                } else {
                  Image(this.resolvedImage)
                    .width(80)
                    .height(80)
                    .borderRadius(12)
                    .margin({ right: 12 })
                }

                // 宠物基本信息
                Column({ space: 6 }) {
                  Row() {
                    Text(this.orderDetail.petName)
                      .fontSize(18)
                      .fontWeight(FontWeight.Bold)
                      .margin({ right: 12 })
                    
                    if (this.orderDetail.animalDetails) {
                      Image($r(this.orderDetail.animalDetails.gender ? 'app.media.Animalgender' : 'app.media.Animalgenderf'))
                        .width(20)
                        .height(20)
                        .margin({ right: 8 })
                      
                      Text(`${this.orderDetail.animalDetails.age || 0}岁`)
                        .fontSize(14)
                        .fontColor('#666')
                    }
                  }
                  .width('100%')

                  Text(`地区：${this.orderDetail.petAddress}`)
                    .fontSize(14)
                    .fontColor('#666')
                    .width('100%')
                    .textAlign(TextAlign.Start)

                  // 健康状态标签
                  if (this.orderDetail.animalDetails) {
                    Row({ space: 2 }) {
                      Row() {
                        Text(this.orderDetail.animalDetails.neutered ? '已绝育' : '未绝育')
                          .fontSize(12)
                          .fontColor(Color.White)
                          .fontWeight(FontWeight.Bold)
                      }
                      .borderRadius(5)
                      .padding(5)
                      .backgroundColor(this.orderDetail.animalDetails.neutered ? Color.Orange : this.AnimalColor2)
                      Row() {
                        Text(this.orderDetail.animalDetails.vaccinated ? '已免疫' : '未免疫')
                          .fontSize(12)
                          .fontColor(Color.White)
                          .fontWeight(FontWeight.Bold)
                      }
                      .margin({ left: 5 })
                      .borderRadius(5)
                      .padding(5)
                      .backgroundColor(this.orderDetail.animalDetails.vaccinated ? Color.Orange : this.AnimalColor2)
                      Row() {
                        Text(this.orderDetail.animalDetails.dewormed ? '已驱虫' : '未驱虫')
                          .fontSize(12)
                          .fontColor(Color.White)
                          .fontWeight(FontWeight.Bold)
                      }
                      .margin({ left: 5 })
                      .borderRadius(5)
                      .padding(5)
                      .backgroundColor(this.orderDetail.animalDetails.dewormed ? Color.Orange : this.AnimalColor2)
                    }
                    .width('100%')
                  }
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')

              if (this.orderDetail.animalDetails && this.orderDetail.animalDetails.description) {
                Divider()
                  .width('100%')
                  .color('#EEEEEE')
                  .margin({ top: 12, bottom: 12 })

                Text('宠物描述')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .width('100%')
                  .textAlign(TextAlign.Start)
                  .margin({ bottom: 8 })

                Text(this.orderDetail.animalDetails.description)
                  .fontSize(14)
                  .fontColor('#666')
                  .width('100%')
                  .textAlign(TextAlign.Start)
                  .lineHeight(22)
              }
            }
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(12)
            .width('100%')

            // 申请人信息卡片
            Column() {
              Text('申请人信息')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .width('100%')
                .textAlign(TextAlign.Start)
                .margin({ bottom: 12 })

              Column({ space: 8 }) {
                Row() {
                  Text('姓名：')
                    .fontSize(14)
                    .fontColor('#666')
                    .width(60)
                  Text(this.orderDetail.applicantName || '未提供')
                    .fontSize(14)
                    .fontColor('#333')
                    .layoutWeight(1)
                }
                .width('100%')

                Row() {
                  Text('电话：')
                    .fontSize(14)
                    .fontColor('#666')
                    .width(60)
                  Text(this.orderDetail.applicantPhone || '未提供')
                    .fontSize(14)
                    .fontColor('#333')
                    .layoutWeight(1)
                }
                .width('100%')

                if (this.orderDetail.shippingAddress) {
                  Row() {
                    Text('地址：')
                      .fontSize(14)
                      .fontColor('#666')
                      .width(60)
                      .alignSelf(ItemAlign.Start)
                    Text(this.orderDetail.shippingAddress)
                      .fontSize(14)
                      .fontColor('#333')
                      .layoutWeight(1)
                      .lineHeight(20)
                  }
                  .width('100%')
                  .alignItems(VerticalAlign.Top)
                }
              }
            }
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(12)
            .width('100%')

            // 养宠经验卡片
            if (this.orderDetail.petExperience) {
              Column() {
                Text('养宠经验')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .width('100%')
                  .textAlign(TextAlign.Start)
                  .margin({ bottom: 12 })

                Text(this.orderDetail.petExperience)
                  .fontSize(14)
                  .fontColor('#666')
                  .width('100%')
                  .textAlign(TextAlign.Start)
                  .lineHeight(22)
              }
              .padding(16)
              .backgroundColor(Color.White)
              .borderRadius(12)
              .width('100%')
            }

            // 申请理由卡片
            if (this.orderDetail.applicationReason) {
              Column() {
                Text('申请理由')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .width('100%')
                  .textAlign(TextAlign.Start)
                  .margin({ bottom: 12 })

                Text(this.orderDetail.applicationReason)
                  .fontSize(14)
                  .fontColor('#666')
                  .width('100%')
                  .textAlign(TextAlign.Start)
                  .lineHeight(22)
              }
              .padding(16)
              .backgroundColor(Color.White)
              .borderRadius(12)
              .width('100%')
            }

            // 底部操作按钮区域（如果是审核中状态）
            if (this.orderDetail.status === '审核中') {
              Column({ space: 12 }) {
                Button('联系送养人')
                  .type(ButtonType.Capsule)
                  .backgroundColor('#E3F2FD')
                  .fontColor('#007AFF')
                  .fontSize(16)
                  .width('100%')
                  .height(48)
                  .onClick(() => {
                    prompt.showToast({
                      message: '联系功能开发中...',
                      duration: 2000
                    });
                  })

                Button('取消申请')
                  .type(ButtonType.Capsule)
                  .backgroundColor('#FFEBEE')
                  .fontColor('#F44336')
                  .fontSize(16)
                  .width('100%')
                  .height(48)
                  .onClick(() => {
                    AlertDialog.show({
                      title: '取消申请',
                      message: '确定要取消并删除该领养申请吗？',
                      autoCancel: true,
                      alignment: DialogAlignment.Center,
                      primaryButton: {
                        value: '取消',
                        action: () => {}
                      },
                      secondaryButton: {
                        value: '删除',
                        fontColor: '#FF0000',
                        action: async () => {
                          const success = await this.apiService.deleteAdoptionOrder(this.orderDetail.id);
                          if (success) {
                            // 设置返回后刷新“我的领养申请”页面的标志
                            try {
                              AppStorage.Set('ordersShouldRefresh', true);
                              AppStorage.Set('deletedOrderId', this.orderDetail.id);
                            } catch (_) {}
                            prompt.showToast({ message: '申请已取消', duration: 1500 });
                            setTimeout(() => {
                              router.replaceUrl({
                                url: 'pages/Profile/MyOrders'
                              });
                            }, 500);
                          } else {
                            prompt.showToast({ message: '取消申请失败，请稍后重试', duration: 2000 });
                          }
                        }
                      }
                    });
                  })
              }
              .width('100%')
              .margin({ top: 8 })
            }

            // 底部间距
            Column() {}
              .height(20)
          }
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .height('100%')
    .width('100%')
    .backgroundColor('#F5F5F5')
  }
}