package com.example.springboot.controller;

import com.example.springboot.entity.MissingPet;
import com.example.springboot.service.MissingPetService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.time.format.DateTimeParseException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/missing-pets")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class MissingPetController {

    private final MissingPetService missingPetService;

    private Map<String, Object> ok(Object data) {
        Map<String, Object> m = new HashMap<>();
        m.put("success", true);
        m.put("data", data);
        return m;
    }

    private Map<String, Object> err(String message) {
        Map<String, Object> m = new HashMap<>();
        m.put("success", false);
        m.put("message", message);
        return m;
    }

    /**
     * 列表查询：支持按状态、城市模糊、走失时间范围筛选
     * 示例：
     * GET /api/missing-pets?status=ACTIVE&city=上海&start=2025-08-01T00:00:00&end=2025-08-31T23:59:59
     */
    @GetMapping
    public ResponseEntity<Map<String, Object>> list(
            @RequestParam(value = "status", required = false) String statusStr,
            @RequestParam(value = "city", required = false) String city,
            @RequestParam(value = "province", required = false) String province,
            @RequestParam(value = "start", required = false) String start,
            @RequestParam(value = "end", required = false) String end
    ) {
        try {
            // 无过滤条件 -> 全部倒序
            if ((statusStr == null || statusStr.isBlank())
                    && (city == null || city.isBlank())
                    && (province == null || province.isBlank())
                    && (start == null || start.isBlank())
                    && (end == null || end.isBlank())) {
                List<MissingPet> list = missingPetService.listAll();
                return ResponseEntity.ok(ok(list));
            }

            // 时间范围
            if (start != null && !start.isBlank() && end != null && !end.isBlank()) {
                LocalDateTime s = LocalDateTime.parse(start);
                LocalDateTime e = LocalDateTime.parse(end);
                List<MissingPet> list = missingPetService.listByLostTimeRange(s, e);
                return ResponseEntity.ok(ok(list));
            }

            // 状态 + 城市
            if (statusStr != null && !statusStr.isBlank() && city != null && !city.isBlank()) {
                MissingPet.Status st = MissingPet.Status.valueOf(statusStr);
                List<MissingPet> list = missingPetService.listByStatusAndCity(st, city);
                return ResponseEntity.ok(ok(list));
            }

            // 仅状态
            if (statusStr != null && !statusStr.isBlank()) {
                MissingPet.Status st = MissingPet.Status.valueOf(statusStr);
                return ResponseEntity.ok(ok(missingPetService.listByStatus(st)));
            }

            // 仅城市（模糊）
            if (city != null && !city.isBlank()) {
                return ResponseEntity.ok(ok(missingPetService.listByCityLike(city)));
            }

            // 仅省份
            if (province != null && !province.isBlank()) {
                return ResponseEntity.ok(ok(missingPetService.listByProvince(province)));
            }

            // 兜底
            return ResponseEntity.ok(ok(missingPetService.listAll()));
        } catch (IllegalArgumentException | DateTimeParseException ex) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(err("无效的查询参数: " + ex.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(err("服务器内部错误"));
        }
    }

    /** 按ID 获取 */
    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> get(@PathVariable Long id) {
        try {
            Optional<MissingPet> opt = missingPetService.getById(id);
            if (opt.isPresent()) return ResponseEntity.ok(ok(opt.get()));
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(err("记录不存在"));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(err("服务器内部错误"));
        }
    }

    /** 新建 */
    @PostMapping
    public ResponseEntity<Map<String, Object>> create(@RequestBody MissingPet mp) {
        try {
            MissingPet created = missingPetService.create(mp);
            Map<String, Object> resp = ok(created);
            resp.put("message", "创建成功");
            return ResponseEntity.status(HttpStatus.CREATED).body(resp);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(err(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(err("创建失败"));
        }
    }

    /** 按用户ID查询该用户发布的寻宠列表（倒序） */
    @GetMapping("/user/{userId}")
    public ResponseEntity<Map<String, Object>> listByUser(@PathVariable Long userId) {
        try {
            List<MissingPet> list = missingPetService.listByUserId(userId);
            return ResponseEntity.ok(ok(list));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(err("服务器内部错误"));
        }
    }

    /** 全量更新（允许部分字段更新） */
    @PutMapping("/{id}")
    public ResponseEntity<Map<String, Object>> update(@PathVariable Long id, @RequestBody MissingPet input) {
        try {
            MissingPet updated = missingPetService.update(id, input);
            Map<String, Object> resp = ok(updated);
            resp.put("message", "更新成功");
            return ResponseEntity.ok(resp);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(err(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(err("更新失败"));
        }
    }

    /** 更新状态 */
    @PutMapping("/{id}/status")
    public ResponseEntity<Map<String, Object>> updateStatus(@PathVariable Long id, @RequestBody Map<String, String> req) {
        try {
            String s = req.get("status");
            MissingPet.Status st = MissingPet.Status.valueOf(s);
            MissingPet updated = missingPetService.updateStatus(id, st);
            Map<String, Object> resp = ok(updated);
            resp.put("message", "状态更新成功");
            return ResponseEntity.ok(resp);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(err("无效的状态或记录不存在"));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(err("状态更新失败"));
        }
    }

    /** 删除 */
    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> delete(@PathVariable Long id) {
        try {
            missingPetService.delete(id);
            Map<String, Object> resp = new HashMap<>();
            resp.put("success", true);
            resp.put("message", "删除成功");
            return ResponseEntity.ok(resp);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(err("删除失败"));
        }
    }
}
