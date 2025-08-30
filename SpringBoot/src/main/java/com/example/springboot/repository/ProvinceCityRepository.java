package com.example.springboot.repository;

import com.example.springboot.entity.ProvinceCity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProvinceCityRepository extends JpaRepository<ProvinceCity, Long> {
    List<ProvinceCity> findByProvinceOrderByCityAsc(String province);
    List<ProvinceCity> findAllByOrderByProvinceAscCityAsc();
    ProvinceCity findByCity(String city);
}


