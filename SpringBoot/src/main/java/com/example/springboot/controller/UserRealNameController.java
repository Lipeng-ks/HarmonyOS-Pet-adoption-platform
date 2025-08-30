package com.example.springboot.controller;

import com.example.springboot.entity.UserRealName;
import com.example.springboot.repository.UserRealNameRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/realname")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class UserRealNameController {

    private final UserRealNameRepository repository;

    /**
     * 获取所有实名认证信息
     */
    @GetMapping("/list")
    public ResponseEntity<Map<String, Object>> getAllRealNames() {
        Map<String, Object> resp = new HashMap<>();
        try {
            var realNames = repository.findAll();
            resp.put("success", true);
            resp.put("data", realNames);
            return ResponseEntity.ok(resp);
        } catch (Exception ex) {
            resp.put("success", false);
            resp.put("message", "获取实名认证信息失败");
            resp.put("error", ex.getMessage());
            return ResponseEntity.status(500).body(resp);
        }
    }

    @PostMapping("/bind")
    public ResponseEntity<Map<String,Object>> bind(@RequestBody UserRealName payload) {
        Map<String,Object> resp = new HashMap<>();
        try {
            // 基本校验
            if (payload.getFullName() == null || payload.getFullName().trim().isEmpty()) {
                resp.put("success", false);
                resp.put("message", "姓名不能为空");
                return ResponseEntity.badRequest().body(resp);
            }
            if (payload.getIdNumber() == null || payload.getIdNumber().trim().isEmpty()) {
                resp.put("success", false);
                resp.put("message", "身份证号不能为空");
                return ResponseEntity.badRequest().body(resp);
            }
            // 简单身份证格式校验（15或18位，最后一位可为X）
            if (!payload.getIdNumber().matches("^(\\d{15}|\\d{17}[\\dXx])$")) {
                resp.put("success", false);
                resp.put("message", "身份证号格式不正确");
                return ResponseEntity.badRequest().body(resp);
            }
            // 1. 校验是否已被绑定
            if (repository.findByUserId(payload.getUserId()).isPresent()) {
                resp.put("success", false);
                resp.put("message", "该用户已绑定实名认证");
                return ResponseEntity.badRequest().body(resp);
            }
            if (repository.findByIdNumber(payload.getIdNumber()).isPresent()) {
                resp.put("success", false);
                resp.put("message", "该身份证号已被绑定");
                return ResponseEntity.badRequest().body(resp);
            }

            UserRealName saved = repository.save(payload);
            // 返回时掩码身份证号，只保留前3后2位
            UserRealName masked = new UserRealName();
            masked.setId(saved.getId());
            masked.setUserId(saved.getUserId());
            masked.setFullName(saved.getFullName());
            String idNum = saved.getIdNumber();
            if (idNum != null && idNum.length() >= 5) {
                String maskedId = idNum.substring(0, 3) + "****" + idNum.substring(idNum.length() - 2);
                masked.setIdNumber(maskedId);
            } else {
                masked.setIdNumber("****");
            }
            resp.put("success", true);
            resp.put("data", masked);
            return ResponseEntity.ok(resp);
        } catch (Exception ex) {
            resp.put("success", false);
            resp.put("message", "服务器错误");
            resp.put("error", ex.getMessage());
            return ResponseEntity.status(500).body(resp);
        }
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<Map<String,Object>> getByUser(@PathVariable Long userId) {
        Map<String,Object> resp = new HashMap<>();
        var opt = repository.findByUserId(userId);
        if (opt.isPresent()) {
            resp.put("success", true);
            resp.put("data", opt.get());
            return ResponseEntity.ok(resp);
        }
        resp.put("success", false);
        resp.put("message", "未找到实名认证信息");
        return ResponseEntity.ok(resp);
    }

    /**
     * 查询身份证号是否已被使用（绑定）
     * 返回 used: true/false；若存在同时返回掩码后的记录
     */
    @GetMapping("/id/{idNumber}")
    public ResponseEntity<Map<String, Object>> getByIdNumber(@PathVariable String idNumber) {
        Map<String, Object> resp = new HashMap<>();
        try {
            var opt = repository.findByIdNumber(idNumber);
            resp.put("success", true);
            resp.put("used", opt.isPresent());
            if (opt.isPresent()) {
                var saved = opt.get();
                var masked = new com.example.springboot.entity.UserRealName();
                masked.setId(saved.getId());
                masked.setUserId(saved.getUserId());
                masked.setFullName(saved.getFullName());
                String idNum = saved.getIdNumber();
                if (idNum != null && idNum.length() >= 5) {
                    String maskedId = idNum.substring(0, 3) + "****" + idNum.substring(idNum.length() - 2);
                    masked.setIdNumber(maskedId);
                } else {
                    masked.setIdNumber("****");
                }
                resp.put("data", masked);
            }
            return ResponseEntity.ok(resp);
        } catch (Exception ex) {
            resp.put("success", false);
            resp.put("message", "服务器错误");
            resp.put("error", ex.getMessage());
            return ResponseEntity.status(500).body(resp);
        }
    }
}


