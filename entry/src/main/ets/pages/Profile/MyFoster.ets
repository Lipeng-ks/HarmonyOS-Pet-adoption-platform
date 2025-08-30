import { router } from '@kit.ArkUI';
import prompt from '@system.prompt';
import { ApiService, Animal } from '../../common/services/ApiService';
import { UserService } from '../../common/database/UserService';
import { UserInfo } from '../../common/models/UserInfo';

// 送养状态常量（避免使用 as const/typeof）
const FOSTER_LISTED: string = '上架中'
const FOSTER_OFFLINE: string = '已下架'
const FOSTER_ADOPTED: string = '已领养'

// 为了 ArkTS 兼容，使用简单的 string 类型
type FosterStatusType = string

// 送养发布数据结构
interface FosterPost {
  id: number;
  animal: Animal;
  status: FosterStatusType;
  views: number;
  favorites: number;
  createdAt: string;
  updatedAt?: string;
}

function nowStr(): string {
  const d = new Date();
  const p = (n: number) => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${p(d.getMonth()+1)}-${p(d.getDate())} ${p(d.getHours())}:${p(d.getMinutes())}:${p(d.getSeconds())}`
}

// 本地图片资源占位（沿用现有本地资源命名风格），用于兜底显示
const LOCAL_MEDIA: string[] = [
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
]

@Entry
@Component
struct MyFoster {
  private tabs: string[] = ['全部', FOSTER_LISTED, FOSTER_OFFLINE, FOSTER_ADOPTED]
  @State currentTab: number = 0
  @State allPosts: FosterPost[] = []
  @State posts: FosterPost[] = []
  @State isLoading: boolean = true
  @State AnimalColor2: string = '#ffdbdbdb'
  
  private apiService: ApiService = ApiService.getInstance();
  private userService: UserService = UserService.getInstance();
  

  // 统一胶囊标签
  @Builder TagPill(text: string, bg: ResourceColor, color: ResourceColor): void {
    Row() {
      Text(text)
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .fontColor(color)
    }
    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
    .backgroundColor(bg)
    .borderRadius(10)
  }

  // 统一操作按钮（描边或浅底填充）
  @Builder ActionBtn(label: string, textColor: ResourceColor, bgColor: ResourceColor, borderColor?: ResourceColor, onTap?: () => void): void {
    Button(label)
      .type(ButtonType.Capsule)
      .fontSize(14)
      .fontColor(textColor)
      .backgroundColor(bgColor)
      .height(34)
      .padding({ left: 16, right: 16 })
      .border({ width: 1, color: borderColor ? borderColor : bgColor })
      .shadow({ radius: 6, color: '#00000008', offsetY: 2 })
      .onClick(() => { if (onTap) { onTap() } })
  }

  async aboutToAppear(): Promise<void> {
    // 登录校验
    const isLoggedIn = AppStorage.Get('isLoggedIn') as boolean | undefined;
    if (!isLoggedIn) {
      prompt.showToast({ message: '请先登录后查看我的送养', duration: 1500 });
      try { router.replaceUrl({ url: 'pages/Auth/Login' }) } catch (_) { router.pushUrl({ url: 'pages/Auth/Login' }) }
      return;
    }
    await this.loadMyFosterPosts();
    this.filterByTab(this.currentTab)
  }

  onPageShow(): void {
    // 返回时刷新数据
    this.loadMyFosterPosts();
  }

  // 状态筛选
  filterByTab(index: number): void {
    this.currentTab = index
    const label = this.tabs[index]
    if (label === '全部') {
      this.posts = this.allPosts
    } else if (label === FOSTER_ADOPTED) {
      // 筛选已领养的动物
      this.posts = this.allPosts.filter((p: FosterPost) => p.animal.adopted === true)
    } else {
      this.posts = this.allPosts.filter((p: FosterPost) => p.status === label && p.animal.adopted !== true)
    }
  }

  // 从后端加载当前用户的送养发布（按 animal.userId 过滤）
  async loadMyFosterPosts(): Promise<void> {
    this.isLoading = true;
    try {
      const userInfo = AppStorage.Get('userInfo') as UserInfo | undefined;
      const username = userInfo?.username;
      let userId: number | null = null;

      if (username && username.trim().length > 0) {
        try {
          await this.userService.init();
          const idStr = await this.userService.getUserIdByUsername(username);
          const parsed = idStr ? Number(idStr) : NaN;
          if (!isNaN(parsed)) userId = parsed;
        } catch (e) {
          console.warn('UserService 初始化或获取 userId 失败，回退为显示全部动物');
        }
      }

      const animals: Animal[] = await this.apiService.getAnimals();

      // 过滤出当前用户发布的动物（若无法识别用户，则显示空列表，以避免显示他人发布）
      const mine = (userId != null)
        ? animals.filter(a => {
            try { return Number(a.userId) === userId } catch { return false }
          })
        : [];

      // 兜底处理图片：将前若干条强制替换为本地资源，避免 URL 在 $r 渲染失败
      for (let i = 0; i < Math.min(10, mine.length); i++) {
        try {
          const img = mine[i].image || '';
          if (!img.startsWith || !img.startsWith('app.media.')) {
            mine[i].image = LOCAL_MEDIA[i] || 'app.media.pet';
          }
        } catch (_) {
          mine[i].image = LOCAL_MEDIA[i] || 'app.media.pet';
        }
      }

      // 映射为页面展示所需的 FosterPost
      this.allPosts = mine.map((a: Animal, idx: number) => {
        let status = FOSTER_LISTED;
        if (a.adopted === true) {
          status = FOSTER_ADOPTED;
        } else if (a.listed === false) {
          status = FOSTER_OFFLINE;
        }
        return {
          id: a.id,
          animal: a,
          status: status,
          views: 0,
          favorites: Number(a.favoriteCount || 0),
          createdAt: nowStr(),
          updatedAt: undefined
        } as FosterPost;
      });

      this.filterByTab(this.currentTab);
    } catch (error) {
      console.error(`加载我的送养失败: ${error}`);
      prompt.showToast({ message: '加载我的送养失败', duration: 1500 });
    } finally {
      this.isLoading = false;
    }
  }

  // 上架
  async listPost(id: number): Promise<void> {
    try {
      const res: Animal | null = await this.apiService.updateAnimalListed(id, true);
      if (!res) {
        prompt.showToast({ message: '上架失败，请稍后重试', duration: 1500 });
        return;
      }
      // 同步更新本地列表
      this.allPosts = this.allPosts.map((p: FosterPost) => {
        if (p.id === id) {
          const updatedAnimal: Animal = {
            id: p.animal.id,
            name: p.animal.name,
            gender: p.animal.gender,
            age: p.animal.age,
            type: p.animal.type,
            description: p.animal.description,
            vaccinated: p.animal.vaccinated,
            dewormed: p.animal.dewormed,
            neutered: p.animal.neutered,
            image: p.animal.image,
            city: p.animal.city,
            isFree: p.animal.isFree,
            favoriteCount: p.animal.favoriteCount,
            userId: p.animal.userId,
            adopted: p.animal.adopted,
            listed: true
          } as Animal;
          const updatedPost: FosterPost = {
            id: p.id,
            animal: updatedAnimal,
            status: FOSTER_LISTED,
            views: p.views,
            favorites: p.favorites,
            createdAt: p.createdAt,
            updatedAt: nowStr()
          } as FosterPost;
          return updatedPost;
        }
        return p;
      });
      this.filterByTab(this.currentTab);
      // 强制触发渲染
      this.posts = [...this.posts];
      prompt.showToast({ message: '已上架', duration: 1200 });
    } catch (e) {
      console.error('listPost error:', e);
      prompt.showToast({ message: '上架失败，请检查网络', duration: 1500 });
    }
  }

  // 下架
  async offlinePost(id: number): Promise<void> {
    try {
      const res: Animal | null = await this.apiService.updateAnimalListed(id, false);
      if (!res) {
        prompt.showToast({ message: '下架失败，请稍后重试', duration: 1500 });
        return;
      }
      // 同步更新本地列表
      this.allPosts = this.allPosts.map((p: FosterPost) => {
        if (p.id === id) {
          const updatedAnimal: Animal = {
            id: p.animal.id,
            name: p.animal.name,
            gender: p.animal.gender,
            age: p.animal.age,
            type: p.animal.type,
            description: p.animal.description,
            vaccinated: p.animal.vaccinated,
            dewormed: p.animal.dewormed,
            neutered: p.animal.neutered,
            image: p.animal.image,
            city: p.animal.city,
            isFree: p.animal.isFree,
            favoriteCount: p.animal.favoriteCount,
            userId: p.animal.userId,
            adopted: p.animal.adopted,
            listed: false
          } as Animal;
          const updatedPost: FosterPost = {
            id: p.id,
            animal: updatedAnimal,
            status: FOSTER_OFFLINE,
            views: p.views,
            favorites: p.favorites,
            createdAt: p.createdAt,
            updatedAt: nowStr()
          } as FosterPost;
          return updatedPost;
        }
        return p;
      });
      this.filterByTab(this.currentTab);
      // 强制触发渲染
      this.posts = [...this.posts];
      prompt.showToast({ message: '已下架', duration: 1200 });
    } catch (e) {
      console.error('offlinePost error:', e);
      prompt.showToast({ message: '下架失败，请检查网络', duration: 1500 });
    }
  }

  // 编辑宠物信息
  editPost(id: number): void {
    try {
      router.pushUrl({ 
        url: 'pages/Profile/EditRehomePet',
        params: { 
          id: id,
          mode: 'edit'
        }
      })
    } catch (error) {
      console.error('跳转编辑页面失败:', error)
      prompt.showToast({ message: '跳转失败，请重试', duration: 1500 })
    }
  }

  

  

  // 顶部栏
  @Builder TopBar(): void {
    Stack() {
      // 背景行布局，用于左右按钮定位
      Row() {
        // 左侧返回按钮
        Button() {
          Image($r('app.media.arrow_left'))
            .width(24)
            .height(24)
            .fillColor('#1C1C1E')
        }
        .type(ButtonType.Normal)
        .backgroundColor(Color.Transparent)
        .width(44)
        .height(44)
        .borderRadius(22)
        .onClick(() => router.back())

        Blank()

        // 右侧发布按钮
        Button('发布')
          .type(ButtonType.Normal)
          .fontSize(16)
          .fontColor(Color.White)
          .backgroundColor('#FF6B35')
          .borderRadius(22)
          .padding({ left: 20, right: 20, top: 10, bottom: 10 })
          .onClick(() => {
            router.pushUrl({
              url: 'pages/Profile/EditRehomePet',
              params: { mode: 'create' }
            }).catch((error: Error) => {
              console.error('跳转失败:', error);
              prompt.showToast({ message: '跳转失败，请重试', duration: 1500 });
            });
          })
      }
      .width('100%')
      .height('100%')
      .padding({ left: 16, right: 16 })

      // 绝对居中的标题
      Text('我的送养')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1C1C1E')
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height(56)
    .backgroundColor(Color.White)
    .border({ width: { bottom: 0.5 }, color: '#E5E5EA' })
    .alignContent(Alignment.Center)
  }

  // 筛选 Tabs
  @Builder TabsBar(): void {
    Tabs() {
      TabContent() { this.ListBuilder() }.tabBar('全部')
      TabContent() { this.ListBuilder() }.tabBar('上架中')
      TabContent() { this.ListBuilder() }.tabBar('已下架')
      TabContent() { this.ListBuilder() }.tabBar('已领养')
    }
    .onChange((i: number) => this.filterByTab(i))
    .barMode(BarMode.Fixed)
    .barHeight(36)
    .width('100%')
    .layoutWeight(1)
  }

  // 列表项卡片
  @Builder FosterCard(item: FosterPost): void {
    Column() {
      Row() {
        Row() {
          Text(`收藏 ${item.favorites}`)
            .fontSize(12)
            .fontColor('#8E8E93')
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.End)

      // 内容行
      Row() {
        Image($r(item.animal.image || 'app.media.pet'))
          .width(92)
          .height(92)
          .borderRadius(18)
          .objectFit(ImageFit.Cover)
          .backgroundColor('#F2F2F7')
          .border({ width: 1, color: '#ECECED' })

        Column() {
          Row() {
            Text(item.animal.name)
              .fontSize(17)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1C1C1E')
          }
          .margin({ bottom: 6 })

          Row() {
            Text(`${item.animal.age}岁`)
              .fontSize(14)
              .fontColor('#8E8E93')
            Text('·').fontSize(14).fontColor('#8E8E93').margin({ left: 4, right: 4 })
            Text(item.animal.gender ? '雄性' : '雌性')
              .fontSize(14)
              .fontColor('#8E8E93')
          }
          .margin({ bottom: 6 })

          Row() {
            Text(item.animal.city)
              .fontSize(13)
              .fontColor('#8E8E93')
          }

          // 健康标签（统一胶囊样式）
          Row() {
            Row() {
              Text(item.animal.neutered ? '已绝育' : '未绝育')
                .fontSize(12)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Bold)
            }
            .borderRadius(5)
            .padding(5)
            .backgroundColor(item.animal.neutered ? Color.Orange : this.AnimalColor2)
            Row() {
              Text(item.animal.vaccinated ? '已免疫' : '未免疫')
                .fontSize(12)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Bold)
            }
            .margin({ left: 5 })
            .borderRadius(5)
            .padding(5)
            .backgroundColor(item.animal.vaccinated ? Color.Orange : this.AnimalColor2)
            Row() {
              Text(item.animal.dewormed ? '已驱虫' : '未驱虫')
                .fontSize(12)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Bold)
            }
            .margin({ left: 5 })
            .borderRadius(5)
            .padding(5)
            .backgroundColor(item.animal.dewormed ? Color.Orange : this.AnimalColor2)

          }
          .margin({ top: 6 })
        }
        .layoutWeight(1)
        .margin({ left: 14 })
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
      .margin({ top: 10, bottom: 8 })

      // 分割线
      Row()
        .width('100%')
        .height(0.5)
        .backgroundColor('#EFEFF4')
        .margin({ bottom: 12 })

      // 操作区（左：详情链接；右：编辑 + 状态按钮）
      Row() {
        // 左侧：详情链接式按钮（统一主题色）
        this.ActionBtn('详情页面', '#0A84FF', '#0A84FF15', '#BBD9FF', () => {
          router.pushUrl({ url: 'pages/Home/AnimalDetail', params: { id: item.animal?.id ?? item.id } })
        })

        // 右侧：按钮组（固定在右下角）
        Row() {
          // 已被领养则不显示编辑与上/下架按钮
          if (!item.animal.adopted) {
            // 编辑（统一主题色）
            this.ActionBtn('编辑', '#0A84FF', '#0A84FF15', '#BBD9FF', () => this.editPost(item.id))
            // 根据状态显示上/下架（统一主题色）
            if (item.status === FOSTER_LISTED) {
              this.ActionBtn('下架', '#0A84FF', '#0A84FF15', '#BBD9FF', () => this.offlinePost(item.id))
            } else if (item.status === FOSTER_OFFLINE) {
              this.ActionBtn('上架', '#0A84FF', '#0A84FF15', '#BBD9FF', () => this.listPost(item.id))
            }
          } else {
            // 右下角显示“已被领养”徽标（胶囊标签样式）
            this.TagPill('已被领养', '#FFEDE5', '#FF3B30')
          }
        }
        .justifyContent(FlexAlign.End)
        .alignItems(VerticalAlign.Bottom)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(18)
    .padding(16)
    .margin({ bottom: 16 })
    .shadow({ radius: 10, color: '#00000010', offsetY: 6 })
  }

  // 列表
  @Builder ListBuilder(): void {
    List() {
      // 数据项
      if (this.isLoading) {
        ListItem() {
          Row() {
            LoadingProgress().width(40).height(40)
          }
          .width('100%')
          .height(200)
          .justifyContent(FlexAlign.Center)
        }
      } else {
        ForEach(this.posts, (item: FosterPost) => {
          ListItem() { this.FosterCard(item) }
        }, (item: FosterPost) => `${item.id}-${item.status}`)
      }

      // 空状态
      if (!this.isLoading && this.posts.length === 0) {
        ListItem() {
          Column() {
            Text(this.currentTab === 3 ? '🎉' : '📦')
              .fontSize(60)
              .margin({ top: 60 })
            Text(this.currentTab === 3 ? '暂无已领养的宠物' : '暂无送养发布')
              .fontSize(18)
              .fontColor('#8E8E93')
              .fontWeight(FontWeight.Medium)
              .margin({ top: 20 })
            Text(this.currentTab === 3 ? '您发布的宠物还未被领养' : '点击上方不同状态标签查看')
              .fontSize(14)
              .fontColor('#C7C7CC')
              .textAlign(TextAlign.Center)
              .lineHeight(20)
              .margin({ top: 8 })
          }
          .width('100%')
          .height(400)
          .justifyContent(FlexAlign.Center)
        }
      }
    }
    .edgeEffect(EdgeEffect.Spring)
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .scrollBar(BarState.Off)
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
