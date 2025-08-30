import { router } from '@kit.ArkUI';
import prompt from '@system.prompt';
import { ApiService, Animal } from '../../common/services/ApiService';

interface CityParams {
  city?: string;
}

interface SwiperAnimal {
  id: number;
  image: string;
  name: string;
}

@Entry
@Component
struct Home {
  @State selectedCity: string = '全国';
  @State AnimalColor1: string = '#ff9b9b9b'
  @State AnimalColor2: string = '#ffdbdbdb'
  @State AnimalImage: string = '';
  @State Animalname: string = '';
  @State Animalgender: boolean = false;
  @State Animalgenderimage: string = '';
  @State Animalage: string = '';
  @State Animaldescription: string = '';
  @State Animaldvaccinated: boolean = false;
  @State Animaldewormed: boolean = false;
  @State Animalneutered: boolean = false;
  @State animalImages: SwiperAnimal[] = [];
  @State animals: Animal[] = [];
  @State isLoading: boolean = true;
  
  private apiService: ApiService = ApiService.getInstance();

  aboutToAppear(): void {
    let params = router.getParams() as CityParams;
    if (params && params.city) {
      this.selectedCity = params.city;
    }
    
    this.loadAnimalsFromApi();
  }

  // 页面每次显示（包括从其他页面返回）时刷新一次
  onPageShow(): void {
    this.loadAnimalsFromApi();
  }

  async loadAnimalsFromApi(): Promise<void> {
    this.isLoading = true;
    try {
      // 仅获取上架中的动物（后端过滤）
      const fetched = await this.apiService.getAnimals(undefined, true);
      // 保险起见，再次在前端过滤一次，且排除已被领养的动物
      const animals = (fetched || []).filter((a: Animal) => a && a.listed === true && a.adopted !== true);
      this.animals = animals;

      // 如果后端返回的是远程 URL 或空字段，强制为前10条使用本地资源，避免远程图片导致空白
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
      for (let i = 0; i < Math.min(10, animals.length); i++) {
        try {
          const img = animals[i].image || '';
          if (!img.startsWith || !img.startsWith('app.media.')) {
            animals[i].image = localResources[i] || 'app.media.person';
          }
        } catch (e) {
          animals[i].image = localResources[i] || 'app.media.person';
        }
      }

      if (animals.length > 0) {
        const randomAnimals = this.getRandomAnimals(animals, 3);
        this.animalImages = randomAnimals.map(animal => {
          return {
            id: animal.id,
            image: animal.image,
            name: animal.name
          } as SwiperAnimal
        });
      }
      
      console.info(`成功加载 ${animals.length} 条动物数据`);
    } catch (error) {
      console.error(`加载动物数据失败: ${error}`);
      prompt.showToast({
        message: '加载数据失败，请确保API服务器已启动',
        duration: 3000
      });
    } finally {
      this.isLoading = false;
    }
  }
  
  // 从数组中随机选择指定数量的元素
  getRandomAnimals(animals: Animal[], count: number): Animal[] {
    if (animals.length <= count) {
      return animals;
    }
    
    const result: Animal[] = [];
    const animalsCopy = [...animals];
    
    for (let i = 0; i < count; i++) {
      const randomIndex = Math.floor(Math.random() * animalsCopy.length);
      result.push(animalsCopy[randomIndex]);
      animalsCopy.splice(randomIndex, 1);
    }
    
    return result;
  }

  build(): void {
    Column() {
      Stack(){
          Row(){
            Row() {
            // 定位图标
              Image($r('app.media.local_fill'))
                .width(24)
                .height(24)
              // 文字
              Text(this.selectedCity)
                .fontSize(15)
                .fontColor('#ff696969')
              // 下拉箭头
                Image($r('app.media.triangleshape_fill'))
                  .width(13)
                  .height(13)
                  .margin({left:3})
              }
            .onClick(() => {
              router.pushUrl({ url: 'pages/Home/CitySelect' });
            })
            .padding({ top: 16, left: 16, right: 16, bottom: 8 })
            // 新增居中标题
            Row() {
              Text('宠物领养平台')
                .fontSize(18)
            }
            .margin({top:5,left:40})
            .width('100%')
          }
        }
        List(){
          ListItem() {
            Column() {
              Row() {
                MarqueeText()
              }
              .width('100%')

              Swiper() {
                ForEach(this.animalImages, (item: SwiperAnimal, idx: number) => {
                  Stack() {
                    Image($r(item.image))
                      .width('100%')
                      .height(150)
                      .onClick(() => {
                        if (item.id !== -1) {
                          router.pushUrl({ url: 'pages/Home/AnimalDetail', params: { id: item.id } });
                        }
                      })
                    Row() {
                      Text(item.name)
                        .fontSize(20)
                        .fontColor(Color.White)
                        .fontWeight(FontWeight.Bold)
                        .margin({ left: 10, bottom: 8 })
                    }
                    .position({ x: 10, y: 115 })
                    .width('100%')
                  }
                }, (item: SwiperAnimal) => item.image)
              }
              .width('90%')
              .autoPlay(true)
              .interval(2000)
              .borderRadius(40)

              Row() {
                Stack() {
                  Image($r('app.media.sdkhfsdf'))
                    .width("95%")
                    .height(70)
                    .borderRadius(20)
                    .opacity(0.7)
                    .zIndex(0)
                  Text('寻宠')
                    .fontSize(17)
                    .fontColor(Color.White)
                    .zIndex(1)
                    .position({ x: 19, y: 10 })
                    .fontWeight(FontWeight.Bold)
                  Text('我好想你！')
                    .fontSize(14)
                    .fontColor(Color.White)
                    .zIndex(1)
                    .position({ x: 19, y: 40 })
                }
              }
              .justifyContent(FlexAlign.Center)
              .margin({ top: 5 })
              .width("95%")
              .height(70)
              .onClick(() => {
                router.pushUrl({ url: 'pages/Home/MissingPets' })
              })

              Tabs() {
                TabContent() {
                  Column() {
                    if (this.isLoading) {
                      Row() {
                        LoadingProgress()
                          .width(50)
                          .height(50)
                      }
                      .width('100%')
                      .justifyContent(FlexAlign.Center)
                      .margin({top: 10})
                    } else {
                      ForEach(
                        this.animals.filter((item: Animal) =>
                        this.selectedCity === '全国' || item.city === this.selectedCity
                        ),
                        (item: Animal) => {
                          Row() {
                            AnimalCard({ animal: item, AnimalColor1: this.AnimalColor1, AnimalColor2: this.AnimalColor2 })
                          }
                          .onClick(() => {
                            router.pushUrl({ url: 'pages/Home/AnimalDetail', params: { id: item.id } })
                          })
                        },
                        (item: Animal) => item.id.toString()
                      )
                    }
                  }
                }.tabBar('全部')

                TabContent() {
                  Column() {
                    ForEach(
                      this.animals.filter((item: Animal) =>
                      (this.selectedCity === '全国' || item.city === this.selectedCity) && item.type === '狗'),
                      (item: Animal) => {
                        Row() {
                          AnimalCard({ animal: item, AnimalColor1: this.AnimalColor1, AnimalColor2: this.AnimalColor2 })
                        }
                        .onClick(() => {
                          router.pushUrl({ url: 'pages/Home/AnimalDetail', params: { id: item.id } })
                        })
                      }, (item: Animal) => String(item.id))
                  }
                }.tabBar('狗狗')

                TabContent() {
                  Column() {
                    ForEach(
                      this.animals.filter((item: Animal) =>
                      (this.selectedCity === '全国' || item.city === this.selectedCity) && item.type === '猫'),
                      (item: Animal) => {
                        Row() {
                          AnimalCard({ animal: item, AnimalColor1: this.AnimalColor1, AnimalColor2: this.AnimalColor2 })
                        }
                        .onClick(() => {
                          router.pushUrl({ url: 'pages/Home/AnimalDetail', params: { id: item.id } })
                        })
                      }, (item: Animal) => String(item.id))
                  }
                }.tabBar('猫咪')

                TabContent() {
                  Column() {
                    ForEach(
                      this.animals.filter((item: Animal) =>
                      (this.selectedCity === '全国' || item.city === this.selectedCity) && item.type === '其他'),
                      (item: Animal) => {
                        Row() {
                          AnimalCard({ animal: item, AnimalColor1: this.AnimalColor1, AnimalColor2: this.AnimalColor2 })
                        }
                        .onClick(() => {
                          router.pushUrl({ url: 'pages/Home/AnimalDetail', params: { id: item.id } })
                        })
                      }, (item: Animal) => String(item.id))
                  }
                }.tabBar('其他')
              }
              .height('auto')
            }
          }
        }
        .edgeEffect(EdgeEffect.Spring)
        .scrollBar(BarState.Off)
        .width('100%')
        .height('88%')
      Row(){
        Column(){
          Image($r('app.media.house_fdlfg'))
            .width(30)
            .height(30)
          Text('首页')
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.Orange)
        }
        Column(){
          Image($r('app.media.stardf'))
            .width(30)
            .height(30)
          Text('收藏')
            .fontColor(this.AnimalColor1)
        }
        .onClick(() => {
          router.pushUrl({ url: 'pages/Collection/Collection'})
        })
        Column(){
          Image($r('app.media.persondf'))
            .width(30)
            .height(30)
          Text('我的')
            .fontColor(this.AnimalColor1)
        }
        .onClick(() => {
          router.pushUrl({ url: 'pages/Profile/Individual'})
        })
      }
      .height(60)
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
      }
      .height('100%')
      .width('100%')
  }
}
@Component
struct MarqueeText {
  @State marqueeOffset: number = 0;
  marqueeText: string = '已经有 2164521 位小可爱被领养';
  containerWidth: number = 400; // 跑马灯显示区域宽度
  scrollLength: number = 360;   // 跑马灯滚动距离，根据内容微调

  aboutToAppear(): void {
    this.marqueeOffset = 0;
  }

  build(): void {
    Stack() {
      Row() {
        Image($r('app.media.speaker'))
          .width(16)
          .height(16)
        Text(this.marqueeText)
          .fontSize(16)
          .fontColor('#FF9900')
      }
      .position({ x: this.marqueeOffset, y: 0 })
      .width('auto')
    }
    .width('100%')
    .width(this.containerWidth)
    .height(24)
    .clip(true)
    .onAppear(() => {
      this.startMarquee();
    })
  }

  startMarquee(): void {
    this.marqueeOffset = this.containerWidth;
    animateTo({ duration: 8000, curve: Curve.Linear }, () => {
      this.marqueeOffset = -this.scrollLength;
    });
    setTimeout(() => {
      this.startMarquee();
    }, 8000);
  }
}

@Component
export struct AnimalCard {
  animal: Animal = {} as Animal;
  AnimalColor1: string = '';
  AnimalColor2: string = '';

  build(): void {
    Row() {
      Image($r(this.animal.image))
        .height(110)
        .width(110)
        .borderRadius(20)
      Column() {
        Row() {
          Text(this.animal.name)
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
          Image($r(this.animal.gender ? 'app.media.Animalgender' : 'app.media.Animalgenderf'))
            .height(15)
            .width(15)
            .margin({ left: 5 })
          Column() {} // 分隔线
            .width(1)
            .height(16)
            .backgroundColor('#ff929292')
            .margin({ left: 5 })
          Row() {
            Text(this.animal.age + '岁')
              .fontSize(12)
              .margin({ left: 5 })
          }
        }
        .width('60%')
        Text(this.animal.description)
          .fontSize(12)
          .fontColor(this.AnimalColor1)
          .width(220)
          .height(65)
          .margin({ left: 10 })
        Row() {
          Row() {
            Text(this.animal.neutered ? '已绝育' : '未绝育')
              .fontSize(12)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
          }
          .borderRadius(5)
          .padding(5)
          .backgroundColor(this.animal.neutered ? Color.Orange : this.AnimalColor2)
          Row() {
            Text(this.animal.vaccinated ? '已免疫' : '未免疫')
              .fontSize(12)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
          }
          .margin({ left: 5 })
          .borderRadius(5)
          .padding(5)
          .backgroundColor(this.animal.vaccinated ? Color.Orange : this.AnimalColor2)
          Row() {
            Text(this.animal.dewormed ? '已驱虫' : '未驱虫')
              .fontSize(12)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
          }
          .margin({ left: 5 })
          .borderRadius(5)
          .padding(5)
          .backgroundColor(this.animal.dewormed ? Color.Orange : this.AnimalColor2)
        }
        .width('60%')
      }
    }
    .margin({ bottom: 10 })
    .width('90%')
  }
}