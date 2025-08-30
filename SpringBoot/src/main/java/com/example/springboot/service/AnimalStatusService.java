package com.example.springboot.service;

import com.example.springboot.entity.Animal;
import com.example.springboot.entity.AdoptionOrder;
import com.example.springboot.repository.AnimalRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

/**
 * 动物状态管理服务
 * 根据订单状态自动管理动物的上下架和领养状态
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class AnimalStatusService {

    private final AnimalRepository animalRepository;

    /**
     * 根据订单状态更新动物状态
     * 
     * @param animalId 动物ID
     * @param orderStatus 订单状态
     */
    @Transactional
    public void updateAnimalStatusByOrder(Long animalId, AdoptionOrder.OrderStatus orderStatus) {
        if (animalId == null) {
            log.warn("动物ID为空，无法更新动物状态");
            return;
        }

        Optional<Animal> animalOpt = animalRepository.findById(animalId);
        if (animalOpt.isEmpty()) {
            log.warn("未找到ID为{}的动物", animalId);
            return;
        }

        Animal animal = animalOpt.get();
        updateAnimalStatus(animal, orderStatus);
        animalRepository.save(animal);
        
        log.info("动物{}状态已更新：订单状态={}, 上架状态={}, 领养状态={}", 
                animal.getName(), orderStatus, animal.getListed(), animal.getAdopted());
    }

    /**
     * 根据订单状态更新动物状态的核心逻辑
     * 
     * 状态规则：
     * - 审核中：上架未领养
     * - 已发货：下架未领养  
     * - 完成：下架领养
     * - 评价：下架领养
     */
    private void updateAnimalStatus(Animal animal, AdoptionOrder.OrderStatus orderStatus) {
        switch (orderStatus) {
            case 审核中:
                // 审核中状态：上架未领养
                animal.setListed(true);
                animal.setAdopted(false);
                break;
                
            case 已发货:
                // 已发货状态：下架未领养
                animal.setListed(false);
                animal.setAdopted(false);
                break;
                
            case 完成:
                // 完成状态：下架领养
                animal.setListed(false);
                animal.setAdopted(true);
                break;
                
            case 评价:
                // 评价状态：下架领养
                animal.setListed(false);
                animal.setAdopted(true);
                break;
                
            default:
                log.warn("未知的订单状态：{}", orderStatus);
                break;
        }
    }

    /**
     * 批量更新动物状态（用于数据修复等场景）
     */
    @Transactional
    public void batchUpdateAnimalStatus() {
        // 这里可以实现批量更新逻辑，比如根据现有订单状态重新计算所有动物状态
        log.info("批量更新动物状态功能待实现");
    }
}
