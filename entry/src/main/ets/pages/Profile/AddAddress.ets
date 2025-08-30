import { router } from '@kit.ArkUI';
import { AddressService } from '../../common/database/AddressService';
import prompt from '@system.prompt';
import { UserInfo, AddressRequest } from '../../common/models/UserInfo';

@Entry
@Component
struct AddAddress {
  @State name: string = '';
  @State phone: string = '';
  @State city: string = '';
  @State detail: string = '';
  @State isDefault: boolean = false;
  @State isSaving: boolean = false;
  @State isEdit: boolean = false;
  @State addressId: string = '';
  @StorageLink('userInfo') userInfo: UserInfo = { 
    username: '',
    avatar: 'app.media.man',
    gender: '男'
  };
  private addressService: AddressService = AddressService.getInstance();

  aboutToAppear() {
    // 获取路由参数，用于编辑模式
    const params: Record<string, string | boolean> = router.getParams() as Record<string, string | boolean>;
    if (params && params.isEdit) {
      this.isEdit = true;
      this.addressId = (params.addressId as string) || '';
      this.name = (params.name as string) || '';
      this.phone = (params.phone as string) || '';
      this.city = (params.city as string) || '';
      this.detail = (params.detail as string) || '';
      this.isDefault = Boolean(params.isDefault || false);
    }
  }

  build() {
    Column() {
      // 顶部栏
      Row() {
        Button() {
          Image($r('app.media.arrow_left'))
            .width(24)
            .height(24)
            .fillColor('#1C1C1E')
        }
        .type(ButtonType.Normal)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          router.back();
        })

        Text(this.isEdit ? '编辑地址' : '新增地址')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1C1C1E')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        // 占位，保持标题居中
        Row()
          .width(24)
          .height(24)
      }
      .width('100%')
      .height(56)
      .backgroundColor(Color.White)
      .padding({ left: 16, right: 16 })
      .border({ width: { bottom: 0.5 }, color: '#E5E5EA' })

      // 地址表单
      Column() {
        // 收货人
        Column() {
          Text('收货人')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 8 })
          
          TextInput({ placeholder: '请输入收货人姓名', text: this.name })
            .height(48)
            .width('100%')
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .onChange((value: string) => {
              this.name = value;
            })
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        .margin({ bottom: 20, top:10 })

        // 手机号
        Column() {
          Text('手机号')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 8 })
          
          TextInput({ placeholder: '请输入手机号码', text: this.phone })
            .height(48)
            .width('100%')
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .type(InputType.Number)
            .onChange((value: string) => {
              this.phone = value;
            })
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        .margin({ bottom: 20 })

        // 所在地区
        Column() {
          Text('所在地区')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 8 })
          
          TextInput({ placeholder: '请输入所在城市', text: this.city })
            .height(48)
            .width('100%')
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .onChange((value: string) => {
              this.city = value;
            })
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        .margin({ bottom: 20 })

        // 详细地址
        Column() {
          Text('详细地址')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 8 })
          
          TextArea({ placeholder: '请输入详细地址信息，如道路、门牌号、小区、楼栋号、单元室等', text: this.detail })
            .height(100)
            .width('100%')
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .onChange((value: string) => {
              this.detail = value;
            })
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        .margin({ bottom: 20 })

        // 设为默认地址
        Row() {
          Text('设为默认地址')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
          
          Blank()
          
          Toggle({ type: ToggleType.Switch, isOn: this.isDefault })
            .height(26)
            .width(44)
            .selectedColor(Color.Orange)
            .onChange((isOn: boolean) => {
              this.isDefault = isOn;
            })
        }
        .width('100%')
        .margin({ bottom: 30 })
      }
      .padding({ left: 20, right: 20 })
      .backgroundColor(Color.White)
      .borderRadius(12)
      .width('94%')
      .margin({ bottom: 20 })

      // 保存按钮
      Button({ type: ButtonType.Capsule }) {
        if (this.isSaving) {
          Row() {
            LoadingProgress()
              .width(20)
              .height(20)
              .color(Color.White)
              .margin({ right: 10 })
            Text('保存中...').fontSize(18)
          }
        } else {
          Text(this.isEdit ? '更新地址' : '保存地址').fontSize(18)
        }
      }
      .backgroundColor(Color.Orange)
      .fontColor(Color.White)
      .width('90%')
      .height(50)
      .enabled(!this.isSaving)
      .onClick(() => {
        this.saveAddress();
      })
    }
    .height('100%')
    .width('100%')
    .backgroundColor('#F5F6FA')
  }

  async saveAddress() {
    // 表单验证
    if (!this.name || this.name.trim() === '') {
      prompt.showToast({ message: '请输入收货人姓名', duration: 2000 });
      return;
    }
    
    if (!this.phone || this.phone.trim() === '') {
      prompt.showToast({ message: '请输入手机号码', duration: 2000 });
      return;
    }
    
    if (!/^1[3-9]\d{9}$/.test(this.phone)) {
      prompt.showToast({ message: '请输入正确的手机号码', duration: 2000 });
      return;
    }
    
    if (!this.city || this.city.trim() === '') {
      prompt.showToast({ message: '请输入所在地区', duration: 2000 });
      return;
    }
    
    if (!this.detail || this.detail.trim() === '') {
      prompt.showToast({ message: '请输入详细地址', duration: 2000 });
      return;
    }
    
    // 检查用户登录
    if (!this.userInfo || !this.userInfo.username) {
      prompt.showToast({ message: '用户未登录，无法添加地址', duration: 2000 });
      return;
    }
    
    this.isSaving = true;
    
    try {
      // 初始化地址服务
      await this.addressService.init();
      
      // 准备地址请求对象
      const addressRequest: AddressRequest = {
        name: this.name.trim(),
        phone: this.phone.trim(),
        city: this.city.trim(),
        detail: this.detail.trim(),
        isDefault: this.isDefault
      };
      
      let success: boolean = false;
      
      if (this.isEdit && this.addressId) {
        // 更新已有地址
        success = await this.addressService.updateAddress(this.userInfo.username, this.addressId, addressRequest);
        if (success) {
          prompt.showToast({ message: '地址更新成功', duration: 2000 });
        } else {
          prompt.showToast({ message: '地址更新失败，请重试', duration: 2000 });
        }
      } else {
        // 添加新地址
        const addressId = await this.addressService.addAddress(this.userInfo.username, addressRequest);
        success = !!addressId;
        if (success) {
          prompt.showToast({ message: '地址添加成功', duration: 2000 });
        } else {
          prompt.showToast({ message: '地址添加失败，请重试', duration: 2000 });
        }
      }
      
      if (success) {
        setTimeout(() => {
          router.back();
        }, 1000);
      }
    } catch (error) {
      console.error(`${this.isEdit ? '更新' : '添加'}地址失败: ${error}`);
      prompt.showToast({ message: `${this.isEdit ? '更新' : '添加'}地址失败，请重试`, duration: 2000 });
    } finally {
      this.isSaving = false;
    }
  }
} 