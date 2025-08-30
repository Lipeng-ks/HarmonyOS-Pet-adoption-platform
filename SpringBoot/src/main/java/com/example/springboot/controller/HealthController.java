package com.example.springboot.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * 健康检查控制器
 */
@RestController
@CrossOrigin(origins = "*")
public class HealthController {
    
    /**
     * 健康检查接口
     */
    @GetMapping("/api/ping")
    public ResponseEntity<Map<String, String>> ping() {
        Map<String, String> response = new HashMap<>();
        response.put("message", "API服务器正常运行");
        return ResponseEntity.ok(response);
    }
}
