import { router } from '@kit.ArkUI';
import { AddressService } from '../../common/database/AddressService';
import prompt from '@system.prompt';
import { UserInfo, Address } from '../../common/models/UserInfo';

@Entry
@Component
struct MyAddress {
  @State addresses: Address[] = [];
  @State isLoading: boolean = false;
  @StorageLink('userInfo') userInfo: UserInfo = { 
    username: '',
    avatar: 'app.media.man',
    gender: '男'
  };
  private addressService: AddressService = AddressService.getInstance();
  
  aboutToAppear() {
    this.loadAddresses(false); // 不显示刷新提示
  }
  
  onPageShow() {
    // 当页面重新显示时（如从添加地址页面返回时），稍微延迟一下再刷新地址列表
    // 这样可以确保页面已经完全过渡，提供更流畅的用户体验
    setTimeout(() => {
      this.loadAddresses(false); // 不显示刷新提示
    }, 300);
  }
  
  async loadAddresses(showRefreshToast: boolean = true) {
    // 如果 @StorageLink 还未同步 userInfo 或页面来自其他入口，尝试从 AppStorage 读取一次
    try {
      const stored = AppStorage.Get<UserInfo>('userInfo') as UserInfo | undefined;
      if ((!this.userInfo || !this.userInfo.username) && stored && stored.username) {
        this.userInfo = stored;
      }
    } catch (e) {
      console.warn('读取 AppStorage.userInfo 失败: ' + e);
    }

    if (!this.userInfo || !this.userInfo.username) {
      prompt.showToast({
        message: '用户未登录，无法获取地址信息',
        duration: 2000
      });
      return;
    }

    this.isLoading = true;
    try {
      // 初始化地址服务（并检查是否成功）
      const inited = await this.addressService.init();
      if (!inited) {
        console.error('AddressService 初始化失败，无法获取地址');
        prompt.showToast({ message: '无法连接后端服务，获取地址失败', duration: 2000 });
        return;
      }

      // 获取地址列表
      const addresses = await this.addressService.getAddresses(this.userInfo.username);
      this.addresses = addresses;
      
      if (addresses.length === 0) {
        console.info('未找到地址信息');
      } else {
        console.info(`获取到${addresses.length}条地址信息`);
        // 刷新成功提示，仅在手动刷新时显示
        if (showRefreshToast) {
          prompt.showToast({
            message: '地址列表已更新',
            duration: 1000
          });
        }
      }
    } catch (error) {
      console.error(`加载地址失败: ${error}`);
      prompt.showToast({
        message: '加载地址失败，请重试',
        duration: 2000
      });
    } finally {
      this.isLoading = false;
    }
  }
  
  async deleteAddress(addressId: string) {
    if (!this.userInfo || !this.userInfo.username) {
      prompt.showToast({
        message: '用户未登录，无法删除地址',
        duration: 2000
      });
      return;
    }
    
    try {
      const success = await this.addressService.deleteAddress(this.userInfo.username, addressId);
      if (success) {
        prompt.showToast({
          message: '地址删除成功',
          duration: 2000
        });
        
        // 刷新地址列表
        this.addresses = this.addresses.filter(addr => addr.id !== addressId);
      } else {
        prompt.showToast({
          message: '地址删除失败，请重试',
          duration: 2000
        });
      }
    } catch (error) {
      console.error(`删除地址失败: ${error}`);
      prompt.showToast({
        message: '删除地址失败，请重试',
        duration: 2000
      });
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        // 顶部栏
        Row() {
          Button() {
            Image($r('app.media.arrow_left'))
              .width(24)
              .height(24)
          }
          .type(ButtonType.Normal)
          .backgroundColor(Color.Transparent)
          .onClick(() => router.back())
          .margin({ left: 10})
          Text('我的地址')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .margin({left:119})
        }
        .width('100%')
        .height(56)
        .backgroundColor('#fff')
        .borderRadius({ bottomLeft: 16, bottomRight: 16 })
        .margin({ bottom: 8 })
  
        // 地址列表区域
        if (this.isLoading) {
          // 加载中状态
          Column() {
            LoadingProgress()
              .width(50)
              .height(50)
              .color(Color.Orange)
            Text('加载中...')
              .fontSize(16)
              .fontColor('#888')
              .margin({ top: 16 })
          }
          .width('100%')
          .height('60%')
          .justifyContent(FlexAlign.Center)
        } else if (this.addresses.length > 0) {
          Refresh({ refreshing: this.isLoading, offset: 120, friction: 100 }) {
            List() {
              ForEach(this.addresses, (addr: Address) => {
                ListItem() {
                  Column() {
                    Row() {
                      Text(addr.name)
                        .fontSize(16)
                        .fontWeight(FontWeight.Bold)
                      Text(addr.phone)
                        .fontSize(15)
                        .margin({ left: 16 })
                      if (addr.isDefault) {
                        Text('默认')
                          .fontSize(12)
                          .fontColor(Color.White)
                          .backgroundColor(Color.Orange)
                          .borderRadius(8)
                          .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                          .margin({ left: 12 })
                      }
                      Blank() // 占位空白，将删除按钮推到右侧
                      
                      // 编辑按钮
                      Button() {
                        Image($r('app.media.square_and_pen'))
                          .width(18)
                          .height(18)
                      }
                      .type(ButtonType.Normal)
                      .backgroundColor(Color.Transparent)
                      .margin({right: 10})
                      .onClick(() => {
                        // 跳转到编辑地址页面，带上当前地址信息
                        router.pushUrl({
                          url: 'pages/Profile/AddAddress',
                          params: {
                            isEdit: true,
                            addressId: addr.id,
                            name: addr.name,
                            phone: addr.phone,
                            city: addr.city,
                            detail: addr.detail,
                            isDefault: addr.isDefault
                          }
                        });
                      })
                      
                      // 删除按钮
                      Button() {
                        Image($r('app.media.trashcan'))
                          .width(20)
                          .height(20)
                      }
                      .type(ButtonType.Normal)
                      .backgroundColor(Color.Transparent)
                      .onClick(() => {
                        // 确认删除对话框
                        AlertDialog.show({
                          title: '删除地址',
                          message: '确定要删除该地址吗？',
                          autoCancel: true,
                          alignment: DialogAlignment.Center,
                          primaryButton: {
                            value: '取消',
                            action: () => {}
                          },
                          secondaryButton: {
                            value: '删除',
                            fontColor: '#FF0000',
                            action: () => {
                              this.deleteAddress(addr.id);
                            }
                          }
                        });
                      })
                    }
                    .width('100%')
                    .margin({ bottom: 4 })
                    Row() {
                      Text(addr.city + ' ' + addr.detail)
                        .fontSize(14)
                        .fontColor('#888')
                    }
                    .width('100%')
                  }
                  .padding(14)
                  .backgroundColor('#fff')
                  .borderRadius(12)
                  .margin({ top: 8, left: 16, right: 16 })
                  .shadow({ radius: 8, color: '#eee', offsetX: 0, offsetY: 2 })
                }
              }, (addr: Address) => addr.id)
            }
            .width('100%')
            .height('80%')
            .scrollBar(BarState.Off)
          }
          .onRefreshing(() => {
            this.loadAddresses(true); // 显示刷新提示
          })
        } else {
          // 无地址时的友好提示
          Refresh({ refreshing: this.isLoading, offset: 120, friction: 100 }) {
            Column() {
              Image($r('app.media.house_fdlfg'))
                .width(120)
                .height(120)
                .margin({ top: 60, bottom: 20 })
              Text('你还没有添加收货地址~')
                .fontSize(18)
                .fontColor('#888')
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Center)
          }
          .onRefreshing(() => {
            this.loadAddresses(true); // 显示刷新提示
          })
        }
      }
      .height('100%')
      .width('100%')
      .backgroundColor('#f5f6fa')
      .padding({ bottom: 80 }) // 为底部按钮留出空间
      
      // 新增地址按钮 - 固定在底部
      Button('新增地址')
        .type(ButtonType.Capsule)
        .backgroundColor(Color.Orange)
        .fontColor(Color.White)
        .fontSize(18)
        .width('90%')
        .height(50)
        .margin({ bottom: 20 })
        .shadow({ radius: 8, color: 'rgba(0, 0, 0, 0.1)', offsetX: 0, offsetY: 2 })
        .onClick(() => {
          // 跳转到新增地址页面或弹窗
          router.pushUrl({ url: 'pages/Profile/AddAddress' });
        })
    }
    .width('100%')
    .height('100%')
  }
} 