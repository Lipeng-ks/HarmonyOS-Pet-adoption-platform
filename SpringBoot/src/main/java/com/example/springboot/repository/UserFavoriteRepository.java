package com.example.springboot.repository;

import com.example.springboot.entity.UserFavorite;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserFavoriteRepository extends JpaRepository<UserFavorite, Long> {
    List<UserFavorite> findByUserIdOrderByCreatedAtDesc(Long userId);
    Optional<UserFavorite> findByUserIdAndAnimalId(Long userId, Long animalId);
    long countByUserId(Long userId);
    void deleteByUserIdAndAnimalId(Long userId, Long animalId);
    List<UserFavorite> findByUserIdAndAnimalIdIn(Long userId, List<Long> animalIds);
}


