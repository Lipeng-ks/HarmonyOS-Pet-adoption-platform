package com.example.springboot.listener;

import com.example.springboot.domain.event.AdoptionOrderStatusChangedEvent;
import com.example.springboot.service.AnimalStatusService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.event.EventListener;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;

/**
 * 领养订单事件监听器
 * 监听订单状态变化事件，自动更新动物上下架状态
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class AdoptionOrderEventListener {

    private final AnimalStatusService animalStatusService;

    /**
     * 监听订单状态变化事件
     * 异步处理以避免影响主业务流程
     */
    @EventListener
    @Async
    public void handleOrderStatusChanged(AdoptionOrderStatusChangedEvent event) {
        try {
            log.info("收到订单状态变化事件：动物ID={}, 宠物名={}, 订单状态={}", 
                    event.getAnimalId(), event.getPetName(), event.getStatus());
            
            // 更新动物状态
            animalStatusService.updateAnimalStatusByOrder(event.getAnimalId(), event.getStatus());
            
        } catch (Exception e) {
            log.error("处理订单状态变化事件失败：动物ID={}, 订单状态={}", 
                    event.getAnimalId(), event.getStatus(), e);
        }
    }
}
