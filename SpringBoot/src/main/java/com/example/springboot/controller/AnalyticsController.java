package com.example.springboot.controller;

import com.example.springboot.dto.AnalyticsDTO;
import com.example.springboot.service.AnalyticsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 数据分析控制器
 */
@RestController
@RequestMapping("/api/analytics")
@CrossOrigin(origins = "*")
public class AnalyticsController {

    @Autowired
    private AnalyticsService analyticsService;

    /**
     * 获取核心指标数据
     */
    @GetMapping("/metrics")
    public ResponseEntity<Map<String, Object>> getMetrics() {
        try {
            AnalyticsDTO.MetricsData metrics = analyticsService.getMetricsData();
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("data", metrics);
            response.put("message", "获取核心指标成功");
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", "获取核心指标失败: " + e.getMessage());
            
            return ResponseEntity.status(500).body(errorResponse);
        }
    }

    /**
     * 获取趋势数据
     */
    @GetMapping("/trend")
    public ResponseEntity<Map<String, Object>> getTrendData(
            @RequestParam(defaultValue = "30d") String period) {
        try {
            List<AnalyticsDTO.TrendData> trendData = analyticsService.getTrendData(period);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("data", trendData);
            response.put("message", "获取趋势数据成功");
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", "获取趋势数据失败: " + e.getMessage());
            
            return ResponseEntity.status(500).body(errorResponse);
        }
    }

    /**
     * 获取宠物类型分布数据
     */
    @GetMapping("/type-distribution")
    public ResponseEntity<Map<String, Object>> getTypeDistribution() {
        try {
            List<AnalyticsDTO.TypeDistribution> typeData = analyticsService.getTypeDistribution();
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("data", typeData);
            response.put("message", "获取类型分布数据成功");
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", "获取类型分布数据失败: " + e.getMessage());
            
            return ResponseEntity.status(500).body(errorResponse);
        }
    }

    /**
     * 获取城市分布数据
     */
    @GetMapping("/city-distribution")
    public ResponseEntity<Map<String, Object>> getCityDistribution() {
        try {
            List<AnalyticsDTO.CityDistribution> cityData = analyticsService.getCityDistribution();
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("data", cityData);
            response.put("message", "获取城市分布数据成功");
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", "获取城市分布数据失败: " + e.getMessage());
            
            return ResponseEntity.status(500).body(errorResponse);
        }
    }

    /**
     * 获取用户活跃度数据
     */
    @GetMapping("/activity")
    public ResponseEntity<Map<String, Object>> getActivityData() {
        try {
            List<AnalyticsDTO.ActivityData> activityData = analyticsService.getActivityData();
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("data", activityData);
            response.put("message", "获取活跃度数据成功");
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", "获取活跃度数据失败: " + e.getMessage());
            
            return ResponseEntity.status(500).body(errorResponse);
        }
    }

    /**
     * 获取详细数据
     */
    @GetMapping("/detail")
    public ResponseEntity<Map<String, Object>> getDetailData() {
        try {
            List<AnalyticsDTO.DetailData> detailData = analyticsService.getDetailData();
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("data", detailData);
            response.put("message", "获取详细数据成功");
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", "获取详细数据失败: " + e.getMessage());
            
            return ResponseEntity.status(500).body(errorResponse);
        }
    }

    /**
     * 获取完整的分析数据
     */
    @GetMapping("/dashboard")
    public ResponseEntity<Map<String, Object>> getDashboardData(
            @RequestParam(defaultValue = "30d") String period) {
        try {
            AnalyticsDTO.AnalyticsResponse analyticsData = analyticsService.getAnalyticsData(period);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("data", analyticsData);
            response.put("message", "获取分析数据成功");
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", "获取分析数据失败: " + e.getMessage());
            
            return ResponseEntity.status(500).body(errorResponse);
        }
    }

    /**
     * 导出报表数据
     */
    @GetMapping("/export")
    public ResponseEntity<Map<String, Object>> exportReport(
            @RequestParam(defaultValue = "30d") String period,
            @RequestParam(defaultValue = "excel") String format) {
        try {
            // 这里可以实现具体的导出逻辑
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "报表导出功能开发中...");
            response.put("downloadUrl", "/api/analytics/download/" + System.currentTimeMillis());
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", "导出报表失败: " + e.getMessage());
            
            return ResponseEntity.status(500).body(errorResponse);
        }
    }

    /**
     * 获取实时统计数据
     */
    @GetMapping("/realtime")
    public ResponseEntity<Map<String, Object>> getRealtimeStats() {
        try {
            Map<String, Object> realtimeData = new HashMap<>();
            
            // 获取实时数据
            AnalyticsDTO.MetricsData metrics = analyticsService.getMetricsData();
            realtimeData.put("onlineUsers", 156); // 模拟在线用户数
            realtimeData.put("todayAdoptions", 12); // 今日领养数
            realtimeData.put("todayRegistrations", 28); // 今日注册数
            realtimeData.put("systemStatus", "正常"); // 系统状态
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("data", realtimeData);
            response.put("message", "获取实时数据成功");
            response.put("timestamp", System.currentTimeMillis());
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", "获取实时数据失败: " + e.getMessage());
            
            return ResponseEntity.status(500).body(errorResponse);
        }
    }
}