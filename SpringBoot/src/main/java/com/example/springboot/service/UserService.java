package com.example.springboot.service;

import com.example.springboot.entity.UserInfo;
import com.example.springboot.entity.UserCheckin;
import com.example.springboot.entity.UserAddress;
import com.example.springboot.entity.UserCheckinSummary;
import com.example.springboot.repository.UserInfoRepository;
import com.example.springboot.repository.UserCheckinRepository;
import com.example.springboot.repository.UserAddressRepository;
import com.example.springboot.repository.UserCheckinSummaryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import java.util.List;
import java.util.Optional;

/**
 * 用户服务类
 */
@Service
@RequiredArgsConstructor
@Transactional
public class UserService {
    
    private final UserInfoRepository userInfoRepository;
    private final UserCheckinRepository userCheckinRepository;
    private final UserAddressRepository userAddressRepository;
    private final UserCheckinSummaryRepository userCheckinSummaryRepository;
    private final BCryptPasswordEncoder passwordEncoder;
    
    @PersistenceContext
    private EntityManager entityManager;
    
    /**
     * 根据用户名获取用户信息
     */
    public Optional<UserInfo> getUserByUsername(String username) {
        return userInfoRepository.findByUsername(username);
    }
    
    /**
     * 根据用户ID获取用户信息
     */
    public Optional<UserInfo> getUserById(Long userId) {
        return userInfoRepository.findById(userId);
    }
    
    /**
     * 根据用户名获取用户ID
     */
    public Optional<Long> getUserIdByUsername(String username) {
        return userInfoRepository.findIdByUsername(username);
    }
    
    /**
     * 创建新用户
     */
    public UserInfo createUser(UserInfo userInfo) {
        // 校验用户名长度
        if (userInfo.getUsername() == null || userInfo.getUsername().length() < 4 || userInfo.getUsername().length() > 12) {
            throw new RuntimeException("用户名长度必须在4到12位之间");
        }

        // 检查用户名是否已存在
        if (userInfoRepository.existsByUsername(userInfo.getUsername())) {
            throw new RuntimeException("用户名已被占用");
        }

        // 校验密码长度（要求至少6位）
        if (userInfo.getPassword() == null || userInfo.getPassword().length() < 6) {
            throw new RuntimeException("密码长度至少6位");
        }

        // 检查手机号唯一
        if (userInfo.getPhone() != null && !userInfo.getPhone().trim().isEmpty()) {
            if (userInfoRepository.existsByPhone(userInfo.getPhone())) {
                throw new RuntimeException("该手机号码已被注册");
            }
        }

        // 加密密码并保存
        String encodedPassword = passwordEncoder.encode(userInfo.getPassword());
        userInfo.setPassword(encodedPassword);

        return userInfoRepository.save(userInfo);
    }
    
    /**
     * 更新用户信息
     */
    public UserInfo updateUser(String originalUsername, UserInfo updatedUserInfo) {
        UserInfo existingUser = userInfoRepository.findByUsername(originalUsername)
            .orElseThrow(() -> new RuntimeException("要更新的用户不存在"));
        
        String newUsername = updatedUserInfo.getUsername();
        boolean usernameChanged = !originalUsername.equals(newUsername);
        
        // 如果用户名发生变化，检查新用户名是否已被占用
        if (usernameChanged && userInfoRepository.existsByUsername(newUsername)) {
            throw new RuntimeException("新用户名已被占用，请选择其他用户名");
        }
        
        // 更新用户基本信息
        existingUser.setUsername(newUsername);
        existingUser.setAvatar(updatedUserInfo.getAvatar());
        existingUser.setGender(updatedUserInfo.getGender());
        existingUser.setPhone(updatedUserInfo.getPhone());
        existingUser.setEmail(updatedUserInfo.getEmail());
        existingUser.setAddress(updatedUserInfo.getAddress());
        existingUser.setBirthday(updatedUserInfo.getBirthday());
        existingUser.setRealName(updatedUserInfo.getRealName());
        existingUser.setIdCard(updatedUserInfo.getIdCard());
        
        // 如果提供了新密码，则更新密码
        if (updatedUserInfo.getPassword() != null && !updatedUserInfo.getPassword().isEmpty()) {
            String encodedPassword = passwordEncoder.encode(updatedUserInfo.getPassword());
            existingUser.setPassword(encodedPassword);
        }
        
        // 对于user_checkin_summary表，需要手动更新（没有外键约束）
        if (usernameChanged) {
            // 使用原生SQL更新user_checkin_summary表
            entityManager.createNativeQuery(
                "UPDATE user_checkin_summary SET username = :newUsername WHERE username = :oldUsername")
                .setParameter("newUsername", newUsername)
                .setParameter("oldUsername", originalUsername)
                .executeUpdate();
        }
        
        // 保存用户信息，数据库级联更新会自动处理user_checkin和user_address表
        return userInfoRepository.save(existingUser);
    }
    /**
     * 删除用户
     */
    public void deleteUser(String username) {
        userInfoRepository.deleteByUsername(username);
    }
    
    /**
     * 验证用户登录
     */
    public boolean validateLogin(String username, String password) {
        Optional<UserInfo> userOpt = userInfoRepository.findByUsername(username);
        if (userOpt.isPresent()) {
            UserInfo user = userOpt.get();
            String stored = user.getPassword();
            if (stored == null || password == null) {
                return false;
            }
            // 兼容开发阶段：数据库中可能存明文密码
            boolean looksLikeBCrypt = stored.startsWith("$2a$") || stored.startsWith("$2b$") || stored.startsWith("$2y$");
            if (looksLikeBCrypt) {
                return passwordEncoder.matches(password, stored);
            } else {
                return password.equals(stored);
            }
        }
        return false;
    }
    
    /**
     * 检查用户名是否存在
     */
    public boolean existsByUsername(String username) {
        return userInfoRepository.existsByUsername(username);
    }

    /**
     * 获取全部用户
     */
    public List<UserInfo> findAllUsers() {
        return userInfoRepository.findAll();
    }
}
