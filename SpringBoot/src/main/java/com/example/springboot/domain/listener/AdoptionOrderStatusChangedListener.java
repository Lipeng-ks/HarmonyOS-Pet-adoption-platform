package com.example.springboot.domain.listener;

import com.example.springboot.domain.event.AdoptionOrderStatusChangedEvent;
import com.example.springboot.entity.AdoptionOrder;
import com.example.springboot.entity.Animal;
import com.example.springboot.repository.AnimalRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

import java.util.List;

/**
 * 监听订单状态变化，在事务提交后统一更新动物上下架/领养状态。
 *
 * 规则：
 * - 审核中：上架（listed=true），未领养（adopted=false）
 * - 已发货：下架（listed=false），未领养（adopted=false）
 * - 完成：下架（listed=false），已领养（adopted=true）
 * - 评价：下架（listed=false），已领养（adopted=true）
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class AdoptionOrderStatusChangedListener {

    private final AnimalRepository animalRepository;

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void onOrderStatusChanged(AdoptionOrderStatusChangedEvent event) {
        String petName = event.getPetName();
        AdoptionOrder.OrderStatus status = event.getStatus();
        Long animalId = event.getAnimalId();
        if ((petName == null || petName.trim().isEmpty()) && animalId == null || status == null) {
            log.debug("[OrderHook] skip: no valid petName/animalId or status. petName='{}', animalId={}, status={}", petName, animalId, status);
            return;
        }

        String trimmed = petName == null ? null : petName.trim();
        List<Animal> animals;

        // 1) 优先按 ID 精确匹配
        if (animalId != null) {
            var byId = animalRepository.findById(animalId);
            if (byId.isPresent()) {
                animals = java.util.List.of(byId.get());
                log.info("[OrderHook] matched by animalId={}, nameHint='{}'", animalId, trimmed);
            } else {
                log.warn("[OrderHook] animalId={} not found, fallback to name matching...", animalId);
                animals = java.util.Collections.emptyList();
            }
        } else {
            animals = java.util.Collections.emptyList();
        }

        // 2) 若未匹配且有名称，则按忽略大小写精确匹配
        if (animals.isEmpty() && trimmed != null && !trimmed.isEmpty()) {
            animals = animalRepository.findByNameIgnoreCase(trimmed);
            if (!animals.isEmpty()) {
                log.info("[OrderHook] matched by name(ignoreCase)='{}', count={}", trimmed, animals.size());
            }
        }

        // 3) 若仍未匹配，则按名称模糊匹配（忽略大小写）
        if (animals.isEmpty() && trimmed != null && !trimmed.isEmpty()) {
            animals = animalRepository.findByNameContainingIgnoreCase(trimmed);
            if (!animals.isEmpty()) {
                log.info("[OrderHook] matched by name(contains, ignoreCase)='{}', count={}", trimmed, animals.size());
            }
        }

        if (animals.isEmpty()) {
            log.warn("[OrderHook] no animals matched. animalId={}, name='{}', status={}", animalId, trimmed, status);
            return;
        }

        boolean targetListed;
        boolean targetAdopted;
        switch (status) {
            case 审核中 -> {
                targetListed = true;
                targetAdopted = false;
            }
            case 已发货 -> {
                targetListed = false;
                targetAdopted = false;
            }
            case 完成, 评价 -> {
                targetListed = false;
                targetAdopted = true;
            }
            default -> {
                // 兜底：不处理未知状态
                return;
            }
        }

        int changed = 0;
        for (Animal a : animals) {
            boolean needSave = false;
            if (a.getListed() == null || a.getListed() != targetListed) {
                a.setListed(targetListed);
                needSave = true;
            }
            if (a.getAdopted() == null || a.getAdopted() != targetAdopted) {
                a.setAdopted(targetAdopted);
                needSave = true;
            }
            if (needSave) {
                animalRepository.save(a);
                changed++;
            }
        }
        log.info("[OrderHook] updated animals for animalId={}, name='{}', status={}, total={}, changed={}", animalId, trimmed, status, animals.size(), changed);
    }
}
