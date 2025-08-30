package com.example.springboot.service;

import com.example.springboot.entity.UserFavorite;
import com.example.springboot.entity.Animal;
import com.example.springboot.repository.UserFavoriteRepository;
import com.example.springboot.repository.AnimalRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class UserFavoriteService {

    private final UserFavoriteRepository repository;
    private final AnimalRepository animalRepository;

    public UserFavorite addFavorite(Long userId, Long animalId) {
        // avoid duplicates
        var opt = repository.findByUserIdAndAnimalId(userId, animalId);
        if (opt.isPresent()) return opt.get();

        UserFavorite fav = new UserFavorite();
        fav.setUserId(userId);
        fav.setAnimalId(animalId);
        fav.setCreatedAt(LocalDateTime.now());
        
        // 增加动物收藏数
        incrementAnimalFavoriteCount(animalId);
        
        return repository.save(fav);
    }

    public void removeFavorite(Long userId, Long animalId) {
        var opt = repository.findByUserIdAndAnimalId(userId, animalId);
        if (opt.isPresent()) {
            repository.deleteByUserIdAndAnimalId(userId, animalId);
            // 减少动物收藏数
            decrementAnimalFavoriteCount(animalId);
        }
    }
    
    private void incrementAnimalFavoriteCount(Long animalId) {
        animalRepository.findById(animalId).ifPresent(animal -> {
            animal.setFavoriteCount(animal.getFavoriteCount() + 1);
            animalRepository.save(animal);
        });
    }
    
    private void decrementAnimalFavoriteCount(Long animalId) {
        animalRepository.findById(animalId).ifPresent(animal -> {
            int newCount = Math.max(0, animal.getFavoriteCount() - 1);
            animal.setFavoriteCount(newCount);
            animalRepository.save(animal);
        });
    }

    public boolean isFavorited(Long userId, Long animalId) {
        return repository.findByUserIdAndAnimalId(userId, animalId).isPresent();
    }

    public List<UserFavorite> listFavoritesByUser(Long userId) {
        return repository.findByUserIdOrderByCreatedAtDesc(userId);
    }

    /**
     * 批量查询指定用户对一组动物的收藏状态，返回已收藏的animalId集合
     */
    public Set<Long> getFavoritedAnimalIds(Long userId, List<Long> animalIds) {
        if (animalIds == null || animalIds.isEmpty()) return Set.of();
        return repository.findByUserIdAndAnimalIdIn(userId, animalIds)
                .stream()
                .map(UserFavorite::getAnimalId)
                .collect(Collectors.toSet());
    }

}


