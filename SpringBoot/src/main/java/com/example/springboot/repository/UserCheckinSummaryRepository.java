package com.example.springboot.repository;

import com.example.springboot.entity.UserCheckinSummary;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserCheckinSummaryRepository extends JpaRepository<UserCheckinSummary, Long> {
    Optional<UserCheckinSummary> findByUsername(String username);
    
    /**
     * 批量更新用户名
     */
    @Modifying
    @Query("UPDATE UserCheckinSummary ucs SET ucs.username = :newUsername WHERE ucs.username = :oldUsername")
    void updateUsername(@Param("oldUsername") String oldUsername, @Param("newUsername") String newUsername);
}


