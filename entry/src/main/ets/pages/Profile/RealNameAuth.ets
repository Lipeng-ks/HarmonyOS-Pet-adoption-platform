import { router } from '@kit.ArkUI';
import { UserInfo } from '../../common/models/UserInfo';
import { ApiService } from '../../common/services/ApiService';

@Entry
@Component
struct RealNameAuth {
  @StorageLink('userInfo') userInfo: UserInfo = {
    username: '',
    avatar: '',
    gender: '',
    phone: '',
    email: '',
    address: '',
    birthday: ''
  };
  @State name: string = '';
  @State idNumber: string = '';
  @State errorMsg: string = '';
  @State success: boolean = false;
  @State nameError: string = '';
  @State idError: string = '';
  @State isAuthed: boolean = false;

  private apiService: ApiService = ApiService.getInstance();

  // 身份证号校验：18位，前17位为数字，最后一位为数字或X/x
  private validateIdNumber(id: string): boolean {
    const reg = /^(^[1-9]\d{5}(18|19|20)\d{2}(0[1-9]|1[0-2])(0[1-9]|[12]\d|3[01])\d{3}[0-9Xx]$)$/;
    return reg.test(id.trim());
  }

  // 基础格式校验：仅用于控制按钮可用性（18位，末位可为X/x，不校验出生日期与地区码的有效性）
  private isIdFormatBasic(id: string): boolean {
    const reg = /^\d{17}[0-9Xx]$/;
    return reg.test(id.trim());
  }

  async onPageShow() {
    try {
      const uid = this.userInfo && this.userInfo.id ? Number(this.userInfo.id) : NaN;
      if (!isNaN(uid)) {
        const real = await this.apiService.getUserRealNameByUserId(uid);
        this.isAuthed = !!real;
      } else {
        this.isAuthed = false;
      }
    } catch (e) {
      this.isAuthed = false;
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
        }
        .type(ButtonType.Normal)
        .backgroundColor(Color.Transparent)
        .onClick(() => router.back())
        .margin({ left: 10})
        Text('实名认证')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .margin({left:119})
      }
      .width('100%')
      .height(56)
      .backgroundColor('#fff')
      .borderRadius({ bottomLeft: 16, bottomRight: 16 })
      .margin({ bottom: 8 })

      // 头像
      Column() {
        Image($r('app.media.idcard'))
          .width(80)
          .height(80)
          .borderRadius(40)
          .margin({ top: 30, bottom: 10 })
        if (this.isAuthed) {
          Text('您已完成实名认证，无需重复认证')
            .fontSize(16)
            .fontColor('#2e7d32')
        } else {
          Text('请填写真实身份信息')
            .fontSize(16)
            .fontColor('#888')
        }
      }
      .width('100%')
      .align(Alignment.Center)

      // 表单（未实名才展示）
      if (!this.isAuthed) {
      Column({ space: 16 }) {
        TextInput({ placeholder: '姓名', text: this.name })
          .onChange((v: string) => {
            this.name = v;
            // 实时清理错误：当两项均有效时
            if (this.name.trim().length > 0 && this.isIdFormatBasic(this.idNumber)) {
              this.errorMsg = '';
            }
            if (this.name.trim()) {
              this.nameError = '';
            }
          })
          .backgroundColor(Color.White)
          .borderRadius(8)
          .fontSize(16)
        if (this.nameError) {
          Text(this.nameError)
            .fontSize(12)
            .fontColor('#D32F2F')
            .margin({ top: -6 })
        }
        TextInput({ placeholder: '身份证号（18位，末位可为X）', text: this.idNumber })
          .onChange((v: string) => {
            // 去空格 + 大写X
            this.idNumber = (v || '').replace(/\s+/g, '').toUpperCase();
            if (this.name.trim().length > 0 && this.isIdFormatBasic(this.idNumber)) {
              this.errorMsg = '';
            }
            if (this.isIdFormatBasic(this.idNumber)) {
              this.idError = '';
            }
          })
          .backgroundColor(Color.White)
          .borderRadius(8)
          .fontSize(16)
        if (this.idError) {
          Text(this.idError)
            .fontSize(12)
            .fontColor('#D32F2F')
            .margin({ top: -6 })
        }
        // 提示与错误区
        Column() {
          // 提示卡片
          Text('提示：仅需填写姓名和18位身份证号，无需上传照片。')
            .fontSize(13)
            .fontColor('#5E6C84')
            .backgroundColor('#F7F9FF')
            .borderRadius(8)
            .padding({ left: 10, right: 10, top: 8, bottom: 8 })
            .width('100%')
            .textAlign(TextAlign.Start)
            .margin({ top: 4, bottom: 8 })

          if (this.errorMsg) {
            // 轻量错误卡片
            Text(this.errorMsg)
              .fontSize(13)
              .fontColor('#D32F2F')
              .backgroundColor('#FFF3F3')
              .borderRadius(8)
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .width('100%')
              .margin({ top: 6, bottom: 0 })
          }
        }
      }
      .margin({ left: 24, right: 24, top: 30, bottom: 10 })

      // 成功提示（错误已在表单内展示）
      if (this.success) {
        Text('实名认证已提交，等待审核！')
          .fontColor(Color.Green)
          .fontSize(16)
          .margin({ left: 24, bottom: 8 })
      }

      // 提交按钮
      Button('提交认证')
        .type(ButtonType.Capsule)
        .backgroundColor((this.name.trim().length > 0 && this.isIdFormatBasic(this.idNumber)) ? Color.Orange : '#ffd8a866')
        .fontColor(Color.White)
        .fontSize(18)
        .width('90%')
        .height(44)
        .margin({ top: 16, bottom: 20, left: 16, right: 16 })
        .enabled(this.name.trim().length > 0 && this.isIdFormatBasic(this.idNumber))
        .onClick(async () => {
          this.nameError = '';
          this.idError = '';
          if (!this.name.trim()) {
            this.nameError = '请输入姓名';
          }
          if (!this.idNumber.trim()) {
            this.idError = '请输入身份证号';
          } else if (!this.validateIdNumber(this.idNumber)) {
            this.idError = '身份证号格式不正确，请检查';
          }
          if (this.nameError || this.idError) {
            this.success = false;
            this.errorMsg = '';
            return;
          }
          // 提交到后端实名认证接口
          try {
            let uid = (this.userInfo && this.userInfo.id !== undefined) ? Number(this.userInfo.id) : NaN;
            // 兜底：若本地未缓存id，尝试根据用户名拉取用户信息获取id
            if (isNaN(uid) && this.userInfo && this.userInfo.username) {
              const latest = await this.apiService.getUserInfo(this.userInfo.username);
              if (latest && latest.id !== undefined) {
                uid = Number(latest.id);
              }
            }
            if (isNaN(uid)) {
              this.errorMsg = '未获取到用户ID，请先登录';
              this.success = false;
              return;
            }
            const res = await this.apiService.bindUserRealName(uid, this.name.trim(), this.idNumber.trim());
            if (res) {
              this.success = true;
              this.errorMsg = '';
              this.isAuthed = true;
            } else {
              this.success = false;
              this.errorMsg = '提交失败，请稍后重试';
            }
          } catch (e) {
            this.success = false;
            this.errorMsg = '网络异常，请稍后重试';
          }
        })
      }
      // 已实名：只显示提示按钮
      if (this.isAuthed) {
        Button('已完成实名认证，返回')
          .type(ButtonType.Capsule)
          .backgroundColor(Color.Orange)
          .fontColor(Color.White)
          .fontSize(18)
          .width('90%')
          .height(44)
          .margin({ top: 24, bottom: 20, left: 16, right: 16 })
          .onClick(() => router.back())
      }
    }
    .height('100%')
    .width('100%')
    .backgroundColor('#f5f6fa')
  }
}