package com.example.springboot.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

/**
 * 动物信息实体类
 */
@Entity
@Table(name = "animals")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Animal {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, length = 50)
    @NotBlank(message = "动物名称不能为空")
    private String name;
    
    @Column(nullable = false)
    @NotNull(message = "性别不能为空")
    private Boolean gender; // true: 雄性, false: 雌性
    
    @Column(nullable = false)
    @NotNull(message = "年龄不能为空")
    @Positive(message = "年龄必须为正数")
    private Float age;
    
    @Column(nullable = false, length = 50)
    @NotBlank(message = "动物类型不能为空")
    private String type;
    
    @Column(columnDefinition = "TEXT")
    private String description;
    
    @Column(nullable = false)
    private Boolean vaccinated = false; // 是否已免疫
    
    @Column(nullable = false)
    private Boolean dewormed = false; // 是否已驱虫
    
    @Column(nullable = false)
    private Boolean neutered = false; // 是否已绝育
    
    @Column(length = 255)
    private String image;
    
    @Column(length = 50)
    private String city;
    
    @Column(name = "is_free", nullable = false)
    private Boolean isFree = true; // 是否免费领养
    
    @Column(name = "favorite_count", nullable = false)
    private Integer favoriteCount = 0; // 收藏数量
    
    @Column(name = "adopted", nullable = false)
    private Boolean adopted = false;

    @Column(name = "user_id")
    private Long userId;

    @Column(name = "listed", nullable = false)
    private Boolean listed = true; // 是否上架：true上架中，false已下架
}
