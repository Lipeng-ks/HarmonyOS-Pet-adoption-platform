package com.example.springboot.repository;

import com.example.springboot.entity.UserRealName;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRealNameRepository extends JpaRepository<UserRealName, Long> {
    Optional<UserRealName> findByUserId(Long userId);
    Optional<UserRealName> findByIdNumber(String idNumber);
}


