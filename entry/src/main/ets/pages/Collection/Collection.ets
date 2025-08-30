import { router } from '@kit.ArkUI';
import { ApiService, Animal } from '../../common/services/ApiService';
import { UserInfo } from '../../common/models/UserInfo';
import { AnimalCard } from '../Home/Home';

@Entry
@Component
struct Collection {
  @State AnimalColor1: string = '#ff9b9b9b'
  @State AnimalColor2: string = '#ffdbdbdb'
  @State favoriteAnimals: Animal[] = [];
  private apiService: ApiService = ApiService.getInstance();

  async aboutToAppear() {
    await this.refreshFavorites();
  }

  async onPageShow() {
    await this.refreshFavorites();
  }

  async refreshFavorites() {
    // 优先从后端按用户获取收藏列表；失败时回退到本地缓存
    try {
      const user = AppStorage.Get<UserInfo>('userInfo') as UserInfo | undefined;
      if (user && user.id) {
        const favorites = await this.apiService.getFavoritesByUser(Number(user.id));
        if (favorites && favorites.length > 0) {
          const animals: Animal[] = [];
          for (const fav of favorites) {
            const a = await this.apiService.getAnimalById(Number(fav.animalId));
            if (a) {
              animals.push(a);
            }
          }
          this.favoriteAnimals = animals;
          return;
        } else {
          this.favoriteAnimals = [];
          return;
        }
      }
    } catch (e) {
      console.warn('从后端获取用户收藏失败，回退到本地缓存', e);
    }

    const list = AppStorage.Get('favoriteAnimals') as Animal[] || [];
    this.favoriteAnimals = list;
  }

  build() {
    Column(){
     Row(){
       Blank().layoutWeight(1)
       Text('我的收藏')
         .fontSize(20)
       Blank().layoutWeight(1)
     }
     .width("100%")
     .margin({top:10})
     Tabs(){
          TabContent(){
            List(){
              ListItem() {
                Column() {
                  ForEach(
                    (this.favoriteAnimals.length > 0)
                      ? this.favoriteAnimals
                      : [{
                      id: -1,
                      name: '没有收藏',
                      gender: true,
                      age: 0,
                      type: '',
                      description: '',
                      vaccinated: false,
                      dewormed: false,
                      neutered: false,
                      image: '',
                      city: ''
                    } as Animal],
                    (item: Animal) => {
                      if (item.id === -1) {
                        Text(item.name).fontSize(16).fontColor('#999').margin({ top: 30, bottom: 30 })
                      } else {
                        Row() {
                          AnimalCard({ animal: item, AnimalColor1: this.AnimalColor1, AnimalColor2: this.AnimalColor2 })
                        }
                        .onClick(() => {
                          router.pushUrl({ url: 'pages/Home/AnimalDetail', params: { id: item.id } })
                        })
                      }
                    },
                    (item: Animal) => String(item.id)
                  )
                }
                .width('100%')
              }
            }
            .edgeEffect(EdgeEffect.Spring)
            .scrollBar(BarState.Off)
            .height('100%')
          }.tabBar('全部')
          TabContent(){
            List(){
              ListItem() {
                Column() {
                  ForEach(
                    this.favoriteAnimals.filter((item: Animal) => item.type === '狗'),
                    (item: Animal) => {
                      Row() {
                        AnimalCard({ animal: item, AnimalColor1: this.AnimalColor1, AnimalColor2: this.AnimalColor2 })
                      }
                      .onClick(() => {
                        router.pushUrl({ url: 'pages/Home/AnimalDetail', params: { id: item.id } })
                      })
                    },
                    (item: Animal) => String(item.id)
                  )
                }
                .width('100%')
              }
            }
            .edgeEffect(EdgeEffect.Spring)
            .scrollBar(BarState.Off)
            .height('100%')
          }.tabBar('狗狗')
          TabContent(){
            List(){
              ListItem() {
                Column() {
                  ForEach(
                    this.favoriteAnimals.filter((item: Animal) => item.type === '猫'),
                    (item: Animal) => {
                      Row() {
                        AnimalCard({ animal: item, AnimalColor1: this.AnimalColor1, AnimalColor2: this.AnimalColor2 })
                      }
                      .onClick(() => {
                        router.pushUrl({ url: 'pages/Home/AnimalDetail', params: { id: item.id } })
                      })
                    },
                    (item: Animal) => String(item.id)
                  )
                }
                .width('100%')
              }
            }
            .edgeEffect(EdgeEffect.Spring)
            .scrollBar(BarState.Off)
            .height('100%')
          }.tabBar('猫咪')
          TabContent(){
            List(){
              ListItem() {
                Column() {
                  ForEach(
                    this.favoriteAnimals.filter((item: Animal) => item.type === '其他'),
                    (item: Animal) => {
                      Row() {
                        AnimalCard({ animal: item, AnimalColor1: this.AnimalColor1, AnimalColor2: this.AnimalColor2 })
                      }
                      .onClick(() => {
                        router.pushUrl({ url: 'pages/Home/AnimalDetail', params: { id: item.id } })
                      })
                    },
                    (item: Animal) => String(item.id)
                  )
                }
                .width('100%')
              }
            }
            .edgeEffect(EdgeEffect.Spring)
            .scrollBar(BarState.On)
            .height('100%')
          }.tabBar('其他')
     }
      .width('100%')
      .height('90%')
      Row(){
        Column(){
          Image($r('app.media.house'))
            .width(30)
            .height(30)
          Text('首页')
            .fontColor(this.AnimalColor1)
        }
        .onClick(() => {
          router.pushUrl({ url: 'pages/Home/Home' })
        })
        Column(){
          Image($r('app.media.star'))
            .width(30)
            .height(30)
          Text('收藏')
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.Orange)
        }
        Column(){
          Image($r('app.media.persondf'))
            .width(30)
            .height(30)
          Text('我的')
            .fontColor(this.AnimalColor1)
        }
        .onClick(() => {
          router.pushUrl({ url: 'pages/Profile/Individual' })
        })
      }
      .height(60)
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
    }
  }
}