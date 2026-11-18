package com.realestate.backend.modules.client_leads;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "lead_interactions")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LeadInteraction {

    @Id
    private UUID id;

    @Column(nullable = false)
    private UUID leadId;

    @Column(nullable = false)
    private UUID brokerId;

    @Column(nullable = false, length = 30)
    private String clientPhone;

    @Column(nullable = false)
    @Builder.Default
    private Integer durationSeconds = 0;

    @Column(columnDefinition = "TEXT")
    private String hindiSummary;

    @Column(length = 255)
    private String actionItem;

    private LocalDateTime followUpDate;

    @Column(nullable = false)
    private LocalDateTime createdAt;
}
