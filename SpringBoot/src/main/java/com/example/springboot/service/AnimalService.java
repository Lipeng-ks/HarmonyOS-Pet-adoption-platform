package com.example.springboot.service;

import com.example.springboot.entity.Animal;
import com.example.springboot.repository.AnimalRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

/**
 * 动物服务类
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AnimalService {
    
    private final AnimalRepository animalRepository;
    
    /**
     * 获取所有动物列表
     */
    public List<Animal> getAllAnimals() {
        return animalRepository.findAll();
    }
    
    /**
     * 根据ID获取动物信息
     */
    public Optional<Animal> getAnimalById(Long id) {
        return animalRepository.findById(id);
    }
    
    /**
     * 根据城市获取动物列表
     */
    public List<Animal> getAnimalsByCity(String city) {
        return animalRepository.findByCity(city);
    }
    
    /**
     * 根据类型获取动物列表
     */
    public List<Animal> getAnimalsByType(String type) {
        return animalRepository.findByType(type);
    }
    
    /**
     * 根据城市和类型获取动物列表
     */
    public List<Animal> getAnimalsByCityAndType(String city, String type) {
        return animalRepository.findByCityAndType(city, type);
    }
    
    /**
     * 获取免费领养的动物
     */
    public List<Animal> getFreeAnimals() {
        return animalRepository.findByIsFreeTrue();
    }

    /**
     * 根据是否已领养查询
     */
    public List<Animal> getAnimalsByAdopted(Boolean adopted) {
        return animalRepository.findByAdopted(adopted);
    }

    /**
     * 根据是否上架查询
     */
    public List<Animal> getAnimalsByListed(Boolean listed) {
        return animalRepository.findByListed(listed);
    }

    /**
     * 组合条件：是否已领养 + 是否上架
     */
    public List<Animal> getAnimalsByAdoptedAndListed(Boolean adopted, Boolean listed) {
        return animalRepository.findByAdoptedAndListed(adopted, listed);
    }

    /**
     * 分页获取动物列表，支持 adopted、listed 过滤
     */
    public Page<Animal> getAnimalsPage(Boolean adopted, Boolean listed, Pageable pageable) {
        if (adopted != null && listed != null) {
            return animalRepository.findByAdoptedAndListed(adopted, listed, pageable);
        } else if (adopted != null) {
            return animalRepository.findByAdopted(adopted, pageable);
        } else if (listed != null) {
            return animalRepository.findByListed(listed, pageable);
        }
        return animalRepository.findAll(pageable);
    }

    /**
     * 更新动物的上/下架状态
     */
    @Transactional(readOnly = false)
    public Optional<Animal> updateListed(Long id, Boolean listed) {
        Optional<Animal> opt = animalRepository.findById(id);
        if (opt.isEmpty()) return Optional.empty();
        Animal a = opt.get();
        a.setListed(listed != null ? listed : a.getListed());
        Animal saved = animalRepository.save(a);
        return Optional.of(saved);
    }

    /**
     * 创建新动物
     */
    @Transactional(readOnly = false)
    public Animal createAnimal(Animal animal) {
        return animalRepository.save(animal);
    }

    /**
     * 更新动物完整信息
     */
    @Transactional(readOnly = false)
    public Optional<Animal> updateAnimal(Long id, Animal updateData) {
        Optional<Animal> opt = animalRepository.findById(id);
        if (opt.isEmpty()) return Optional.empty();
        
        Animal existing = opt.get();
        
        // 更新所有可修改的字段
        if (updateData.getName() != null) {
            existing.setName(updateData.getName());
        }
        if (updateData.getGender() != null) {
            existing.setGender(updateData.getGender());
        }
        if (updateData.getAge() != null) {
            existing.setAge(updateData.getAge());
        }
        if (updateData.getType() != null) {
            existing.setType(updateData.getType());
        }
        if (updateData.getDescription() != null) {
            existing.setDescription(updateData.getDescription());
        }
        if (updateData.getVaccinated() != null) {
            existing.setVaccinated(updateData.getVaccinated());
        }
        if (updateData.getDewormed() != null) {
            existing.setDewormed(updateData.getDewormed());
        }
        if (updateData.getNeutered() != null) {
            existing.setNeutered(updateData.getNeutered());
        }
        if (updateData.getImage() != null) {
            existing.setImage(updateData.getImage());
        }
        if (updateData.getCity() != null) {
            existing.setCity(updateData.getCity());
        }
        if (updateData.getIsFree() != null) {
            existing.setIsFree(updateData.getIsFree());
        }
        if (updateData.getListed() != null) {
            existing.setListed(updateData.getListed());
        }
        
        Animal saved = animalRepository.save(existing);
        return Optional.of(saved);
    }

    /**
     * 删除动物，返回是否存在并成功删除
     */
    @Transactional(readOnly = false)
    public boolean deleteAnimal(Long id) {
        if (!animalRepository.existsById(id)) {
            return false;
        }
        animalRepository.deleteById(id);
        return true;
    }
}
