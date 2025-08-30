package com.example.springboot.controller;

import com.example.springboot.entity.City;
import com.example.springboot.repository.CityRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 城市管理控制器
 */
@RestController
@RequestMapping("/api/cities")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class CityController {
    
    private final CityRepository cityRepository;
    
    /**
     * 获取所有城市列表（按拼音排序）
     */
    @GetMapping
    public ResponseEntity<Map<String, Object>> getAllCities() {
        try {
            List<City> cities = cityRepository.findAllByOrderByPinyinAsc();
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("data", cities);
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "服务器内部错误");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
}
