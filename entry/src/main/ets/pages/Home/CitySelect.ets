import { router } from '@kit.ArkUI';
import { ApiService } from '../../common/services/ApiService';
import { GlobalState } from '../../common/utils/GlobalState';
import { City } from '../../common/data/cityData';

interface CityGroup {
  letter: string;
  cities: City[];
}

// Define interface for router parameters
interface CitySelectParams {
  fromPage?: string;
  animalId?: number;
}

@Entry
@Component
struct CitySelect {

  @State searchText: string = '';
  @State filteredCities: City[] = [];
  @State cities: City[] = [];
  @State isLoading: boolean = true;
  
  // 存储来源页面信息和必要参数
  @State fromPage: string = '';
  @State animalId: number = 0;
  
  private apiService: ApiService = ApiService.getInstance();

  aboutToAppear() {
    // 获取路由参数
    const params = router.getParams() as CitySelectParams;
    if (params) {
      if (params.fromPage) {
        this.fromPage = params.fromPage;
      }
      if (params.animalId) {
        this.animalId = params.animalId;
      }
    }
    this.loadCitiesFromApi();
  }
  
  async loadCitiesFromApi() {
    this.isLoading = true;
    try {
      const cities = await this.apiService.getCities();
      this.cities = this.ensureNationFirst(cities);
      this.filteredCities = this.cities;
      console.info(`成功加载${cities.length}条城市数据`);
    } catch (error) {
      console.error(`加载城市数据失败: ${error}`);
    } finally {
      this.isLoading = false;
    }
  }

  get groupedCities(): CityGroup[] {
    // 按首字母分组排序
    let groups: Record<string, City[]> = {};
    this.cities.forEach((city: City) => {
      const letter = city.pinyin[0].toUpperCase();
      if (!groups[letter]) groups[letter] = [];
      groups[letter].push(city);
    });
    // 排序分组
    return Object.keys(groups).sort().map((letter: string): CityGroup => ({
      letter: letter,
      cities: groups[letter].sort((a: City, b: City) => a.pinyin.localeCompare(b.pinyin))
    }));
  }

  // 确保“全国”固定在列表第一位
  private ensureNationFirst(list: City[]): City[] {
    if (!list || list.length === 0) return list;
    const idx = list.findIndex((c: City) => c.name === '全国');
    if (idx <= 0) return list; // 已在首位或不存在
    const copy = list.slice();
    const nation = copy.splice(idx, 1)[0];
    copy.unshift(nation);
    return copy;
  }

  searchCities(value: string) {
    this.searchText = value;
    if (!value || value.trim() === '') {
      this.filteredCities = this.cities; // 已经是 ensureNationFirst 过的
      return;
    }
    let newList: City[] = [];
    for (let i = 0; i < this.cities.length; i++) {
      if (
        this.cities[i].name.toLowerCase().includes(value.toLowerCase()) ||
        this.cities[i].pinyin.toLowerCase().includes(value.toLowerCase())
      ) {
        newList.push(this.cities[i]);
      }
    }
    this.filteredCities = this.ensureNationFirst(newList);
  }
  
  // 处理城市选择并返回到来源页面
  handleCitySelect(cityName: string) {
    if (this.fromPage === 'AdoptApply') {
      // 返回领养申请页面，传递选中的城市和动物ID
      router.replaceUrl({
        url: 'pages/Home/AdoptApply',
        params: {
          selectedCity: cityName,
          id: this.animalId
        }
      });
    } else if (this.fromPage === 'EditRehomePet') {
      // 返回发布送养页面，传递选中的城市
      router.replaceUrl({
        url: 'pages/Profile/EditRehomePet',
        params: {
          selectedCity: cityName
        }
      });
    } else if (this.fromPage === 'EditMissingPet') {
      // 返回发布寻宠页面，传递选中的城市
      router.replaceUrl({
        url: 'pages/Profile/EditMissingPet',
        params: {
          selectedCity: cityName
        }
      });
    } else if (this.fromPage === 'MissingPets') {
      // 返回寻宠页面，使用全局状态传递选中的城市
      GlobalState.getInstance().setSelectedCity(cityName);
      router.back();
    } else {
      // 默认返回首页，传递选中的城市
      router.replaceUrl({ url: 'pages/Home/Home', params: { city: cityName } });
    }
  }

  build() {
    Column() {
      // 顶部标题
      Row() {
        Stack(){
          Row(){
            Button() {
              Image($r('app.media.arrow_left'))
                .height(27)
                .width(27)
            }
            .zIndex(2)
            .type(ButtonType.Normal)
            .backgroundColor(Color.Transparent)
            .margin({left:15})
            .onClick(() => {
              router.back();
            })
          }
          .zIndex(1)
          .width('100%')
          Row() {
            Text('选择城市')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
          }
          .zIndex(0)
          .width('100%')
          .justifyContent(FlexAlign.Center)
        }
      }
      .margin({top:10})

      // 搜索框和搜索/取消按钮
      Row() {
        TextInput({
          placeholder: '搜索城市',
          text: this.searchText
        })
        .onChange((value: string) => { this.searchCities(value); })
        .width('75%')
        .backgroundColor('#f5f5f5')
        .fontColor(Color.Black)

        // 始终显示按钮
        Button(this.searchText && this.searchText.length > 0 ? '取消' : '搜索')
          .type(ButtonType.Normal)
          .backgroundColor('#f5f5f5')
          .borderRadius(20)
          .fontColor(this.searchText && this.searchText.length > 0 ? Color.Red : Color.Blue)
          .onClick(() => {
            if (this.searchText && this.searchText.length > 0) {
              this.searchText = '';
              this.filteredCities = this.cities;
            } else {
              // 可选：无操作或聚焦输入框
            }
          })
          .margin({ left: 8 })
      }
      .margin({left:15, right:15, top:10, bottom:5})

      if (this.isLoading) {
        Row() {
          LoadingProgress()
            .width(50)
            .height(50)
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({top: 30})
      } else if (this.filteredCities.length > 0) {
        List() {
          ForEach(this.filteredCities, (city: City) => {
            ListItem() {
              Column(){
                Button() {
                    Row() {
                        Text(city.name)
                          .fontColor(Color.Black)
                          .fontSize(16)
                    }
                    .margin({left:10})
                    .height('7%')
                    .width('100%')
                    .justifyContent(FlexAlign.Start)
                  }
                  .backgroundColor(Color.White)
                  .width('90%')
                  .margin({left:17})
                  .type(ButtonType.Normal)
                  .align(Alignment.Start)
                  .onClick(() => {
                    this.handleCitySelect(city.name);
                  })
                Row() {} // 空内容撑满宽度
                  .height(1)
                  .width('90%')
                  .margin({left:17})
                  .backgroundColor('#000')
              }
            }
          }, (city: City) => city.name)
        }
        .scrollBar(BarState.Off)
      } else {
        Row() {
          Text('未找到相关城市')
            .fontColor('#888')
            .fontSize(16)
            .margin({top: 30})
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
      }
    }
    .height('100%')
    .width('100%')
    .backgroundColor('#FFF')
  }
}