import { router } from '@kit.ArkUI';
import { ApiService, Animal, CreateAdoptionOrderRequest, OrderStatus } from '../../common/services/ApiService';
import prompt from '@system.prompt';
import { UserInfo } from '../../common/models/UserInfo';
import { Address } from '../../common/models/UserInfo';
import { AddressService } from '../../common/database/AddressService';

interface AnimalDetailParams { 
  id?: number;
  selectedCity?: string;
  animalId?: number;
}

@Entry
@Component
struct AdoptApplyPage {
  private animal: Animal = {
    id: 0, name: '', gender: false, age: 0, type: '', description: '', vaccinated: false, dewormed: false, neutered: false, image: '', city: '',isFree:false
  };
  
  private apiService: ApiService = ApiService.getInstance();
  @State name: string = '';
  @State experience: string = '';
  @State reason: string = '';
  @State errorMsg: string = '';
  @State success: boolean = false;
  @State isLoading: boolean = true;
  @State loadError: boolean = false;
  @State showRequirements: boolean = false;
  @State resolvedImage: string = '';
  // 实名校验相关状态
  @State userId: number | undefined = undefined;
  @State realName: string = '';
  @State isNameChecked: boolean = false; // 已拉取实名信息
  // 地址相关状态
  private addressService: AddressService = AddressService.getInstance();
  @State username: string = '';
  @State addresses: Address[] = [];
  @State selectedAddressId: string = '';
  @State showAddressSelector: boolean = false;

  aboutToAppear() {
    let params = router.getParams() as AnimalDetailParams;
    console.info(`接收到的参数: ${JSON.stringify(params)}`);
    
    // 加载动物详情
    if (params && params.id) {
      this.loadAnimalFromDb(Number(params.id));
    } else {
      prompt.showToast({
        message: '未能获取宠物信息参数',
        duration: 2000
      });
      this.loadError = true;
      this.isLoading = false;
    }

    // 读取当前用户信息（用于实名校验）
    const ui = AppStorage.Get<UserInfo>('userInfo');
    if (ui && typeof ui.id === 'number') {
      this.userId = ui.id;
      // 异步获取实名信息
      this.fetchRealName(ui.id);
    } else {
      // 若没有登录信息或ID，提示用户登录/完善资料
      console.warn('未获取到用户ID，无法进行实名认证比对');
    }

    // 读取用户名并加载地址
    if (ui && ui.username) {
      this.username = ui.username;
      this.loadAddresses(ui.username);
    }
  }

  // 从其他页面返回时刷新（例如新增地址返回）
  onPageShow() {
    if (this.username) {
      this.loadAddresses(this.username);
    }
  }

  // 从数据库加载动物详情
  async loadAnimalFromDb(id: number) {
    this.isLoading = true;
    this.loadError = false;
    try {
      const animal = await this.apiService.getAnimalById(id);
      if (animal) {
        this.animal = animal;
        // 解析并确定最终用于显示的图片来源，避免在 build 中写复杂逻辑
        const backendBase = 'http://192.168.184.89:8080';
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

        let imageUrl = animal.image || '';
        if (imageUrl.startsWith && imageUrl.startsWith('http')) {
          // 仅接受后端域名的图片，外部域名回退为本地资源
          if (imageUrl.startsWith(backendBase)) {
            this.resolvedImage = imageUrl;
          } else {
            const idx = animal.id && animal.id > 0 ? Math.min(Math.floor(animal.id) - 1, localResources.length - 1) : 0;
            this.resolvedImage = localResources[idx];
          }
        } else if (imageUrl.startsWith && imageUrl.startsWith('app.media.')) {
          this.resolvedImage = imageUrl; // local resource id
        } else if (imageUrl.startsWith && imageUrl.startsWith('/media')) {
          // server-hosted media path
          this.resolvedImage = `${backendBase}${imageUrl}`;
        } else {
          // fallback to local default
          this.resolvedImage = localResources[0];
        }

        console.info(`成功加载ID为${id}的动物数据`);
      } else {
        console.error(`未找到ID为${id}的动物数据`);
        prompt.showToast({
          message: '未找到该宠物信息',
          duration: 2000
        });
        this.loadError = true;
        setTimeout(() => {
          router.back();
        }, 2000);
      }
    } catch (error) {
      console.error(`加载动物详情失败: ${error}`);
      prompt.showToast({
        message: '加载宠物信息失败',
        duration: 2000
      });
      this.loadError = true;
    } finally {
      this.isLoading = false;
    }
  }

  // 拉取实名信息
  private async fetchRealName(uid: number) {
    try {
      const rn = await this.apiService.getUserRealNameByUserId(uid);
      if (rn && rn.fullName) {
        this.realName = (rn.fullName || '').trim();
      } else {
        this.realName = '';
      }
    } catch (e) {
      console.error(`获取实名信息异常: ${e}`);
      this.realName = '';
    } finally {
      this.isNameChecked = true;
    }
  }

  // 加载用户地址列表
  private async loadAddresses(username: string) {
    try {
      await this.addressService.init();
      const list = await this.addressService.getAddresses(username);
      this.addresses = Array.isArray(list) ? list : [];
      // 默认选中默认地址；若没有默认，选第一条
      const def = this.addresses.find(a => a.isDefault);
      if (def) {
        this.selectedAddressId = String(def.id);
      } else if (this.addresses.length > 0) {
        this.selectedAddressId = String(this.addresses[0].id);
      } else {
        this.selectedAddressId = '';
      }
    } catch (e) {
      console.error(`加载地址失败: ${e}`);
      this.addresses = [];
      this.selectedAddressId = '';
    }
  }

  // 获取当前选中的地址
  private getSelectedAddress(): Address | null {
    const id = this.selectedAddressId;
    if (!id) { return null; }
    const a = this.addresses.find(a => String(a.id) === id);
    return a ? a : null;
  }

  // 判断地址是否选中
  private isAddrSelected(addr: Address): boolean {
    return String(addr.id) === this.selectedAddressId;
  }

  async submit() {
    if (!this.name || !this.reason) {
      this.errorMsg = '请填写所有必填项';
      this.success = false;
      return;
    }

    // 校验是否已选择地址（如存在地址数据）
    if (this.addresses.length > 0 && !this.selectedAddressId) {
      this.errorMsg = '请选择收货地址';
      this.success = false;
      prompt.showToast({ message: '请选择收货地址', duration: 2000 });
      return;
    }

    // 实名姓名比对（若已拉取实名信息）
    const inputName = (this.name || '').trim();
    if (this.isNameChecked) {
      if (!this.realName) {
        this.errorMsg = '您尚未进行实名认证，请先在“我的-实名认证”中完成认证';
        prompt.showToast({ message: '请先完成实名认证', duration: 2000 });
        this.success = false;
        return;
      }
      if (inputName !== this.realName) {
        // 不直接提示用户姓名，仅用小弹窗提示不一致
        this.errorMsg = '';
        prompt.showToast({ message: '姓名与实名认证信息不符', duration: 2000 });
        this.success = false;
        return;
      }
    }

    // 校验用户登录
    if (!this.userId || this.userId <= 0) {
      this.errorMsg = '未获取到用户信息，请先登录';
      this.success = false;
      prompt.showToast({ message: '请先登录', duration: 2000 });
      return;
    }

    // 组织 shippingAddress
    const addr = this.getSelectedAddress();
    const shippingAddress = addr ? `${addr.name} ${addr.phone} ${addr.city} ${addr.detail}` : undefined;

    // 组织订单请求体
    const payload: CreateAdoptionOrderRequest = {
      userId: this.userId as number,
      petName: this.animal.name,
      petAddress: this.animal.city,
      image: this.animal.image,
      shippingAddress: shippingAddress,
      petExperience: this.experience || undefined,
      applicationReason: this.reason || undefined,
      status: '审核中' as OrderStatus
    };

    // 调用创建订单接口
    const created = await this.apiService.createAdoptionOrder(payload);
    if (!created) {
      this.errorMsg = '提交失败，请稍后重试';
      this.success = false;
      prompt.showToast({ message: '提交失败，请稍后重试', duration: 2000 });
      return;
    }

    // 提交成功：仅小弹窗提示，1秒后跳转首页
    this.errorMsg = '';
    this.success = true;
    prompt.showToast({ message: '申请已提交，等待审核！', duration: 1000 });
    setTimeout(() => {
      router.replaceUrl({ url: 'pages/Home/Home' });
    }, 1000);
  }

  build() {
    Column() {
      // 顶部栏
      Row() {
        Image($r('app.media.arrow_left'))
          .width(24)
          .height(24)
          .margin({ left: 16 })
          .onClick(() => router.back())
        
        Text('领养申请')
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
          Text('正在加载宠物信息...')
            .fontSize(16)
            .margin({ top: 20 })
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
          Text('加载宠物信息失败')
            .fontSize(18)
            .fontColor('#666')
          Button('返回')
            .type(ButtonType.Capsule)
            .backgroundColor(Color.Orange)
            .fontColor(Color.White)
            .fontSize(16)
            .width(120)
            .height(40)
            .margin({ top: 30 })
            .onClick(() => router.back())
        }
        .width('100%')
        .height('80%')
        .justifyContent(FlexAlign.Center)
      } else {
        // 正常内容，宠物信息已加载
        Scroll() {
          Column() {
            // 宠物信息
            Row() {
              // 显示图片：如果 resolvedImage 是本地资源 id，则使用 $r，否则直接使用 URL
              if (this.resolvedImage && this.resolvedImage.startsWith && this.resolvedImage.startsWith('app.media.')) {
                Image($r(this.resolvedImage))
                  .width(64)
                  .height(64)
                  .borderRadius(10)
                  .margin({ left:20, right:10 })
              } else {
                Image(this.resolvedImage)
                  .width(64)
                  .height(64)
                  .borderRadius(10)
                  .margin({ left:20, right:10 })
              }
              Column(){
                Row() {
                  Text(this.animal.name)
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)
                    .margin({right:10})
                  Column() {} // 分隔线
                  .width(1)
                  .height(16)
                  .backgroundColor('#ff929292')
                  .margin({right:10})
                  Image($r(this.animal.gender ? 'app.media.Animalgender' : 'app.media.Animalgenderf'))
                    .width(18)
                    .height(18)
                    .margin({ right: 10 })
                  Column() {} // 分隔线
                  .width(1)
                  .height(16)
                  .backgroundColor('#ff929292')
                  .margin({right:10})
                  Text(this.animal.age + '岁').fontSize(14).margin({ right: 10 })
                  Column() {} // 分隔线
                  .width(1)
                  .height(16)
                  .backgroundColor('#ff929292')
                  .margin({right:10})
                  Text(this.animal.city).fontSize(14)
                }
                .width('100%')
                Row() {
                  Text(this.animal.neutered ? '已绝育' : '未绝育')
                    .fontSize(12)
                    .fontColor(this.animal.neutered ? Color.White : Color.Red)
                    .backgroundColor(this.animal.neutered ? Color.Orange : '#ffe0e0')
                    .borderRadius(8)
                    .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                    .margin({right:10})
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
                    .margin({right:10})
                  Text('免费')
                    .fontSize(12)
                    .fontColor(this.animal.isFree ? Color.White : '#A259FF')
                    .backgroundColor(this.animal.isFree ? Color.Orange : '#f0e0ff')
                    .borderRadius(8)
                    .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                }
                .width('100%')
                .margin({ top: 10 })
              }
            }
            .width('95%')
            .height(90)
            .backgroundColor('#fff')
            .borderRadius(20)
            .margin({ left: 10, right: 10, bottom: 10, top: 8 })

            // 领养须知区域
            Column(){
              Row(){
                Text('领养须知')
                  .margin({left: 16})
                  .fontSize(15)
                  .fontWeight(FontWeight.Medium)
                Blank()
                Image($r('app.media.chevron_right'))
                  .width(12)
                  .height(12)
                  .margin({ right: 16 })
              }
              .margin({top:10, bottom:10})
              .width('100%')
              .onClick(() => {
                this.showRequirements = true
              })
            }
            .padding({top:10, bottom:10})
            .margin({ bottom:10})
            .borderRadius(20)
            .backgroundColor(Color.White)
            .width('95%')

            // 收货地址区域
            Column(){
              Row(){
                Text('收货地址')
                  .margin({left: 16})
                  .fontSize(15)
                  .fontWeight(FontWeight.Medium)
                Blank()
                if (this.addresses.length > 0) {
                  Text('选择地址')
                    .fontSize(13)
                    .fontColor(Color.Orange)
                    .margin({right: 16})
                    .onClick(() => { this.showAddressSelector = true; })
                } else {
                  Text('去新增')
                    .fontSize(13)
                    .fontColor(Color.Orange)
                    .margin({right: 16})
                    .onClick(() => { router.pushUrl({ url: 'pages/Profile/AddAddress' }); })
                }
              }
              .margin({ bottom:10 })
              .width('100%')

              if (this.addresses.length > 0 && this.selectedAddressId) {
                // 已有地址，展示已选地址摘要
                Column(){
                  Text(`${this.getSelectedAddress() ? this.getSelectedAddress()!.name : ''}  ${this.getSelectedAddress() ? this.getSelectedAddress()!.phone : ''}`)
                    .fontSize(14)
                    .margin({ left: 16, bottom: 4 })
                  Text(`${this.getSelectedAddress() ? this.getSelectedAddress()!.city : ''} ${this.getSelectedAddress() ? this.getSelectedAddress()!.detail : ''}`)
                    .fontSize(13)
                    .fontColor('#666')
                    .margin({ left: 16 })
                }
                .width('100%')
              } else {
                // 无地址提示新增
                Column(){
                  Text('您还没有收货地址')
                    .fontSize(14)
                    .fontColor('#666')
                    .margin({ left: 16, bottom: 10 })
                  Button('新增地址')
                    .type(ButtonType.Capsule)
                    .backgroundColor(Color.Orange)
                    .fontColor(Color.White)
                    .width(120)
                    .height(36)
                    .margin({ left: 16 })
                    .onClick(() => { router.pushUrl({ url: 'pages/Profile/AddAddress' }); })
                }
                .width('100%')
              }
            }
            .padding({top:10, bottom:10})
            .margin({ bottom:10})
            .borderRadius(20)
            .backgroundColor(Color.White)
            .width('95%')

            // 表单区域
            Column({ space: 16 }) {
              Text('申请人信息')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .width('100%')
                .textAlign(TextAlign.Start)
                .margin({ left: 16 })
              
              // 姓名
              Column() {
                Text('姓名')
                  .fontSize(14)
                  .fontColor('#666')
                  .margin({ left: 16 })
                
                TextInput({ placeholder: '请输入您的姓名', text: this.name })
                  .onChange((value: string) => { this.name = value })
                  .backgroundColor(Color.Transparent)
                  .fontSize(16)
                  .height(48)
                  .width('90%')
                  .placeholderColor('#999')
                
                Divider().width('90%').color('#EEEEEE')
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
              
              // 养宠经验
              Column() {
                Text('养宠经验 (选填)')
                  .fontSize(14)
                  .fontColor('#666')
                  .margin({ left: 16 })
                
                TextInput({ placeholder: '请描述您的养宠经验', text: this.experience })
                  .onChange((value: string) => { this.experience = value })
                  .backgroundColor(Color.Transparent)
                  .fontSize(16)
                  .height(48)
                  .width('90%')
                  .placeholderColor('#999')
                
                Divider().width('90%').color('#EEEEEE')
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
              
              // 申请理由
              Column() {
                Text('申请理由')
                  .fontSize(14)
                  .fontColor('#666')
                  .margin({ left: 16 })
                
                TextArea({ placeholder: '请详细描述您想领养的理由...', text: this.reason })
                  .onChange((value: string) => { this.reason = value })
                  .backgroundColor(Color.Transparent)
                  .fontSize(16)
                  .height(120)
                  .width('90%')
                  .placeholderColor('#999')
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
            }
            .padding({top:20, bottom:20})
            .margin({ bottom:10 })
            .borderRadius(20)
            .backgroundColor(Color.White)
            .width('95%')

            // 错误或成功提示
            if (this.errorMsg) {
              Text(this.errorMsg)
                .fontColor(Color.Red)
                .fontSize(14)
                .width('90%')
                .textAlign(TextAlign.Center)
                .margin({ bottom: 10 })
            }
            
            // 成功信息改为弹窗展示

            // 提交按钮
            Button('提交申请')
              .type(ButtonType.Capsule)
              .backgroundColor(Color.Orange)
              .fontColor(Color.White)
              .fontSize(18)
              .width('90%')
              .height(50)
              .margin({ bottom: 20 })
              .onClick(() => this.submit())
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
        .edgeEffect(EdgeEffect.Spring)
      }
      
      // 领养须知弹窗
      if (this.showRequirements) {
        Column() {
          Column() {
            Text('领养须知')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .margin({ top: 20, bottom: 20 })
            
            Column({ space: 10 }) {
              Text('1. 年满18周岁，有民事行为能力')
                .fontSize(14)
                .width('90%')
                .textAlign(TextAlign.Start)
              
              Text('2. 有稳定的居住环境和经济能力')
                .fontSize(14)
                .width('90%')
                .textAlign(TextAlign.Start)
              
              Text('3. 接受领养前家访和领养后回访')
                .fontSize(14)
                .width('90%')
                .textAlign(TextAlign.Start)
              
              Text('4. 承诺不遗弃，不虐待，按时免疫')
                .fontSize(14)
                .width('90%')
                .textAlign(TextAlign.Start)
              
              Text('5. 接受领养协议的各项条款')
                .fontSize(14)
                .width('90%')
                .textAlign(TextAlign.Start)

              Text('6. 进行实名认证，并且通过')
                .fontSize(14)
                .width('90%')
                .textAlign(TextAlign.Start)
            }
            .margin({ bottom: 20 })
            
            Button('我已了解')
              .type(ButtonType.Capsule)
              .backgroundColor(Color.Orange)
              .fontColor(Color.White)
              .width('80%')
              .height(40)
              .margin({ bottom: 20 })
              .onClick(() => {
                this.showRequirements = false;
              })
          }
          .width('90%')
          .backgroundColor(Color.White)
          .border({ width: 2, color: '#ffcfcfcf' })
          .borderRadius(16)
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#00000080')
        .position({ x: 0, y: 0 })
        .zIndex(100)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          // 点击背景不关闭
          return false;
        })
      }

      // 地址选择弹窗
      if (this.showAddressSelector) {
        Column() {
          Column() {
            Row(){
              Text('选择收货地址')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
              Blank()
              Image($r('app.media.xmark_circle_fill'))
                .width(20)
                .height(20)
                .margin({ right: 12 })
                .onClick(() => { this.showAddressSelector = false; })
            }
            .width('90%')
            .margin({ top: 16, bottom: 10 })

            if (this.addresses.length > 0) {
              // 可滚动地址列表
              Scroll(){
                Column(){
                  ForEach(this.addresses, (addr: Address) => {
                    Column(){
                      Row(){
                        Text(`${addr.name}  ${addr.phone}`)
                          .fontSize(15)
                          .fontWeight(this.isAddrSelected(addr) ? FontWeight.Medium : FontWeight.Regular)
                        Blank()
                        if (this.isAddrSelected(addr)) {
                          Text('已选择')
                            .fontSize(12)
                            .fontColor(Color.Orange)
                        }
                      }
                      .width('100%')
                      .margin({ bottom: 4 })
                      Text(`${addr.city} ${addr.detail}`)
                        .fontSize(13)
                        .fontColor('#666')
                      Divider().width('100%').color('#EEEEEE').margin({ top: 10 })
                    }
                    .width('90%')
                    .padding({ top: 10, bottom: 10 })
                    .onClick(() => {
                      this.selectedAddressId = String(addr.id);
                      this.showAddressSelector = false;
                    })
                  })
                }
                .width('100%')
              }
              .width('100%')
              .height(260)
              .scrollBar(BarState.Off)

              Row(){
                Button('关闭')
                  .type(ButtonType.Capsule)
                  .backgroundColor('#f0f0f0')
                  .fontColor('#333')
                  .width(120)
                  .height(36)
                  .onClick(() => { this.showAddressSelector = false; })
                Blank()
                Button('去新增')
                  .type(ButtonType.Capsule)
                  .backgroundColor(Color.Orange)
                  .fontColor(Color.White)
                  .width(120)
                  .height(36)
                  .onClick(() => { this.showAddressSelector = false; router.pushUrl({ url: 'pages/Profile/AddAddress' }); })
              }
              .width('90%')
              .margin({ top: 12, bottom: 16 })
            } else {
              // 无地址时的提示
              Column(){
                Text('暂无收货地址')
                  .fontSize(15)
                  .fontColor('#666')
                  .margin({ bottom: 12 })
                Button('去新增地址')
                  .type(ButtonType.Capsule)
                  .backgroundColor(Color.Orange)
                  .fontColor(Color.White)
                  .width(180)
                  .height(40)
                  .onClick(() => { this.showAddressSelector = false; router.pushUrl({ url: 'pages/Profile/AddAddress' }); })
              }
              .width('90%')
              .margin({ top: 20, bottom: 20 })
            }
          }
          .width('90%')
          .backgroundColor(Color.White)
          .border({ width: 2, color: '#ffcfcfcf' })
          .borderRadius(16)
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#00000080')
        .position({ x: 0, y: 0 })
        .zIndex(100)
        .justifyContent(FlexAlign.Center)
        .onClick(() => { return false; })
      }
    }
    .height('100%')
    .width('100%')
    .backgroundColor('#ffefefef')
  }
}