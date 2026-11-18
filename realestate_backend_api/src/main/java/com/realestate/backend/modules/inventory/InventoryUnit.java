package com.realestate.backend.modules.inventory;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "inventory_units")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class InventoryUnit {

    @Id
    private UUID id;

    @Column(nullable = false)
    private UUID companyId;

    private UUID brokerId; // null if company-wide inventory

    @Column(nullable = false, length = 120)
    private String projectName;

    @Column(nullable = false, length = 50)
    private String unitNumber;

    @Column(nullable = false, length = 40)
    private String unitType; // 2BHK, 3BHK, Villa, Plot, Commercial

    @Column(nullable = false)
    private Double superAreaSqft;

    @Column(nullable = false)
    private Double askingPriceInr;

    @Column(nullable = false, length = 30)
    @Builder.Default
    private String status = "AVAILABLE"; // "AVAILABLE", "BLOCKED", "SOLD"

    @Column(length = 150)
    private String location;

    @Column(columnDefinition = "TEXT")
    private String customSpecsJson; // Dynamic specs: Facing, Floor, Key Location, etc.

    @Column(nullable = false)
    private LocalDateTime createdAt;
}
