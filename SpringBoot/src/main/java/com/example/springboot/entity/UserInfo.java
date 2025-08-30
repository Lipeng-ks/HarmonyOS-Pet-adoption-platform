package com.example.springboot.entity;

import jakarta.persistence.*;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.util.List;

/**
 * 用户信息实体类
 */
@Entity
@Table(name = "user_info")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserInfo {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(unique = true, nullable = false, length = 50)
    @NotBlank(message = "用户名不能为空")
    @Size(min = 3, max = 50, message = "用户名长度必须在3-50个字符之间")
    private String username;
    
    @Column(nullable = false)
    @NotBlank(message = "头像不能为空")
    private String avatar;
    
    @Column(nullable = false, length = 10)
    @NotBlank(message = "性别不能为空")
    private String gender;
    
    @Column(length = 20)
    private String phone;
    
    @Email(message = "邮箱格式不正确")
    @Column(length = 100)
    private String email;
    
    @Column(length = 255)
    private String address;
    
    @Column(length = 20)
    private String birthday;
    
    // 真实姓名（可选）
    @Column(length = 50)
    private String realName;

    // 身份证号（可选）
    @Column(length = 32)
    private String idCard;

    @Column(nullable = false, length = 100)
    @NotBlank(message = "密码不能为空")
    // 允许从请求体反序列化密码但不在响应中序列化返回
    @JsonProperty(access = JsonProperty.Access.WRITE_ONLY)
    private String password;
    
    // 一对多关系：一个用户可以有多个地址
    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JsonIgnore // 避免懒加载在序列化阶段导致失败
    private List<UserAddress> addresses;
}
