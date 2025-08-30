package com.example.springboot.repository;

import com.example.springboot.entity.UserInfo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * 用户信息数据访问接口
 */
@Repository
public interface UserInfoRepository extends JpaRepository<UserInfo, Long> {
    
    /**
     * 根据用户名查找用户
     */
    Optional<UserInfo> findByUsername(String username);
    
    /**
     * 检查用户名是否存在
     */
    boolean existsByUsername(String username);
    
    /**
     * 检查手机号是否已存在
     */
    boolean existsByPhone(String phone);
    
    /**
     * 根据邮箱查找用户
     */
    Optional<UserInfo> findByEmail(String email);
    
    /**
     * 根据用户名删除用户
     */
    void deleteByUsername(String username);
    
    /**
     * 根据用户名获取用户ID
     */
    @Query("SELECT u.id FROM UserInfo u WHERE u.username = :username")
    Optional<Long> findIdByUsername(@Param("username") String username);
}
