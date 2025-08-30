package com.example.springboot.service;

import com.example.springboot.entity.MissingPet;
import com.example.springboot.repository.MissingPetRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Transactional
public class MissingPetService {

    private final MissingPetRepository missingPetRepository;

    public List<MissingPet> listAll() {
        return missingPetRepository.findAllByOrderByCreatedAtDesc();
    }

    public Optional<MissingPet> getById(Long id) {
        return missingPetRepository.findById(id);
    }

    public List<MissingPet> listByStatus(MissingPet.Status status) {
        return missingPetRepository.findByStatusOrderByCreatedAtDesc(status);
    }

    public List<MissingPet> listByCityLike(String city) {
        return missingPetRepository.findByCityContainingOrderByCreatedAtDesc(city);
    }

    public List<MissingPet> listByLostTimeRange(LocalDateTime start, LocalDateTime end) {
        return missingPetRepository.findByLostTimeBetweenOrderByCreatedAtDesc(start, end);
    }

    public List<MissingPet> listByStatusAndCity(MissingPet.Status status, String city) {
        return missingPetRepository.findByStatusAndCityContainingOrderByCreatedAtDesc(status, city);
    }

    // 按用户ID倒序
    public List<MissingPet> listByUserId(Long userId) {
        return missingPetRepository.findByUserIdOrderByCreatedAtDesc(userId);
    }

    // 按省份查询
    public List<MissingPet> listByProvince(String province) {
        return missingPetRepository.findByProvinceOrderByCreatedAtDesc(province);
    }

    public MissingPet create(MissingPet mp) {
        if (mp == null) throw new IllegalArgumentException("数据不能为空");
        if (mp.getTitle() == null || mp.getTitle().trim().isEmpty()) {
            throw new IllegalArgumentException("标题不能为空");
        }
        return missingPetRepository.save(mp);
    }

    public MissingPet update(Long id, MissingPet input) {
        MissingPet db = missingPetRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("记录不存在: " + id));
        // 允许更新的字段
        db.setTitle(input.getTitle() != null ? input.getTitle() : db.getTitle());
        db.setPetName(input.getPetName());
        db.setType(input.getType());
        db.setGender(input.getGender());
        db.setAge(input.getAge());
        db.setLostTime(input.getLostTime());
        db.setCity(input.getCity());
        db.setLostAddress(input.getLostAddress());
        db.setDescription(input.getDescription());
        db.setContactName(input.getContactName());
        db.setContactPhone(input.getContactPhone());
        db.setReward(input.getReward());
        db.setImage(input.getImage());
        db.setStatus(input.getStatus() != null ? input.getStatus() : db.getStatus());
        return missingPetRepository.save(db);
    }

    public MissingPet updateStatus(Long id, MissingPet.Status status) {
        MissingPet db = missingPetRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("记录不存在: " + id));
        db.setStatus(status);
        return missingPetRepository.save(db);
    }

    public void delete(Long id) {
        missingPetRepository.deleteById(id);
    }
}
