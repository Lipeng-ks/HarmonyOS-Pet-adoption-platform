import { router } from '@kit.ArkUI';
import prompt from '@system.prompt';
import { ApiService } from '../../common/services/ApiService';
import { MissingPet } from '../../common/models/MissingPet';
import { UserService } from '../../common/database/UserService';
import { UserInfo } from '../../common/models/UserInfo';
interface MissingPetDetailParams {
  id?: number;
}

@Entry
@Component
struct MissingPetDetailPage {
  @State private missingPet: MissingPet = {} as MissingPet;
  @State isLoading: boolean = false;
  @State loadError: boolean = false;
  @State refreshFlag: number = 0;
  @State private currentUserId: number | null = null; // 当前登录用户ID
  
  private apiService: ApiService = ApiService.getInstance();
  private userService: UserService = UserService.getInstance();

  async aboutToAppear(): Promise<void> {
    // 先加载当前用户ID
    await this.loadCurrentUserId();
    
    let params = router.getParams() as MissingPetDetailParams;
    if (params && params.id) {
      this.loadMissingPetById(params.id);
    } else {
      this.loadError = true;
      prompt.showToast({
        message: '缺少必要的参数',
        duration: 2000
      });
    }
  }

  onPageShow(): void {
    let params = router.getParams() as MissingPetDetailParams;
    if (params && params.id) {
      this.loadMissingPetById(params.id);
    }
    this.refreshFlag++;
  }

  async loadMissingPetById(id: number): Promise<void> {
    this.isLoading = true;
    this.loadError = false;
    
    try {
      const pet = await this.apiService.getMissingPetById(id);
      if (pet) {
        this.missingPet = pet;
        console.info(`成功加载ID为${id}的寻宠数据`);
      } else {
        console.error(`未找到ID为${id}的寻宠数据`);
        this.loadError = true;
        prompt.showToast({
          message: '未找到该寻宠信息',
          duration: 2000
        });
      }
    } catch (error) {
      console.error(`加载寻宠详情失败: ${error}`);
      this.loadError = true;
    } finally {
      this.isLoading = false;
    }
  }

  // 加载当前登录用户ID，用于前端限制：不能联系自己发布的寻宠
  private async loadCurrentUserId(): Promise<void> {
    try {
      //直接从 AppStorage 读取 userInfo.id
      const userInfo = AppStorage.Get('userInfo') as UserInfo | undefined;
      if (userInfo && typeof userInfo.id === 'number') {
        this.currentUserId = userInfo.id;
        return;
      }

      //兜底：通过用户名查ID（如果后端登录未返回id）
      const username = userInfo?.username || (AppStorage.Get('currentUsername') as string | undefined);
      if (username) {
        await this.userService.init();
        const uidStr = await this.userService.getUserIdByUsername(username);
        if (uidStr && !isNaN(Number(uidStr))) {
          this.currentUserId = Number(uidStr);
          return;
        }
      }

      //最后兜底：尝试读取 AppStorage 中可能存在的 userId
      const fallbackUserId = AppStorage.Get('userId') as number | undefined;
      if (typeof fallbackUserId === 'number') {
        this.currentUserId = fallbackUserId;
      }
    } catch (e) {
      // 静默失败，保持 null
      console.warn(`[MissingPetDetail] 加载当前用户ID失败: ${e}`);
      this.currentUserId = null;
    }
  }

  // 格式化时间显示
  formatTime(timeStr: string): string {
    if (!timeStr) return '';
    
    const date = new Date(timeStr);
    const now = new Date();
    const diffMs = now.getTime() - date.getTime();
    const diffHours = Math.floor(diffMs / (1000 * 60 * 60));
    const diffDays = Math.floor(diffHours / 24);
    
    if (diffHours < 1) {
      return '刚刚发布';
    } else if (diffHours < 24) {
      return `${diffHours}小时前发布`;
    } else {
      return `${diffDays}天前发布`;
    }
  }

  // 格式化丢失时间
  formatLostTime(timeStr: string): string {
    if (!timeStr) return '';
    
    try {
      const date = new Date(timeStr);
      const year = date.getFullYear();
      const month = String(date.getMonth() + 1).padStart(2, '0');
      const day = String(date.getDate()).padStart(2, '0');
      const hour = String(date.getHours()).padStart(2, '0');
      const minute = String(date.getMinutes()).padStart(2, '0');
      
      return `${year}-${month}-${day} ${hour}:${minute}`;
    } catch (e) {
      return timeStr;
    }
  }

  build(): void {
    Column() {
      Row() { Text('') }.opacity(0).id('refresh-' + this.refreshFlag)
      
      // 顶部导航栏
      Row() {
        Image($r('app.media.arrow_left'))
          .width(24)
          .height(24)
          .onClick(() => router.back())
          .margin({ left: 16 })
          
        Text('寻宠详情')
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
          Text('正在加载寻宠信息...')
            .fontSize(16)
            .margin({ top: 20 })
            .fontColor('#666')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.loadError) {
        // 加载错误状态
        Column() {
          Image($r('app.media.xmark_circle_fill'))
            .width(64)
            .height(64)
            .margin({ bottom: 20 })
          Text('加载寻宠信息失败')
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
              let params = router.getParams() as MissingPetDetailParams;
              if (params && params.id) {
                this.loadMissingPetById(params.id);
              }
            })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        // 正常内容
        Scroll() {
          Column() {
            // 宠物大图
            Stack() {
              Image($r(this.missingPet.image))
                .width('100%')
                .height(300)
                .objectFit(ImageFit.Cover)
              
              // 悬赏金额标签
              if (this.missingPet.reward && this.missingPet.reward > 0) {
                Row() {
                  Text(`悬赏 ¥${this.missingPet.reward}`)
                    .fontSize(16)
                    .fontColor(Color.White)
                    .fontWeight(FontWeight.Bold)
                }
                .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                .backgroundColor('#ff6b35')
                .borderRadius(20)
                .position({ x: 16, y: 16 })
              }
            }
            .width('100%')
            
            Column() {
              // 标题和发布时间
              Row() {
                Text(this.missingPet.title)
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .layoutWeight(1)
                
                Text(this.formatTime(this.missingPet.createdAt || this.missingPet.lostTime))
                  .fontSize(12)
                  .fontColor('#999')
              }
              .width('100%')
              .margin({ bottom: 12 })
              
              // 宠物基本信息
              Row() {
                Row() {
                  Text(this.missingPet.petName)
                    .fontSize(18)
                    .fontWeight(FontWeight.Medium)
                  
                  Image($r(this.missingPet.gender ? 'app.media.Animalgender' : 'app.media.Animalgenderf'))
                    .width(20)
                    .height(20)
                    .margin({ left: 8, right: 8 })
                  
                  Text(`${this.missingPet.age}岁`)
                    .fontSize(16)
                    .fontColor('#666')
                  
                  Text('·')
                    .fontSize(16)
                    .fontColor('#999')
                    .margin({ left: 8, right: 8 })
                  
                  Text(this.missingPet.type)
                    .fontSize(16)
                    .fontColor('#666')
                }
              }
              .width('100%')
              .margin({ bottom: 16 })
              
              // 走失信息卡片
              Column() {
                Text('走失信息')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .width('100%')
                  .margin({ bottom: 12 })
                
                Row() {
                  Image($r('app.media.birthday'))
                    .width(16)
                    .height(16)
                    .margin({ right: 8 })
                  Text('走失时间：')
                    .fontSize(14)
                    .fontColor('#666')
                  Text(this.formatLostTime(this.missingPet.lostTime))
                    .fontSize(14)
                    .fontColor('#333')
                }
                .width('100%')
                .margin({ bottom: 8 })
                
                Row() {
                  Image($r('app.media.local_fill2'))
                    .width(16)
                    .height(16)
                    .margin({ right: 8 })
                    .alignSelf(ItemAlign.Start)
                    .margin({ top: 2 })
                  Text('走失地点：')
                    .fontSize(14)
                    .fontColor('#666')
                  Text(this.missingPet.lostAddress)
                    .fontSize(14)
                    .fontColor('#333')
                    .layoutWeight(1)
                    .lineHeight(20)
                }
                .width('100%')
                .alignItems(VerticalAlign.Top)
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#f8f8f8')
              .borderRadius(12)
              .margin({ bottom: 16 })
              
              // 宠物描述
              Column() {
                Text('详细描述')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .width('100%')
                  .margin({ bottom: 12 })
                
                Text(this.missingPet.description)
                  .fontSize(14)
                  .fontColor('#333')
                  .width('100%')
                  .lineHeight(22)
              }
              .width('100%')
              .margin({ bottom: 16 })
              
              // 联系信息卡片
              Column() {
                Text('联系方式')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .width('100%')
                  .margin({ bottom: 12 })
                
                Row() {
                  Image($r('app.media.idcard'))
                    .width(16)
                    .height(16)
                    .margin({ right: 8 })
                  Text('联系人：')
                    .fontSize(14)
                    .fontColor('#666')
                  Text(this.missingPet.contactName)
                    .fontSize(14)
                    .fontColor('#333')
                }
                .width('100%')
                .margin({ bottom: 8 })
                
                Row() {
                  Image($r('app.media.speaker'))
                    .width(16)
                    .height(16)
                    .margin({ right: 8 })
                  Text('联系电话：')
                    .fontSize(14)
                    .fontColor('#666')
                  Text(this.missingPet.contactPhone)
                    .fontSize(14)
                    .fontColor('#333')
                }
                .width('100%')
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#fff3e0')
              .borderRadius(12)
              .margin({ bottom: 20 })
              
              // 温馨提示
              Row() {
                Image($r('app.media.speaker'))
                  .width(16)
                  .height(16)
                  .margin({ right: 8 })
                Text('如果您看到这只小可爱，请及时联系失主，让它早日回家！')
                  .fontSize(12)
                  .fontColor('#ff9900')
                  .layoutWeight(1)
              }
              .width('100%')
              .padding(12)
              .backgroundColor('#fff3cd')
              .borderRadius(8)
              .margin({ bottom: 80 })
            }
            .padding({ left: 16, right: 16, top: 16 })
          }
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        
        // 底部操作栏
        Row() {
          Button('联系失主')
            .type(ButtonType.Capsule)
            .backgroundColor(Color.Orange)
            .fontColor(Color.White)
            .fontSize(16)
            .layoutWeight(1)
            .height(44)
            .margin({ right: 8 })
            .enabled(this.missingPet?.userId !== this.currentUserId)
            .onClick(() => {
              // 二次校验，防止异常状态下仍可点击
              if (this.currentUserId !== null && this.missingPet?.userId === this.currentUserId) {
                prompt.showToast({ message: '不能联系自己发布的寻宠', duration: 1500 });
                return;
              }
              prompt.showToast({ message: `请拨打电话：${this.missingPet.contactPhone}` , duration: 3000 });
            })
          
          Button() {
            Row() {
              Image($r('app.media.share'))
                .width(20)
                .height(20)
                .margin({ right: 8 })
              Text('分享')
                .fontSize(16)
            }
          }
          .type(ButtonType.Capsule)
          .backgroundColor('#f5f5f5')
          .fontColor('#333')
          .width(100)
          .height(44)
          .onClick(() => {
            prompt.showToast({
              message: '分享功能开发中...',
              duration: 2000
            });
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        .backgroundColor(Color.White)
        .shadow({ radius: 4, color: '#10000000', offsetX: 0, offsetY: -2 })
      }
    }
    .height('100%')
    .width('100%')
    .backgroundColor('#f5f5f5')
  }
}
