import { router } from '@kit.ArkUI';
import prompt from '@system.prompt';
import { AuthService } from '../../common/services/AuthService';
import { UserInfo } from '../../common/models/UserInfo';

// 错误对象接口
interface ErrorLike {
  message?: string;
  toString(): string;
}

@Entry
@Component
struct Login {
  @State username: string = '';
  @State password: string = '';
  @State message: string = '';
  @State isLoading: boolean = false;
  private authService: AuthService = AuthService.getInstance();

  build() {
    RelativeContainer() {
      Column() {
        Text('宠物领养平台')
          .fontSize(28)
        .fontWeight(FontWeight.Bold)
          .fontColor('#FFA500')
          .margin({ bottom: 32 })
          .align(Alignment.Center)
        // 顶部宠物主题插画或logo
        Row() {
          Blank().layoutWeight(1)
          Image($r('app.media.tyikjgch')) // 请将宠物主题PNG或SVG放到资源目录
            .width(72)
            .height(72)
            .margin({ bottom: 8 })
            .borderRadius(100)
          Blank().layoutWeight(1)
        }
        .width('100%')
        .margin({ bottom:20 })
        // 登录表单卡片
        Column() {
        TextInput({
          placeholder: '用户名',
          text: this.username
        })
          .onChange((value: string) => { this.username = value; })
          .type(InputType.Normal)
            .width('100%')
            .backgroundColor('#FFF8F0')
            .borderRadius(16)
            .fontColor('#FFA500')
            .margin({ bottom: 20, top: 8 })
            .padding({ left: 16, right: 16 })
        TextInput({
          placeholder: '密码',
          text: this.password
        })
          .onChange((value: string) => { this.password = value; })
          .type(InputType.Password)
            .width('100%')
            .backgroundColor('#FFF8F0')
            .borderRadius(16)
            .fontColor('#FFA500')
          .margin({ bottom: 24 })
            .padding({ left: 16, right: 16 })
        Button(this.isLoading ? '登录中...' : '登录')
            .margin({top:16, bottom: 8})
          .type(ButtonType.Capsule)
            .width('100%')
            .fontColor(Color.White)
            .backgroundColor('#FFA500')
            .fontSize(18)
            .borderRadius(20)
            .shadow({ radius: 8, color: '#FFD580', offsetX: 0, offsetY: 2 })
          .onClick(async () => {
            console.info('Login button clicked');
            if (!this.username || !this.password) {
              this.message = '请输入用户名和密码';
              console.warn('Username or password empty');
              return;
            }
            this.isLoading = true;
            this.message = '';
            
            try {
              console.info(`Attempting to log in user: ${this.username}`);
              // 调用登录接口验证用户
              const result = await this.authService.login(this.username, this.password);
              console.info(`Login service returned: ${JSON.stringify(result)}`);
              
              if (result.success) {
                console.info('Login successful, setting AppStorage with fallback');
                // 数据兜底，防止后端未返回 data 导致不跳转
                const data = result.data ?? {
                  username: this.username,
                  avatar: '',
                  gender: 'unknown',
                  phone: '',
                  email: '',
                  address: '',
                  birthday: ''
                };

                // 设置登录状态（使用 SetOrCreate 防止键不存在导致失败）
                const ok1 = AppStorage.SetOrCreate('isLoggedIn', true);
                const ok2 = AppStorage.SetOrCreate<UserInfo>('userInfo', data as UserInfo);
                console.info(`AppStorage SetOrCreate isLoggedIn=${ok1}, userInfo=${ok2}`);

                prompt.showToast({ message: result.message || '登录成功', duration: 500 });
                // 立即跳转，避免延时导致未导航
                console.info('Redirecting to Home page immediately');
                // 优先使用 replaceUrl，失败时回退到 pushUrl
                try {
                  router.replaceUrl({ url: 'pages/Home/Home' });
                } catch (navErr) {
                  const nerr = navErr as ErrorLike;
                  console.error(`replaceUrl failed: ${nerr?.toString?.() ?? navErr}`);
                  try {
                    router.pushUrl({ url: 'pages/Home/Home' });
                  } catch (navErr2) {
                    const nerr2 = navErr2 as ErrorLike;
                    console.error(`pushUrl failed: ${nerr2?.toString?.() ?? navErr2}`);
                  }
                }
              } else {
                console.error(`Login failed: ${result.message}`);
                this.message = result.message || '登录失败';
              }
            } catch (error) {
              const err = error as ErrorLike;
              this.message = `登录出错: ${err.message || err.toString()}`;
              console.error(`Login error caught: ${this.message}`);
            } finally {
              console.info('Login process finished');
              this.isLoading = false;
            }
          })
        if (this.message) {
          Text(this.message)
            .fontSize(16)
            .fontColor(this.message === '登录成功' ? Color.Green : Color.Red)
              .margin({ top: 10 })
        }
          Button('注册')
            .margin({ top: 8 })
            .type(ButtonType.Capsule)
            .width('100%')
            .fontColor('#FFA500')
            .backgroundColor('#FFF8F0')
            .fontSize(18)
            .borderRadius(20)
            .shadow({ radius: 8, color: '#FFD580', offsetX: 0, offsetY: 2 })
            .onClick(() => {
              router.pushUrl({ url: 'pages/Auth/Register' });
            })
        }
        .backgroundColor('#FFF')
        .borderRadius(24)
        .shadow({ radius: 12, color: '#FFD580', offsetX: 0, offsetY: 4 })
        .padding({ left: 32, right: 32, top: 32, bottom: 32 })
        .width('85%')
        .align(Alignment.Center)
      }
      .margin({top:40})
      .align(Alignment.Center)
      .width('100%')
    }
    .margin({top:60})
    .height('100%')
    .width('100%')
  }
}