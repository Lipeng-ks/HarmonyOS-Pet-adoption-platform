// 全局状态管理
export class GlobalState {
  private static instance: GlobalState;
  private selectedCity: string = '全国';
  private cityChangeCallbacks: ((city: string) => void)[] = [];

  private constructor() {}

  static getInstance(): GlobalState {
    if (!GlobalState.instance) {
      GlobalState.instance = new GlobalState();
    }
    return GlobalState.instance;
  }

  // 设置选中的城市
  setSelectedCity(city: string): void {
    this.selectedCity = city;
    // 通知所有监听者
    this.cityChangeCallbacks.forEach(callback => callback(city));
  }

  // 获取选中的城市
  getSelectedCity(): string {
    return this.selectedCity;
  }

  // 注册城市变化监听
  onCityChange(callback: (city: string) => void): void {
    this.cityChangeCallbacks.push(callback);
  }

  // 移除城市变化监听
  offCityChange(callback: (city: string) => void): void {
    const index = this.cityChangeCallbacks.indexOf(callback);
    if (index > -1) {
      this.cityChangeCallbacks.splice(index, 1);
    }
  }
}
