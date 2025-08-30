import { router } from '@kit.ArkUI';
import prompt from '@system.prompt';
import common from '@ohos.app.ability.common';

@Entry
@Component
struct Setoptions {
  @State bgColor: string = '#F5F5F5';

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        // 左侧返回按钮
        Button() {
          Row() {
              Image($r('app.media.arrow_left'))
                .width(24)
                .height(24)
            }
            .backgroundColor(Color.Transparent)
            .onClick(() => router.back())
            .margin({ left: 10})
        }
        .type(ButtonType.Normal)
        .backgroundColor(Color.Transparent)
        .onClick(() => router.back())
        .width(44)
        .height(44)

        // 中间标题区域
        Row() {
          Text('设置')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)

        // 右侧占位区域（保持对称）
        Row()
          .width(44)
          .height(44)
      }
      .width('100%')
      .height(56)
      .backgroundColor('#fff')
      .borderRadius({ bottomLeft: 16, bottomRight: 16 })
      .shadow({ radius: 6, color: '#E0E0E0', offsetY: 2 })
      .margin({ bottom: 8 })
      .padding({ left: 10, right: 10 })
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      // 设置选项列表
      Scroll() {
        Column() {
          // 账号安全设置组
          Column() {
            Text('账号与安全')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#666666')
              .alignSelf(ItemAlign.Start)
              .margin({ left: 20, top: 12, bottom: 8 })

            // 个人信息
            Row() {
              Text('个人信息')
                .fontSize(17)
                .fontColor('#333333')
              
              Text('>')
                .fontSize(18)
                .fontColor('#999')
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .width('100%')
            .height(56)
            .padding({ left: 20, right: 20 })
            .onClick(() => {
              router.pushUrl({ url: 'pages/Profile/EditProfile' });
            })

            Divider()
              .color('#EEEEEE')
              .margin({ left: 20, right: 20 })

            // 修改密码
            Row() {
              Text('修改密码')
                .fontSize(17)
                .fontColor('#333333')
              
              Text('>')
                .fontSize(18)
                .fontColor('#999')
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .width('100%')
            .height(56)
            .padding({ left: 20, right: 20 })
            .onClick(() => {
              router.pushUrl({ url: 'pages/Profile/ChangePassword' });
            })

            Divider()
              .color('#EEEEEE')
              .margin({ left: 20, right: 20 })
          }
          .borderRadius(12)
          .backgroundColor(Color.White)
          .margin({ top: 12, left: 12, right: 12 })

          // 通用设置组
          Column() {
            Text('通用设置')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#666666')
              .alignSelf(ItemAlign.Start)
              .margin({ left: 20, top: 12, bottom: 8 })

            // 消息通知
            Row() {
              Text('消息通知')
                .fontSize(17)
                .fontColor('#333333')
              
              Toggle({ type: ToggleType.Switch, isOn: true })
                .width(48)
                .height(28)
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .width('100%')
            .height(56)
            .padding({ left: 20, right: 20 })

            Divider()
              .color('#EEEEEE')
              .margin({ left: 20, right: 20 })

            // 应用主题
            Row() {
              Text('应用主题')
                .fontSize(17)
                .fontColor('#333333')
              
              Row() {
                Text('默认')
                  .fontSize(16)
                  .fontColor('#999999')
                  .margin({ right: 5 })
                
                Text('>')
                  .fontSize(18)
                  .fontColor('#999')
              }
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .width('100%')
            .height(56)
            .padding({ left: 20, right: 20 })
            .onClick(() => {
              prompt.showToast({ message: '暂未开放此功能', duration: 2000 });
            })

            Divider()
              .color('#EEEEEE')
              .margin({ left: 20, right: 20 })

            // 清除缓存
            Row() {
              Text('清除缓存')
                .fontSize(17)
                .fontColor('#333333')
              
              Text('0 MB')
                .fontSize(16)
                .fontColor('#999999')
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .width('100%')
            .height(56)
            .padding({ left: 20, right: 20 })
            .onClick(() => {
              prompt.showToast({ message: '缓存已清除', duration: 2000 });
            })
          }
          .borderRadius(12)
          .backgroundColor(Color.White)
          .margin({ top: 20, left: 12, right: 12 })

          // 关于和支持
          Column() {
            Text('关于与支持')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#666666')
              .alignSelf(ItemAlign.Start)
              .margin({ left: 20, top: 12, bottom: 8 })

            // 关于我们
            Row() {
              Text('关于我们')
                .fontSize(17)
                .fontColor('#333333')
              
              Text('>')
                .fontSize(18)
                .fontColor('#999')
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .width('100%')
            .height(56)
            .padding({ left: 20, right: 20 })
            .onClick(() => {
              prompt.showToast({ message: '暂未开放此功能', duration: 2000 });
            })

            Divider()
              .color('#EEEEEE')
              .margin({ left: 20, right: 20 })

            // 意见反馈
            Row() {
              Text('意见反馈')
                .fontSize(17)
                .fontColor('#333333')
              
              Text('>')
                .fontSize(18)
                .fontColor('#999')
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .width('100%')
            .height(56)
            .padding({ left: 20, right: 20 })
            .onClick(() => {
              prompt.showToast({ message: '暂未开放此功能', duration: 2000 });
            })

            Divider()
              .color('#EEEEEE')
              .margin({ left: 20, right: 20 })

            // 检查更新
            Row() {
              Text('检查更新')
                .fontSize(17)
                .fontColor('#333333')
              
              Text('当前已是最新版本 V1.0')
                .fontSize(14)
                .fontColor('#999999')
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .width('100%')
            .height(56)
            .padding({ left: 20, right: 20 })
            .onClick(() => {
              prompt.showToast({ message: '当前已是最新版本', duration: 2000 });
            })
          }
          .borderRadius(12)
          .backgroundColor(Color.White)
          .margin({ top: 20, left: 12, right: 12 })

          // 退出登录按钮
          Button('退出登录')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)
            .backgroundColor('#FF5252')
            .height(52)
            .width('90%')
            .borderRadius(26)
            .margin({ top: 40, bottom: 20 })
            .onClick(() => {
              this.showLogoutDialog();
            })
        }
        .width('100%')
        .padding({ bottom: 20 })
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor(this.bgColor)
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.bgColor)
  }

  // 显示退出登录对话框
  showLogoutDialog() {
    AlertDialog.show({
      title: '确认退出登录',
      message: '退出后需要重新登录才能使用账号',
      autoCancel: true,
      alignment: DialogAlignment.Center,
      gridCount: 3,
      offset: { dx: 0, dy: 0 },
      primaryButton: {
        value: '取消',
        fontColor: '#666666',
        backgroundColor: '#F5F5F5',
        action: () => {
          console.info('取消退出登录')
        }
      },
      secondaryButton: {
        value: '退出',
        fontColor: '#FFFFFF',
        backgroundColor: '#FF5252',
        action: () => {
          // 清除登录相关存储
          AppStorage.Delete('isLoggedIn');
          AppStorage.Delete('userInfo');
          AppStorage.Delete('token');
          
          // 显示提示
          prompt.showToast({ 
            message: '已安全退出登录', 
            duration: 2000 
          });
          
          // 延迟返回登录页
          setTimeout(() => {
            router.clear();
            router.replaceUrl({ url: 'pages/Auth/Login' });
          }, 500);
        }
      }
    })
  }
}