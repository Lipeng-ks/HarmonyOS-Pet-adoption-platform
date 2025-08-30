package com.example.springboot.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

/**
 * 用户打卡记录（按日期记录每一次打卡）
 */
@Entity
@Table(name = "user_checkin")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserCheckin {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // 关联用户，使用 username 作为外键
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "username", referencedColumnName = "username")
    private UserInfo user;

    // 打卡日期（不包含时间）
    @Column(name = "checkin_date", nullable = false)
    private LocalDate checkinDate;

    // 记录创建时间（可选）：由数据库或应用层设置
    @Column(name = "created_at")
    private java.time.LocalDateTime createdAt;

    // 当前打卡在用户累计中的序号（从1开始）
    @Column(name = "checkin_number", nullable = false)
    private Integer checkinNumber = 1;
}


