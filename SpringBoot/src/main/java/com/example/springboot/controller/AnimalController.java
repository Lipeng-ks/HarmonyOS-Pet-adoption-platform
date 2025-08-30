package com.example.springboot.controller;

import com.example.springboot.entity.Animal;
import com.example.springboot.service.AnimalService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import jakarta.servlet.http.HttpServletRequest;

/**
 * 动物管理控制器
 */
@RestController
@RequestMapping("/api/animals")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AnimalController {
    
    private final AnimalService animalService;
    
    /**
     * 获取所有动物列表
     */
    @GetMapping
    public ResponseEntity<Map<String, Object>> getAllAnimals(
            @RequestParam(value = "adopted", required = false) Boolean adopted,
            @RequestParam(value = "listed", required = false) Boolean listed,
            HttpServletRequest request) {
        try {
            List<Animal> animals;
            if (adopted != null && listed != null) {
                animals = animalService.getAnimalsByAdoptedAndListed(adopted, listed);
            } else if (adopted != null) {
                animals = animalService.getAnimalsByAdopted(adopted);
            } else if (listed != null) {
                animals = animalService.getAnimalsByListed(listed);
            } else {
                animals = animalService.getAllAnimals();
            }
            // 规范化所有动物的 image 字段，确保返回可直接访问的后端 URL 或保留本地资源 id
            normalizeAllImages(animals, request);

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("data", animals);
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "服务器内部错误");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    /**
     * 分页获取动物列表
     * GET /api/animals/page?page=0&size=10&adopted=true&listed=false
     */
    @GetMapping("/page")
    public ResponseEntity<Map<String, Object>> getAnimalsPage(
            @RequestParam(value = "page", defaultValue = "0") int page,
            @RequestParam(value = "size", defaultValue = "10") int size,
            @RequestParam(value = "adopted", required = false) Boolean adopted,
            @RequestParam(value = "listed", required = false) Boolean listed,
            HttpServletRequest request) {
        try {
            Pageable pageable = PageRequest.of(Math.max(page, 0), Math.max(size, 1));
            Page<Animal> p = animalService.getAnimalsPage(adopted, listed, pageable);
            List<Animal> records = p.getContent();
            normalizeAllImages(records, request);

            Map<String, Object> resp = new HashMap<>();
            resp.put("success", true);
            resp.put("records", records);
            resp.put("total", p.getTotalElements());
            resp.put("page", p.getNumber());
            resp.put("size", p.getSize());
            return ResponseEntity.ok(resp);
        } catch (Exception e) {
            Map<String, Object> resp = new HashMap<>();
            resp.put("success", false);
            resp.put("message", "服务器内部错误");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(resp);
        }
    }

    /**
     * 删除动物
     * DELETE /api/animals/{id}
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> deleteAnimal(@PathVariable Long id) {
        Map<String, Object> resp = new HashMap<>();
        try {
            boolean existed = animalService.deleteAnimal(id);
            if (!existed) {
                resp.put("success", false);
                resp.put("message", "未找到该动物信息");
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(resp);
            }
            resp.put("success", true);
            return ResponseEntity.ok(resp);
        } catch (Exception e) {
            resp.put("success", false);
            resp.put("message", "删除失败：" + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(resp);
        }
    }
    
    /**
     * 根据ID获取单个动物信息
     */
    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> getAnimalById(@PathVariable Long id, HttpServletRequest request) {
        try {
            Optional<Animal> animalOpt = animalService.getAnimalById(id);
            
            if (animalOpt.isPresent()) {
                Animal animal = animalOpt.get();
                animal.setImage(normalizeImage(animal.getImage(), request));

                Map<String, Object> response = new HashMap<>();
                response.put("success", true);
                response.put("data", animal);
                return ResponseEntity.ok(response);
            } else {
                Map<String, Object> response = new HashMap<>();
                response.put("success", false);
                response.put("message", "未找到该动物信息");
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
            }
            
        } catch (Exception e) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "服务器内部错误");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    /**
     * 确保 image 字段为资源 ID（以 app.media. 开头）或保留远程 URL
     */
    private String normalizeImage(String image, HttpServletRequest request) {
        if (image == null || image.trim().isEmpty()) {
            return "app.media.person"; // 默认占位图
        }
        String trimmed = image.trim();
        if (trimmed.startsWith("app.media.") ) {
            return trimmed; // local resource id, keep as-is
        }
        if (trimmed.startsWith("http://") || trimmed.startsWith("https://")) {
            return trimmed; // already full URL
        }
        // Otherwise treat as a relative path or filename stored in DB; build absolute URL to media endpoint
        // Example: if image = "uploads/abc.jpg" or "abc.jpg" -> build http(s)://host:port/media/{image}
        String contextPath = request.getContextPath();
        String scheme = request.getScheme();
        String host = request.getServerName();
        int port = request.getServerPort();
        String mediaPath = trimmed.startsWith("/") ? trimmed : "/media/" + trimmed;
        StringBuilder sb = new StringBuilder();
        sb.append(scheme).append("://").append(host);
        if ((scheme.equals("http") && port != 80) || (scheme.equals("https") && port != 443)) {
            sb.append(":").append(port);
        }
        if (contextPath != null && !contextPath.isEmpty() && !contextPath.equals("/")) {
            sb.append(contextPath);
        }
        sb.append(mediaPath);
        return sb.toString();
    }

    private void normalizeAllImages(List<Animal> animals, HttpServletRequest request) {
        if (animals == null || animals.isEmpty()) return;
        for (Animal a : animals) {
            a.setImage(normalizeImage(a.getImage(), request));
        }
    }

    /**
     * 更新上/下架状态
     * 示例：PUT /api/animals/123/listed?listed=false
     */
    @PutMapping("/{id}/listed")
    public ResponseEntity<Map<String, Object>> updateListed(
            @PathVariable Long id,
            @RequestParam("listed") Boolean listed,
            HttpServletRequest request) {
        try {
            Optional<Animal> updated = animalService.updateListed(id, listed);
            if (updated.isEmpty()) {
                Map<String, Object> resp = new HashMap<>();
                resp.put("success", false);
                resp.put("message", "未找到该动物信息");
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(resp);
            }
            Animal a = updated.get();
            a.setImage(normalizeImage(a.getImage(), request));
            Map<String, Object> resp = new HashMap<>();
            resp.put("success", true);
            resp.put("data", a);
            return ResponseEntity.ok(resp);
        } catch (Exception e) {
            Map<String, Object> resp = new HashMap<>();
            resp.put("success", false);
            resp.put("message", "服务器内部错误");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(resp);
        }
    }

    /**
     * 创建新动物
     * POST /api/animals
     */
    @PostMapping
    public ResponseEntity<Map<String, Object>> createAnimal(
            @RequestBody Animal animal,
            HttpServletRequest request) {
        try {
            Animal created = animalService.createAnimal(animal);
            created.setImage(normalizeImage(created.getImage(), request));
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("data", created);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
            
        } catch (Exception e) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "创建失败：" + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    /**
     * 更新动物完整信息
     * PUT /api/animals/{id}
     */
    @PutMapping("/{id}")
    public ResponseEntity<Map<String, Object>> updateAnimal(
            @PathVariable Long id,
            @RequestBody Animal updateData,
            HttpServletRequest request) {
        try {
            Optional<Animal> updated = animalService.updateAnimal(id, updateData);
            if (updated.isEmpty()) {
                Map<String, Object> resp = new HashMap<>();
                resp.put("success", false);
                resp.put("message", "未找到该动物信息");
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(resp);
            }
            
            Animal animal = updated.get();
            animal.setImage(normalizeImage(animal.getImage(), request));
            
            Map<String, Object> resp = new HashMap<>();
            resp.put("success", true);
            resp.put("data", animal);
            return ResponseEntity.ok(resp);
            
        } catch (Exception e) {
            Map<String, Object> resp = new HashMap<>();
            resp.put("success", false);
            resp.put("message", "更新失败：" + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(resp);
        }
    }
}
