package com.example.springboot.controller;

import com.example.springboot.entity.ProvinceCity;
import com.example.springboot.repository.ProvinceCityRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class ProvinceController {

    private final ProvinceCityRepository provinceCityRepository;

    @GetMapping("/provinces")
    public ResponseEntity<List<String>> getProvinces() {
        List<ProvinceCity> all = provinceCityRepository.findAllByOrderByProvinceAscCityAsc();
        LinkedHashSet<String> set = new LinkedHashSet<>();
        for (ProvinceCity pc : all) {
            set.add(pc.getProvince());
        }
        return ResponseEntity.ok(new ArrayList<>(set));
    }

    @GetMapping("/provinces/{province}/cities")
    public ResponseEntity<List<String>> getCitiesByProvince(@PathVariable String province) {
        List<ProvinceCity> list = provinceCityRepository.findByProvinceOrderByCityAsc(province);
        List<String> cities = list.stream().map(ProvinceCity::getCity).collect(Collectors.toList());
        return ResponseEntity.ok(cities);
    }
}


