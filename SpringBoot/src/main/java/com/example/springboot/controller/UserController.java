package com.example.springboot.controller;

import com.example.springboot.entity.UserInfo;
import com.example.springboot.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * 用户管理控制器
 */
@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class UserController {
    
    private final UserService userService;
    
    /**
     * 获取全部用户列表
     */
    @GetMapping
    public ResponseEntity<Map<String, Object>> listAllUsers() {
        Map<String, Object> response = new HashMap<>();
        try {
            List<UserInfo> users = userService.findAllUsers();
            // 不返回密码
            for (UserInfo u : users) {
                u.setPassword(null);
            }
            response.put("success", true);
            response.put("data", users);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "获取用户列表失败");
            response.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    /**
     * 获取用户信息
     */
    @GetMapping("/{username}")
    public ResponseEntity<Map<String, Object>> getUserInfo(@PathVariable String username) {
        try {
            Optional<UserInfo> userOpt = userService.getUserByUsername(username);
            if (userOpt.isPresent()) {
                UserInfo user = userOpt.get();
                // 不返回密码
                user.setPassword(null);
                
                Map<String, Object> response = new HashMap<>();
                response.put("data", user);
                return ResponseEntity.ok(response);
            } else {
                Map<String, Object> response = new HashMap<>();
                response.put("message", "用户不存在");
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
            }
        } catch (Exception e) {
            Map<String, Object> response = new HashMap<>();
            response.put("message", "服务器错误");
            response.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
    
    /**
     * 获取用户ID
     */
    @GetMapping("/{username}/id")
    public ResponseEntity<Map<String, Object>> getUserId(@PathVariable String username) {
        try {
            Optional<Long> userIdOpt = userService.getUserIdByUsername(username);
            if (userIdOpt.isPresent()) {
                Map<String, Object> data = new HashMap<>();
                data.put("id", userIdOpt.get());
                
                Map<String, Object> response = new HashMap<>();
                response.put("data", data);
                return ResponseEntity.ok(response);
            } else {
                Map<String, Object> response = new HashMap<>();
                response.put("message", "用户不存在");
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
            }
        } catch (Exception e) {
            Map<String, Object> response = new HashMap<>();
            response.put("message", "服务器错误");
            response.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
    
    /**
     * 根据用户ID获取用户信息
     */
    @GetMapping("/by-id/{userId}")
    public ResponseEntity<Map<String, Object>> getUserById(@PathVariable Long userId) {
        Map<String, Object> response = new HashMap<>();
        try {
            Optional<UserInfo> userOpt = userService.getUserById(userId);
            if (userOpt.isPresent()) {
                UserInfo user = userOpt.get();
                // 不返回密码字段
                user.setPassword(null);
                response.put("success", true);
                response.put("data", user);
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "用户不存在");
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
            }
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "获取用户信息失败");
            response.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
    
    /**
     * 创建用户
     */
    @PostMapping
    public ResponseEntity<Map<String, Object>> createUser(@RequestBody UserInfo userInfo) {
        try {
            // 记录收到的请求体，便于调试注册问题（注意：不要在生产环境打印敏感信息）
            System.out.println("[DEBUG] createUser payload: " + userInfo);

            if (userService.existsByUsername(userInfo.getUsername())) {
                Map<String, Object> response = new HashMap<>();
                response.put("message", "用户名已被占用");
                return ResponseEntity.status(HttpStatus.CONFLICT).body(response);
            }
            // 基本校验：必须包含密码
            if (userInfo.getPassword() == null || userInfo.getPassword().trim().isEmpty()) {
                Map<String, Object> response = new HashMap<>();
                response.put("message", "密码不能为空");
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
            }
            
            UserInfo createdUser = userService.createUser(userInfo);
            
            Map<String, Object> response = new HashMap<>();
            response.put("message", "用户信息创建成功");
            response.put("affectedRows", 1);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
            
        } catch (Exception e) {
            // 打印完整堆栈以便定位问题
            e.printStackTrace();
            Map<String, Object> response = new HashMap<>();
            response.put("message", "服务器错误");
            response.put("error", e.toString());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
    
    /**
     * 更新用户信息
     */
    @PutMapping("/{username}")
    public ResponseEntity<Map<String, Object>> updateUser(
            @PathVariable String username, 
            @RequestBody UserInfo userInfo) {
        try {
            UserInfo updatedUser = userService.updateUser(username, userInfo);
            // 不返回密码
            updatedUser.setPassword(null);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "用户信息更新成功");
            response.put("data", updatedUser);
            return ResponseEntity.ok(response);
            
        } catch (RuntimeException e) {
            Map<String, Object> response = new HashMap<>();
            if (e.getMessage().contains("不存在")) {
                response.put("message", e.getMessage());
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
            } else if (e.getMessage().contains("已被占用")) {
                response.put("message", e.getMessage());
                return ResponseEntity.status(HttpStatus.CONFLICT).body(response);
            } else {
                response.put("message", "服务器错误");
                response.put("error", e.getMessage());
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
            }
        }
    }
    
    /**
     * 删除用户
     */
    @DeleteMapping("/{username}")
    public ResponseEntity<Map<String, Object>> deleteUser(@PathVariable String username) {
        try {
            userService.deleteUser(username);
            
            Map<String, Object> response = new HashMap<>();
            response.put("message", "用户信息删除成功");
            response.put("affectedRows", 1);
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            Map<String, Object> response = new HashMap<>();
            response.put("message", "服务器错误");
            response.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
}
