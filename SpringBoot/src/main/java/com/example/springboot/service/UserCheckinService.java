package com.example.springboot.service;

import com.example.springboot.entity.UserCheckin;
import com.example.springboot.entity.UserInfo;
import com.example.springboot.entity.UserCheckinSummary;
import com.example.springboot.repository.UserCheckinRepository;
import com.example.springboot.repository.UserInfoRepository;
import com.example.springboot.repository.UserCheckinSummaryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class UserCheckinService {

    private final UserCheckinRepository checkinRepository;
    private final UserInfoRepository userInfoRepository;
    private final UserCheckinSummaryRepository summaryRepository;

    public boolean checkinForUser(String username, LocalDate date) {
        Optional<UserInfo> userOpt = userInfoRepository.findByUsername(username);
        if (userOpt.isEmpty()) return false;
        UserInfo user = userOpt.get();

        List<UserCheckin> exists = checkinRepository.findByUsernameAndDate(username, date);
        if (exists != null && !exists.isEmpty()) return false; // already checked in today

        UserCheckin uc = new UserCheckin();
        uc.setUser(user);
        uc.setCheckinDate(date);
        uc.setCreatedAt(LocalDateTime.now());
        // 设置该次打卡的序号（基于已存在记录数 + 1）
        long existing = checkinRepository.countByUserUsername(username);
        uc.setCheckinNumber((int) existing + 1);
        checkinRepository.save(uc);
        // 更新或创建汇总表中的打卡次数记录
        try {
            UserCheckinSummary summary = summaryRepository.findByUsername(username).orElse(null);
            if (summary == null) {
                summary = new UserCheckinSummary();
                summary.setUserId(user.getId());
                summary.setUsername(user.getUsername());
                summary.setCheckinCount(1);
            } else {
                summary.setCheckinCount((summary.getCheckinCount() == null ? 0 : summary.getCheckinCount()) + 1);
            }
            summaryRepository.save(summary);
        } catch (Exception ex) {
            // 不抛出异常，打卡记录已保存，汇总表更新失败不会影响打卡本身
            System.err.println("更新打卡汇总失败: " + ex.getMessage());
        }
        return true;
    }

    /**
     * 检查用户在指定日期是否已打卡
     */
    public boolean hasCheckinOnDate(String username, LocalDate date) {
        List<UserCheckin> exists = checkinRepository.findByUsernameAndDate(username, date);
        return exists != null && !exists.isEmpty();
    }

    public List<UserCheckin> getCheckinsForUser(String username) {
        return checkinRepository.findByUsernameOrderByDateDesc(username);
    }

    public UserCheckinSummary getSummaryForUser(String username) {
        return summaryRepository.findByUsername(username).orElse(null);
    }

    /**
     * 获取用户历史打卡的日期列表（按日期倒序）
     */
    public List<LocalDate> getCheckinDates(String username) {
        return checkinRepository.findByUsernameOrderByDateDesc(username)
                .stream()
                .map(UserCheckin::getCheckinDate)
                .collect(Collectors.toList());
    }

    /**
     * 获取所有用户的签到记录
     */
    public List<Map<String, Object>> getAllCheckinRecords() {
        List<UserCheckin> allCheckins = checkinRepository.findAllByOrderByCheckinDateDesc();
        return allCheckins.stream().map(checkin -> {
            Map<String, Object> record = new HashMap<>();
            record.put("userId", checkin.getUser().getId());
            record.put("username", checkin.getUser().getUsername());
            record.put("date", checkin.getCheckinDate().toString());
            return record;
        }).collect(Collectors.toList());
    }

}


