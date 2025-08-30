import { router } from '@kit.ArkUI';
import { ApiService, Animal } from '../../common/services/ApiService';
import prompt from '@system.prompt';
import { UserInfo } from '../../common/models/UserInfo';

interface AnimalDetailParams { id?: number }

@Entry
@Component
struct AnimalDetailPage {
  private animal: Animal = {
    id: 0,
    name: '',
    gender: false,
    age: 0,
    type: '',
    description: '',
    vaccinated: false,
    dewormed: false,
    neutered: false,
    image: '',
    city: '',
    isFree:false
  };
  
  @State isLoading: boolean = false;
  @State refreshFlag: number = 0;
  @State isFavorited: boolean = false;
  @State favoriteCount: number = 0;
  @State private isAdopted: boolean = false;
  @State currentUserCheckinCount: number = 0;
  @State currentUsername: string = '';
  @State hasRealNameAuth: boolean = false; // 是否已完成实名认证
  
  private apiService: ApiService = ApiService.getInstance();

  async aboutToAppear() {
    let params = router.getParams() as AnimalDetailParams;
    if (params && params.id) {
      await this.loadAnimalFromDb(Number(params.id));
    }

    // 首先读取本地缓存以快速展示状态
    try {
      let list: Animal[] = AppStorage.Get('favoriteAnimals') as Animal[] || [];
      this.isFavorited = list.find((item: Animal) => item.id === this.animal.id) !== undefined;

      let adoptedList: Animal[] = AppStorage.Get('adoptedAnimals') as Animal[] || [];
      this.isAdopted = adoptedList.find((item: Animal) => item.id === this.animal.id) !== undefined;
    } catch (e) {
      console.warn('读取本地收藏/领养状态失败', e);
    }

    this.refreshFlag = 0;
    // 如果用户已登录，尝试从后端获取最新的打卡汇总与收藏状态
    try {
      const user = AppStorage.Get<UserInfo>('userInfo') as UserInfo | undefined;
      if (user && user.username) {
        this.currentUsername = user.username;
        this.loadUserCheckin();
        // 查询实名认证状态
        try {
          if (user.id) {
            const rn = await this.apiService.getUserRealNameByUserId(Number(user.id));
            this.hasRealNameAuth = !!rn;
          }
        } catch (e) {
          console.warn('获取实名认证状态失败', e);
          this.hasRealNameAuth = false;
        }
        // 如果后端可用且 animal 已加载，检查收藏状态
        if (user.id && this.animal && this.animal.id) {
          try {
            const fav = await this.apiService.isFavorited(Number(user.id), Number(this.animal.id));
            this.isFavorited = !!fav;
          } catch (err) {
            console.warn('检查收藏状态失败', err);
          }
        }
      }
    } catch (e) {
      console.warn('获取用户信息失败', e);
    }
  }

  async onPageShow() {
    // 页面回退或切换回本页时刷新数据
    let params = router.getParams() as AnimalDetailParams;
    if (params && params.id) {
      await this.loadAnimalFromDb(Number(params.id));
    }
    try {
      let list: Animal[] = AppStorage.Get('favoriteAnimals') as Animal[] || [];
      this.isFavorited = list.find((item: Animal) => item.id === this.animal.id) !== undefined;

      let adoptedList: Animal[] = AppStorage.Get('adoptedAnimals') as Animal[] || [];
      this.isAdopted = adoptedList.find((item: Animal) => item.id === this.animal.id) !== undefined;
    } catch (e) {
      console.warn('读取本地收藏/领养状态失败', e);
    }

    this.refreshFlag++;
    // 页面显示时再次请求用户打卡汇总（以防在其他页面打卡）并刷新收藏状态
    if (this.currentUsername) {
      await this.loadUserCheckin();
      try {
        const user = AppStorage.Get<UserInfo>('userInfo') as UserInfo | undefined;
        if (user && user.id && this.animal && this.animal.id) {
          const fav = await this.apiService.isFavorited(Number(user.id), Number(this.animal.id));
          this.isFavorited = !!fav;
        }
      } catch (err) {
        console.warn('刷新收藏状态失败', err);
      }
    }
  }
  
  // 从数据库加载动物详情
  async loadAnimalFromDb(id: number) {
    this.isLoading = true;
    try {
      const animal = await this.apiService.getAnimalById(id);
      if (animal) {
        // 如果 image 为空或不是本地资源，使用本地预置资源（避免远程 URL 导致显示空白）
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

        if (!animal.image || !animal.image.startsWith || !animal.image.startsWith('app.media.')) {
          // 为前10条或有 id 的动物分配本地资源，避免远程图片
          if (animal.id && animal.id >= 1) {
            const idx = Math.min(Math.max(Math.floor(animal.id) - 1, 0), localResources.length - 1);
            animal.image = localResources[idx] || 'app.media.person';
          } else {
            animal.image = localResources[0];
          }
        }

        this.animal = animal;
        // 初始化收藏数状态
        this.favoriteCount = Number(animal.favoriteCount ?? 0);
        // 加载完成后根据本地存储更新收藏和领养状态，确保从收藏页面跳转过来时状态正确
        let favList: Animal[] = AppStorage.Get('favoriteAnimals') as Animal[] || [];
        this.isFavorited = favList.find((item: Animal) => item.id === this.animal.id) !== undefined;
        let adoptedList: Animal[] = AppStorage.Get('adoptedAnimals') as Animal[] || [];
        this.isAdopted = adoptedList.find((item: Animal) => item.id === this.animal.id) !== undefined;
        console.info(`成功加载ID为${id}的动物数据`);
      } else {
        console.error(`未找到ID为${id}的动物数据`);
        prompt.showToast({
          message: '未找到该宠物信息',
          duration: 2000
        });
        router.back();
      }
    } catch (error) {
      console.error(`加载动物详情失败: ${error}`);
      prompt.showToast({
        message: '加载宠物信息失败',
        duration: 2000
      });
    } finally {
      this.isLoading = false;
    }
  }

  async loadUserCheckin() {
    try {
      const summary = await this.apiService.getUserCheckinSummary(this.currentUsername);
      if (summary && summary.checkinCount !== undefined) {
        this.currentUserCheckinCount = Number(summary.checkinCount) || 0;
      }
    } catch (e) {
      console.warn('加载用户打卡汇总失败', e);
    }
  }

  // 当前用户是否为该动物的发布者
  private isOwner(): boolean {
    try {
      const user = AppStorage.Get<UserInfo>('userInfo') as UserInfo | undefined;
      if (!user || !user.id || !this.animal || this.animal.userId === undefined) return false;
      return Number(user.id) === Number(this.animal.userId);
    } catch (_) {
      return false;
    }
  }

  build() {
    Column() {
      Row() { Text('') }.opacity(0).id('refresh-' + this.refreshFlag)
      Column() {
        // 顶部导航
        Row() {
          Image($r('app.media.arrow_left')).width(24).height(24).onClick(() => router.back())
            .margin({left:15})
          Text(this.animal.name)
            .fontSize(20)
            .margin({left:136})
        }
        .margin({ top: 10, left: 10, right: 10 })
        .width('100%')
        
        if (this.isLoading) {
          Row() {
            LoadingProgress()
              .width(50)
              .height(50)
          }
          .width('100%')
          .height('80%')
          .justifyContent(FlexAlign.Center)
        } else {
          // 宠物大图和轮播
          List(){
            ListItem(){
              Column(){
                Stack() {
                  Image($r(this.animal.image))
                    .width('100%')
                    .height(260)
                    .borderRadius(16)
                    .objectFit(ImageFit.Cover)
                }
                .margin({ top: 10, bottom: 10 })
                .width('100%')

                // 宠物基本信息
                Row() {
                  Text(this.animal.name)
                    .fontSize(20)
                    .fontWeight(FontWeight.Bold)
                  Image($r(this.animal.gender ? 'app.media.Animalgender' : 'app.media.Animalgenderf'))
                    .width(18)
                    .height(18)
                    .margin({ left: 6, right: 6 })
                  Text(this.animal.age + '岁').fontSize(16)
                  Blank().layoutWeight(1)
                }
                .margin({ left: 16, right: 16, top: 6 })

                // 更新时间、城市、收藏数
                Row() {
                  Text('16分钟前更新').fontSize(12).fontColor('#888')
                  Text(' · ').fontSize(12).fontColor('#888')
                  Image($r('app.media.local_fill2')).width(14).height(14).margin({ left: 2 })
                  Text(this.animal.city).fontSize(12).fontColor('#888')
                  // Text(' · ').fontSize(12).fontColor('#888')
                  // Image($r('app.media.yj')).width(14).height(16).margin({ left: 2 })
                  // Text('2').fontSize(12).fontColor('#888').margin({left:2})
                  Blank().layoutWeight(1)
                  Text((String(this.favoriteCount) + '人收藏')).fontSize(12).fontColor('#888')
                }
                .margin({ left: 16, right: 16, top: 6 })

                // 宠物描述
                Text(this.animal.description)
                  .fontSize(14)
                  .fontColor('#333')
                  .margin({ left: 16, right: 16, top: 40 })

                // 状态标签
                Row() {
                  Text(this.animal.neutered ? '已绝育' : '未绝育')
                    .fontSize(12)
                    .fontColor(this.animal.neutered ? Color.White : Color.Red)
                    .backgroundColor(this.animal.neutered ? Color.Orange : '#ffe0e0')
                    .borderRadius(8)
                    .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                    .margin({right:20})
                  Text(this.animal.vaccinated ? '已免疫' : '未免疫')
                    .fontSize(12)
                    .fontColor(this.animal.vaccinated ? Color.White : Color.Blue)
                    .backgroundColor(this.animal.vaccinated ? Color.Orange : '#e0f0ff')
                    .borderRadius(8)
                    .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                    .margin({right:10})
                  Text(this.animal.dewormed ? '已驱虫' : '未驱虫')
                    .fontSize(12)
                    .fontColor(this.animal.dewormed ? Color.White : '#A259FF')
                    .backgroundColor(this.animal.dewormed ? Color.Orange : '#f0e0ff')
                    .borderRadius(8)
                    .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                    .margin({left:10})
                  Text('免费')
                    .fontSize(12)
                    .fontColor(this.animal.isFree ? Color.White : '#A259FF')
                    .backgroundColor(this.animal.isFree ? Color.Orange : '#f0e0ff')
                    .borderRadius(8)
                    .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                    .margin({left:20})
                }
                .width('auto')
                .margin({ top: 40 })

                // 领养须知
                Column() {
                  Text('领养后需打卡2周').fontSize(14).fontColor(Color.Orange).margin({top:5})
                  Row() {
                    Column({ space: 5 }) {
                      Text('仅限同城').fontSize(12)
                      Text('送货到家').fontSize(12)
                      Text('打卡更新').fontSize(12)
                      Text('有稳定收入').fontSize(12)
                    }
                    .margin({ right: 24 })
                    Column({ space: 5 }) {
                      Text('按时打疫苗').fontSize(12)
                      Text('科学养宠，办理狗证').fontSize(12)
                      Text('签领养协议').fontSize(12)
                      Text('不得遗弃、转让、贩卖').fontSize(12)
                    }
                  }
                  .margin({ top: 15,bottom: 5 })
                }
                .width('90%')
                .margin({ left: 16, right: 16, top: 20, bottom: 12 })
                .backgroundColor('#f8f8f8')
                .borderRadius(12)
              }
            }
          }
          .height('90%')

          // 底部操作栏
          Row() {
            Row() {
              Image($r(this.isFavorited ? 'app.media.star' : 'app.media.stardf')).width(20).height(20)
              // 为了避免未收藏时布局抖动，预留固定宽度给文字区域
              Text(this.isFavorited ? '已收藏' : '收藏').fontSize(14)
                .margin({left:5,top:2})
                .width(42)
            }
            .onClick(async () => {
              const user = AppStorage.Get<UserInfo>('userInfo') as UserInfo | undefined;
              if (!user || !user.id) {
                prompt.showToast({ message: '请先登录后再收藏', duration: 1500 });
                router.pushUrl({ url: 'pages/Auth/Login' });
                return;
              }

              const userId = Number(user.id);
              const animalId = Number(this.animal.id);

              try {
                if (!this.isFavorited) {
                  const added = await this.apiService.addFavorite(userId, animalId);
                  if (added) {
                    // 更新本地缓存
                    let list: Animal[] = AppStorage.Get('favoriteAnimals') as Animal[] || [];
                    list.push(this.animal);
                    AppStorage.SetOrCreate('favoriteAnimals', list);
                    this.isFavorited = true;
                    // 仅更新数据，不刷新页面，使用状态变量触发UI更新
                    this.favoriteCount = this.favoriteCount + 1;
                    // 同步到本地对象以保持一致（非必须）
                    this.animal.favoriteCount = this.favoriteCount;
                    
                    prompt.showToast({ message: '已收藏', duration: 1500 });
                  } else {
                    prompt.showToast({ message: '收藏失败', duration: 1500 });
                  }
                } else {
                  const ok = await this.apiService.removeFavorite(userId, animalId);
                  if (ok) {
                    let list: Animal[] = AppStorage.Get('favoriteAnimals') as Animal[] || [];
                    const idx = list.findIndex((item: Animal) => item.id === this.animal.id);
                    if (idx !== -1) list.splice(idx, 1);
                    AppStorage.SetOrCreate('favoriteAnimals', list);
                    this.isFavorited = false;
                    // 仅更新数据，不刷新页面，使用状态变量触发UI更新
                    this.favoriteCount = Math.max(0, this.favoriteCount - 1);
                    // 同步到本地对象以保持一致（非必须）
                    this.animal.favoriteCount = this.favoriteCount;
                    
                    prompt.showToast({ message: '已取消收藏', duration: 1500 });
                  } else {
                    prompt.showToast({ message: '取消收藏失败', duration: 1500 });
                  }
                }
              } catch (err) {
                console.error('收藏操作失败', err);
                prompt.showToast({ message: '网络错误，操作失败', duration: 1500 });
              }

              // 不进行整页刷新
            })
            .margin({ right: 12,left: 10 })

            Row() {
              Image($r('app.media.share')).width(20).height(20)
              Text('分享').fontSize(14)
                .margin({left:5,top:2})
            }
            .onClick(() => {
              // 分享逻辑
            })
            .margin({ right: 12 })

            Button('申请领养')
              .type(ButtonType.Capsule)
              .backgroundColor((this.isAdopted || this.currentUserCheckinCount < 14 || this.isOwner() || !this.hasRealNameAuth) ? '#bbb' : Color.Orange)
              .fontColor(Color.White)
              .fontSize(16)
              .width(120)
              .height(40)
              .onClick(() => {
                if (this.isAdopted) return;
                if (this.isOwner()) {
                  prompt.showToast({ message: '不能申请自己上架的宠物', duration: 2000 });
                  return;
                }
                if (this.currentUserCheckinCount < 14) {
                  prompt.showToast({ message: '需连续打卡 14 天才能申请领养', duration: 2000 });
                  return;
                }
                if (!this.hasRealNameAuth) {
                  prompt.showToast({ message: '需完成实名认证后才能申请领养', duration: 2000 });
                  router.pushUrl({ url: 'pages/Profile/RealNameAuth' });
                  return;
                }
                router.pushUrl({ url: 'pages/Home/AdoptApply', params: { id: this.animal.id } });
              })
              .margin({left:100})
          }
          .margin({ left: 16, right: 16, top: 10, bottom: 10 })
          .width('100%')
        }
      }
    }
    .width('100%')
  }
} 