package com.example.springboot.domain.event;

import com.example.springboot.entity.AdoptionOrder;
import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 订单状态变化领域事件（用于触发动物上下架/领养状态更新的勾子）
 */
@Getter
@AllArgsConstructor
public class AdoptionOrderStatusChangedEvent {
    private final Long animalId;
    private final String petName;
    private final AdoptionOrder.OrderStatus status;
}
