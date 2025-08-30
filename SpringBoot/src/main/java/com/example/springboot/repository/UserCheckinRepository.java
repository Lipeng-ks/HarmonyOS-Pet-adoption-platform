package com.example.springboot.repository;

import com.example.springboot.entity.UserCheckin;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface UserCheckinRepository extends JpaRepository<UserCheckin, Long> {

    /**
     * 根据用户名获取指定日期的打卡记录
     */
    @Query("SELECT uc FROM UserCheckin uc JOIN uc.user u WHERE u.username = :username AND uc.checkinDate = :date")
    List<UserCheckin> findByUsernameAndDate(@Param("username") String username, @Param("date") LocalDate date);

    /**
     * 获取某用户的所有打卡记录（按日期降序）
     */
    @Query("SELECT uc FROM UserCheckin uc JOIN uc.user u WHERE u.username = :username ORDER BY uc.checkinDate DESC")
    List<UserCheckin> findByUsernameOrderByDateDesc(@Param("username") String username);

    /**
     * Count checkin records for a given username
     */
    long countByUserUsername(String username);
    
    /**
     * 批量更新用户名
     */
    @Modifying
    @Query("UPDATE UserCheckin uc SET uc.user.username = :newUsername WHERE uc.user.username = :oldUsername")
    void updateUsernameForUserCheckins(@Param("oldUsername") String oldUsername, @Param("newUsername") String newUsername);

    /**
     * 获取所有用户的签到记录（按日期降序）
     */
    @Query("SELECT uc FROM UserCheckin uc ORDER BY uc.checkinDate DESC")
    List<UserCheckin> findAllByOrderByCheckinDateDesc();
}


