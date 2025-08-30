import { router } from '@kit.ArkUI';
import { UserInfo } from '../../common/models/UserInfo';
import { UserService } from '../../common/database/UserService';
import prompt from '@system.prompt';
import { ApiService } from '../../common/services/ApiService';

@Entry
@Component
struct EditProfile {
  // 默认不在代码中嵌入示例用户信息，使用空对象或运行时从存储/接口获取
  @StorageLink('userInfo') userInfo: UserInfo = {
    username: '',
    avatar: '',
    gender: '',
    phone: '',
    email: '',
    address: '',
    birthday: ''
  };

  
  // 使用后端与本地存储的头像数据进行展示

  // 本地编辑副本状态
  @State username: string = '';
  @State gender: string = '';
  @State phone: string = '';
  @State email: string = '';
  @State address: string = '';
  @State selectedProvince: string = '';
  @State selectedCity: string = '';
  @State provinces: string[] = [];
  @State cities: string[] = [];
  @State birthday: string = '';
  @State avatar: string = '';

  // 与界面相关的状态
  @State isLoading: boolean = false;
  @State showGenderPicker: boolean = false;
  @State showDatePicker: boolean = false;
  private userService: UserService = UserService.getInstance();
  private apiService: ApiService = ApiService.getInstance();

  // 性别选项
  private genderOptions: string[] = ['男', '女'];
  // 使用后端接口提供省份与地级市，不使用本地静态数据

  async onPageShow() {
    console.info('EditProfile页面显示，开始加载用户数据');
    
    // 1) 从全局存储拿用户信息
    const current = AppStorage.Get<UserInfo>('userInfo');
    if (current && current.username) {
      this.userInfo = current;
      console.info(`从全局存储获取到用户信息: ${current.username}`);
    } else {
      console.warn('全局存储中没有用户信息');
      prompt.showToast({ message: '请先登录', duration: 2000 });
      router.back();
      return;
    }

    const username = this.userInfo.username;
    if (!username) {
      console.error('用户名为空，无法继续');
      prompt.showToast({ message: '用户信息错误，请重新登录', duration: 2000 });
      router.back();
      return;
    }
    
    this.isLoading = true;
    try {
      // 2) 优先从后端获取最新用户信息
      console.info(`正在从后端获取用户信息: ${username}`);
      const remote = await this.apiService.getUserInfo(username);
      if (remote) {
        console.info(`成功从后端获取用户信息: ${JSON.stringify(remote)}`);
        this.userInfo = remote;
        AppStorage.Set<UserInfo>('userInfo', remote);
        // 写入本地缓存
        await this.userService.init();
        await this.userService.saveUserInfo(remote);
      } else {
        console.warn('后端获取用户信息失败，使用本地缓存');
        // 3) 网络失败/无数据 -> 回退本地缓存
        await this.userService.init();
        const local = await this.userService.getUserInfo(username);
        if (local) {
          this.userInfo = local;
          AppStorage.Set<UserInfo>('userInfo', local);
          prompt.showToast({ message: '使用离线数据', duration: 1500 });
        }
      }
    } catch (e) {
      console.error('加载用户信息异常: ' + e);
      try {
        await this.userService.init();
        const local = await this.userService.getUserInfo(username);
        if (local) {
          this.userInfo = local;
          AppStorage.Set<UserInfo>('userInfo', local);
          prompt.showToast({ message: '网络异常，使用离线数据', duration: 1800 });
        }
      } catch (localError) {
        console.error('本地数据也获取失败: ' + localError);
      }
    } finally {
      // 同步到本地编辑状态
      this.username = this.userInfo.username || '';
      this.gender = this.userInfo.gender || '男';
      this.phone = this.userInfo.phone || '';
      this.email = this.userInfo.email || '';
      this.address = this.userInfo.address || '';
      this.birthday = this.userInfo.birthday || '';
      this.avatar = this.userInfo.avatar || 'app.media.man';
      
      console.info(`编辑状态已同步: 用户名=${this.username}, 性别=${this.gender}`);

      try {
        this.provinces = await this.apiService.getProvinces();
      } catch (e) {
        console.warn('加载省份失败', e);
        this.provinces = [];
      }

      // 解析省市
      if (this.address && this.address.trim().length > 0) {
        const parts = this.address.split(/[\s,，-]+/);
        if (parts.length >= 2) {
          this.selectedProvince = parts[0];
          this.selectedCity = parts[1];
        } else {
          const provList = this.provinces || [];
          for (let i = 0; i < provList.length; i++) {
            const prov = provList[i];
            if (this.address.indexOf(prov) !== -1) {
              this.selectedProvince = prov;
              const rest = this.address.replace(prov, '').trim();
              this.selectedCity = rest || '';
              break;
            }
          }
        }
      }
      this.isLoading = false;
    }
  }

  async onSave() {
    console.info('开始保存用户信息');
    
    if (!this.validateInputs()) {
      return;
    }
    
    // 检查当前用户信息是否有效
    if (!this.userInfo || !this.userInfo.username) {
      console.error('当前用户信息为空，无法保存');
      prompt.showToast({ message: '用户信息错误，请重新登录', duration: 2000 });
      return;
    }

    this.isLoading = true;

    try {
      // 构造待提交的字段（Partial）
      const payload = {
        username: this.username.trim(),
        gender: this.gender,
        phone: this.phone.trim(),
        email: this.email.trim(),
        address: this.selectedProvince && this.selectedCity ? `${this.selectedProvince} ${this.selectedCity}` : this.address.trim(),
        birthday: this.birthday,
        avatar: this.avatar
      } as Partial<UserInfo>;

      console.info(`保存用户信息: 原用户名=${this.userInfo.username}, 新用户名=${this.username}`);
      console.info(`payload: ${JSON.stringify(payload)}`);

      // 1) 调用后端更新
      const updated = await this.apiService.updateUserInfo(this.userInfo.username, payload);
      console.info(`后端更新结果: ${updated ? '成功' : '失败'}`);
      
      if (updated) {
        console.info(`后端返回的更新数据: ${JSON.stringify(updated)}`);
        
        // 2) 更新全局存储
        this.userInfo = updated;
        AppStorage.Set<UserInfo>('userInfo', updated);
        
        // 3) 同步本地缓存
        try {
          await this.userService.init();
          await this.userService.saveUserInfo(updated);
          console.info('本地缓存更新成功');
        } catch (localError) {
          console.warn(`本地缓存更新失败: ${localError}`);
          // 本地缓存失败不影响主流程
        }

        prompt.showToast({ message: '保存成功', duration: 2000 });
        router.back();
      } else {
        console.error('后端更新返回空值');
        // 网络失败：降级为本地缓存更新（离线策略）
        try {
          await this.userService.init();
          const mergedData = this.mergeUserInfo(this.userInfo, payload);
          const offlineData = await this.userService.updateUserInfo(this.userInfo.username, mergedData);
          if (offlineData) {
            this.userInfo = offlineData;
            AppStorage.Set<UserInfo>('userInfo', offlineData);
            prompt.showToast({ message: '网络异常，已离线保存', duration: 2000 });
            router.back();
          } else {
            prompt.showToast({ message: '保存失败', duration: 2000 });
          }
        } catch (offlineError) {
          console.error(`离线保存失败: ${offlineError}`);
          prompt.showToast({ message: '保存失败', duration: 2000 });
        }
      }
    } catch (error) {
      console.error(`保存用户信息异常: ${error}`);
      prompt.showToast({
        message: '保存失败，请重试',
        duration: 2000,
      });
    } finally {
      this.isLoading = false;
    }
  }

  validateInputs(): boolean {
    // 验证用户名
    if (!this.username || this.username.trim().length === 0) {
      prompt.showToast({
        message: '用户名不能为空',
        duration: 2000,
      });
      return false;
    }
    
    if (this.username.trim().length < 4 || this.username.trim().length > 12) {
      prompt.showToast({
        message: '用户名长度必须在4-12位之间',
        duration: 2000,
      });
      return false;
    }
    
    // 验证用户名格式（只允许中文、英文、数字和下划线）
    const usernameRegex = /^[\u4e00-\u9fa5a-zA-Z0-9_]+$/;
    if (!usernameRegex.test(this.username.trim())) {
      prompt.showToast({
        message: '用户名只能包含中文、英文、数字和下划线',
        duration: 2000,
      });
      return false;
    }

    // 如果填写了邮箱则校验格式
    if (this.email && this.email.trim().length > 0) {
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      if (!emailRegex.test(this.email)) {
        prompt.showToast({
          message: '邮箱格式不正确',
          duration: 2000,
        });
        return false;
      }
    }

    // 如果填写了手机号则校验格式
    if (this.phone && this.phone.trim().length > 0) {
      const phoneRegex = /^1[3-9]\d{9}$/;
      if (!phoneRegex.test(this.phone)) {
        prompt.showToast({
          message: '手机号格式不正确',
          duration: 2000,
        });
        return false;
      }
    }

    return true;
  }

  // 显式合并用户信息，避免使用受限标准库与未类型化对象字面量
  private mergeUserInfo(base: UserInfo, patch: Partial<UserInfo>): UserInfo {
    const result: UserInfo = {
      id: base.id,
      username: patch.username !== undefined ? patch.username as string : base.username,
      avatar: patch.avatar !== undefined ? patch.avatar as string : base.avatar,
      gender: patch.gender !== undefined ? patch.gender as string : base.gender,
      phone: patch.phone !== undefined ? patch.phone as string : base.phone,
      email: patch.email !== undefined ? patch.email as string : base.email,
      address: patch.address !== undefined ? patch.address as string : base.address,
      birthday: patch.birthday !== undefined ? patch.birthday as string : base.birthday,
      password: base.password
    };
    return result;
  }

  // 自定义生日选择器
  showBirthdayPicker() {
    // 使用 ArkUI 的 DatePickerDialog 弹窗
    DatePickerDialog.show({
      start: new Date('1900-01-01'),
      end: new Date(),
      selected: this.birthday ? new Date(this.birthday) : new Date(),
      onAccept: (value: DatePickerResult) => {
        // 将日期格式化为 YYYY-MM-DD
        const year = value.year || new Date().getFullYear();
        const monthValue = value.month !== undefined ? value.month + 1 : new Date().getMonth() + 1;
        const month = monthValue.toString().padStart(2, '0');
        const day = (value.day || new Date().getDate()).toString().padStart(2, '0');
        this.birthday = `${year}-${month}-${day}`;
      }
    });
  }

  build() {
    Column() {
      // 顶部：返回按钮与标题
      Row() {
        Image($r('app.media.arrow_left'))
          .width(24)
          .height(24)
          .margin({ left: 16 })
          .onClick(() => {
            router.back();
          })

        Text('编辑个人资料')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Text('保存')
          .fontSize(16)
          .fontColor(Color.Orange)
          .margin({ right: 16 })
          .onClick(() => {
            this.onSave();
          })
      }
      .width('100%')
      .height(50)
      .backgroundColor(Color.White)

      // 主体：使用 List 提升滚动体验
      List() {
        // 头像区域：圆形白底、阴影与边框
        ListItem() {
          Row() {
            Column() {
              Stack() {
                // 背景圆盘
                Column()
                  .width(96)
                  .height(96)
                  .borderRadius(48)
                  .backgroundColor(Color.White)
                  .shadow({ radius: 6, color: '#E0E0E0', offsetY: 2 })
                  .border({ width: 1, color: '#F0F0F0' })
                  // 头像兼容：URL/data 与 本地资源
                    Image($r(this.userInfo.avatar))
                      .width(80)
                      .height(80)
                      .borderRadius(40)
                      .alignSelf(ItemAlign.Center)
                      .objectFit(ImageFit.Cover)
              }
              .width('100%')
              .alignSelf(ItemAlign.Center)

            }
            .width('100%')
            .alignItems(HorizontalAlign.Center)
          }
          .padding({ top: 20, bottom: 20 })
          .backgroundColor("#ffefefef")
          .width('95%')
          .borderRadius(20)
          .margin({ top: 10, left: '2.5%', right: '2.5%' })
        }
        
        // 表单区域
        ListItem() {
          Column() {
            // 用户名
            Row() {
              Text('用户名')
                .fontSize(16)
                .width(80)
              
              TextInput({ text: this.username })
                .fontSize(16)
                .layoutWeight(1)
                .backgroundColor(Color.Transparent)
                .placeholderColor('#999999')
                .placeholderFont({ size: 16 })
                .height(40)
                .onChange((value: string) => {
                  this.username = value;
                })
            }
            .padding({ top: 12, bottom: 12, left: 16, right: 16 })
            .width('90%')
            .alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.Start)
            
            Divider().width('90%').color('#EEEEEE').margin({left: 'auto', right: 'auto'})
            
            // 性别
            Row() {
              Text('性别')
                .fontSize(16)
                .width(80)
              
              Text(this.gender)
                .fontSize(16)
                .layoutWeight(1)
                .textAlign(TextAlign.Start)
                .margin({left:15})
                
              Image(this.gender === '男' ? $r('app.media.icon_male') : $r('app.media.icon_female'))
                .width(20)
                .height(20)
                .margin({ right: 16 })
            }
            .padding({ top: 12, bottom: 12, left: 16, right: 16 })
            .width('90%')
            .alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.Start)
            .onClick(() => {
              // 使用TextPickerDialog显示性别选择
              TextPickerDialog.show({
                // 传入一维数组，显示两项：'男'、'女'
                range: this.genderOptions,
                selected: this.gender === '男' ? 0 : 1,
                onAccept: (result) => {
                  const selectedIndex = Array.isArray(result.index) ? result.index[0] : result.index;
                  this.gender = this.genderOptions[selectedIndex];
                  console.info('选择性别: ' + this.gender);
                },
                onCancel: () => {
                  console.info('取消选择性别');
                }
              })
            })
            
            Divider().width('90%').color('#EEEEEE').margin({left: 'auto', right: 'auto'})
            
            // 手机
            Row() {
              Text('手机')
                .fontSize(16)
                .width(80)
              
              TextInput({ text: this.phone })
                .fontSize(16)
                .layoutWeight(1)
                .backgroundColor(Color.Transparent)
                .placeholderColor('#999999')
                .placeholderFont({ size: 16 })
                .type(InputType.Number)
                .height(40)
                .onChange((value: string) => {
                  this.phone = value;
                })
            }
            .padding({ top: 12, bottom: 12, left: 16, right: 16 })
            .width('90%')
            .alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.Start)
            
            Divider().width('90%').color('#EEEEEE').margin({left: 'auto', right: 'auto'})
            
            // 邮箱
            Row() {
              Text('邮箱')
                .fontSize(16)
                .width(80)
              
              TextInput({ text: this.email })
                .fontSize(16)
                .layoutWeight(1)
                .backgroundColor(Color.Transparent)
                .placeholderColor('#999999')
                .placeholderFont({ size: 16 })
                .height(40)
                .onChange((value: string) => {
                  this.email = value;
                })
            }
            .padding({ top: 12, bottom: 12, left: 16, right: 16 })
            .width('90%')
            .alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.Start)
            
            Divider().width('90%').color('#EEEEEE').margin({left: 'auto', right: 'auto'})
            
            // 地址：省市选择
            Row() {
              Text('地址')
                .fontSize(16)
                .width(80)

              Column() {
                // 显示已选省/市或占位文字
                Row() {
                  Text(this.selectedProvince || '请选择省份')
                    .fontSize(16)
                    .layoutWeight(1)
                    .fontColor(this.selectedProvince ? '#000' : '#999')
                    .margin({ left: 8 })

                  Image($r('app.media.chevron_right'))
                    .width(18)
                    .height(18)
                    .margin({ right: 8 })
                }
                .height(40)
                .onClick(async () => {
                  // 省份选择器：使用已加载的 this.provinces
                  if (!this.provinces || this.provinces.length === 0) {
                    prompt.showToast({ message: '未能获取省份列表', duration: 1500 });
                    return;
                  }

                  TextPickerDialog.show({
                    range: this.provinces,
                    selected: Math.max(0, this.provinces.indexOf(this.selectedProvince)),
                    onAccept: (result) => {
                      const idx = Array.isArray(result.index) ? result.index[0] : result.index;
                      this.selectedProvince = this.provinces[idx] || '';
                      // 省变更后清空城市选择
                      this.selectedCity = '';
                    }
                  })
                })

                Divider().width('100%').color('#FFFFFF00').margin({ top: 6 })

                Row() {
                  Text(this.selectedCity || '请选择市区')
                    .fontSize(16)
                    .layoutWeight(1)
                    .fontColor(this.selectedCity ? '#000' : '#999')
                    .margin({ left: 8 })

                  Image($r('app.media.chevron_right'))
                    .width(18)
                    .height(18)
                    .margin({ right: 8 })
                }
                .height(40)
                .onClick(async () => {
                  // 城市选择：根据选中的省从后端加载城市列表
                  if (!this.selectedProvince) {
                    prompt.showToast({ message: '请先选择省份', duration: 1500 });
                    return;
                  }

                  try {
                    this.cities = await this.apiService.getCitiesByProvince(this.selectedProvince);
                  } catch (e) {
                    console.warn('获取城市失败', e);
                    this.cities = [];
                  }

                  if (!this.cities || this.cities.length === 0) {
                    prompt.showToast({ message: '未找到该省的地级市', duration: 1500 });
                    return;
                  }

                  TextPickerDialog.show({
                    range: this.cities,
                    selected: Math.max(0, this.cities.indexOf(this.selectedCity)),
                    onAccept: (result) => {
                      const idx = Array.isArray(result.index) ? result.index[0] : result.index;
                      this.selectedCity = this.cities[idx] || '';
                    }
                  })
                })
              }
              .layoutWeight(1)
            }
            .padding({ top: 12, bottom: 12, left: 16, right: 16 })
            .width('90%')
            .alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.Start)
            
            Divider().width('90%').color('#EEEEEE').margin({left: 'auto', right: 'auto'})
            
            // Birthday
            Row() {
              Text('生日')
                .fontSize(16)
                .width(80)
              
              Text(this.birthday || '请选择生日')
                .fontSize(16)
                .layoutWeight(1)
                .textAlign(TextAlign.Start)
                .fontColor(this.birthday ? '#000000' : '#999999')
                .margin({left:15})
                
              Image($r('app.media.birthday'))
                .width(20)
                .height(20)
                .margin({ right: 16 })
            }
            .padding({ top: 12, bottom: 12, left: 16, right: 16 })
            .width('90%')
            .alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.Start)
            .onClick(() => {
              this.showBirthdayPicker();
            })
          }
          .padding({ top: 10, bottom: 10 })
          .backgroundColor(Color.White)
          .width('95%')
          .borderRadius(20)
          .margin({ top: 10, bottom: 20, left: '2.5%', right: '2.5%' })
          .alignItems(HorizontalAlign.Center)
        }
      }
      .width('100%')
      .height('100%')
      .edgeEffect(EdgeEffect.Spring)  // 添加弹性效果
      .scrollBar(BarState.Off)        // 隐藏滚动条
      .layoutWeight(1)                // 占用剩余空间
      .width('100%')
      .backgroundColor('#ffefefef')
      .alignListItem(ListItemAlign.Center) // 居中列表项
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#ffefefef')
  }
} 