package com.example.springboot;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

/**
 * 宠物领养平台 Spring Boot 主应用类
 */
@SpringBootApplication
@EnableJpaRepositories
public class PetAdoptionApplication {
    public static void main(String[] args) {
        SpringApplication.run(PetAdoptionApplication.class, args);
        System.out.println("宠物领养平台 API 服务器启动成功！");
        System.out.println("访问地址: http://localhost:8080/api");
    }
}
