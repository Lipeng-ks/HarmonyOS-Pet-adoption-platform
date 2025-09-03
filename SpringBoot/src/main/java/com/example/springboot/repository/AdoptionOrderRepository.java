package com.example.springboot.repository;

import com.example.springboot.entity.AdoptionOrder;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface AdoptionOrderRepository extends JpaRepository<AdoptionOrder, Long> {

    /**
     * 根据状态查询订单
     */
    List<AdoptionOrder> findByStatusOrderByApplicationTimeDesc(AdoptionOrder.OrderStatus status);

    // 分页：按状态
    Page<AdoptionOrder> findByStatus(AdoptionOrder.OrderStatus status, Pageable pageable);

    /**
     * 获取所有订单，按申请时间倒序
     */
    List<AdoptionOrder> findAllByOrderByApplicationTimeDesc();


    /**
     * 根据宠物名字查询订单
     */
    List<AdoptionOrder> findByPetNameContainingOrderByApplicationTimeDesc(String petName);

    // 分页：按宠物名字
    Page<AdoptionOrder> findByPetNameContaining(String petName, Pageable pageable);

    /**
     * 根据地址查询订单
     */
    List<AdoptionOrder> findByPetAddressContainingOrderByApplicationTimeDesc(String address);

    // 分页：按地址
    Page<AdoptionOrder> findByPetAddressContaining(String address, Pageable pageable);

    /**
     * 根据用户ID查询订单
     */
    List<AdoptionOrder> findByUserIdOrderByApplicationTimeDesc(Long userId);

    // 分页：按用户ID
    Page<AdoptionOrder> findByUserId(Long userId, Pageable pageable);

    /**
     * 判断是否存在相同用户与宠物、且状态为指定状态的订单
     */
    boolean existsByUserIdAndPetNameAndStatus(Long userId, String petName, AdoptionOrder.OrderStatus status);

    // 数据分析相关查询方法
    
    /**
     * 根据状态统计订单数量
     */
    Long countByStatus(AdoptionOrder.OrderStatus status);
    
    /**
     * 统计指定状态和完成时间范围内的订单数量
     */
    Long countByStatusAndCompletedAtBetween(AdoptionOrder.OrderStatus status, LocalDateTime startDate, LocalDateTime endDate);
    
    /**
     * 统计申请时间范围内的订单数量
     */
    Long countByApplicationTimeBetween(LocalDateTime startDate, LocalDateTime endDate);
}
