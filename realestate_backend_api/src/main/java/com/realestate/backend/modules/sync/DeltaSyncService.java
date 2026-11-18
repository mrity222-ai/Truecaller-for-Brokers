package com.realestate.backend.modules.sync;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.realestate.backend.modules.auth_tenant.BrokerUser;
import com.realestate.backend.modules.auth_tenant.BrokerUserRepository;
import com.realestate.backend.modules.client_leads.LeadEntity;
import com.realestate.backend.modules.client_leads.LeadInteraction;
import com.realestate.backend.modules.client_leads.LeadInteractionRepository;
import com.realestate.backend.modules.client_leads.LeadRepository;
import com.realestate.backend.modules.inventory.InventoryRepository;
import com.realestate.backend.modules.inventory.InventoryUnit;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class DeltaSyncService {

    private final LeadRepository leadRepository;
    private final LeadInteractionRepository interactionRepository;
    private final BrokerUserRepository brokerUserRepository;
    private final InventoryRepository inventoryRepository;
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Transactional
    public SyncPullResponseDto processPush(SyncPushRequestDto request) {
        final UUID brokerId = request.getBrokerId();
        final UUID companyId = request.getCompanyId();

        Optional<BrokerUser> brokerOpt = brokerUserRepository.findById(brokerId);
        if (brokerOpt.isPresent()) {
            BrokerUser broker = brokerOpt.get();
            if (broker.isLocalOnlyMode()) {
                log.info("Broker {} is in 100% Local-Only Mode. Rejecting cloud ingestion per privacy settings.", brokerId);
                return SyncPullResponseDto.builder()
                        .serverTimestamp(System.currentTimeMillis())
                        .status("IGNORED_LOCAL_ONLY_MODE")
                        .build();
            }
            broker.setLastSyncedAt(LocalDateTime.now());
            brokerUserRepository.save(broker);
        }

        // 1. Process Leads Delta
        if (request.getLeads() != null) {
            for (SyncPushRequestDto.LeadSyncItem item : request.getLeads()) {
                LocalDateTime incomingUpdatedAt = LocalDateTime.ofInstant(
                        Instant.ofEpochMilli(item.getUpdatedAt()), ZoneId.systemDefault());
                LocalDateTime incomingCreatedAt = LocalDateTime.ofInstant(
                        Instant.ofEpochMilli(item.getCreatedAt()), ZoneId.systemDefault());

                Optional<LeadEntity> existingOpt = leadRepository.findById(item.getId());
                if (existingOpt.isEmpty()) {
                    // New Lead from Mobile
                    String customJson = "{}";
                    try {
                        if (item.getCustomFields() != null) {
                            customJson = objectMapper.writeValueAsString(item.getCustomFields());
                        }
                    } catch (Exception ignored) {}

                    LeadEntity newLead = LeadEntity.builder()
                            .id(item.getId())
                            .companyId(companyId)
                            .brokerId(brokerId)
                            .clientName(item.getName())
                            .clientPhone(item.getPhoneNumber())
                            .currentStageId(item.getStageId())
                            .budgetInr(item.getBudgetInr())
                            .preferredLocation(item.getPreferredLocation())
                            .inventoryType(item.getInventoryType())
                            .customStageDataJson(customJson)
                            .syncVersion(1)
                            .lastContactedAt(incomingUpdatedAt)
                            .createdAt(incomingCreatedAt)
                            .updatedAt(incomingUpdatedAt)
                            .build();

                    leadRepository.save(newLead);
                } else {
                    // Existing Lead: Last-Write-Wins
                    LeadEntity existing = existingOpt.get();
                    if (incomingUpdatedAt.isAfter(existing.getUpdatedAt())) {
                        existing.setClientName(item.getName());
                        existing.setCurrentStageId(item.getStageId());
                        existing.setBudgetInr(item.getBudgetInr());
                        existing.setPreferredLocation(item.getPreferredLocation());
                        existing.setInventoryType(item.getInventoryType());
                        existing.setSyncVersion(existing.getSyncVersion() + 1);
                        existing.setUpdatedAt(incomingUpdatedAt);
                        existing.setLastContactedAt(incomingUpdatedAt);

                        try {
                            if (item.getCustomFields() != null) {
                                existing.setCustomStageDataJson(objectMapper.writeValueAsString(item.getCustomFields()));
                            }
                        } catch (Exception ignored) {}

                        leadRepository.save(existing);
                    }
                }
            }
        }

        // 2. Process Interactions
        if (request.getInteractions() != null) {
            for (SyncPushRequestDto.InteractionSyncItem item : request.getInteractions()) {
                if (!interactionRepository.existsById(item.getId())) {
                    LocalDateTime followUp = item.getFollowUpDate() != null
                            ? LocalDateTime.ofInstant(Instant.ofEpochMilli(item.getFollowUpDate()), ZoneId.systemDefault())
                            : null;
                    LocalDateTime created = LocalDateTime.ofInstant(
                            Instant.ofEpochMilli(item.getCreatedAt()), ZoneId.systemDefault());

                    LeadInteraction logEntity = LeadInteraction.builder()
                            .id(item.getId())
                            .leadId(item.getLeadId())
                            .brokerId(brokerId)
                            .clientPhone(item.getPhoneNumber())
                            .durationSeconds(item.getDurationSeconds())
                            .hindiSummary(item.getHindiSummary())
                            .actionItem(item.getActionItem())
                            .followUpDate(followUp)
                            .createdAt(created)
                            .build();

                    interactionRepository.save(logEntity);
                }
            }
        }

        return SyncPullResponseDto.builder()
                .serverTimestamp(System.currentTimeMillis())
                .status("SYNC_SUCCESS")
                .build();
    }

    @Transactional(readOnly = true)
    public SyncPullResponseDto processPull(UUID companyId, Long sinceTimestamp) {
        LocalDateTime since = sinceTimestamp != null && sinceTimestamp > 0
                ? LocalDateTime.ofInstant(Instant.ofEpochMilli(sinceTimestamp), ZoneId.systemDefault())
                : LocalDateTime.now().minusDays(90);

        List<LeadEntity> deltas = leadRepository.findDeltasSince(companyId, since);
        List<InventoryUnit> inventories = inventoryRepository.findByCompanyId(companyId);

        return SyncPullResponseDto.builder()
                .serverTimestamp(System.currentTimeMillis())
                .updatedLeads(deltas)
                .updatedInventories(inventories)
                .status("PULL_SUCCESS")
                .build();
    }
}
