import { router } from '@kit.ArkUI';
import prompt from '@system.prompt';
import { ApiService, Animal, CreateAnimalRequest, UpdateAnimalRequest } from '../../common/services/ApiService';
import { UserInfo } from '../../common/models/UserInfo';

interface EditRehomePetParams {
  id?: number;
  mode?: 'create' | 'edit';
}

@Entry
@Component
struct EditRehomePet {
  @State private mode: 'create' | 'edit' = 'create';
  @State private petId: number = 0;
  @State private isLoading: boolean = false;
  @State private isSaving: boolean = false;
  @State private isDeleting: boolean = false;
  
  // 表单数据
  @State private petName: string = '';
  @State private petType: string = '狗';
  @State private gender: boolean = true; // true=公，false=母
  @State private age: string = '';
  @State private description: string = '';
  @State private vaccinated: boolean = false;
  @State private dewormed: boolean = false;
  @State private neutered: boolean = false;
  @State private petImage: string = '';
  @State private selectedCity: string = '';
  @State private isFree: boolean = true;

  // 省份城市相关状态
  @State private provinces: string[] = [];
  @State private cities: string[] = [];
  @State private selectedProvince: string = '';
  @State private showProvinceDialog: boolean = false;
  @State private showCityDialog: boolean = false;

  // 宠物类型选项
  private petTypeOptions: string[] = ['狗', '猫', '其他'];
  
  private apiService: ApiService = ApiService.getInstance();

  async aboutToAppear(): Promise<void> {
    // 检查登录状态
    const isLoggedIn = AppStorage.Get('isLoggedIn') as boolean | undefined;
    if (!isLoggedIn) {
      prompt.showToast({ message: '请先登录', duration: 1500 });
      router.back();
      return;
    }
    
    // 获取路由参数
    const params = router.getParams() as EditRehomePetParams;
    if (params) {
      this.mode = params.mode || 'create';
      if (params.id) {
        this.petId = params.id;
      }
    }

    // 先加载省份数据
    await this.loadProvinces();

    // 若为编辑模式，加载已有送养数据
    if (this.mode === 'edit' && this.petId) {
      await this.loadPetData();
    }
  }

  // 加载省份数据
  async loadProvinces(): Promise<void> {
    try {
      const provinceList: string[] = await this.apiService.getProvinces();
      this.provinces = provinceList.map((p: string): string => {
        if (typeof p === 'string') {
          return p;
        }
        return (p as Record<string, string>).name || String(p);
      });
    } catch (error) {
      console.error('加载省份数据失败:', error);
      // 使用默认省份数据
      this.provinces = ['北京市', '上海市', '广东省', '浙江省', '江苏省', '山东省', '河南省', '四川省', '湖北省', '湖南省'];
    }
  }

  // 加载城市数据
  async loadCities(provinceName: string): Promise<void> {
    try {
      const cityList: string[] = await this.apiService.getCitiesByProvince(provinceName);
      this.cities = cityList.map((c: string): string => {
        if (typeof c === 'string') {
          return c;
        }
        return (c as Record<string, string>).name || String(c);
      });
    } catch (error) {
      console.error('加载城市数据失败:', error);
      this.cities = [];
    }
  }

  // 解析省份信息（编辑模式使用）
  async parseProvince(cityName: string): Promise<void> {
    if (!cityName) return;
    
    // 简单的城市到省份映射逻辑
    const cityProvinceMap: Record<string, string> = {
      '北京': '北京市',
      '上海': '上海市',
      '广州': '广东省',
      '深圳': '广东省',
      '杭州': '浙江省',
      '南京': '江苏省',
      '苏州': '江苏省',
      '济南': '山东省',
      '青岛': '山东省',
      '郑州': '河南省',
      '成都': '四川省',
      '武汉': '湖北省',
      '长沙': '湖南省'
    };

    const province = cityProvinceMap[cityName] || '广东省';
    this.selectedProvince = province;
    await this.loadCities(province);
  }

  // 加载宠物数据（编辑模式）
  async loadPetData(): Promise<void> {
    this.isLoading = true;
    try {
      const pet = await this.apiService.getAnimalById(this.petId);
      if (pet) {
        this.petName = pet.name;
        this.petType = pet.type;
        this.gender = pet.gender;
        this.age = pet.age.toString();
        this.description = pet.description;
        this.vaccinated = pet.vaccinated;
        this.dewormed = pet.dewormed;
        this.neutered = pet.neutered;
        this.selectedCity = pet.city;
        this.isFree = pet.isFree;
        this.petImage = pet.image || '';
        
        // 解析省份信息
        await this.parseProvince(pet.city);
      }
    } catch (error) {
      console.error('加载宠物数据失败:', error);
      prompt.showToast({ message: '加载数据失败', duration: 1500 });
      router.back();
    } finally {
      this.isLoading = false;
    }
  }


  // 验证表单
  validateForm(): boolean {
    if (!this.petName.trim()) {
      prompt.showToast({ message: '请输入宠物名字', duration: 1500 });
      return false;
    }
    
    if (!this.age || parseInt(this.age) <= 0) {
      prompt.showToast({ message: '请输入正确的年龄', duration: 1500 });
      return false;
    }
    
    if (!this.selectedCity) {
      prompt.showToast({ message: '请选择城市', duration: 1500 });
      return false;
    }
    
    if (!this.description.trim()) {
      prompt.showToast({ message: '请输入宠物描述', duration: 1500 });
      return false;
    }
    
    return true;
  }

  // 保存数据
  async onSave(): Promise<void> {
    if (!this.validateForm()) {
      return;
    }
    
    this.isSaving = true;
    
    try {
      const userInfo = AppStorage.Get('userInfo') as UserInfo | undefined;
      if (!userInfo || !userInfo.id) {
        prompt.showToast({ message: '用户信息错误，请重新登录', duration: 1500 });
        return;
      }
      
      if (this.mode === 'create') {
        const petData: CreateAnimalRequest = {
          userId: userInfo.id,
          name: this.petName.trim(),
          gender: this.gender,
          age: parseInt(this.age),
          type: this.petType,
          description: this.description.trim(),
          vaccinated: this.vaccinated,
          dewormed: this.dewormed,
          neutered: this.neutered,
          city: this.selectedCity,
          isFree: this.isFree,
          image: this.petImage || 'app.media.tyikjgch',
          listed: true
        };
        
        const result = await this.apiService.createAnimal(petData);
        if (result) {
          prompt.showToast({ message: '发布成功', duration: 1500 });
          router.back();
        } else {
          prompt.showToast({ message: '发布失败，请重试', duration: 1500 });
        }
      } else {
        const petData: UpdateAnimalRequest = {
          name: this.petName.trim(),
          gender: this.gender,
          age: parseInt(this.age),
          type: this.petType,
          description: this.description.trim(),
          vaccinated: this.vaccinated,
          dewormed: this.dewormed,
          neutered: this.neutered,
          city: this.selectedCity,
          isFree: this.isFree,
          image: this.petImage || 'app.media.tyikjgch'
        };
        
        const result = await this.apiService.updateAnimal(this.petId, petData);
        if (result) {
          prompt.showToast({ message: '更新成功', duration: 1500 });
          router.back();
        } else {
          prompt.showToast({ message: '更新失败，请重试', duration: 1500 });
        }
      }
    } catch (error) {
      console.error('保存失败:', error);
      prompt.showToast({ message: '保存失败，请检查网络', duration: 1500 });
    } finally {
      this.isSaving = false;
    }
  }

  // 删除送养动物
  async onDeleteAnimal(): Promise<void> {
    if (!this.petId) {
      prompt.showToast({ message: '未找到记录ID', duration: 1500 });
      return;
    }
    if (this.isDeleting) return;

    AlertDialog.show({
      title: '确认删除',
      message: '删除后不可恢复，确定要删除该送养信息吗？',
      primaryButton: {
        value: this.isDeleting ? '删除中...' : '删除',
        action: async () => {
          if (this.isDeleting) return;
          this.isDeleting = true;
          try {
            const ok = await this.apiService.deleteAnimal(this.petId);
            if (ok) {
              prompt.showToast({ message: '删除成功', duration: 1200 });
              router.back();
            } else {
              prompt.showToast({ message: '删除失败，请重试', duration: 1500 });
            }
          } catch (e) {
            console.error('删除送养异常:', e);
            prompt.showToast({ message: '网络异常，请稍后再试', duration: 1500 });
          } finally {
            this.isDeleting = false;
          }
        }
      },
      secondaryButton: { value: '取消', action: () => {} }
    });
  }

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

        // 右侧保存按钮
        Button(this.isSaving ? '保存中...' : '保存')
          .type(ButtonType.Normal)
          .fontSize(16)
          .fontColor(Color.White)
          .backgroundColor(this.isSaving ? '#C7C7CC' : '#FF6B35')
          .borderRadius(22)
          .padding({ left: 20, right: 20, top: 10, bottom: 10 })
          .enabled(!this.isSaving)
          .onClick(() => this.onSave())
      }
      .width('100%')
      .height('100%')
      .padding({ left: 16, right: 16 })

      // 绝对居中的标题
      Text(this.mode === 'create' ? '发布送养' : '编辑送养')
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

  @Builder FormSection(title: string): void {
    Row() {
      Circle({ width: 4, height: 4 })
        .fill('#007AFF')
        .margin({ right: 8 })
      Text(title)
        .fontSize(16)
        .fontColor('#1D1D1F')
        .fontWeight(FontWeight.Medium)
    }
    .margin({ top: 24, bottom: 16, left: 20 })
  }

  @Builder FormItem(label: string, required: boolean = false): void {
    Row() {
      if (required) {
        Text('*')
          .fontSize(16)
          .fontColor('#FF3B30')
          .margin({ right: 2 })
      }
      Text(label)
        .fontSize(16)
        .fontColor('#1C1C1E')
        .width(80)
    }
  }

  build(): void {
    Column() {
      this.TopBar()
      
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
            .color('#007AFF')
          Text('加载中...')
            .fontSize(16)
            .fontColor('#666')
            .margin({ top: 20 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column() {
            // 宠物照片区域
            this.FormSection('宠物照片')
            Column() {
              if (this.petImage) {
                Stack() {
                  Image($r(this.petImage))
                    .width(160)
                    .height(160)
                    .borderRadius(16)
                    .objectFit(ImageFit.Cover)
                    .shadow({ radius: 8, color: 'rgba(0,0,0,0.1)', offsetY: 2 })
                  
                  // 删除按钮
                  Button() {
                    Image($r('app.media.xmark_circle_fill'))
                      .width(28)
                      .height(28)
                      .fillColor('#FF3B30')
                  }
                  .type(ButtonType.Normal)
                  .backgroundColor(Color.White)
                  .borderRadius(14)
                  .width(28)
                  .height(28)
                  .position({ x: 136, y: -4 })
                  .shadow({ radius: 4, color: 'rgba(0,0,0,0.15)', offsetY: 1 })
                  .onClick(() => this.petImage = '')
                }
              } else {
                Column() {
                  Column() {
                    Image($r('app.media.tyikjgch'))
                      .width(56)
                      .height(56)
                      .fillColor('#007AFF')
                      .opacity(0.6)
                      .margin({ bottom: 12 })
                    Text('添加宠物照片')
                      .fontSize(16)
                      .fontColor('#007AFF')
                      .fontWeight(FontWeight.Medium)
                      .margin({ bottom: 4 })
                    Text('清晰的照片有助于找到合适的领养人')
                      .fontSize(12)
                      .fontColor('#8E8E93')
                  }
                  .justifyContent(FlexAlign.Center)
                }
                .width(160)
                .height(160)
                .backgroundColor('#F8F9FA')
                .borderRadius(16)
                .border({ width: 2, color: '#E5E7EB', style: BorderStyle.Dashed })
                .justifyContent(FlexAlign.Center)
                .onClick(() => {
                  prompt.showToast({ message: '图片上传功能开发中', duration: 1500 });
                })
              }
            }
            .padding(20)
            .backgroundColor(Color.White)
            .borderRadius(16)
            .margin({ left: 16, right: 16 })
            .shadow({ radius: 4, color: 'rgba(0,0,0,0.05)', offsetY: 2 })

            // 基本信息
            this.FormSection('基本信息')
            Column() {
              // 宠物名字
              Row() {
                this.FormItem('名字', true)
                TextInput({ text: this.petName, placeholder: '请输入宠物名字' })
                  .fontSize(16)
                  .layoutWeight(1)
                  .backgroundColor(Color.Transparent)
                  .borderRadius(8)
                  .padding({ left: 8, right: 8 })
                  .focusOnTouch(true)
                  .onChange((value: string) => this.petName = value)
              }
              .padding({ left: 16, right: 16, top: 12, bottom: 12 })
              .alignItems(VerticalAlign.Center)
              
              Divider().color('#E5E5EA').margin({ left: 16, right: 16 })
              
              // 宠物类型
              Row() {
                this.FormItem('类型', true)
                Text(this.petType)
                  .fontSize(16)
                  .layoutWeight(1)
                  .fontColor('#1C1C1E')
                Image($r('app.media.chevron_right'))
                  .width(18)
                  .height(18)
                  .margin({ right: 8 })
              }
              .padding({ left: 16, right: 16, top: 12, bottom: 12 })
              .alignItems(VerticalAlign.Center)
              .onClick(() => {
                TextPickerDialog.show({
                  range: this.petTypeOptions,
                  selected: this.petTypeOptions.indexOf(this.petType),
                  onAccept: (result) => {
                    const idx = Array.isArray(result.index) ? result.index[0] : result.index;
                    this.petType = this.petTypeOptions[idx];
                  }
                });
              })
              
              Divider().color('#E5E5EA').margin({ left: 16, right: 16 })
              
              // 性别
              Row() {
                this.FormItem('性别', true)
                Row() {
                  Button() {
                    Row() {
                      Image($r(this.gender ? 'app.media.Animalgender' : 'app.media.Animalgenderf'))
                        .width(18)
                        .height(18)
                        .margin({ right: 6 })
                      Text(this.gender ? '公' : '母')
                        .fontSize(15)
                        .fontColor(this.gender ? '#007AFF' : '#FF69B4')
                        .fontWeight(FontWeight.Medium)
                    }
                  }
                  .type(ButtonType.Normal)
                  .backgroundColor(this.gender ? '#E8F4FF' : '#FFE8F4')
                  .borderRadius(20)
                  .height(36)
                  .padding({ left:16, right: 16 })
                  .border({ width: 1, color: this.gender ? '#007AFF' : '#FF69B4' })
                  .onClick(() => this.gender = !this.gender)
                }
                .layoutWeight(1)
              }
              .padding({ left: 16, right: 16, top: 12, bottom: 12 })
              .alignItems(VerticalAlign.Center)
              
              Divider().color('#E5E5EA').margin({ left: 16, right: 16 })
              
              // 年龄
              Row() {
                this.FormItem('年龄', true)
                TextInput({ text: this.age, placeholder: '请输入宠物年龄' })
                  .fontSize(16)
                  .layoutWeight(1)
                  .type(InputType.Number)
                  .backgroundColor(Color.Transparent)
                  .borderRadius(8)
                  .padding({ left: 8, right: 8 })
                  .focusOnTouch(true)
                  .onChange((value: string) => this.age = value)
                Text('岁')
                  .fontSize(16)
                  .fontColor('#666')
                  .margin({ left: 8 })
              }
              .padding({ left: 16, right: 16, top: 12, bottom: 12 })
              .alignItems(VerticalAlign.Center)
            }
            .backgroundColor(Color.White)
            .borderRadius(16)
            .margin({ left: 16, right: 16 })
            .shadow({ radius: 4, color: 'rgba(0,0,0,0.05)', offsetY: 2 })
            
            // 健康状况
            this.FormSection('健康状况')
            Column() {
              // 健康状态选择
              Row() {
                Text('健康状态')
                  .fontSize(16)
                  .fontColor('#1C1C1E')
                  .width(80)
                
                Row() {
                  // 已免疫
                  Button() {
                    Row() {
                      Text('已免疫')
                        .fontSize(12)
                        .fontColor(this.vaccinated ? '#34C759' : '#8E8E93')
                        .fontWeight(this.vaccinated ? FontWeight.Medium : FontWeight.Normal)
                        .height("100%")
                    }
                  }
                  .type(ButtonType.Normal)
                  .backgroundColor(this.vaccinated ? '#E8F5E8' : Color.Transparent)
                  .borderRadius(20)
                  .padding({ left: 16, right: 16, top: 10, bottom: 10 })
                  .border({ width: 1, color: this.vaccinated ? '#34C759' : '#E5E5EA' })
                  .height(30)
                  .onClick(() => this.vaccinated = !this.vaccinated)
                  
                  // 已驱虫
                  Button() {
                    Row() {
                      Text('已驱虫')
                        .fontSize(12)
                        .fontColor(this.isFree ? '#34C759' : '#8E8E93')
                        .fontWeight(this.isFree ? FontWeight.Medium : FontWeight.Normal)
                        .height("100%")
                    }
                  }  
                  .type(ButtonType.Normal)
                  .backgroundColor(this.dewormed ? '#E8F5E8' : Color.Transparent)
                  .borderRadius(20)
                  .padding({ left: 16, right: 16, top: 10, bottom: 10 })
                  .border({ width: 1, color: this.dewormed ? '#34C759' : '#E5E5EA' })
                  .height(30)
                  .margin({ left: 10 })
                  .onClick(() => this.dewormed = !this.dewormed)
                  
                  // 已绝育
                  Button() {
                    Row() {
                      Text('已绝育')
                        .fontSize(12)
                        .fontColor(this.neutered ? '#34C759' : '#8E8E93')
                        .fontWeight(this.neutered ? FontWeight.Medium : FontWeight.Normal)
                        .height("100%")
                    }
                  }
                  .type(ButtonType.Normal)
                  .backgroundColor(this.neutered ? '#E8F5E8' : Color.Transparent)
                  .borderRadius(20)
                  .padding({ left: 16, right: 16, top: 10, bottom: 10 })
                  .border({ width: 1, color: this.neutered ? '#34C759' : '#E5E5EA' })
                  .height(30)
                  .margin({ left: 10 })
                  .onClick(() => this.neutered = !this.neutered)
                }
                .layoutWeight(1)
              }
              .padding({ left: 16, right: 16, top: 12, bottom: 12 })
              .alignItems(VerticalAlign.Center)
            }
            .backgroundColor(Color.White)
            .borderRadius(16)
            .margin({ left: 16, right: 16 })
            .shadow({ radius: 4, color: 'rgba(0,0,0,0.05)', offsetY: 2 })
            
            // 位置信息
            this.FormSection('位置信息')
            Column() {
              // 城市选择
              Row() {
                this.FormItem('城市', true)
                Column() {
                  // 省份选择
                  Row() {
                    Text(this.selectedProvince || '请选择省份')
                      .fontSize(16)
                      .layoutWeight(1)
                      .fontColor(this.selectedProvince ? '#1C1C1E' : '#999')
                    Image($r('app.media.chevron_right'))
                      .width(18)
                      .height(18)
                  }
                  .height(40)
                  .onClick(async () => {
                    if (!this.provinces || this.provinces.length === 0) {
                      prompt.showToast({ message: '省份数据加载中', duration: 1500 });
                      return;
                    }
                    
                    TextPickerDialog.show({
                      range: this.provinces,
                      selected: Math.max(0, this.provinces.indexOf(this.selectedProvince)),
                      onAccept: (result) => {
                        const idx = Array.isArray(result.index) ? result.index[0] : result.index;
                        this.selectedProvince = this.provinces[idx] || '';
                        this.selectedCity = '';
                        this.cities = [];
                      }
                    });
                  })
                  
                  // 城市选择
                  if (this.selectedProvince) {
                    Row() {
                      Text(this.selectedCity || '请选择城市')
                        .fontSize(16)
                        .layoutWeight(1)
                        .fontColor(this.selectedCity ? '#1C1C1E' : '#999')
                      Image($r('app.media.chevron_right'))
                        .width(18)
                        .height(18)
                    }
                    .height(40)
                    .margin({ top: 8 })
                    .onClick(async () => {
                      if (!this.selectedProvince) {
                        prompt.showToast({ message: '请先选择省份', duration: 1500 });
                        return;
                      }
                      try {
                        this.cities = await this.apiService.getCitiesByProvince(this.selectedProvince);
                        if (!this.cities || this.cities.length === 0) {
                          prompt.showToast({ message: '未找到城市数据', duration: 1500 });
                          return;
                        }
                        TextPickerDialog.show({
                          range: this.cities,
                          selected: Math.max(0, this.cities.indexOf(this.selectedCity)),
                          onAccept: (result) => {
                            const idx = Array.isArray(result.index) ? result.index[0] : result.index;
                            this.selectedCity = this.cities[idx] || '';
                          }
                        });
                      } catch (e) {
                        prompt.showToast({ message: '获取城市失败', duration: 1500 });
                      }
                    })
                  }
                }
                .layoutWeight(1)
              }
              .padding({ left: 16, right: 16, top: 12, bottom: 12 })
              .alignItems(VerticalAlign.Top)
            }
            .backgroundColor(Color.White)
            .borderRadius(16)
            .margin({ left: 16, right: 16 })
            .shadow({ radius: 4, color: 'rgba(0,0,0,0.05)', offsetY: 2 })
            
            // 详细描述
            this.FormSection('详细描述')
            Column() {
              TextArea({ text: this.description, placeholder: '请详细描述宠物性格、习性等信息，便于找到合适的领养人' })
                .fontSize(16)
                .height(140)
                .backgroundColor('#F8F9FA')
                .borderRadius(12)
                .padding(16)
                .border({ width: 1, color: '#E5E7EB' })
                .focusOnTouch(true)
                .maxLength(50)
                .onChange((value: string) => {
                  if (value.length <= 50) {
                    this.description = value;
                  }
                })
              
              // 字数统计
              Row() {
                Blank()
                Text(`${this.description.length}/50`)
                  .fontSize(12)
                  .fontColor(this.description.length >= 50 ? '#FF3B30' : '#8E8E93')
              }
              .width('100%')
              .margin({ top: 8 })
            }
            .padding(20)
            .backgroundColor(Color.White)
            .borderRadius(16)
            .margin({ left: 16, right: 16 })
            .shadow({ radius: 4, color: 'rgba(0,0,0,0.05)', offsetY: 2 })
            
            // 送养设置
            this.FormSection('送养设置')
            Column() {
              // 是否免费
              Row() {
                this.FormItem('送养方式', true)
                Row() {
                  Button() {
                    Row() {
                      Text('免费送养')
                        .fontSize(12)
                        .fontColor(this.isFree ? '#34C759' : '#8E8E93')
                        .fontWeight(this.isFree ? FontWeight.Medium : FontWeight.Normal)
                    }
                    .justifyContent(FlexAlign.Center)
                    .alignItems(VerticalAlign.Center)
                  }
                  .type(ButtonType.Normal)
                  .backgroundColor(this.isFree ? '#E8F5E8' : Color.Transparent)
                  .borderRadius(20)
                  .padding({ left: 16, right: 16, top: 10, bottom: 10 })
                  .border({ width: 1, color: this.isFree ? '#34C759' : '#E5E5EA' })
                  .height(30)
                  .onClick(() => this.isFree = !this.isFree)
                }
                .layoutWeight(1)
              }
              .padding({ left: 16, right: 16, top: 12, bottom: 12 })
              .alignItems(VerticalAlign.Center)
            }
            .backgroundColor(Color.White)
            .borderRadius(16)
            .margin({ left: 16, right: 16 })
            .shadow({ radius: 4, color: 'rgba(0,0,0,0.05)', offsetY: 2 })
            
            // 温馨提示
            Column() {
              Row() {
                Image($r('app.media.speaker'))
                  .width(20)
                  .height(20)
                  .fillColor('#FF9500')
                  .margin({ right: 12 })
                Text('温馨提示')
                  .fontSize(16)
                  .fontColor('#FF9500')
                  .fontWeight(FontWeight.Medium)
              }
              .margin({ bottom: 8 })
              
              Text('• 请确保信息准确，为宠物找到合适的新家庭\n• 建议上传清晰的宠物照片，提高送养成功率\n• 请认真筛选领养人，确保宠物得到良好照顾')
                .fontSize(14)
                .fontColor('#8B5A00')
                .lineHeight(20)
            }
            .padding(20)
            .backgroundColor('#FFF8E1')
            .borderRadius(16)
            .border({ width: 1, color: '#FFE082' })
            .margin({ left: 16, right: 16, bottom: 100 })
          }
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .layoutWeight(1)
      }

      // 底部删除按钮（仅编辑模式显示）
      if (this.mode === 'edit') {
        Row() {
          Button(this.isDeleting ? '删除中...' : '删除该送养')
            .type(ButtonType.Normal)
            .fontSize(16)
            .fontColor(Color.White)
            .backgroundColor(this.isDeleting ? '#C7C7CC' : '#FF3B30')
            .borderRadius(24)
            .padding({ left: 24, right: 24, top: 12, bottom: 12 })
            .enabled(!this.isDeleting)
            .onClick(() => this.onDeleteAnimal())
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 8, bottom: 16 })
        .backgroundColor(Color.White)
        .border({ width: { top: 0.5 }, color: '#E5E5EA' })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
  }
}
