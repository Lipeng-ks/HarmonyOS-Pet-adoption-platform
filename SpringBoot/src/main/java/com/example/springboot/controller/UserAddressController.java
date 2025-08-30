package com.example.springboot.controller;

import com.example.springboot.entity.UserAddress;
import com.example.springboot.entity.UserInfo;
import com.example.springboot.repository.UserAddressRepository;
import com.example.springboot.repository.UserInfoRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * 用户地址控制器
 */
@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class UserAddressController {

    private final UserAddressRepository userAddressRepository;
    private final UserInfoRepository userInfoRepository;

    /**
     * 获取某用户的地址列表
     */
    @GetMapping("/{username}/addresses")
    public ResponseEntity<Map<String, Object>> getUserAddresses(@PathVariable String username) {
        try {
            List<UserAddress> addresses = userAddressRepository.findByUserUsernameOrderByIsDefaultDesc(username);
            List<Map<String, Object>> data = addresses.stream().map(a -> {
                Map<String, Object> m = new HashMap<>();
                m.put("id", a.getId());
                m.put("name", a.getName());
                m.put("phone", a.getPhone());
                m.put("city", a.getCity());
                m.put("detail", a.getDetail());
                m.put("isDefault", a.getIsDefault());
                return m;
            }).collect(Collectors.toList());

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("data", data);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "服务器内部错误");
            response.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    /**
     * 新增地址
     */
    @PostMapping("/{username}/addresses")
    public ResponseEntity<Map<String, Object>> addAddress(@PathVariable String username, @RequestBody Map<String, Object> body) {
        try {
            Optional<UserInfo> userOpt = userInfoRepository.findByUsername(username);
            if (userOpt.isEmpty()) {
                Map<String, Object> response = new HashMap<>();
                response.put("message", "用户不存在");
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
            }

            UserInfo user = userOpt.get();
            UserAddress addr = new UserAddress();
            addr.setName((String) body.getOrDefault("name", ""));
            addr.setPhone((String) body.getOrDefault("phone", ""));
            addr.setCity((String) body.getOrDefault("city", ""));
            addr.setDetail((String) body.getOrDefault("detail", ""));
            Object isDef = body.get("isDefault");
            addr.setIsDefault(isDef instanceof Boolean ? (Boolean) isDef : false);
            addr.setUser(user);

            UserAddress saved = userAddressRepository.save(addr);

            Map<String, Object> data = new HashMap<>();
            data.put("id", saved.getId());

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("data", data);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (Exception e) {
            Map<String, Object> response = new HashMap<>();
            response.put("message", "服务器错误");
            response.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    /**
     * 更新地址
     */
    @PutMapping("/{username}/addresses/{id}")
    public ResponseEntity<Map<String, Object>> updateAddress(@PathVariable String username, @PathVariable Long id, @RequestBody Map<String, Object> body) {
        try {
            UserAddress existing = userAddressRepository.findByUserUsernameAndId(username, id);
            if (existing == null) {
                Map<String, Object> response = new HashMap<>();
                response.put("message", "地址不存在");
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
            }

            existing.setName((String) body.getOrDefault("name", existing.getName()));
            existing.setPhone((String) body.getOrDefault("phone", existing.getPhone()));
            existing.setCity((String) body.getOrDefault("city", existing.getCity()));
            existing.setDetail((String) body.getOrDefault("detail", existing.getDetail()));
            Object isDef = body.get("isDefault");
            if (isDef instanceof Boolean) existing.setIsDefault((Boolean) isDef);

            userAddressRepository.save(existing);

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "地址更新成功");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> response = new HashMap<>();
            response.put("message", "服务器错误");
            response.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    /**
     * 删除地址
     */
    @DeleteMapping("/{username}/addresses/{id}")
    public ResponseEntity<Map<String, Object>> deleteAddress(@PathVariable String username, @PathVariable Long id) {
        try {
            UserAddress existing = userAddressRepository.findByUserUsernameAndId(username, id);
            if (existing == null) {
                Map<String, Object> response = new HashMap<>();
                response.put("message", "地址不存在");
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
            }

            userAddressRepository.delete(existing);
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "地址删除成功");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> response = new HashMap<>();
            response.put("message", "服务器错误");
            response.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
}


