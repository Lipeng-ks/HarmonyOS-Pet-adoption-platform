package com.example.springboot.repository;

import com.example.springboot.entity.City;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * 城市信息数据访问接口
 */
@Repository
public interface CityRepository extends JpaRepository<City, Long> {
    
    /**
     * 根据城市名称查找
     */
    Optional<City> findByName(String name);
    
    /**
     * 根据拼音查找
     */
    Optional<City> findByPinyin(String pinyin);
    
    /**
     * 按拼音排序获取所有城市
     */
    List<City> findAllByOrderByPinyinAsc();
}
