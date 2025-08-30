import { router } from '@kit.ArkUI';
import { ApiService } from '../../common/services/ApiService';
import { MissingPet, MissingPetStatus } from '../../common/models/MissingPet';
import { GlobalState } from '../../common/utils/GlobalState';

interface CityParams {
  city?: string;
  selectedCity?: string;
}

@Entry
@Component
struct MissingPets {
  @State selectedCity: string = '全国';
  @State missingPets: MissingPet[] = [];
  @State isLoading: boolean = true;
  @State refreshFlag: number = 0;
  
  private apiService: ApiService = ApiService.getInstance();
  private globalState: GlobalState = GlobalState.getInstance();
  private cityChangeCallback = (city: string) => {
    this.selectedCity = city;
    this.loadMissingPetsData();
  };

  aboutToAppear(): void {
    // 注册全局状态监听
    this.globalState.onCityChange(this.cityChangeCallback);
    
    let params = router.getParams() as CityParams;
    if (params && params.city) {
      this.selectedCity = params.city;
      this.globalState.setSelectedCity(params.city);
    } else if (params && params.selectedCity) {
      this.selectedCity = params.selectedCity;
      this.globalState.setSelectedCity(params.selectedCity);
    } else {
      // 从Home页面进入时，重置为全国
      this.selectedCity = '全国';
      this.globalState.setSelectedCity('全国');
    }
    
    this.loadMissingPetsData();
  }

  onPageShow(): void {
    // 从全局状态获取最新的城市信息
    const currentCity = this.globalState.getSelectedCity();
    if (currentCity !== this.selectedCity) {
      this.selectedCity = currentCity;
      this.loadMissingPetsData();
    }
  }

  aboutToDisappear(): void {
    // 移除全局状态监听
    this.globalState.offCityChange(this.cityChangeCallback);
  }

  async loadMissingPetsData(): Promise<void> {
    this.isLoading = true;
    try {
      // 获取寻宠数据，按城市过滤
      const city = this.selectedCity === '全国' ? undefined : this.selectedCity;
      const fetchedPets = await this.apiService.getMissingPets('ACTIVE', city);
      
      this.missingPets = fetchedPets;
      console.info(`成功加载 ${fetchedPets.length} 条寻宠数据`);
    } catch (error) {
      console.error(`加载寻宠数据失败: ${error}`);
      this.missingPets = [];
    } finally {
      this.isLoading = false;
    }
  }

  // 格式化时间显示（容错空值/无效格式）
  formatTime(timeStr?: string | null): string {
    if (!timeStr || typeof timeStr !== 'string') {
      return '刚刚发布';
    }
    // 兼容 "YYYY-MM-DD HH:mm:ss" 与 ISO 格式
    const normalized = timeStr.includes('T') ? timeStr : timeStr.replace(' ', 'T');
    const date = new Date(normalized);
    const now = new Date();
    const diffMs = now.getTime() - date.getTime();
    const diffHours = Math.floor(diffMs / (1000 * 60 * 60));
    const diffDays = Math.floor(diffHours / 24);
    
    if (diffHours < 1) {
      return '刚刚发布';
    } else if (diffHours < 24) {
      return `${diffHours}小时前`;
    } else {
      return `${diffDays}天前`;
    }
  }

  build(): void {
    Column() {
      Stack() {
        // 底层：左右分布（返回按钮 / 城市选择器）
        Row() {
          // 左：返回按钮（扩大点击热区）
          Row() {
            Image($r('app.media.arrow_left'))
              .width(24)
              .height(24)
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
          .onClick(() => router.back())

          Blank().layoutWeight(1)

          // 右：城市胶囊选择器
          Row() {
            Image($r('app.media.local_fill'))
              .width(18)
              .height(18)
            Text(this.selectedCity)
              .fontSize(14)
              .fontColor('#333')
              .margin({ left: 4 })
            Image($r('app.media.triangleshape_fill'))
              .width(12)
              .height(12)
              .margin({ left: 2 })
          }
          .height(32)
          .padding({ right: 10 ,left: 10 })
          .backgroundColor('#f0f0f0')
          .borderRadius(16)
          .onClick(() => router.pushUrl({ 
            url: 'pages/Home/CitySelect',
            params: { fromPage: 'MissingPets' }
          }))
        }
        .width('100%')
        .height(56)
        .padding({ left: 12, right: 12 })

        // 上层：全宽居中标题
        Row() {
          Text('寻宠')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
        }
        .width('100%')
        .height(56)
        .padding({ left: 12, right: 12 })
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .hitTestBehavior(HitTestMode.Transparent)
      }
      .width('100%')
      .height(56)
      .backgroundColor('#ffffff')
      .border({ width: { bottom: 0.5 }, color: { bottom: '#11000000' } })

      // 主要内容区域
      List() {
        ListItem() {
          Column() {
            // 提示信息
            Row() {
              Image($r('app.media.speaker'))
                .width(16)
                .height(16)
              Text('请大家帮忙留意这些走失的小可爱，让它们早日回家！')
                .fontSize(14)
                .fontColor('#ff9900')
                .margin({ left: 5 })
            }
            .width('100%')
            .padding({ top: 10, left: 16, right: 16, bottom: 10 })
            .backgroundColor('#fff3cd')

            // 寻宠列表
            if (this.isLoading) {
              Row() {
                LoadingProgress()
                  .width(50)
                  .height(50)
              }
              .width('100%')
              .height(300)
              .justifyContent(FlexAlign.Center)
            } else if (this.missingPets.length === 0) {
              Column() {
                Image($r('app.media.person'))
                  .width(60)
                  .height(60)
                  .opacity(0.3)
                Text('暂无寻宠信息')
                  .fontSize(16)
                  .fontColor('#999')
                  .margin({ top: 10 })
              }
              .width('100%')
              .height(300)
              .justifyContent(FlexAlign.Center)
            } else {
              ForEach(
                this.missingPets.filter((pet: MissingPet) =>
                  this.selectedCity === '全国' || pet.city === this.selectedCity
                ),
                (pet: MissingPet) => {
                  MissingPetCard({ pet: pet })
                    .margin({ top: 10, left: 16, right: 16 })
                    .onClick(() => {
                      router.pushUrl({ 
                        url: 'pages/Home/MissingPetDetail', 
                        params: { id: pet.id } 
                      });
                    })
                },
                (pet: MissingPet) => pet.id.toString()
              )
            }
          }
        }
      }
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)
      .width('100%')
      .layoutWeight(1)
    }
    .height('100%')
    .width('100%')
    .backgroundColor('#f5f5f5')
  }
}

@Component
export struct MissingPetCard {
  pet: MissingPet = {} as MissingPet;

  // 格式化时间显示
  formatTime(timeStr?: string | null): string {
    if (!timeStr || typeof timeStr !== 'string') {
      return '刚刚发布';
    }
    const normalized = timeStr.includes('T') ? timeStr : timeStr.replace(' ', 'T');
    const date = new Date(normalized);
    const now = new Date();
    const diffMs = now.getTime() - date.getTime();
    const diffHours = Math.floor(diffMs / (1000 * 60 * 60));
    const diffDays = Math.floor(diffHours / 24);
    
    if (diffHours < 1) {
      return '刚刚发布';
    } else if (diffHours < 24) {
      return `${diffHours}小时前`;
    } else {
      return `${diffDays}天前`;
    }
  }

  build(): void {
    Column() {
      // 卡片标题和时间
      Row() {
        Text(this.pet.title ?? '')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
        
        Text(this.formatTime(this.pet.lostTime))
          .fontSize(12)
          .fontColor('#999')
      }
      .width('100%')
      .margin({ bottom: 8 })

      Row() {
        // 宠物图片（为空使用占位图）
        Image($r(this.pet.image ?? 'app.media.person'))
          .width(100)
          .height(100)
          .borderRadius(8)
          .objectFit(ImageFit.Cover)
          .margin({ right: 12 })

        // 宠物信息
        Column() {
          // 宠物名称和性别
          Row() {
            Text(this.pet.petName ?? '')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .margin({ right: 6 })
            Image($r((this.pet.gender ?? false) ? 'app.media.Animalgender' : 'app.media.Animalgenderf'))
              .width(16)
              .height(16)
              .margin({ right: 8 })
            Text(`${this.pet.age ?? '-'}岁`)
              .fontSize(14)
              .fontColor('#666')
          }
          .width('100%')
          .margin({ bottom: 6 })

          // 走失地点
          Row() {
            Image($r('app.media.local_fill2'))
              .width(14)
              .height(14)
              .margin({ right: 4 })
            Text(this.pet.lostAddress ?? '')
              .fontSize(12)
              .fontColor('#666')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)
          }
          .width('100%')
          .margin({ bottom: 6 })

          // 描述信息
          Text(this.pet.description ?? '')
            .fontSize(12)
            .fontColor('#666')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
            .margin({ bottom: 8 })

          // 悬赏金额和联系方式
          Row() {
            if ((this.pet.reward ?? 0) > 0) {
              Text(`悬赏￥${this.pet.reward ?? 0}`)
                .fontSize(14)
                .fontColor('#ff6b35')
                .fontWeight(FontWeight.Bold)
                .backgroundColor('#fff3e0')
                .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                .borderRadius(4)
            }
            
            Blank().layoutWeight(1)
            
            Text(`联系：${this.pet.contactName ?? ''}`)
              .fontSize(12)
              .fontColor('#666')
          }
          .width('100%')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
    }
    .width('100%')
    .padding(12)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .shadow({ radius: 2, color: '#10000000', offsetX: 0, offsetY: 1 })
  }
}
