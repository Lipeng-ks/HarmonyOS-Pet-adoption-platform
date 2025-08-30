package com.example.springboot.controller;

import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import jakarta.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

/**
 * 通用文件上传接口
 * POST /api/upload
 * 返回 { success, data: { url, filename, size } }
 */
@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
@Slf4j
public class UploadController {

    @PostMapping("/upload")
    public ResponseEntity<Map<String, Object>> upload(@RequestParam("file") MultipartFile file,
                                                      HttpServletRequest request) {
        Map<String, Object> resp = new HashMap<>();
        if (file == null || file.isEmpty()) {
            resp.put("success", false);
            resp.put("message", "文件为空");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(resp);
        }
        try {
            // 目录结构: media/uploads/2025-08-28/
            String date = LocalDate.now().toString();
            Path baseDir = Path.of("media", "uploads", date);
            Files.createDirectories(baseDir);

            String name = file.getOriginalFilename();
            if (name == null || name.isBlank()) {
                name = "file";
            }
            String original = StringUtils.cleanPath(name);
            String ext = "";
            int dot = original.lastIndexOf('.');
            if (dot > 0 && dot < original.length() - 1) {
                ext = original.substring(dot);
            }
            String filename = UUID.randomUUID().toString().replace("-", "") + ext;
            Path target = baseDir.resolve(filename);
            Files.copy(file.getInputStream(), target, StandardCopyOption.REPLACE_EXISTING);

            // Web 访问地址：/media/uploads/{date}/{filename}
            String scheme = request.getScheme();
            String host = request.getServerName();
            int port = request.getServerPort();
            String contextPath = request.getContextPath();

            StringBuilder url = new StringBuilder();
            url.append(scheme).append("://").append(host);
            if (("http".equals(scheme) && port != 80) || ("https".equals(scheme) && port != 443)) {
                url.append(":").append(port);
            }
            if (contextPath != null && !contextPath.isEmpty() && !"/".equals(contextPath)) {
                url.append(contextPath);
            }
            url.append("/media/uploads/").append(date).append("/").append(filename);

            Map<String, Object> data = new HashMap<>();
            data.put("url", url.toString());
            data.put("filename", filename);
            data.put("size", file.getSize());

            resp.put("success", true);
            resp.put("data", data);
            return ResponseEntity.ok(resp);
        } catch (IOException e) {
            log.error("上传失败", e);
            resp.put("success", false);
            resp.put("message", "上传失败: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(resp);
        }
    }
}
