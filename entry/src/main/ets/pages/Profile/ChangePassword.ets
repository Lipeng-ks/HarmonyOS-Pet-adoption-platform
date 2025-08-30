import { router } from '@kit.ArkUI';
import prompt from '@system.prompt';
import { ApiService } from '../../common/services/ApiService';
import { UserInfo } from '../../common/models/UserInfo';

@Entry
@Component
struct ChangePassword {
  @State oldPassword: string = '';
  @State newPassword: string = '';
  @State confirmPassword: string = '';
  @State isLoading: boolean = false;
  @State showOldPassword: boolean = false;
  @State showNewPassword: boolean = false;
  @State showConfirmPassword: boolean = false;

  private apiService: ApiService = ApiService.getInstance();

  // 验证密码格式
  private validatePassword(password: string): boolean {
    return password.length >= 6 && password.length <= 20;
  }

  // 提交修改密码
  private async submitPasswordChange(): Promise<void> {
    if (!this.oldPassword) {
      prompt.showToast({ message: '请输入当前密码', duration: 1500 });
      return;
    }

    if (!this.newPassword) {
      prompt.showToast({ message: '请输入新密码', duration: 1500 });
      return;
    }

    if (!this.validatePassword(this.newPassword)) {
      prompt.showToast({ message: '新密码长度应为6-20位', duration: 1500 });
      return;
    }

    if (this.newPassword !== this.confirmPassword) {
      prompt.showToast({ message: '两次输入的新密码不一致', duration: 1500 });
      return;
    }

    if (this.oldPassword === this.newPassword) {
      prompt.showToast({ message: '新密码不能与当前密码相同', duration: 1500 });
      return;
    }

    // 获取当前登录用户
    const user = AppStorage.Get<UserInfo>('userInfo') as UserInfo | undefined;
    if (!user || !user.username) {
      prompt.showToast({ message: '请先登录后再修改密码', duration: 1500 });
      router.pushUrl({ url: 'pages/Auth/Login' });
      return;
    }

    this.isLoading = true;
    try {
      // 1) 先校验旧密码是否正确（调用后端 /api/auth/login）
      const ok = await this.apiService.login(user.username, this.oldPassword);
      if (!ok) {
        prompt.showToast({ message: '当前密码错误，请重新输入', duration: 1500 });
        return;
      }

      // 注意：后端 updateUser 会用请求体的字段覆盖实体，如果仅传 password 可能把其它字段置空
      // 因此这里携带完整用户资料，仅替换 password
      const fullPayload = {
        username: user.username,
        avatar: user.avatar,
        gender: user.gender,
        phone: user.phone,
        email: user.email,
        address: user.address,
        birthday: user.birthday,
        password: this.newPassword
      } as Partial<UserInfo>;
      const updated = await this.apiService.updateUserInfo(user.username, fullPayload);
      if (!updated) {
        prompt.showToast({ message: '修改失败，请稍后重试', duration: 1500 });
        return;
      }

      prompt.showToast({ message: '密码修改成功', duration: 1500 });
      setTimeout(() => {
        router.back();
      }, 1500);
    } catch (error) {
      console.error('修改密码失败:', error);
      prompt.showToast({ message: '修改失败，请检查网络', duration: 1500 });
    } finally {
      this.isLoading = false;
    }
  }


  build() {
    Column() {
      // 顶部导航栏
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
        Text('修改密码')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .margin({left:119})
      }
      .width('100%')
      .height(56)
      .backgroundColor('#fff')
      .borderRadius({ bottomLeft: 16, bottomRight: 16 })
      .margin({ bottom: 8 })

      // 密码修改表单
        Column() {
          // 密码输入组
          Column() {
            Text('安全验证')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#666666')
              .alignSelf(ItemAlign.Start)
              .margin({ left: 20, top: 12, bottom: 8 })

            // 当前密码
            Column() {
              Row() {
                Text('当前密码')
                  .fontSize(17)
                  .fontColor('#333333')
                  .width(80)
                
                TextInput({ 
                  text: this.oldPassword, 
                  placeholder: '请输入当前密码' 
                })
                  .type(this.showOldPassword ? InputType.Normal : InputType.Password)
                  .fontSize(16)
                  .backgroundColor(Color.Transparent)
                  .border({ width: 0 })
                  .layoutWeight(1)
                  .onChange((value: string) => this.oldPassword = value)

                Button() {
                  Text(this.showOldPassword ? '隐藏' : '显示')
                    .fontSize(14)
                    .fontColor('#007AFF')
                }
                .type(ButtonType.Normal)
                .backgroundColor(Color.Transparent)
                .onClick(() => this.showOldPassword = !this.showOldPassword)
              }
              .width('100%')
              .height(56)
              .padding({ left: 20, right: 20 })
              .alignItems(VerticalAlign.Center)

              Divider()
                .color('#EEEEEE')
                .margin({ left: 20, right: 20 })

              // 新密码
              Row() {
                Text('新密码')
                  .fontSize(17)
                  .fontColor('#333333')
                  .width(80)
                
                TextInput({ 
                  text: this.newPassword, 
                  placeholder: '请输入新密码(6-20位)' 
                })
                  .type(this.showNewPassword ? InputType.Normal : InputType.Password)
                  .fontSize(16)
                  .backgroundColor(Color.Transparent)
                  .border({ width: 0 })
                  .layoutWeight(1)
                  .onChange((value: string) => this.newPassword = value)

                Button() {
                  Text(this.showNewPassword ? '隐藏' : '显示')
                    .fontSize(14)
                    .fontColor('#007AFF')
                }
                .type(ButtonType.Normal)
                .backgroundColor(Color.Transparent)
                .onClick(() => this.showNewPassword = !this.showNewPassword)
              }
              .width('100%')
              .height(56)
              .padding({ left: 20, right: 20 })
              .alignItems(VerticalAlign.Center)

              Divider()
                .color('#EEEEEE')
                .margin({ left: 20, right: 20 })

              // 确认新密码
              Row() {
                Text('确认密码')
                  .fontSize(17)
                  .fontColor('#333333')
                  .width(80)
                
                TextInput({ 
                  text: this.confirmPassword, 
                  placeholder: '请再次输入新密码' 
                })
                  .type(this.showConfirmPassword ? InputType.Normal : InputType.Password)
                  .fontSize(16)
                  .backgroundColor(Color.Transparent)
                  .border({ width: 0 })
                  .layoutWeight(1)
                  .onChange((value: string) => this.confirmPassword = value)

                Button() {
                  Text(this.showConfirmPassword ? '隐藏' : '显示')
                    .fontSize(14)
                    .fontColor('#007AFF')
                }
                .type(ButtonType.Normal)
                .backgroundColor(Color.Transparent)
                .onClick(() => this.showConfirmPassword = !this.showConfirmPassword)
              }
              .width('100%')
              .height(56)
              .padding({ left: 20, right: 20 })
              .alignItems(VerticalAlign.Center)
            }
          }
          .borderRadius(12)
          .backgroundColor(Color.White)
          .margin({ top: 12, left: 12, right: 12 })

          // 密码要求提示
          Column() {
            Text('密码要求')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#666666')
              .alignSelf(ItemAlign.Start)
              .margin({ left: 20, top: 12, bottom: 8 })

            Column() {
              Text('• 密码长度为6-20位字符\n• 建议包含字母、数字和特殊字符\n• 不能与当前密码相同')
                .fontSize(14)
                .fontColor('#999999')
                .lineHeight(22)
                .padding({ left: 20, right: 20, top: 16, bottom: 16 })
            }
          }
          .width("90%")
          .borderRadius(12)
          .backgroundColor(Color.White)
          .margin({ top: 12 })

          // 提交按钮
          Button(this.isLoading ? '修改中...' : '确认修改')
            .type(ButtonType.Normal)
            .fontSize(18)
            .fontColor(Color.White)
            .backgroundColor(this.isLoading ? '#CCCCCC' : '#FF6B35')
            .borderRadius(25)
            .width('90%')
            .height(50)
            .margin({ top: 30, bottom: 30 })
            .enabled(!this.isLoading)
            .onClick(() => this.submitPasswordChange())
        }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
