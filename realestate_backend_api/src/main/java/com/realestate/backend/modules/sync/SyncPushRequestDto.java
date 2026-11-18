package com.realestate.backend.modules.sync;

import lombok.*;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SyncPushRequestDto {

    private UUID brokerId;
    private UUID companyId;
    private Long clientTimestamp;
    private List<LeadSyncItem> leads;
    private List<InteractionSyncItem> interactions;

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class LeadSyncItem {
        private UUID id;
        private String name;
        private String phoneNumber;
        private String stageId;
        private Double budgetInr;
        private String preferredLocation;
        private String inventoryType;
        private Map<String, Object> customFields;
        private Long updatedAt;
        private Long createdAt;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class InteractionSyncItem {
        private UUID id;
        private UUID leadId;
        private String phoneNumber;
        private Integer durationSeconds;
        private String hindiSummary;
        private String actionItem;
        private Long followUpDate;
        private Long createdAt;
    }
}
