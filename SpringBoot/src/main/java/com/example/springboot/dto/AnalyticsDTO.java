package com.example.springboot.dto;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 数据分析相关的DTO类
 */
public class AnalyticsDTO {

    /**
     * 核心指标数据
     */
    public static class MetricsData {
        private Long totalAdoptions;
        private Double adoptionGrowth;
        private Long totalAnimals;
        private Double animalGrowth;
        private Long totalUsers;
        private Double userGrowth;
        private Double successRate;
        private Double rateGrowth;

        // 构造函数
        public MetricsData() {}

        public MetricsData(Long totalAdoptions, Double adoptionGrowth, Long totalAnimals, 
                          Double animalGrowth, Long totalUsers, Double userGrowth, 
                          Double successRate, Double rateGrowth) {
            this.totalAdoptions = totalAdoptions;
            this.adoptionGrowth = adoptionGrowth;
            this.totalAnimals = totalAnimals;
            this.animalGrowth = animalGrowth;
            this.totalUsers = totalUsers;
            this.userGrowth = userGrowth;
            this.successRate = successRate;
            this.rateGrowth = rateGrowth;
        }

        // Getters and Setters
        public Long getTotalAdoptions() { return totalAdoptions; }
        public void setTotalAdoptions(Long totalAdoptions) { this.totalAdoptions = totalAdoptions; }

        public Double getAdoptionGrowth() { return adoptionGrowth; }
        public void setAdoptionGrowth(Double adoptionGrowth) { this.adoptionGrowth = adoptionGrowth; }

        public Long getTotalAnimals() { return totalAnimals; }
        public void setTotalAnimals(Long totalAnimals) { this.totalAnimals = totalAnimals; }

        public Double getAnimalGrowth() { return animalGrowth; }
        public void setAnimalGrowth(Double animalGrowth) { this.animalGrowth = animalGrowth; }

        public Long getTotalUsers() { return totalUsers; }
        public void setTotalUsers(Long totalUsers) { this.totalUsers = totalUsers; }

        public Double getUserGrowth() { return userGrowth; }
        public void setUserGrowth(Double userGrowth) { this.userGrowth = userGrowth; }

        public Double getSuccessRate() { return successRate; }
        public void setSuccessRate(Double successRate) { this.successRate = successRate; }

        public Double getRateGrowth() { return rateGrowth; }
        public void setRateGrowth(Double rateGrowth) { this.rateGrowth = rateGrowth; }
    }

    /**
     * 趋势数据
     */
    public static class TrendData {
        private String label;
        private Long value;

        public TrendData() {}

        public TrendData(String label, Long value) {
            this.label = label;
            this.value = value;
        }

        public String getLabel() { return label; }
        public void setLabel(String label) { this.label = label; }

        public Long getValue() { return value; }
        public void setValue(Long value) { this.value = value; }
    }

    /**
     * 宠物类型分布数据
     */
    public static class TypeDistribution {
        private String name;
        private Long value;
        private Double percentage;
        private String color;

        public TypeDistribution() {}

        public TypeDistribution(String name, Long value, Double percentage, String color) {
            this.name = name;
            this.value = value;
            this.percentage = percentage;
            this.color = color;
        }

        public String getName() { return name; }
        public void setName(String name) { this.name = name; }

        public Long getValue() { return value; }
        public void setValue(Long value) { this.value = value; }

        public Double getPercentage() { return percentage; }
        public void setPercentage(Double percentage) { this.percentage = percentage; }

        public String getColor() { return color; }
        public void setColor(String color) { this.color = color; }
    }

    /**
     * 城市分布数据
     */
    public static class CityDistribution {
        private String city;
        private Long count;

        public CityDistribution() {}

        public CityDistribution(String city, Long count) {
            this.city = city;
            this.count = count;
        }

        public String getCity() { return city; }
        public void setCity(String city) { this.city = city; }

        public Long getCount() { return count; }
        public void setCount(Long count) { this.count = count; }
    }

    /**
     * 用户活跃度数据
     */
    public static class ActivityData {
        private String day;
        private Long newUsers;
        private Long activeUsers;

        public ActivityData() {}

        public ActivityData(String day, Long newUsers, Long activeUsers) {
            this.day = day;
            this.newUsers = newUsers;
            this.activeUsers = activeUsers;
        }

        public String getDay() { return day; }
        public void setDay(String day) { this.day = day; }

        public Long getNewUsers() { return newUsers; }
        public void setNewUsers(Long newUsers) { this.newUsers = newUsers; }

        public Long getActiveUsers() { return activeUsers; }
        public void setActiveUsers(Long activeUsers) { this.activeUsers = activeUsers; }
    }

    /**
     * 详细数据
     */
    public static class DetailData {
        private String date;
        private Long adoptions;
        private Long newAnimals;
        private Long newUsers;
        private Double successRate;
        private Double revenue;

        public DetailData() {}

        public DetailData(String date, Long adoptions, Long newAnimals, Long newUsers, 
                         Double successRate, Double revenue) {
            this.date = date;
            this.adoptions = adoptions;
            this.newAnimals = newAnimals;
            this.newUsers = newUsers;
            this.successRate = successRate;
            this.revenue = revenue;
        }

        public String getDate() { return date; }
        public void setDate(String date) { this.date = date; }

        public Long getAdoptions() { return adoptions; }
        public void setAdoptions(Long adoptions) { this.adoptions = adoptions; }

        public Long getNewAnimals() { return newAnimals; }
        public void setNewAnimals(Long newAnimals) { this.newAnimals = newAnimals; }

        public Long getNewUsers() { return newUsers; }
        public void setNewUsers(Long newUsers) { this.newUsers = newUsers; }

        public Double getSuccessRate() { return successRate; }
        public void setSuccessRate(Double successRate) { this.successRate = successRate; }

        public Double getRevenue() { return revenue; }
        public void setRevenue(Double revenue) { this.revenue = revenue; }
    }

    /**
     * 完整的分析数据响应
     */
    public static class AnalyticsResponse {
        private MetricsData metrics;
        private List<TrendData> trendData;
        private List<TypeDistribution> typeData;
        private List<CityDistribution> cityData;
        private List<ActivityData> activityData;
        private List<DetailData> detailData;

        public AnalyticsResponse() {}

        public MetricsData getMetrics() { return metrics; }
        public void setMetrics(MetricsData metrics) { this.metrics = metrics; }

        public List<TrendData> getTrendData() { return trendData; }
        public void setTrendData(List<TrendData> trendData) { this.trendData = trendData; }

        public List<TypeDistribution> getTypeData() { return typeData; }
        public void setTypeData(List<TypeDistribution> typeData) { this.typeData = typeData; }

        public List<CityDistribution> getCityData() { return cityData; }
        public void setCityData(List<CityDistribution> cityData) { this.cityData = cityData; }

        public List<ActivityData> getActivityData() { return activityData; }
        public void setActivityData(List<ActivityData> activityData) { this.activityData = activityData; }

        public List<DetailData> getDetailData() { return detailData; }
        public void setDetailData(List<DetailData> detailData) { this.detailData = detailData; }
    }
}