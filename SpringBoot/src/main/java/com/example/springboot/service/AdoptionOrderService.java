package com.example.springboot.service;

import com.example.springboot.entity.AdoptionOrder;
import com.example.springboot.repository.AdoptionOrderRepository;
import com.example.springboot.domain.event.AdoptionOrderStatusChangedEvent;
import org.springframework.context.ApplicationEventPublisher;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Transactional
public class AdoptionOrderService {

    private final AdoptionOrderRepository adoptionOrderRepository;
    private final ApplicationEventPublisher applicationEventPublisher;

    /**
     * 获取所有订单
     */
    public List<AdoptionOrder> getAllOrders() {
        return adoptionOrderRepository.findAllByOrderByApplicationTimeDesc();
    }

    /**
     * 根据状态获取订单
     */
    public List<AdoptionOrder> getOrdersByStatus(AdoptionOrder.OrderStatus status) {
        return adoptionOrderRepository.findByStatusOrderByApplicationTimeDesc(status);
    }

    /**
     * 根据ID获取订单
     */
    public Optional<AdoptionOrder> getOrderById(Long id) {
        return adoptionOrderRepository.findById(id);
    }

    /**
     * 创建新订单
     */
    public AdoptionOrder createOrder(AdoptionOrder order) {
        if (order == null) {
            throw new IllegalArgumentException("订单数据不能为空");
        }
        if (order.getUserId() == null || order.getUserId() <= 0) {
            throw new IllegalArgumentException("缺少有效的用户ID");
        }
        String petName = order.getPetName() == null ? null : order.getPetName().trim();
        if (petName == null || petName.isEmpty()) {
            throw new IllegalArgumentException("宠物名称不能为空");
        }

        // 业务校验：同一用户针对同一宠物是否已存在“审核中”订单
        boolean existsPending = adoptionOrderRepository
                .existsByUserIdAndPetNameAndStatus(order.getUserId(), petName, AdoptionOrder.OrderStatus.审核中);
        if (existsPending) {
            throw new IllegalArgumentException("您已提交过该宠物的审核中订单，请勿重复申请");
        }

        // 将修整后的宠物名写回
        order.setPetName(petName);
        AdoptionOrder saved = adoptionOrderRepository.save(order);
        // 发布状态变更事件（新建订单通常为“审核中”），携带 animalId
        applicationEventPublisher.publishEvent(new AdoptionOrderStatusChangedEvent(saved.getAnimalId(), saved.getPetName(), saved.getStatus()));
        return saved;
    }

    /**
     * 更新订单状态
     */
    public AdoptionOrder updateOrderStatus(Long id, AdoptionOrder.OrderStatus status) {
        Optional<AdoptionOrder> orderOpt = adoptionOrderRepository.findById(id);
        if (orderOpt.isPresent()) {
            AdoptionOrder order = orderOpt.get();
            
            // 记录原状态，用于判断是否需要设置完成时间
            AdoptionOrder.OrderStatus previousStatus = order.getStatus();
            
            order.setStatus(status);
            
            // 如果订单状态从非完成状态变为完成状态，设置完成时间
            if (status == AdoptionOrder.OrderStatus.完成 && previousStatus != AdoptionOrder.OrderStatus.完成) {
                order.setCompletedAt(java.time.LocalDateTime.now());
            }
            // 如果订单状态从完成状态变为其他状态，清空完成时间
            else if (status != AdoptionOrder.OrderStatus.完成 && previousStatus == AdoptionOrder.OrderStatus.完成) {
                order.setCompletedAt(null);
            }

            AdoptionOrder saved = adoptionOrderRepository.save(order);
            // 发布订单状态变化事件（交由监听器在事务提交后统一处理动物状态），携带 animalId
            applicationEventPublisher.publishEvent(new AdoptionOrderStatusChangedEvent(saved.getAnimalId(), saved.getPetName(), saved.getStatus()));
            return saved;
        }
        throw new RuntimeException("订单不存在，ID: " + id);
    }

    /**
     * 删除订单
     */
    public void deleteOrder(Long id) {
        adoptionOrderRepository.deleteById(id);
    }

    /**
     * 根据宠物名字搜索订单
     */
    public List<AdoptionOrder> searchOrdersByPetName(String petName) {
        return adoptionOrderRepository.findByPetNameContainingOrderByApplicationTimeDesc(petName);
    }

    /**
     * 根据地址搜索订单
     */
    public List<AdoptionOrder> searchOrdersByAddress(String address) {
        return adoptionOrderRepository.findByPetAddressContainingOrderByApplicationTimeDesc(address);
    }

    /**
     * 根据用户ID获取订单
     */
    public List<AdoptionOrder> getOrdersByUserId(Long userId) {
        return adoptionOrderRepository.findByUserIdOrderByApplicationTimeDesc(userId);
    }

    /**
     * 更新订单信息
     */
    public AdoptionOrder updateOrder(Long id, AdoptionOrder order) {
        Optional<AdoptionOrder> existingOrderOpt = adoptionOrderRepository.findById(id);
        if (existingOrderOpt.isPresent()) {
            AdoptionOrder existingOrder = existingOrderOpt.get();
            
            // 更新可编辑的字段
            if (order.getUserId() != null) {
                existingOrder.setUserId(order.getUserId());
            }
            if (order.getAnimalId() != null) {
                existingOrder.setAnimalId(order.getAnimalId());
            }
            if (order.getPetName() != null && !order.getPetName().trim().isEmpty()) {
                existingOrder.setPetName(order.getPetName().trim());
            }
            if (order.getPetAddress() != null && !order.getPetAddress().trim().isEmpty()) {
                existingOrder.setPetAddress(order.getPetAddress().trim());
            }
            if (order.getApplicationReason() != null) {
                existingOrder.setApplicationReason(order.getApplicationReason());
            }
            if (order.getPetExperience() != null) {
                existingOrder.setPetExperience(order.getPetExperience());
            }
            if (order.getShippingAddress() != null) {
                existingOrder.setShippingAddress(order.getShippingAddress());
            }
            if (order.getStatus() != null) {
                // 记录原状态，用于判断是否需要设置完成时间
                AdoptionOrder.OrderStatus previousStatus = existingOrder.getStatus();
                existingOrder.setStatus(order.getStatus());
                
                // 如果订单状态从非完成状态变为完成状态，设置完成时间
                if (order.getStatus() == AdoptionOrder.OrderStatus.完成 && previousStatus != AdoptionOrder.OrderStatus.完成) {
                    existingOrder.setCompletedAt(java.time.LocalDateTime.now());
                }
                // 如果订单状态从完成状态变为其他状态，清空完成时间
                else if (order.getStatus() != AdoptionOrder.OrderStatus.完成 && previousStatus == AdoptionOrder.OrderStatus.完成) {
                    existingOrder.setCompletedAt(null);
                }
            }
            
            AdoptionOrder saved = adoptionOrderRepository.save(existingOrder);
            // 发布状态变更事件
            applicationEventPublisher.publishEvent(new AdoptionOrderStatusChangedEvent(saved.getAnimalId(), saved.getPetName(), saved.getStatus()));
            return saved;
        }
        throw new RuntimeException("订单不存在，ID: " + id);
    }

    /**
     * 分页获取订单，支持按 status、userId、keyword(宠物名或地址) 简单筛选
     */
    public Page<AdoptionOrder> getOrdersPage(AdoptionOrder.OrderStatus status,
                                             Long userId,
                                             String keyword,
                                             Pageable pageable) {
        if (userId != null) {
            return adoptionOrderRepository.findByUserId(userId, pageable);
        }
        if (status != null) {
            return adoptionOrderRepository.findByStatus(status, pageable);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            // 先以宠物名匹配；如需更复杂的 OR 查询，可在 Repository 增加对应方法
            return adoptionOrderRepository.findByPetNameContaining(keyword.trim(), pageable);
        }
        // 默认全部
        return adoptionOrderRepository.findAll(pageable);
    }
}
