package com.example.springboot.controller;

import com.example.springboot.entity.UserFavorite;
import com.example.springboot.service.UserFavoriteService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;
import java.util.stream.Stream;

@RestController
@RequestMapping("/api/favorites")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class UserFavoriteController {

    private final UserFavoriteService service;

    @PostMapping
    public ResponseEntity<Map<String,Object>> addFavorite(@RequestBody Map<String,Object> payload) {
        Map<String,Object> resp = new HashMap<>();
        try {
            Long userId = Long.valueOf(String.valueOf(payload.get("userId")));
            Long animalId = Long.valueOf(String.valueOf(payload.get("animalId")));
            UserFavorite saved = service.addFavorite(userId, animalId);
            resp.put("success", true);
            resp.put("data", saved);
            return ResponseEntity.ok(resp);
        } catch (Exception ex) {
            resp.put("success", false);
            resp.put("message", "参数错误或服务器错误");
            resp.put("error", ex.getMessage());
            return ResponseEntity.badRequest().body(resp);
        }
    }

    @DeleteMapping
    public ResponseEntity<Map<String,Object>> removeFavorite(@RequestParam Long userId, @RequestParam Long animalId) {
        Map<String,Object> resp = new HashMap<>();
        try {
            service.removeFavorite(userId, animalId);
            resp.put("success", true);
            return ResponseEntity.ok(resp);
        } catch (Exception ex) {
            resp.put("success", false);
            resp.put("message", "删除失败");
            resp.put("error", ex.getMessage());
            return ResponseEntity.status(500).body(resp);
        }
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<Map<String,Object>> listByUser(@PathVariable Long userId) {
        Map<String,Object> resp = new HashMap<>();
        List<UserFavorite> list = service.listFavoritesByUser(userId);
        resp.put("success", true);
        resp.put("data", list);
        return ResponseEntity.ok(resp);
    }

    @GetMapping("/exists")
    public ResponseEntity<Map<String,Object>> exists(@RequestParam Long userId, @RequestParam Long animalId) {
        Map<String,Object> resp = new HashMap<>();
        boolean ex = service.isFavorited(userId, animalId);
        resp.put("success", true);
        resp.put("favorited", ex);
        return ResponseEntity.ok(resp);
    }

    /**
     * 批量查询收藏状态
     * 示例：/api/favorites/batch-check?userId=1&animalIds=1,2,3
     * 返回：{ success: true, data: [1,3] }
     */
    @GetMapping("/batch-check")
    public ResponseEntity<Map<String, Object>> batchCheck(@RequestParam Long userId, @RequestParam String animalIds) {
        Map<String, Object> resp = new HashMap<>();
        try {
            List<Long> ids = Stream.of(animalIds.split(","))
                    .map(String::trim)
                    .filter(s -> !s.isEmpty())
                    .map(Long::valueOf)
                    .collect(Collectors.toList());
            Set<Long> favorited = service.getFavoritedAnimalIds(userId, ids);
            resp.put("success", true);
            resp.put("data", favorited);
            return ResponseEntity.ok(resp);
        } catch (Exception ex) {
            resp.put("success", false);
            resp.put("message", "参数错误或服务器错误");
            resp.put("error", ex.getMessage());
            return ResponseEntity.badRequest().body(resp);
        }
    }

}


