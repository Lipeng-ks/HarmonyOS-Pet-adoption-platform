import { router } from '@kit.ArkUI';
import prompt from '@system.prompt';
import { AuthService } from '../../common/services/AuthService';
import { UserInfo } from '../../common/models/UserInfo';

@Entry
@Component
struct Register {
  @State username: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';
  @State phone: string = '';
  @State gender: string = '男';
  @State message: string = '';
  @State isLoading: boolean = false;
  // 头像（data URI 或 URL）。为空则使用默认资源 app.media.tyikjgch
  @State avatar: string = '';
  private authService: AuthService = AuthService.getInstance();

  build() {
    RelativeContainer() {
      Column() {
        // 顶部：注册标题、头像、性别（从上到下排列）
        Column() {
          Text('注册账号')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFA500')
            .margin({ bottom: 12 })
            .align(Alignment.Center)
            Image($r('app.media.tyikjgch'))
              .width(96)
              .height(96)
              .margin({ bottom: 8 })
              .borderRadius(48)
              .align(Alignment.Center)

          Text("默认头像").fontColor('#666').margin({ top:5 ,bottom:10 })

          // 性别选择器（横向排列，居中）
          Row() {
            Text('性别').fontSize(14).fontColor('#666').margin({ right: 12 }).align(Alignment.Center)
            Button('男')
              .type(ButtonType.Capsule)
              .fontColor(this.gender === '男' ? Color.White : '#FFA500')
              .backgroundColor(this.gender === '男' ? '#ff35b8ff' : '#FFF8F0')
              .onClick(() => {
                this.gender = '男'
              })
              .width(60)
              .height(36)
            Button('女')
              .type(ButtonType.Capsule)
              .fontColor(this.gender === '女' ? Color.White : '#FFA500')
              .backgroundColor(this.gender === '女' ? '#ffff2e7b' : '#FFF8F0')
              .onClick(() => {
                this.gender = '女'
              })
              .width(60)
              .height(36)
          }
          .justifyContent(FlexAlign.Center)
          .margin({ bottom: 20 })

          // 注册表单卡片
          Column() {
            TextInput({
              placeholder: '用户名',
              text: this.username
            })
              .onChange((value: string) => {
                this.username = value;
              })
              .type(InputType.Normal)
              .width('100%')
              .backgroundColor('#FFF8F0')
              .borderRadius(16)
              .fontColor('#FFA500')
              .margin({ bottom: 16, top: 8 })
              .padding({ left: 16, right: 16 })

            TextInput({
              placeholder: '手机号码',
              text: this.phone
            })
              .onChange((value: string) => {
                this.phone = value;
              })
              .type(InputType.Normal)
              .width('100%')
              .backgroundColor('#FFF8F0')
              .borderRadius(16)
              .fontColor('#FFA500')
              .margin({ bottom: 16, top: 8 })
              .padding({ left: 16, right: 16 })

            TextInput({
              placeholder: '密码',
              text: this.password
            })
              .onChange((value: string) => {
                this.password = value;
              })
              .type(InputType.Password)
              .width('100%')
              .backgroundColor('#FFF8F0')
              .borderRadius(16)
              .fontColor('#FFA500')
              .margin({ bottom: 16 })
              .padding({ left: 16, right: 16 })


            TextInput({
              placeholder: '确认密码',
              text: this.confirmPassword
            })
              .onChange((value: string) => {
                this.confirmPassword = value;
              })
              .type(InputType.Password)
              .width('100%')
              .backgroundColor('#FFF8F0')
              .borderRadius(16)
              .fontColor('#FFA500')
              .margin({ bottom: 20 })
              .padding({ left: 16, right: 16 })

            Button(this.isLoading ? '注册中...' : '注册')
              .margin({ top: 16, bottom: 8 })
              .type(ButtonType.Capsule)
              .width('100%')
              .fontColor(Color.White)
              .backgroundColor('#FFA500')
              .fontSize(18)
              .borderRadius(20)
              .shadow({
                radius: 8,
                color: '#FFD580',
                offsetX: 0,
                offsetY: 2
              })
              .onClick(async () => {
                // 表单验证
                if (!this.username || !this.phone || !this.password || !this.confirmPassword) {
                  this.message = '请填写所有字段';
                  return;
                }

                // 简单手机格式校验（中国手机号）
                const phoneRegex = /^1[3-9]\d{9}$/
                if (!phoneRegex.test(this.phone)) {
                  this.message = '请输入有效的手机号码';
                  return;
                }

                if (this.password !== this.confirmPassword) {
                  this.message = '两次密码输入不一致';
                  return;
                }

                this.isLoading = true;

                try {
                  // 创建用户信息对象
                  const userInfo: UserInfo = {
                    username: this.username,
                    // 未选择头像则使用当前默认资源（注册页顶部显示的图片）
                    avatar: (this.avatar && this.avatar.length > 0) ? this.avatar : 'app.media.tyikjgch',
                    gender: this.gender, // 使用当前选择的性别
                    phone: this.phone,
                  };

                  // 调用注册接口
                  const result = await this.authService.register(userInfo, this.password);

                  if (result.success) {
                    prompt.showToast({ message: result.message, duration: 500 });

                    // 注册成功后延迟跳转到登录页
                    setTimeout(() => {
                      router.back();
                    }, 500);
                  } else {
                    // 显示友好提示，避免直接暴露服务器内部错误信息
                    const serverMsg = result.message && result.message !== '服务器错误' ? result.message : '注册失败，请稍后重试';
                    this.message = serverMsg;
                  }
                } catch (error) {
                  // 捕获异常时显示简洁的用户提示，不展示具体错误堆栈
                  this.message = '注册出错，请检查网络或稍后重试';
                  console.error('注册出错:', error);
                } finally {
                  this.isLoading = false;
                }
              })

            if (this.message) {
              Text(this.message)
                .fontSize(16)
                .fontColor(Color.Red)
                .margin({ top: 10 })
            }

            Button('返回登录')
              .margin({ top: 8 })
              .type(ButtonType.Capsule)
              .width('100%')
              .fontColor('#FFA500')
              .backgroundColor('#FFF8F0')
              .fontSize(18)
              .borderRadius(20)
              .shadow({
                radius: 8,
                color: '#FFD580',
                offsetX: 0,
                offsetY: 2
              })
              .onClick(() => {
                router.back();
              })
          }
          .backgroundColor('#FFF')
          .borderRadius(24)
          .shadow({
            radius: 12,
            color: '#FFD580',
            offsetX: 0,
            offsetY: 4
          })
          .padding({
            left: 32,
            right: 32,
            top: 32,
            bottom: 32
          })
          .width('85%')
          .align(Alignment.Center)
        }
        .margin({ top: 40 })
        .align(Alignment.Center)
        .width('100%')
      }
      .margin({ top: 20 })
      .height('100%')
      .width('100%')
    }
  }
}