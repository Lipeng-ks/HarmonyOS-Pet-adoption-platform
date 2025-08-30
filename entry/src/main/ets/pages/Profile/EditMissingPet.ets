import { router } from '@kit.ArkUI';
import prompt from '@system.prompt';
import { ApiService } from '../../common/services/ApiService';
import { MissingPet, CreateMissingPetRequest } from '../../common/models/MissingPet';
import { UserInfo } from '../../common/models/UserInfo';

interface EditMissingPetParams {
  id?: number;
  mode?: 'create' | 'edit';
}

@Entry
@Component
struct EditMissingPet {
  @State private mode: 'create' | 'edit' = 'create';
  @State private petId: number = 0;
  @State private isLoading: boolean = false;
  @State private isSaving: boolean = false;
  @State private isDeleting: boolean = false;
  
  // 表单数据
  @State private title: string = '';
  @State private petName: string = '';
  @State private petType: string = '狗';
  @State private gender: boolean = true; // true=公，false=母
  @State private age: string = '';
  @State private lostTime: string = '';
  @State private selectedProvince: string = '';
  @State private selectedCity: string = '';
  @State private lostAddress: string = '';
  @State private description: string = '';
  @State private contactName: string = '';
  @State private contactPhone: string = '';
  @State private reward: string = '';
  @State private petImage: string = '';
  
  // 省市数据
  @State private provinces: string[] = [];
  @State private cities: string[] = [];
  
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
    const params = router.getParams() as EditMissingPetParams;
    if (params) {
      this.mode = params.mode || 'create';
      if (params.id) {
        this.petId = params.id;
      }
    }

    // 先加载省份数据，确保后续解析省份时有数据可用
    await this.loadProvinces();

    // 若为编辑模式，加载已有寻宠数据（依赖省份列表以解析所属省份）
    if (this.mode === 'edit' && this.petId) {
      await this.loadPetData();
    }
    
    // 如果是新建，预填充用户联系信息
    if (this.mode === 'create') {
      const userInfo = AppStorage.Get('userInfo') as UserInfo | undefined;
      if (userInfo) {
        this.contactName = userInfo.username || '';
        this.contactPhone = userInfo.phone || '';
      }
    }
  }

  // 加载宠物数据（编辑模式）
  async loadPetData(): Promise<void> {
    this.isLoading = true;
    try {
      // 健壮性处理：若省份尚未加载，先加载省份
      if (!this.provinces || this.provinces.length === 0) {
        await this.loadProvinces();
      }
      const pet = await this.apiService.getMissingPetById(this.petId);
      if (pet) {
        this.title = pet.title;
        this.petName = pet.petName;
        this.petType = pet.type;
        this.gender = pet.gender;
        this.age = pet.age.toString();
        this.lostTime = pet.lostTime;
        this.selectedCity = pet.city;
        this.lostAddress = pet.lostAddress;
        this.description = pet.description;
        this.contactName = pet.contactName;
        this.contactPhone = pet.contactPhone;
        this.reward = pet.reward ? pet.reward.toString() : '';
        this.petImage = pet.image || '';
        
        // 解析省份信息（根据城市反查省份）
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

  // 加载省份列表
  async loadProvinces(): Promise<void> {
    try {
      this.provinces = await this.apiService.getProvinces();
    } catch (e) {
      console.warn('加载省份失败', e);
      this.provinces = [];
    }
  }

  // 解析省份（从城市名称）
  async parseProvince(city: string): Promise<void> {
    // 这里需要根据城市反查省份，简单处理
    for (const province of this.provinces) {
      try {
        const cities = await this.apiService.getCitiesByProvince(province);
        if (cities.includes(city)) {
          this.selectedProvince = province;
          this.cities = cities;
          break;
        }
      } catch (e) {
        continue;
      }
    }
  }

  // 显示日期选择器
  showDatePicker(): void {
    DatePickerDialog.show({
      start: new Date(Date.now() - 365 * 24 * 60 * 60 * 1000), // 一年前
      end: new Date(),
      selected: this.lostTime ? new Date(this.lostTime) : new Date(),
      onAccept: (value: DatePickerResult) => {
        const year = value.year || new Date().getFullYear();
        const monthValue = value.month !== undefined ? value.month + 1 : new Date().getMonth() + 1;
        const month = monthValue.toString().padStart(2, '0');
        const day = (value.day || new Date().getDate()).toString().padStart(2, '0');
        this.lostTime = `${year}-${month}-${day}T00:00:00.000Z`;
      }
    });
  }

  // 验证表单
  validateForm(): boolean {
    if (!this.title.trim()) {
      prompt.showToast({ message: '请输入寻宠标题', duration: 1500 });
      return false;
    }
    
    if (!this.petName.trim()) {
      prompt.showToast({ message: '请输入宠物名字', duration: 1500 });
      return false;
    }
    
    if (!this.age || parseInt(this.age) <= 0) {
      prompt.showToast({ message: '请输入正确的年龄', duration: 1500 });
      return false;
    }
    
    if (!this.lostTime) {
      prompt.showToast({ message: '请选择走失时间', duration: 1500 });
      return false;
    }
    
    if (!this.selectedCity) {
      prompt.showToast({ message: '请选择城市', duration: 1500 });
      return false;
    }
    
    if (!this.lostAddress.trim()) {
      prompt.showToast({ message: '请输入详细走失地点', duration: 1500 });
      return false;
    }
    
    if (!this.contactName.trim()) {
      prompt.showToast({ message: '请输入联系人姓名', duration: 1500 });
      return false;
    }
    
    if (!this.contactPhone.trim()) {
      prompt.showToast({ message: '请输入联系电话', duration: 1500 });
      return false;
    }
    
    // 验证手机号格式
    const phoneRegex = /^1[3-9]\d{9}$/;
    if (!phoneRegex.test(this.contactPhone)) {
      prompt.showToast({ message: '手机号格式不正确', duration: 1500 });
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
    
    const userInfo = AppStorage.Get('userInfo') as UserInfo | undefined;
    if (!userInfo || !userInfo.id) {
      prompt.showToast({ message: '用户信息错误，请重新登录', duration: 1500 });
      return;
    }
    
    const petData: CreateMissingPetRequest = {
      userId: userInfo.id,
      title: this.title.trim(),
      petName: this.petName.trim(),
      type: this.petType,
      gender: this.gender,
      age: parseInt(this.age),
      lostTime: this.lostTime,
      city: this.selectedCity,
      lostAddress: this.lostAddress.trim(),
      description: this.description.trim(),
      contactName: this.contactName.trim(),
      contactPhone: this.contactPhone.trim(),
      reward: this.reward ? parseFloat(this.reward) : 0,
      image: this.petImage || 'app.media.tyikjgch'
    };

    try {
      let result: MissingPet | null = null;
      if (this.mode === 'create') {
        // 创建模式
        result = await this.apiService.createMissingPet(petData);
        if (result) {
          prompt.showToast({ message: '发布成功', duration: 1500 });
          router.back();
        } else {
          prompt.showToast({ message: '发布失败，请重试', duration: 1500 });
        }
      } else {
        // 编辑模式
        result = await this.apiService.updateMissingPet(this.petId, petData);
        if (result) {
          prompt.showToast({ message: '保存成功', duration: 1500 });
          router.back();
        } else {
          prompt.showToast({ message: '更新失败，请重试', duration: 1500 });
        }
      }
    } catch (error) {
      console.error('保存失败:', error);
      console.error('请求数据详情:', JSON.stringify(petData, null, 2));
      prompt.showToast({ message: '保存失败，请检查网络', duration: 1500 });
    } finally {
      this.isSaving = false;
    }
  }

  // 删除寻宠
  async onDeleteMissingPet(): Promise<void> {
    if (!this.petId) {
      prompt.showToast({ message: '未找到记录ID', duration: 1500 });
      return;
    }
    if (this.isDeleting) return;

    AlertDialog.show({
      title: '确认删除',
      message: '删除后不可恢复，确定要删除该寻宠信息吗？',
      primaryButton: {
        value: this.isDeleting ? '删除中...' : '删除',
        action: async () => {
          if (this.isDeleting) return;
          this.isDeleting = true;
          try {
            const ok = await this.apiService.deleteMissingPet(this.petId);
            if (ok) {
              prompt.showToast({ message: '删除成功', duration: 1200 });
              router.back();
            } else {
              prompt.showToast({ message: '删除失败，请重试', duration: 1500 });
            }
          } catch (e) {
            console.error('删除寻宠异常:', e);
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
      // 背景行布局，用于按钮定位
      Row() {
        // 左侧返回按钮
        Button() {
          Image($r('app.media.arrow_left'))
            .width(20)
            .height(20)
            .fillColor('#007AFF')
        }
        .type(ButtonType.Normal)
        .backgroundColor(Color.Transparent)
        .padding({ left: 8, right: 8, top: 8, bottom: 8 })
        .borderRadius(20)
        .onClick(() => router.back())
        .width(44)
        .height(44)

        Blank()

        // 右侧保存按钮
        Button(this.isSaving ? '保存中...' : '保存')
          .type(ButtonType.Normal)
          .fontSize(16)
          .fontColor(Color.White)
          .backgroundColor(this.isSaving ? '#999' : '#007AFF')
          .borderRadius(20)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .enabled(!this.isSaving)
          .onClick(() => this.onSave())
      }
      .width('100%')
      .height('100%')

      // 绝对居中的标题
      Text(this.mode === 'create' ? '发布寻宠' : '编辑寻宠')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1D1D1F')
    }
    .width('100%')
    .height(64)
    .backgroundColor(Color.White)
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .shadow({ radius: 2, color: 'rgba(0,0,0,0.05)', offsetY: 1 })
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
                    Text('清晰的照片有助于他人辨认')
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
              // 寻宠标题
              Row() {
                this.FormItem('标题', true)
                TextInput({ text: this.title, placeholder: '请输入寻宠标题' })
                  .fontSize(16)
                  .layoutWeight(1)
                  .backgroundColor(Color.Transparent)
                  .borderRadius(8)
                  .padding({ left: 8, right: 8 })
                  .focusOnTouch(true)
                  .onChange((value: string) => this.title = value)
              }
              .padding({ left: 16, right: 16, top: 12, bottom: 12 })
              .alignItems(VerticalAlign.Center)
              
              Divider().color('#E5E5EA').margin({ left: 16, right: 16 })
              
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
            
            // 走失信息
            this.FormSection('走失信息')
            
            Column() {
              // 走失时间
              Row() {
                this.FormItem('走失时间', true)
                Text(this.lostTime || '请选择走失时间')
                  .fontSize(16)
                  .layoutWeight(1)
                  .fontColor(this.lostTime ? '#1C1C1E' : '#999')
                Image($r('app.media.birthday'))
                  .width(20)
                  .height(20)
                  .margin({ right: 8 })
              }
              .padding({ left: 16, right: 16, top: 12, bottom: 12 })
              .alignItems(VerticalAlign.Center)
              .onClick(() => this.showDatePicker())
              
              Divider().color('#E5E5EA').margin({ left: 16, right: 16 })
              
              // 走失城市
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
              
              Divider().color('#E5E5EA').margin({ left: 16, right: 16 })
              
              // 详细地址
              Row() {
                this.FormItem('详细地点', true)
                TextInput({ text: this.lostAddress, placeholder: '请输入详细走失地点' })
                  .fontSize(16)
                  .layoutWeight(1)
                  .backgroundColor(Color.Transparent)
                  .borderRadius(8)
                  .padding({ left: 8, right: 8 })
                  .focusOnTouch(true)
                  .onChange((value: string) => this.lostAddress = value)
              }
              .padding({ left: 16, right: 16, top: 12, bottom: 12 })
              .alignItems(VerticalAlign.Center)
            }
            .backgroundColor(Color.White)
            .borderRadius(16)
            .margin({ left: 16, right: 16 })
            .shadow({ radius: 4, color: 'rgba(0,0,0,0.05)', offsetY: 2 })
            
            // 详细描述
            this.FormSection('详细描述')
            
            Column() {
              TextArea({ text: this.description, placeholder: '请详细描述宠物特征、走失情况等信息，便于他人辨认' })
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
            
            // 联系方式
            this.FormSection('联系方式')
            
            Column() {
              // 联系人
              Row() {
                this.FormItem('联系人', true)
                TextInput({ text: this.contactName, placeholder: '请输入联系人姓名' })
                  .fontSize(16)
                  .layoutWeight(1)
                  .backgroundColor(Color.Transparent)
                  .borderRadius(8)
                  .padding({ left: 8, right: 8 })
                  .focusOnTouch(true)
                  .onChange((value: string) => this.contactName = value)
              }
              .padding({ left: 16, right: 16, top: 12, bottom: 12 })
              .alignItems(VerticalAlign.Center)
              
              Divider().color('#E5E5EA').margin({ left: 16, right: 16 })
              
              // 联系电话
              Row() {
                this.FormItem('电话', true)
                TextInput({ text: this.contactPhone, placeholder: '请输入联系电话' })
                  .fontSize(16)
                  .layoutWeight(1)
                  .type(InputType.Number)
                  .backgroundColor(Color.Transparent)
                  .borderRadius(8)
                  .padding({ left: 8, right: 8 })
                  .focusOnTouch(true)
                  .onChange((value: string) => this.contactPhone = value)
              }
              .padding({ left: 16, right: 16, top: 12, bottom: 12 })
              .alignItems(VerticalAlign.Center)
              
              Divider().color('#E5E5EA').margin({ left: 16, right: 16 })
              
              // 悬赏金额
              Row() {
                this.FormItem('悬赏金额')
                TextInput({ text: this.reward, placeholder: '选填，设置悬赏金额' })
                  .fontSize(16)
                  .layoutWeight(1)
                  .type(InputType.Number)
                  .backgroundColor(Color.Transparent)
                  .borderRadius(8)
                  .padding({ left: 8, right: 8 })
                  .focusOnTouch(true)
                  .onChange((value: string) => this.reward = value)
                Text('元')
                  .fontSize(16)
                  .fontColor('#666')
                  .margin({ left: 8 })
              }
              .padding({ left: 16, right: 16, top: 12, bottom: 12 })
              .alignItems(VerticalAlign.Center)
            }
            .backgroundColor(Color.White)
            .borderRadius(12)
            .margin({ left: 16, right: 16 })
            
            
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
              
              Text('• 请确保信息准确，以便他人帮助您找到走失的宠物\n• 建议上传清晰的宠物照片，有助于提高找回成功率\n• 保持联系方式畅通，及时回复热心网友的消息')
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
          Button(this.isDeleting ? '删除中...' : '删除该寻宠')
            .type(ButtonType.Normal)
            .fontSize(16)
            .fontColor(Color.White)
            .backgroundColor(this.isDeleting ? '#C7C7CC' : '#FF3B30')
            .borderRadius(24)
            .padding({ left: 24, right: 24, top: 12, bottom: 12 })
            .enabled(!this.isDeleting)
            .onClick(() => this.onDeleteMissingPet())
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
