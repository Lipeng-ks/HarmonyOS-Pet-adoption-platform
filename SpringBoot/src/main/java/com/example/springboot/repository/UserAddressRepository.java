package com.example.springboot.repository;

import com.example.springboot.entity.UserAddress;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * 用户地址数据访问接口
 */
@Repository
public interface UserAddressRepository extends JpaRepository<UserAddress, Long> {
    
    /**
     * 根据用户名查找所有地址，按默认地址排序
     */
    @Query("SELECT ua FROM UserAddress ua JOIN ua.user u WHERE u.username = :username ORDER BY ua.isDefault DESC")
    List<UserAddress> findByUserUsernameOrderByIsDefaultDesc(@Param("username") String username);
    
    /**
     * 根据用户名删除所有地址
     */
    @Modifying
    @Query("DELETE FROM UserAddress ua WHERE ua.user.username = :username")
    void deleteByUserUsername(@Param("username") String username);
    
    /**
     * 将用户的所有地址设为非默认
     */
    @Modifying
    @Query("UPDATE UserAddress ua SET ua.isDefault = false WHERE ua.user.username = :username")
    void resetDefaultByUsername(@Param("username") String username);
    
    /**
     * 根据用户名和地址ID查找地址
     */
    @Query("SELECT ua FROM UserAddress ua JOIN ua.user u WHERE u.username = :username AND ua.id = :id")
    UserAddress findByUserUsernameAndId(@Param("username") String username, @Param("id") Long id);
    
    /**
     * 批量更新用户名
     */
    @Modifying
    @Query("UPDATE UserAddress ua SET ua.user.username = :newUsername WHERE ua.user.username = :oldUsername")
    void updateUsernameForUserAddresses(@Param("oldUsername") String oldUsername, @Param("newUsername") String newUsername);
}
