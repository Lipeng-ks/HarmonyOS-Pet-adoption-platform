import { router } from '@kit.ArkUI';
import prompt from '@system.prompt';
import { UserInfo } from '../../common/models/UserInfo';
import { ApiService } from '../../common/services/ApiService';

interface CheckinSummary {
  checkinCount?: number;
  userId?: number;
  username?: string;
  checkedToday?: boolean;
}

interface GetSummaryResponse {
  success?: boolean;
  summary?: CheckinSummary;
}

interface PostCheckinResponse {
  success?: boolean;
  message?: string;
}

// 日期数据接口
interface CalendarDay {
  day: number
  isCurrentMonth: boolean
  isCheckedIn: boolean
  isToday: boolean
}

// Calendar接口定义
interface Calendar {
  year: number
  month: number
  day: number
  content: string
}

// 月份数据与滚动事件显式类型
interface YearMonth {
  year: number
  month: number
}

interface MonthData extends YearMonth {
  days: Calendar[]
}

interface ScrollEventLike {
  offsetX?: number
  offsetY?: number
}

@Entry
@Component
struct Checkin {
  @State username: string = ''
  @State checkinCount: number = 0
  @State isLoading: boolean = true
  @State checkedToday: boolean = false
  @State currentYear: number = new Date().getFullYear()
  @State currentMonth: number = new Date().getMonth() + 1
  @State calendarDays: CalendarDay[] = []
  @State MONTHDAY: Calendar[] = []
  @State checkinDates: Set<string> = new Set()
  
  @State dateToday: Date = new Date()
  @State monthNow: number = new Date().getMonth() + 1
  @State yearNow: number = new Date().getFullYear()
  
  // 滚动日历相关状态
  @State months: MonthData[] = []
  @State currentMonthIndex: number = 2 // 当前显示月份在数组中的索引
  @State scrollY: number = 0
  @State isScrolling: boolean = false
  // 月份切换过渡动画（0~1，控制淡入）
  @State monthFade: number = 1
  // 月份切换位移过渡（px，正数向下偏移，增强动效层次）
  @State monthShift: number = 0
  // 当年12个月数据缓存
  @State yearMonthsCache: MonthData[] = []
  private scroller: Scroller = new Scroller()
  private readonly MONTH_HEIGHT: number = 360


  private apiService: ApiService = ApiService.getInstance();
  private monthNames: string[] = ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月']

  async aboutToAppear() {
    try {
      const user = AppStorage.Get<UserInfo>('userInfo') as UserInfo | undefined
      if (!user || !user.username) {
        prompt.showToast({ message: '请先登录', duration: 1500 })
        router.pushUrl({ url: 'pages/Auth/Login' })
        return
      }
      this.username = user.username
      await this.loadSummary()
      await this.loadCheckinDates(user.id)
      this.buildCurrentMonthDays()
      this.refreshYearMonths(this.yearNow)
      this.initCalendarMonths()
    } catch (e) {
      console.error('获取用户信息失败: ' + e)
    }
  }

  getMonthContent() {
    const monthDays: number[] = this.getMonthDate(this.monthNow, this.yearNow)
    this.MONTHDAY = []
    for (let index = 0; index < monthDays.length; index++) {
      const num = monthDays[index]
      let calendarItem: Calendar = {
        year: this.yearNow,
        month: this.monthNow,
        day: num,
        content: num > 0 ? (this.isCheckedIn(this.yearNow, this.monthNow, num) ? '已签到' : '') : ''
      }
      this.MONTHDAY.push(calendarItem)
    }
  }

  getMonthDate(month: number, year: number): number[] {
    const SATURDAY: number = 6
    let currentFirstWeekDay: number = 0
    let currentLastWeekDay: number = 0
    const currentAllDay: number[] = []
    const totalDays = new Date(year, month, 0).getDate()
    currentFirstWeekDay = new Date(year, month - 1, 1).getDay()
    currentLastWeekDay = new Date(year, month - 1, totalDays).getDay()
    for (let item = 0; item < currentFirstWeekDay; item++) {
      currentAllDay[item] = 0
    }
    for (let item = 1; item <= totalDays; item++) {
      currentAllDay.push(item)
    }
    for (let item = 0; item < SATURDAY - currentLastWeekDay; item++) {
      currentAllDay.push(0)
    }
    return currentAllDay
  }

  isCheckedIn(year: number, month: number, day: number): boolean {
    const dateStr = `${year}-${month.toString().padStart(2, '0')}-${day.toString().padStart(2, '0')}`
    return this.checkinDates.has(dateStr)
  }

  addZero(num: number): string {
    return num > 9 ? num.toString() : '0' + num.toString()
  }

  // 判断是否为今天
  isToday(calendar: Calendar): boolean {
    const today = new Date()
    return calendar.year === today.getFullYear() && 
           calendar.month === (today.getMonth() + 1) && 
           calendar.day === today.getDate()
  }

  // 日期点击事件
  onDateClick(day: number) {
    const dateStr = `${this.yearNow}-${this.monthNow.toString().padStart(2, '0')}-${day.toString().padStart(2, '0')}`
    console.log('点击日期:', dateStr)
    // 这里可以添加日期点击的处理逻辑
  }

  // 上一个月
  lastMonth() {
    const prevMonth = this.getAdjacentMonth({ year: this.yearNow, month: this.monthNow }, -1)
    this.navigateToMonth(prevMonth.year, prevMonth.month)
  }

  // 计算相邻月份
  private getPrevMonth(year: number, month: number): YearMonth {
    if (month > 1) return { year, month: month - 1 }
    return { year: year - 1, month: 12 }
  }

  private getNextMonth(year: number, month: number): YearMonth {
    if (month < 12) return { year, month: month + 1 }
    return { year: year + 1, month: 1 }
  }

  // 生成某月的 Calendar[]
  private buildMonth(year: number, month: number): Calendar[] {
    const days = this.getMonthDate(month, year)
    const list: Calendar[] = []
    for (let i = 0; i < days.length; i++) {
      const d = days[i]
      list.push({
        year,
        month,
        day: d,
        content: d > 0 ? (this.isCheckedIn(year, month, d) ? '已签到' : '') : ''
      })
    }
    return list
  }

  // 刷新指定年份的12个月缓存（一次性重建缓存，用于快速渲染/更新）
  private refreshYearMonths(year: number): void {
    const arr: MonthData[] = []
    for (let m = 1; m <= 12; m++) {
      arr.push({ year, month: m, days: this.buildMonth(year, m) } as MonthData)
    }
    this.yearMonthsCache = arr
  }

  // 依据当前 yearNow/monthNow 刷新当月天数据
  private buildCurrentMonthDays(): void {
    this.getMonthContent()
  }

  // 载入历史签到日期
  private async loadCheckinDates(userId: number | undefined): Promise<void> {
    if (userId === undefined) { return }
    try {
      const dates = await this.apiService.getUserCheckinDates(this.username)
      this.checkinDates.clear()
      dates.forEach(dateStr => {
        this.checkinDates.add(dateStr)
      })
      console.info(`已加载 ${dates.length} 条历史签到记录`)
    } catch (error) {
      console.error('加载历史签到日期失败:', error)
    }
  }

  // 初始化月份数据：预加载5个月（前2+当前+后2）
  private initCalendarMonths(): void {
    const current: YearMonth = { year: this.yearNow, month: this.monthNow }
    const months = this.generateMonthsAround(current)
    this.months = months
    this.currentMonthIndex = 2
    
    // 滚动到当前月份
    setTimeout(() => {
      this.scrollToMonth(this.currentMonthIndex, true)
    }, 50)
  }

  // 生成指定月份周围的5个月数据
  private generateMonthsAround(center: YearMonth): MonthData[] {
    const prev2 = this.getAdjacentMonth(center, -2)
    const prev1 = this.getAdjacentMonth(center, -1)
    const next1 = this.getAdjacentMonth(center, 1)
    const next2 = this.getAdjacentMonth(center, 2)
    
    return [
      this.createMonthData(prev2),
      this.createMonthData(prev1), 
      this.createMonthData(center),
      this.createMonthData(next1),
      this.createMonthData(next2)
    ]
  }

  // 获取相对月份（支持负数表示前几个月）
  private getAdjacentMonth(base: YearMonth, offset: number): YearMonth {
    let year = base.year
    let month = base.month
    month += offset
    
    while (month > 12) {
      month -= 12
      year++
    }
    while (month < 1) {
      month += 12
      year--
    }
    
    return { year, month }
  }

  // 创建月份数据
  private createMonthData(ym: YearMonth): MonthData {
    return {
      year: ym.year,
      month: ym.month,
      days: this.buildMonth(ym.year, ym.month)
    }
  }

  // 重新居中到指定月份（边缘重建时使用）
  private recenterToMonth(year: number, month: number): void {
    this.updateCurrentMonth(year, month)
    const center: YearMonth = { year, month }
    this.months = this.generateMonthsAround(center)
    this.currentMonthIndex = 2
    
    // 无动画滚动到中心位置
    setTimeout(() => {
      this.scrollToMonth(this.currentMonthIndex, false)
    }, 10)
  }

  // 手势滚动已被拦截，吸附与方向计算逻辑已移除，仅保留按钮驱动的跳转

  // 吸附到指定索引
  private snapToIndex(targetIndex: number): void {
    if (targetIndex === this.currentMonthIndex && Math.abs(this.scrollY - targetIndex * this.MONTH_HEIGHT) < 1) {
      return // 已经在正确位置
    }
    
    this.isScrolling = true
    this.currentMonthIndex = targetIndex
    // 先快速降透明与位移，制造过渡感觉
    this.monthFade = 0.6
    this.monthShift = 12
    this.scrollToMonth(targetIndex, true)
    
    // 更新当前月份信息
    const targetMonth = this.months[targetIndex]
    this.updateCurrentMonth(targetMonth.year, targetMonth.month)
    
    // 检查是否需要重建边缘
    if (targetIndex === 0 || targetIndex === this.months.length - 1) {
      setTimeout(() => {
        this.recenterToMonth(targetMonth.year, targetMonth.month)
        // 淡入+回位
        animateTo({ duration: 220, curve: Curve.EaseOut }, () => {
          this.monthFade = 1.0
          this.monthShift = 0
        })
        this.isScrolling = false
      }, 300)
    } else {
      setTimeout(() => {
        // 淡入+回位
        animateTo({ duration: 220, curve: Curve.EaseOut }, () => {
          this.monthFade = 1.0
          this.monthShift = 0
        })
        this.isScrolling = false
      }, 300)
    }
  }

  // 滚动到指定月份索引
  private scrollToMonth(index: number, animated: boolean = true): void {
    const targetY = index * this.MONTH_HEIGHT
    this.scroller.scrollTo({ xOffset: 0, yOffset: targetY, animation: animated })
    this.scrollY = targetY
  }

  // 更新当前月份状态
  private updateCurrentMonth(year: number, month: number): void {
    if (this.yearNow !== year || this.monthNow !== month) {
      this.yearNow = year
      this.monthNow = month
      this.buildCurrentMonthDays()
      this.refreshYearMonths(year)
    }
  }

  // 导航到指定月份（按钮点击时使用）
  private navigateToMonth(year: number, month: number): void {
    // 查找目标月份在当前months数组中的索引
    let targetIndex = -1
    for (let i = 0; i < this.months.length; i++) {
      if (this.months[i].year === year && this.months[i].month === month) {
        targetIndex = i
        break
      }
    }

    if (targetIndex !== -1) {
      // 目标月份在当前数组中，直接滚动过去
      this.snapToIndex(targetIndex)
    } else {
      // 目标月份不在当前数组中，重建数组并居中
      this.updateCurrentMonth(year, month)
      this.recenterToMonth(year, month)
    }
  }

  // 下一个月
  nextMonth() {
    const nextMonth = this.getAdjacentMonth({ year: this.yearNow, month: this.monthNow }, 1)
    this.navigateToMonth(nextMonth.year, nextMonth.month)
  }

  

  async loadSummary() {
    this.isLoading = true
    try {
      const summary = await this.apiService.getUserCheckinSummary(this.username);
      if (summary) {
        this.checkinCount = Number(summary.checkinCount || 0);
        this.checkedToday = !!summary.checkedToday;
        // TODO: 从后端获取历史签到记录（如有接口）并填充 this.checkinDates
      } else {
        prompt.showToast({ message: '获取打卡信息失败', duration: 1500 });
      }
    } catch (err) {
      console.error('请求打卡汇总出错: ' + err)
      prompt.showToast({ message: '网络错误，获取打卡失败', duration: 1500 })
    } finally {
      this.isLoading = false
    }
  }


  async doCheckin() {
    if (!this.username) {
      prompt.showToast({ message: '请先登录', duration: 1500 })
      return
    }
    try {
      const result = await this.apiService.postUserCheckin(this.username);
      if (result && result.success) {
        prompt.showToast({ message: result.message || '签到成功！', duration: 1500 });
        this.checkinCount = (this.checkinCount || 0) + 1;
        this.checkedToday = true;
        const today = new Date();
        const todayStr = `${today.getFullYear()}-${(today.getMonth() + 1).toString().padStart(2, '0')}-${today.getDate().toString().padStart(2, '0')}`;
        this.checkinDates.add(todayStr);
        this.getMonthContent();
      } else if (result && !result.success && result.message) {
        prompt.showToast({ message: result.message, duration: 1500 });
        if (result.message.includes('今日已打卡') || result.message.includes('已打卡')) {
          this.checkedToday = true;
        }
      } else {
        prompt.showToast({ message: '打卡失败', duration: 1500 });
      }
    } catch (err) {
      console.error('打卡请求异常: ' + err)
      prompt.showToast({ message: '网络错误，打卡失败', duration: 1500 })
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Stack(){
          Row(){
            Image($r('app.media.arrow_left'))
              .width(24)
              .height(24)
              .onClick(() => router.back())
              .margin({ right:340 })
          }
          .zIndex(2)
          Row(){
            Text('签到打卡')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .layoutWeight(1)
              .textAlign(TextAlign.Center)
          }
          .zIndex(1)
        }
      }
      .width('100%')
      .height(56)
      .backgroundColor(Color.White)

      if (this.isLoading) {
        Row() {
          LoadingProgress().width(50).height(50)
        }
        .justifyContent(FlexAlign.Center)
        .margin({ top: 40 })
      } else {
        Column() {
          // 月份导航
          Row({ space: 20 }) {
            Image($r('app.media.chevron_left'))
              .width(15)
              .height(15)
              .onClick(() => {
                this.lastMonth()
              })
            Text(this.yearNow.toString() + '-' + this.addZero(this.monthNow))
              .fontSize(15)
              .fontColor(Color.Black)
              .fontWeight(FontWeight.Bold)
            Image($r('app.media.chevron_right'))
              .width(15)
              .height(15)
              .onClick(() => {
                this.nextMonth()
              })
          }
          .width('40%')
          .backgroundColor(Color.White)
          .borderRadius(15)
          .height(40)
          .justifyContent(FlexAlign.Center)
          .margin({top:5})

          // 星期标题
          Column() {
            Flex({ direction: FlexDirection.Row, wrap: FlexWrap.NoWrap }) {
              ForEach(['周日', '周一', '周二', '周三', '周四', '周五', '周六'], (str: string, index) => {
                Text(str)
                  .fontSize(14)
                  .fontColor(Color.Gray)
                  .textAlign(TextAlign.Center)
                  .width('14.2%')
                  .height(35)
              })
            }
          }
          .margin({ top:5 , bottom:5 })
          .borderRadius(15)
          .backgroundColor("#ffffe86f")
          .width("90%")
          
          // 日历滚动（预加载上/本/下月，滚动吸附到整月）
          Scroll(this.scroller) {
            Column() {
              ForEach(this.months, (monthData: MonthData, idx: number) => {
                this.MonthView(monthData)
              })
            }
          }
          .width('90%')
          .height(340)
          .edgeEffect(EdgeEffect.None)
          .scrollBar(BarState.Off)
          .scrollable(ScrollDirection.Vertical) // 允许纵向滚动，确保编程滚动有效
          .opacity(this.monthFade)
          .translate({ x: 0, y: this.monthShift })
          .onScroll((x: number, y: number) => { 
            const expectedY = this.currentMonthIndex * this.MONTH_HEIGHT
            if (!this.isScrolling) {
              // 拦截用户手势滚动：立即回到当前月份位置
              if (Math.abs(y - expectedY) > 1) {
                this.scroller.scrollTo({ xOffset: 0, yOffset: expectedY, animation: false })
              }
              this.scrollY = expectedY
              return
            }
            // 程序性滚动时，正常记录位置
            this.scrollY = y
          })

          // 统计信息和签到按钮
          Column() {
            Row() {
              Image($r("app.media.tyikjgch"))
                .height(100)
              Column() {
                Text('累计签到')
                  .fontSize(14)
                  .fontColor('#666')
                Text(`${this.checkinCount}天`)
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FF6B35')
                  .margin({ top: 5 })
              }
              .layoutWeight(1)

              Column() {
                if (this.checkedToday) {
                  Button('今日已签到')
                    .type(ButtonType.Capsule)
                    .backgroundColor('#E0E0E0')
                    .fontColor('#999')
                    .width(120)
                    .height(44)
                    .enabled(false)
                } else {
                  Button('立即签到')
                    .type(ButtonType.Capsule)
                    .backgroundColor('#FF6B35')
                    .fontColor(Color.White)
                    .width(120)
                    .height(44)
                    .onClick(() => { this.doCheckin() })
                }
              }
            }
            .padding({ left: 20, right: 20, top: 20, bottom: 15 })

            Text('连续签到14天即可获得领养资格')
              .fontSize(12)
              .fontColor('#999')
              .textAlign(TextAlign.Center)
              .margin({ bottom: 20 })
          }
          .backgroundColor(Color.White)
          .borderRadius(15)
          .margin({ left: 15, right: 15, top: 15 })
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  // 单个月份视图组件
  @Builder
  MonthView(monthData: MonthData) {
    Column() {
      Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
        ForEach(monthData.days, (calendar: Calendar, index: number) => {
          Column({ space: 4 }) {
            // 日期圆形高亮
            Stack() {
              if (this.isToday(calendar)) {
                // 今天：蓝色高亮（优先级最高）
                Row() {}
                  .width(28)
                  .height(28)
                  .backgroundColor('#2F80ED')
                  .borderRadius(14)
              } else if (calendar.day > 0 && this.isCheckedIn(calendar.year, calendar.month, calendar.day)) {
                // 已签到日期：橙色高亮
                Row() {}
                  .width(28)
                  .height(28)
                  .backgroundColor('#FF6B35')
                  .borderRadius(14)
              } else {
                // 普通日期：透明背景
                Row() {}
                  .width(28)
                  .height(28)
                  .backgroundColor(Color.Transparent)
              }
              Text(calendar.day > 0 ? calendar.day.toString() : '')
                .fontSize(14)
                .fontColor(this.isToday(calendar) || (calendar.day > 0 && this.isCheckedIn(calendar.year, calendar.month, calendar.day)) ? Color.White : Color.Black)
                .fontWeight(this.isToday(calendar) || (calendar.day > 0 && this.isCheckedIn(calendar.year, calendar.month, calendar.day)) ? FontWeight.Bold : FontWeight.Normal)
                .textAlign(TextAlign.Center)
            }
            .width('100%')
            .height(32)
            .align(Alignment.Center)

            if (calendar.day > 0 && calendar.content && calendar.content.length > 0) {
              Text(calendar.content)
                .fontColor('#AAA')
                .fontSize(10)
                .textAlign(TextAlign.Center)
            } else {
              Blank().height(0)
            }
          }
          .justifyContent(FlexAlign.Center)
          .padding({ top: 6, bottom: 6 })
          .width('14.28%')
          .height(56)
          .alignItems(HorizontalAlign.Center)
          .visibility(calendar.day == 0 ? Visibility.Hidden : Visibility.Visible)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            if (calendar.day > 0) {
              this.onDateClick(calendar.day)
            }
          })
        })
      }
    }
    .padding({ left: 10, right: 10 })
    .width('100%')
    .height(this.MONTH_HEIGHT)
    .backgroundColor(Color.White)
  }
}
