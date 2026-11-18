package com.realestate.backend.modules.client_leads;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "client_leads", indexes = {
    @Index(name = "idx_lead_phone", columnList = "clientPhone"),
    @Index(name = "idx_lead_company", columnList = "companyId")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LeadEntity {

    @Id
    private UUID id; // Matches the mobile app local UUID for seamless delta sync

    @Column(nullable = false)
    private UUID companyId;

    @Column(nullable = false)
    private UUID brokerId;

    @Column(nullable = false, length = 120)
    private String clientName;

    @Column(nullable = false, length = 30)
    private String clientPhone;

    @Column(nullable = false, length = 50)
    private String currentStageId; // "new_lead", "site_visit_scheduled", "token_biana_pending", "deal_closed"

    @Column(nullable = false)
    private Double budgetInr;

    @Column(length = 150)
    private String preferredLocation;

    @Column(length = 50)
    private String inventoryType; // 2BHK, 3BHK, Villa, Plot, Commercial

    @Column(columnDefinition = "TEXT")
    private String customStageDataJson; // JSON representation of broker's dynamic schema fields

    @Column(nullable = false)
    @Builder.Default
    private Integer syncVersion = 1;

    private LocalDateTime lastContactedAt;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    @Column(nullable = false)
    private LocalDateTime updatedAt;
}
