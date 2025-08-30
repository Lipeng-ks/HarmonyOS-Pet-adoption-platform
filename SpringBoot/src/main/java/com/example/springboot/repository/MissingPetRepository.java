package com.example.springboot.repository;

import com.example.springboot.entity.MissingPet;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface MissingPetRepository extends JpaRepository<MissingPet, Long> {

    // 全部倒序
    List<MissingPet> findAllByOrderByCreatedAtDesc();

    // 按状态倒序
    List<MissingPet> findByStatusOrderByCreatedAtDesc(MissingPet.Status status);

    // 按城市（模糊）倒序
    List<MissingPet> findByCityContainingOrderByCreatedAtDesc(String city);

    // 按走失时间范围倒序
    List<MissingPet> findByLostTimeBetweenOrderByCreatedAtDesc(LocalDateTime start, LocalDateTime end);

    // 按状态 + 城市（模糊）倒序
    List<MissingPet> findByStatusAndCityContainingOrderByCreatedAtDesc(MissingPet.Status status, String city);

    // 按用户ID倒序
    List<MissingPet> findByUserIdOrderByCreatedAtDesc(Long userId);

    // 按省份查询（通过城市关联）
    @Query("SELECT mp FROM MissingPet mp JOIN City c ON mp.city = c.name WHERE c.province = :province ORDER BY mp.createdAt DESC")
    List<MissingPet> findByProvinceOrderByCreatedAtDesc(@Param("province") String province);
}
