package com.example.springboot.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

/**
 * 用户地址实体类
 */
@Entity
@Table(name = "user_address")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserAddress {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, length = 50)
    @NotBlank(message = "收货人姓名不能为空")
    @Size(max = 50, message = "收货人姓名长度不能超过50个字符")
    private String name;
    
    @Column(nullable = false, length = 20)
    @NotBlank(message = "联系电话不能为空")
    @Size(max = 20, message = "联系电话长度不能超过20个字符")
    private String phone;
    
    @Column(nullable = false, length = 100)
    @NotBlank(message = "城市不能为空")
    @Size(max = 100, message = "城市名称长度不能超过100个字符")
    private String city;
    
    @Column(nullable = false)
    @NotBlank(message = "详细地址不能为空")
    @Size(max = 255, message = "详细地址长度不能超过255个字符")
    private String detail;
    
    @Column(name = "is_default", nullable = false)
    private Boolean isDefault = false;
    
    // 多对一关系：多个地址属于一个用户
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "username", referencedColumnName = "username")
    private UserInfo user;
}
