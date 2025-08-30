package com.example.springboot.controller;

import com.example.springboot.entity.AdoptionOrder;
import com.example.springboot.service.AdoptionOrderService;
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

@RestController
@RequestMapping("/api/adoption-orders")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AdoptionOrderController {

    private final AdoptionOrderService adoptionOrderService;

    /**
     * 获取所有订单
     */
    @GetMapping
    public ResponseEntity<Map<String, Object>> getAllOrders() {
        Map<String, Object> response = new HashMap<>();
        try {
            List<AdoptionOrder> orders = adoptionOrderService.getAllOrders();
            response.put("success", true);
            response.put("data", orders);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "获取订单列表失败");
            response.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    /**
     * 分页获取订单
     * GET /api/adoption-orders/page?page=0&size=10&status=审核中&userId=1&keyword=小黑
     * status、userId、keyword 三者择一优先顺序：userId > status > keyword
     */
    @GetMapping("/page")
    public ResponseEntity<Map<String, Object>> getOrdersPage(
            @RequestParam(value = "page", defaultValue = "0") int page,
            @RequestParam(value = "size", defaultValue = "10") int size,
            @RequestParam(value = "status", required = false) String statusStr,
            @RequestParam(value = "userId", required = false) Long userId,
            @RequestParam(value = "keyword", required = false) String keyword
    ) {
        Map<String, Object> resp = new HashMap<>();
        try {
            Pageable pageable = PageRequest.of(Math.max(page, 0), Math.max(size, 1));
            AdoptionOrder.OrderStatus status = null;
            if (statusStr != null && !statusStr.isEmpty()) {
                status = AdoptionOrder.OrderStatus.valueOf(statusStr);
            }
            Page<AdoptionOrder> p = adoptionOrderService.getOrdersPage(status, userId, keyword, pageable);
            resp.put("success", true);
            resp.put("records", p.getContent());
            resp.put("total", p.getTotalElements());
            resp.put("page", p.getNumber());
            resp.put("size", p.getSize());
            return ResponseEntity.ok(resp);
        } catch (IllegalArgumentException e) {
            resp.put("success", false);
            resp.put("message", "无效的订单状态");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(resp);
        } catch (Exception e) {
            resp.put("success", false);
            resp.put("message", "获取订单分页失败");
            resp.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(resp);
        }
    }

        /**
         * 根据用户ID获取订单
         */
        @GetMapping("/user/{userId}")
        public ResponseEntity<Map<String, Object>> getOrdersByUser(@PathVariable Long userId) {
            Map<String, Object> response = new HashMap<>();
            try {
                List<AdoptionOrder> orders = adoptionOrderService.getOrdersByUserId(userId);
                response.put("success", true);
                response.put("data", orders);
                return ResponseEntity.ok(response);
            } catch (Exception e) {
                response.put("success", false);
                response.put("message", "获取用户订单失败");
                response.put("error", e.getMessage());
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
            }
        }

    /**
     * 根据状态获取订单
     */
    @GetMapping("/status/{status}")
    public ResponseEntity<Map<String, Object>> getOrdersByStatus(@PathVariable String status) {
        Map<String, Object> response = new HashMap<>();
        try {
            AdoptionOrder.OrderStatus orderStatus = AdoptionOrder.OrderStatus.valueOf(status);
            List<AdoptionOrder> orders = adoptionOrderService.getOrdersByStatus(orderStatus);
            response.put("success", true);
            response.put("data", orders);
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            response.put("success", false);
            response.put("message", "无效的订单状态: " + status);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "获取订单列表失败");
            response.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    /**
     * 根据ID获取订单详情
     */
    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> getOrderById(@PathVariable Long id) {
        Map<String, Object> response = new HashMap<>();
        try {
            var orderOpt = adoptionOrderService.getOrderById(id);
            if (orderOpt.isPresent()) {
                response.put("success", true);
                response.put("data", orderOpt.get());
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "订单不存在");
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
            }
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "获取订单详情失败");
            response.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    /**
     * 创建新订单
     */
    @PostMapping
    public ResponseEntity<Map<String, Object>> createOrder(@RequestBody AdoptionOrder order) {
        Map<String, Object> response = new HashMap<>();
        try {
            // 基础参数校验，避免由于必填字段缺失导致 500
            if (order == null) {
                response.put("success", false);
                response.put("message", "请求体不能为空");
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
            }

            // 校验并填充必填字段
            if (order.getUserId() == null || order.getUserId() <= 0) {
                response.put("success", false);
                response.put("message", "缺少有效的用户ID");
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
            }
            if (order.getPetName() == null || order.getPetName().trim().isEmpty()) {
                response.put("success", false);
                response.put("message", "宠物名称不能为空");
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
            }
            if (order.getPetAddress() == null || order.getPetAddress().trim().isEmpty()) {
                response.put("success", false);
                response.put("message", "宠物所在地区不能为空");
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
            }

            // 强制设置初始状态为 审核中，忽略前端传入状态
            order.setStatus(AdoptionOrder.OrderStatus.审核中);

            // 确保申请时间存在
            if (order.getApplicationTime() == null) {
                order.setApplicationTime(java.time.LocalDateTime.now());
            }

            AdoptionOrder createdOrder = adoptionOrderService.createOrder(order);
            response.put("success", true);
            response.put("message", "订单创建成功");
            response.put("data", createdOrder);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (IllegalArgumentException e) {
            response.put("success", false);
            response.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "创建订单失败");
            response.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    /**
     * 更新订单状态
     */
    @PutMapping("/{id}/status")
    public ResponseEntity<Map<String, Object>> updateOrderStatus(
            @PathVariable Long id, 
            @RequestBody Map<String, String> statusRequest) {
        Map<String, Object> response = new HashMap<>();
        try {
            String statusStr = statusRequest.get("status");
            AdoptionOrder.OrderStatus status = AdoptionOrder.OrderStatus.valueOf(statusStr);
            AdoptionOrder updatedOrder = adoptionOrderService.updateOrderStatus(id, status);
            response.put("success", true);
            response.put("message", "订单状态更新成功");
            response.put("data", updatedOrder);
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            response.put("success", false);
            response.put("message", "无效的订单状态");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
        } catch (RuntimeException e) {
            response.put("success", false);
            response.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "更新订单状态失败");
            response.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    /**
     * 更新订单信息
     */
    @PutMapping("/{id}")
    public ResponseEntity<Map<String, Object>> updateOrder(@PathVariable Long id, @RequestBody AdoptionOrder order) {
        Map<String, Object> response = new HashMap<>();
        try {
            // 基础参数校验
            if (order == null) {
                response.put("success", false);
                response.put("message", "请求体不能为空");
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
            }

            // 校验必填字段
            if (order.getUserId() == null || order.getUserId() <= 0) {
                response.put("success", false);
                response.put("message", "缺少有效的用户ID");
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
            }
            if (order.getPetName() == null || order.getPetName().trim().isEmpty()) {
                response.put("success", false);
                response.put("message", "宠物名称不能为空");
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
            }
            if (order.getPetAddress() == null || order.getPetAddress().trim().isEmpty()) {
                response.put("success", false);
                response.put("message", "宠物所在地区不能为空");
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
            }

            AdoptionOrder updatedOrder = adoptionOrderService.updateOrder(id, order);
            response.put("success", true);
            response.put("message", "订单更新成功");
            response.put("data", updatedOrder);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            response.put("success", false);
            response.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "更新订单失败");
            response.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    /**
     * 删除订单
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> deleteOrder(@PathVariable Long id) {
        Map<String, Object> response = new HashMap<>();
        try {
            adoptionOrderService.deleteOrder(id);
            response.put("success", true);
            response.put("message", "订单删除成功");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "删除订单失败");
            response.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
}
