import axios from 'axios'

const API_BASE_URL = 'http://localhost:8080/api'

export interface MetricsData {
  totalAdoptions: number
  adoptionGrowth: number
  totalAnimals: number
  animalGrowth: number
  totalUsers: number
  userGrowth: number
  successRate: number
  rateGrowth: number
}

export interface TrendData {
  label: string
  value: number
}

export interface TypeDistribution {
  name: string
  value: number
  percentage: number
  color: string
}

export interface CityDistribution {
  city: string
  count: number
}

export interface ActivityData {
  day: string
  newUsers: number
  activeUsers: number
}

export interface DetailData {
  date: string
  adoptions: number
  newAnimals: number
  newUsers: number
  successRate: number
  revenue: number
}

export interface AnalyticsResponse {
  metrics: MetricsData
  trendData: TrendData[]
  typeData: TypeDistribution[]
  cityData: CityDistribution[]
  activityData: ActivityData[]
  detailData: DetailData[]
}

class AnalyticsService {
  /**
   * 获取核心指标数据
   */
  async getMetrics(): Promise<MetricsData> {
    try {
      const response = await axios.get(`${API_BASE_URL}/analytics/metrics`)
      if (response.data.success) {
        return response.data.data
      }
      throw new Error(response.data.message || '获取核心指标失败')
    } catch (error) {
      console.error('获取核心指标失败:', error)
      throw error
    }
  }

  /**
   * 获取趋势数据
   */
  async getTrendData(period: string = '30d'): Promise<TrendData[]> {
    try {
      const response = await axios.get(`${API_BASE_URL}/analytics/trend`, {
        params: { period }
      })
      if (response.data.success) {
        return response.data.data
      }
      throw new Error(response.data.message || '获取趋势数据失败')
    } catch (error) {
      console.error('获取趋势数据失败:', error)
      throw error
    }
  }

  /**
   * 获取宠物类型分布数据
   */
  async getTypeDistribution(): Promise<TypeDistribution[]> {
    try {
      const response = await axios.get(`${API_BASE_URL}/analytics/type-distribution`)
      if (response.data.success) {
        return response.data.data
      }
      throw new Error(response.data.message || '获取类型分布数据失败')
    } catch (error) {
      console.error('获取类型分布数据失败:', error)
      throw error
    }
  }

  /**
   * 获取城市分布数据
   */
  async getCityDistribution(): Promise<CityDistribution[]> {
    try {
      const response = await axios.get(`${API_BASE_URL}/analytics/city-distribution`)
      if (response.data.success) {
        return response.data.data
      }
      throw new Error(response.data.message || '获取城市分布数据失败')
    } catch (error) {
      console.error('获取城市分布数据失败:', error)
      throw error
    }
  }

  /**
   * 获取用户活跃度数据
   */
  async getActivityData(): Promise<ActivityData[]> {
    try {
      const response = await axios.get(`${API_BASE_URL}/analytics/activity`)
      if (response.data.success) {
        return response.data.data
      }
      throw new Error(response.data.message || '获取活跃度数据失败')
    } catch (error) {
      console.error('获取活跃度数据失败:', error)
      throw error
    }
  }

  /**
   * 获取详细数据
   */
  async getDetailData(): Promise<DetailData[]> {
    try {
      const response = await axios.get(`${API_BASE_URL}/analytics/detail`)
      if (response.data.success) {
        return response.data.data
      }
      throw new Error(response.data.message || '获取详细数据失败')
    } catch (error) {
      console.error('获取详细数据失败:', error)
      throw error
    }
  }

  /**
   * 获取完整的分析数据
   */
  async getDashboardData(period: string = '30d'): Promise<AnalyticsResponse> {
    try {
      const response = await axios.get(`${API_BASE_URL}/analytics/dashboard`, {
        params: { period }
      })
      if (response.data.success) {
        return response.data.data
      }
      throw new Error(response.data.message || '获取分析数据失败')
    } catch (error) {
      console.error('获取分析数据失败:', error)
      throw error
    }
  }

  /**
   * 获取实时统计数据
   */
  async getRealtimeStats(): Promise<any> {
    try {
      const response = await axios.get(`${API_BASE_URL}/analytics/realtime`)
      if (response.data.success) {
        return response.data.data
      }
      throw new Error(response.data.message || '获取实时数据失败')
    } catch (error) {
      console.error('获取实时数据失败:', error)
      throw error
    }
  }

  /**
   * 导出报表
   */
  async exportReport(period: string = '30d', format: string = 'excel'): Promise<any> {
    try {
      const response = await axios.get(`${API_BASE_URL}/analytics/export`, {
        params: { period, format }
      })
      if (response.data.success) {
        return response.data
      }
      throw new Error(response.data.message || '导出报表失败')
    } catch (error) {
      console.error('导出报表失败:', error)
      throw error
    }
  }
}

export default new AnalyticsService()