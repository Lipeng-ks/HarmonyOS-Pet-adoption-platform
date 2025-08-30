import { router } from '@kit.ArkUI';
import { UserInfo } from '../../common/models/UserInfo';
import { UserService } from '../../common/database/UserService';

@Entry
@Component
struct Individual {
  @State AnimalColor1: string = '#ff9b9b9b'
  @State AnimalColor2: string = '#ffdbdbdb'
  // 不在文件中写死示例用户信息，避免将测试数据保存在源代码
  @StorageLink('userInfo') UserInfo: UserInfo = {
    id: undefined,
    username: '',
    avatar: 'app.media.man',
    gender: '',
    phone: '',
    email: '',
    address: '',
    birthday: ''
  };
  @State userId: string = '';
  @State isLoading: boolean = false;
  private userService: UserService = UserService.getInstance();

  build() {
    Column(){
      Column(){
        Stack(){
          Row(){
            Blank().layoutWeight(1)
            Text('我的')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
            Blank().layoutWeight(1)
          }
          .zIndex(1)
          .backgroundColor(Color.White)
          .width('100%')
          .height(50)
          Row(){
            Image($r("app.media.Checkinicon"))
              .width(20)
              .height(20)
          }
          .margin({left:320})
          .zIndex(2)
          .onClick(() => { router.pushUrl({ url: 'pages/Profile/Checkin' }) })
        }
        Row(){
            Image($r(this.UserInfo.avatar))
              .width(70)
              .height(70)
              .borderRadius(100)
              .margin({left:10})
              .objectFit(ImageFit.Cover)
          Column(){
            Row(){
              Text(this.UserInfo.username)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
              Image(this.UserInfo.gender === '男' ? $r('app.media.icon_male') : $r('app.media.icon_female'))
                .height(20)
                .width(20)
                .margin({left:5})
            }
            .margin({bottom:5})
            .width('100%')
            Row(){
              Text(`ID:${this.UserInfo.id}`)
                .fontSize(12)
                .fontColor('#ffa4a4a4')
            }
            .width('100%')
          }
          .margin({left:10})
          .width(155)
          Row(){
            Image($r('app.media.square_and_pen'))
              .width(25)
              .height(25)
            Text('修改资料')
              .fontSize(14)
              .margin({left:5})
          }
          .onClick(() => {
            router.pushUrl({ url: 'pages/Profile/EditProfile'})
          })
        }
        .padding({top:10,bottom:10})
        .margin({top:10})
        .borderRadius(20)
        .backgroundColor(Color.White)
        .width('95%')
        Row(){
          Column(){
            Image($r('app.media.lidjfgd'))
              .width(60)
              .height(60)
            Text('我的领养')
          }
          .width('33.3%')
          .onClick(() => {
            router.pushUrl({ url: 'pages/Profile/Adopt'})
          })
          Column(){
            Image($r('app.media.sy'))
              .width(60)
              .height(60)
            Text('我的送养')
          }
          .width('33.3%')
          .onClick(() => {
            router.pushUrl({ url: 'pages/Profile/MyFoster'})
          })
          Column(){
            Image($r('app.media.sc'))
              .width(60)
              .height(60)
            Text('我的寻宠')
          }
          .width('33.3%')
          .onClick(() => {
            const uid = typeof this.UserInfo.id === 'number' ? this.UserInfo.id : undefined
            router.pushUrl({ url: 'pages/Profile/MyMissingPets', params: { userId: uid } })
          })
        }
        .padding({top:10,bottom:10})
        .margin({top:10})
        .borderRadius(20)
        .backgroundColor(Color.White)
        .width('95%')
        Column(){
          Row(){
            Image($r('app.media.doc_plaintext_and_pencil'))
              .height(30)
              .width(30)
            Text('我的申请')
              .margin({left:10})
            Image($r('app.media.chevron_right'))
              .height(12)
              .width(12)
              .margin({left:195})
          }
          .onClick(() => {
            router.pushUrl({ url: 'pages/Profile/MyOrders'})
          })
          .margin({bottom:10,top:10})
          Row() {} // 空内容撑满宽度
          .height(1)
          .width('90%')
          // .margin({left:17})
          .backgroundColor(Color.Orange)
          .opacity(0.5)
          Row(){
            Image($r('app.media.shdz'))
              .height(30)
              .width(30)
            // .margin({left:5})
            Text('我的地址')
              .margin({left:10})
            Image($r('app.media.chevron_right'))
              .height(12)
              .width(12)
              .margin({left:195})
          }
          .onClick(() => {
            router.pushUrl({ url: 'pages/Profile/MyAddress'})
          })
          .margin({bottom:10,top:10})
          Row() {} // 空内容撑满宽度
          .height(1)
          .width('90%')
          // .margin({left:17})
          .backgroundColor(Color.Orange)
          .opacity(0.5)
          Row(){
            Image($r('app.media.smyz'))
              .height(30)
              .width(30)
            // .margin({left:5})
            Text('实名认证')
              .margin({left:10})
            Image($r('app.media.chevron_right'))
              .height(12)
              .width(12)
              .margin({left:195})
          }
          .onClick(() => {
            router.pushUrl({ url: 'pages/Profile/RealNameAuth'})
          })
          .margin({bottom:15,top:5})
        }
        .padding({top:10})
        .margin({top:10})
        .borderRadius(20)
        .backgroundColor(Color.White)
        .width('95%')
        Column(){
          Row(){
            Image($r('app.media.gearshape'))
              .height(30)
              .width(30)
            Text('设置选项')
              .margin({left:10})
            Image($r('app.media.chevron_right'))
              .height(12)
              .width(12)
              .margin({left:195})
          }
          .onClick(() => {
            router.pushUrl({ url: 'pages/PersonalCenter/Setoptions'})
          })
        }
        .padding({top:10,bottom:10})
        .margin({top:10})
        .borderRadius(20)
        .backgroundColor(Color.White)
        .width('95%')

      }
      .backgroundColor('#ffefefef')
      .width('100%')
      .height('88%')
      Column(){
        Text('')
          .width('100%')
          .height('100%')
      }.height('6.5%')
      .backgroundColor('#ffefefef')
      Row(){
        Column(){
          Image($r('app.media.house'))
            .width(30)
            .height(30)
          Text('首页')
            .fontColor(this.AnimalColor1)
        }
        .onClick(() => {
          router.pushUrl({ url: 'pages/Home/Home'})
        })
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
          Image($r('app.media.person'))
            .width(30)
            .height(30)
          Text('我的')
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.Orange)
        }
      }
      .height(60)
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
    }
    .height('100%')
  }
}