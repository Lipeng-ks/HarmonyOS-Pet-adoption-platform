package com.example.springboot.config;

import com.example.springboot.entity.Animal;
import com.example.springboot.entity.City;
import com.example.springboot.entity.ProvinceCity;
import com.example.springboot.entity.UserAddress;
import com.example.springboot.entity.UserInfo;
import com.example.springboot.repository.AnimalRepository;
import com.example.springboot.repository.CityRepository;
import com.example.springboot.repository.ProvinceCityRepository;
import com.example.springboot.repository.UserAddressRepository;
import com.example.springboot.repository.UserInfoRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Component;

import java.util.List;

/**
 * 数据初始化器
 */
@Component
@Profile("mysql")
@RequiredArgsConstructor
public class DataInitializer implements CommandLineRunner {
    
    private final UserInfoRepository userInfoRepository;
    private final UserAddressRepository userAddressRepository;
    private final AnimalRepository animalRepository;
    private final CityRepository cityRepository;
    private final ProvinceCityRepository provinceCityRepository;
    private final BCryptPasswordEncoder passwordEncoder;
    
    @Override
    public void run(String... args) throws Exception {
        // 跳过所有示例/模拟数据的初始化，保持数据库/数据为空或由真实数据驱动
        initializeAnimals(); // animals 已在方法内被设置为跳过
        initializeCities(); // 初始化城市数据
        System.out.println("数据初始化已跳过示例数据");
    }
    
    /**
     * 初始化默认用户数据
     */
    private void initializeDefaultUser() {
        // 已移除默认用户示例数据的初始化逻辑，避免在启动时插入测试用户
        System.out.println("默认用户初始化已禁用，跳过示例用户数据创建");
    }
    
    /**
     * 初始化动物数据
     */
    private void initializeAnimals() {
        // 不再初始化任何动物数据，保持数据库为空
        System.out.println("动物数据初始化跳过，数据库保持空白状态");
    }
    
    private void initializeCities() {
        // 更新现有城市数据，添加省份信息
        updateCitiesWithProvinceInfo();
    }
    
    /**
     * 为现有城市数据添加省份信息
     */
    private void updateCitiesWithProvinceInfo() {
        List<City> allCities = cityRepository.findAll();
        
        for (City city : allCities) {
            if (city.getProvince() == null || city.getProvince().isEmpty()) {
                String province = getProvinceByCity(city.getName());
                if (province != null) {
                    city.setProvince(province);
                }
            }
        }
        
        cityRepository.saveAll(allCities);
        System.out.println("城市省份信息更新完成，共更新 " + allCities.size() + " 条记录");
    }
    
    /**
     * 根据城市名称从数据库获取对应的省份
     */
    private String getProvinceByCity(String cityName) {
        try {
            ProvinceCity provinceCity = provinceCityRepository.findByCity(cityName);
            return provinceCity != null ? provinceCity.getProvince() : null;
        } catch (Exception e) {
            System.err.println("查询省份信息失败，城市: " + cityName + ", 错误: " + e.getMessage());
            return null;
        }
    }
    
    /**
     * 创建动物对象的辅助方法
     */
    private Animal createAnimal(String name, Boolean gender, Float age, String type, String description,
                               Boolean vaccinated, Boolean dewormed, Boolean neutered, String image, 
                               String city, Boolean isFree) {
        Animal animal = new Animal();
        animal.setName(name);
        animal.setGender(gender);
        animal.setAge(age);
        animal.setType(type);
        animal.setDescription(description);
        animal.setVaccinated(vaccinated);
        animal.setDewormed(dewormed);
        animal.setNeutered(neutered);
        animal.setImage(image);
        animal.setCity(city);
        animal.setIsFree(isFree);
        return animal;
    }
}
