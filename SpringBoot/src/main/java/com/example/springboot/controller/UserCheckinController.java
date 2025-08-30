package com.example.springboot.controller;

import com.example.springboot.service.UserCheckinService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class UserCheckinController {

    private final UserCheckinService checkinService;

    /**
     * 用户今日打卡
     */
    @PostMapping("/{username}/checkin")
    public ResponseEntity<Map<String, Object>> checkin(@PathVariable String username) {
        Map<String, Object> response = new HashMap<>();
        try {
            boolean ok = checkinService.checkinForUser(username, LocalDate.now());
            response.put("success", ok);
            if (ok) {
                response.put("message", "打卡成功");
                return ResponseEntity.ok(response);
            } else {
                response.put("message", "今日已打卡或用户不存在");
                return ResponseEntity.status(HttpStatus.CONFLICT).body(response);
            }
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "服务器错误");
            response.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    /**
     * 获取用户历史打卡日期列表
     * GET /api/users/{username}/checkin-dates
     * 响应示例：
     * {
     *   "success": true,
     *   "dates": ["2025-08-01", "2025-07-30", ...]
     * }
     */
    @GetMapping("/{username}/checkin-dates")
    public ResponseEntity<Map<String, Object>> getCheckinDates(@PathVariable String username) {
        Map<String, Object> response = new HashMap<>();
        try {
            var dates = checkinService.getCheckinDates(username);
            response.put("success", true);
            // 统一返回字符串数组（yyyy-MM-dd）
            var list = new ArrayList<String>();
            for (var d : dates) {
                list.add(d.toString());
            }
            response.put("dates", list);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "服务器错误");
            response.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    /**
     * 获取用户所有打卡记录
     */
    @GetMapping("/{username}/checkins")
    public ResponseEntity<Map<String, Object>> getCheckins(@PathVariable String username) {
        Map<String, Object> response = new HashMap<>();
        try {
            response.put("success", true);
            // 获取汇总并判断是否今日已打卡
            var summary = checkinService.getSummaryForUser(username);
            Map<String, Object> summaryMap = new HashMap<>();
            if (summary != null) {
                summaryMap.put("checkinCount", summary.getCheckinCount());
                summaryMap.put("userId", summary.getUserId());
                summaryMap.put("username", summary.getUsername());
            }
            boolean checkedToday = checkinService.hasCheckinOnDate(username, LocalDate.now());
            summaryMap.put("checkedToday", checkedToday);
            response.put("summary", summaryMap);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "服务器错误");
            response.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    /**
     * 获取所有用户的签到记录
     * GET /api/users/checkins/all
     * 响应示例：
     * {
     *   "success": true,
     *   "records": [
     *     {
     *       "userId": 1,
     *       "username": "admin",
     *       "date": "2025-08-25"
     *     },
     *     ...
     *   ]
     * }
     */
    @GetMapping("/checkins/all")
    public ResponseEntity<Map<String, Object>> getAllCheckins() {
        Map<String, Object> response = new HashMap<>();
        try {
            var allRecords = checkinService.getAllCheckinRecords();
            response.put("success", true);
            response.put("records", allRecords);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "服务器错误");
            response.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
}


