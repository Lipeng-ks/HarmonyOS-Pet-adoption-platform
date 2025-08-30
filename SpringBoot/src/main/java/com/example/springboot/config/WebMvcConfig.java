package com.example.springboot.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.lang.NonNull;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * 配置静态资源映射
 */
@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

    @Override
    public void addResourceHandlers(@NonNull ResourceHandlerRegistry registry) {
        // 将请求 /media/** 映射到项目运行目录下的 media/ 文件夹
        // 你也可以改为绝对路径，例如 "file:/var/www/media/"
        registry.addResourceHandler("/media/**")
                .addResourceLocations("file:media/")
                .setCachePeriod(3600);
    }
}


