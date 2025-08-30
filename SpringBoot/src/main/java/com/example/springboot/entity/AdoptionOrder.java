package com.example.springboot.entity;

import jakarta.persistence.*;
import jakarta.persistence.Index;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * 领养订单实体
 */
@Entity
@Table(name = "adoption_orders", indexes = {
        @Index(name = "idx_adoption_orders_user_id", columnList = "user_id"),
        @Index(name = "idx_adoption_orders_animal_id", columnList = "animal_id")
})
@Data
@NoArgsConstructor
@AllArgsConstructor
public class AdoptionOrder {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * 订单号（数据库列为 order_no，非空且唯一）
     */
    @Column(name = "order_no", nullable = false, unique = true, length = 32)
    private String orderNo;

    /**
     * 绑定的用户ID
     */
    @Column(name = "user_id")
    private Long userId;

    /**
     * 绑定的动物ID（用于精准关联动物，避免名称歧义）
     */
    @Column(name = "animal_id")
    private Long animalId;

    @Column(name = "pet_name", nullable = false, length = 100)
    private String petName;

    @Column(name = "pet_address", nullable = false, length = 200)
    private String petAddress;

    @Column(name = "image", length = 500)
    private String image;

    @Column(name = "shipping_address", length = 255)
    private String shippingAddress;

    @Column(name = "pet_experience", length = 1000)
    private String petExperience;

    @Column(name = "application_reason", length = 1000)
    private String applicationReason;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private OrderStatus status = OrderStatus.审核中;

    @Column(name = "application_time", nullable = false)
    private LocalDateTime applicationTime;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @Column(name = "completed_at")
    private LocalDateTime completedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
        if (applicationTime == null) {
            applicationTime = LocalDateTime.now();
        }
        // 生成订单号：AO + yyyyMMddHHmmss + 6位随机数，长度不超过32
        if (orderNo == null || orderNo.isEmpty()) {
            String ts = java.time.format.DateTimeFormatter.ofPattern("yyyyMMddHHmmss").format(LocalDateTime.now());
            int rnd = (int)(Math.random() * 1_000_000);
            String candidate = "AO" + ts + String.format("%06d", rnd);
            orderNo = candidate.length() > 32 ? candidate.substring(0, 32) : candidate;
        }
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    public enum OrderStatus {
        审核中, 已发货, 完成, 评价
    }
}
