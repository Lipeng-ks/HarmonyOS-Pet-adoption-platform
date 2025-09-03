package com.example.springboot.repository;

import com.example.springboot.entity.Animal;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * 动物信息数据访问接口
 */
@Repository
public interface AnimalRepository extends JpaRepository<Animal, Long> {
    
    /**
     * 根据城市查找动物
     */
    List<Animal> findByCity(String city);
    
    /**
     * 根据动物类型查找
     */
    List<Animal> findByType(String type);
    
    /**
     * 根据城市和类型查找动物
     */
    List<Animal> findByCityAndType(String city, String type);

    /**
     * 根据名称精确查找动物
     */
    List<Animal> findByName(String name);
    
    /**
     * 根据名称（忽略大小写）查找动物
     */
    List<Animal> findByNameIgnoreCase(String name);
    
    /**
     * 根据名称模糊匹配（忽略大小写）查找动物
     */
    List<Animal> findByNameContainingIgnoreCase(String namePart);
    
    /**
     * 查找免费领养的动物
     */
    List<Animal> findByIsFreeTrue();
    
    /**
     * 根据年龄范围查找动物
     */
    @Query("SELECT a FROM Animal a WHERE a.age BETWEEN :minAge AND :maxAge")
    List<Animal> findByAgeBetween(@Param("minAge") Float minAge, @Param("maxAge") Float maxAge);

    /**
     * 根据是否已领养查询
     */
    List<Animal> findByAdopted(Boolean adopted);

    /**
     * 根据是否上架查询
     */
    List<Animal> findByListed(Boolean listed);

    /**
     * 组合条件：是否已领养 + 是否上架
     */
    List<Animal> findByAdoptedAndListed(Boolean adopted, Boolean listed);

    // 分页方法
    Page<Animal> findByAdopted(Boolean adopted, Pageable pageable);
    Page<Animal> findByListed(Boolean listed, Pageable pageable);
    Page<Animal> findByAdoptedAndListed(Boolean adopted, Boolean listed, Pageable pageable);

    // 数据分析相关查询方法
    
    /**
     * 获取宠物类型分布统计
     */
    @Query("SELECT a.type, COUNT(a) FROM Animal a GROUP BY a.type ORDER BY COUNT(a) DESC")
    List<Object[]> findTypeDistribution();
    
    /**
     * 获取城市分布统计
     */
    @Query("SELECT a.city, COUNT(a) FROM Animal a WHERE a.city IS NOT NULL GROUP BY a.city ORDER BY COUNT(a) DESC")
    List<Object[]> findCityDistribution();
}
