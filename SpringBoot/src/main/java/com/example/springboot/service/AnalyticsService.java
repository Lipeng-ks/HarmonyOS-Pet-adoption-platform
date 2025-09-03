package com.example.springboot.service;

import com.example.springboot.dto.AnalyticsDTO;
import com.example.springboot.entity.AdoptionOrder;
import com.example.springboot.repository.AdoptionOrderRepository;
import com.example.springboot.repository.AnimalRepository;
import com.example.springboot.repository.UserInfoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 数据分析服务类
 */
@Service
public class AnalyticsService {

    @Autowired
    private AdoptionOrderRepository adoptionOrderRepository;

    @Autowired
    private AnimalRepository animalRepository;

    @Autowired
    private UserInfoRepository userInfoRepository;

    /**
     * 获取核心指标数据
     */
    public AnalyticsDTO.MetricsData getMetricsData() {
        // 获取总领养数
        Long totalAdoptions = adoptionOrderRepository.countByStatus(AdoptionOrder.OrderStatus.完成);
        
        // 获取总宠物数
        Long totalAnimals = animalRepository.count();
        
        // 获取总用户数
        Long totalUsers = userInfoRepository.count();
        
        // 计算成功率（完成订单 / 总订单）
        Long totalOrders = adoptionOrderRepository.count();
        Double successRate = totalOrders > 0 ? (totalAdoptions.doubleValue() / totalOrders.doubleValue()) * 100 : 0.0;
        
        // 计算增长率（这里使用模拟数据，实际应该对比上个周期）
        Double adoptionGrowth = 12.5;
        Double animalGrowth = 8.3;
        Double userGrowth = 15.2;
        Double rateGrowth = 3.2;

        return new AnalyticsDTO.MetricsData(
            totalAdoptions, adoptionGrowth,
            totalAnimals, animalGrowth,
            totalUsers, userGrowth,
            successRate, rateGrowth
        );
    }

    /**
     * 获取趋势数据
     */
    public List<AnalyticsDTO.TrendData> getTrendData(String period) {
        List<AnalyticsDTO.TrendData> trendData = new ArrayList<>();
        
        // 根据周期获取数据
        LocalDateTime endDate = LocalDateTime.now();
        LocalDateTime startDate;
        
        switch (period) {
            case "7d":
                startDate = endDate.minusDays(7);
                // 按天统计最近7天
                for (int i = 6; i >= 0; i--) {
                    LocalDateTime date = endDate.minusDays(i);
                    String label = date.format(DateTimeFormatter.ofPattern("MM-dd"));
                    Long count = getAdoptionCountByDate(date.toLocalDate());
                    trendData.add(new AnalyticsDTO.TrendData(label, count));
                }
                break;
            case "30d":
                startDate = endDate.minusDays(30);
                // 按周统计最近30天
                for (int i = 4; i >= 0; i--) {
                    LocalDateTime weekStart = endDate.minusDays(i * 7 + 6);
                    LocalDateTime weekEnd = endDate.minusDays(i * 7);
                    String label = "第" + (5 - i) + "周";
                    Long count = getAdoptionCountBetweenDates(weekStart.toLocalDate(), weekEnd.toLocalDate());
                    trendData.add(new AnalyticsDTO.TrendData(label, count));
                }
                break;
            case "3m":
            default:
                // 按月统计最近3个月
                for (int i = 2; i >= 0; i--) {
                    LocalDateTime monthStart = endDate.minusMonths(i).withDayOfMonth(1);
                    LocalDateTime monthEnd = monthStart.plusMonths(1).minusDays(1);
                    String label = monthStart.format(DateTimeFormatter.ofPattern("MM月"));
                    Long count = getAdoptionCountBetweenDates(monthStart.toLocalDate(), monthEnd.toLocalDate());
                    trendData.add(new AnalyticsDTO.TrendData(label, count));
                }
                break;
        }
        
        return trendData;
    }

    /**
     * 获取宠物类型分布数据
     */
    public List<AnalyticsDTO.TypeDistribution> getTypeDistribution() {
        List<Object[]> typeStats = animalRepository.findTypeDistribution();
        Long totalAnimals = animalRepository.count();
        
        List<AnalyticsDTO.TypeDistribution> typeData = new ArrayList<>();
        String[] colors = {"#409EFF", "#67C23A", "#E6A23C", "#F56C6C", "#909399"};
        
        for (int i = 0; i < typeStats.size() && i < colors.length; i++) {
            Object[] stat = typeStats.get(i);
            String type = (String) stat[0];
            Long count = ((Number) stat[1]).longValue();
            Double percentage = totalAnimals > 0 ? (count.doubleValue() / totalAnimals.doubleValue()) * 100 : 0.0;
            
            typeData.add(new AnalyticsDTO.TypeDistribution(
                type, count, Math.round(percentage * 100.0) / 100.0, colors[i]
            ));
        }
        
        return typeData;
    }

    /**
     * 获取城市分布数据
     */
    public List<AnalyticsDTO.CityDistribution> getCityDistribution() {
        List<Object[]> cityStats = animalRepository.findCityDistribution();
        
        return cityStats.stream()
            .limit(10) // 只取前10个城市
            .map(stat -> new AnalyticsDTO.CityDistribution(
                (String) stat[0], 
                ((Number) stat[1]).longValue()
            ))
            .collect(Collectors.toList());
    }

    /**
     * 获取用户活跃度数据
     */
    public List<AnalyticsDTO.ActivityData> getActivityData() {
        List<AnalyticsDTO.ActivityData> activityData = new ArrayList<>();
        String[] days = {"周一", "周二", "周三", "周四", "周五", "周六", "周日"};
        
        // 这里使用模拟数据，实际应该从数据库查询
        Random random = new Random();
        for (String day : days) {
            Long newUsers = (long) (50 + random.nextInt(100));
            Long activeUsers = (long) (newUsers * 0.6 + random.nextInt(20));
            activityData.add(new AnalyticsDTO.ActivityData(day, newUsers, activeUsers));
        }
        
        return activityData;
    }

    /**
     * 获取详细数据
     */
    public List<AnalyticsDTO.DetailData> getDetailData() {
        List<AnalyticsDTO.DetailData> detailData = new ArrayList<>();
        LocalDate today = LocalDate.now();
        
        for (int i = 6; i >= 0; i--) {
            LocalDate date = today.minusDays(i);
            String dateStr = date.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
            
            Long adoptions = getAdoptionCountByDate(date);
            Long newAnimals = getNewAnimalCountByDate(date);
            Long newUsers = getNewUserCountByDate(date);
            
            // 计算当日成功率
            Long totalOrdersOnDate = getTotalOrderCountByDate(date);
            Double successRate = totalOrdersOnDate > 0 ? 
                (adoptions.doubleValue() / totalOrdersOnDate.doubleValue()) * 100 : 0.0;
            
            // 模拟收入数据
            Double revenue = adoptions * 300.0 + Math.random() * 1000;
            
            detailData.add(new AnalyticsDTO.DetailData(
                dateStr, adoptions, newAnimals, newUsers, 
                Math.round(successRate * 100.0) / 100.0, 
                Math.round(revenue * 100.0) / 100.0
            ));
        }
        
        return detailData;
    }

    /**
     * 获取完整的分析数据
     */
    public AnalyticsDTO.AnalyticsResponse getAnalyticsData(String period) {
        AnalyticsDTO.AnalyticsResponse response = new AnalyticsDTO.AnalyticsResponse();
        
        response.setMetrics(getMetricsData());
        response.setTrendData(getTrendData(period));
        response.setTypeData(getTypeDistribution());
        response.setCityData(getCityDistribution());
        response.setActivityData(getActivityData());
        response.setDetailData(getDetailData());
        
        return response;
    }

    // 辅助方法
    private Long getAdoptionCountByDate(LocalDate date) {
        LocalDateTime startOfDay = date.atStartOfDay();
        LocalDateTime endOfDay = date.atTime(23, 59, 59);
        return adoptionOrderRepository.countByStatusAndCompletedAtBetween(AdoptionOrder.OrderStatus.完成, startOfDay, endOfDay);
    }

    private Long getAdoptionCountBetweenDates(LocalDate startDate, LocalDate endDate) {
        LocalDateTime start = startDate.atStartOfDay();
        LocalDateTime end = endDate.atTime(23, 59, 59);
        return adoptionOrderRepository.countByStatusAndCompletedAtBetween(AdoptionOrder.OrderStatus.完成, start, end);
    }

    private Long getNewAnimalCountByDate(LocalDate date) {
        // 这里需要根据实际的创建时间字段查询，暂时返回模拟数据
        return (long) (20 + new Random().nextInt(20));
    }

    private Long getNewUserCountByDate(LocalDate date) {
        // 这里需要根据实际的创建时间字段查询，暂时返回模拟数据
        return (long) (80 + new Random().nextInt(60));
    }

    private Long getTotalOrderCountByDate(LocalDate date) {
        LocalDateTime startOfDay = date.atStartOfDay();
        LocalDateTime endOfDay = date.atTime(23, 59, 59);
        return adoptionOrderRepository.countByApplicationTimeBetween(startOfDay, endOfDay);
    }
}