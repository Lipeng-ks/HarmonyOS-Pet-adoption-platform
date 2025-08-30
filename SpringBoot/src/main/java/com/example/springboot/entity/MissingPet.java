package com.example.springboot.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * 寻宠信息实体（走失宠物）
 */
@Entity
@Table(name = "missing_pets", indexes = {
        @Index(name = "idx_missing_pets_user_id", columnList = "user_id"),
        @Index(name = "idx_missing_pets_status", columnList = "status")
})
@Data
@NoArgsConstructor
@AllArgsConstructor
public class MissingPet {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * 发布用户ID（可选）
     */
    @Column(name = "user_id")
    private Long userId;

    /**
     * 标题
     */
    @Column(nullable = false, length = 100)
    private String title;

    /**
     * 宠物名称
     */
    @Column(name = "pet_name", length = 60)
    private String petName;

    /**
     * 宠物类型（狗/猫/其他）
     */
    @Column(length = 30)
    private String type;

    /**
     * 性别：true=雄性，false=雌性，null=未知
     */
    @Column
    private Boolean gender;

    /**
     * 年龄（岁，可为小数）
     */
    @Column
    private Float age;

    /**
     * 走失时间
     */
    @Column(name = "lost_time")
    private LocalDateTime lostTime;

    /**
     * 走失城市
     */
    @Column(length = 50)
    private String city;

    /**
     * 走失详细地址
     */
    @Column(name = "lost_address", length = 200)
    private String lostAddress;

    /**
     * 特征描述/备注
     */
    @Column(columnDefinition = "TEXT")
    private String description;

    /**
     * 联系人
     */
    @Column(name = "contact_name", length = 50)
    private String contactName;

    /**
     * 联系电话
     */
    @Column(name = "contact_phone", length = 30)
    private String contactPhone;

    /**
     * 悬赏金额（可选）
     */
    @Column
    private Float reward;

    /**
     * 图片URL或资源ID
     */
    @Column(length = 255)
    private String image;

    /**
     * 状态：ACTIVE=寻宠中，FOUND=已找到，CLOSED=已关闭
     */
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private Status status = Status.ACTIVE;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    public enum Status {
        ACTIVE, FOUND, CLOSED
    }
}
