package com.realestate.backend.modules.auth_tenant;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "companies")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Company {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, length = 150)
    private String companyName;

    @Column(length = 60)
    private String reraRegistrationNumber;

    @Column(nullable = false)
    @Builder.Default
    private boolean cloudSyncEnforced = false;

    @Column(nullable = false)
    private LocalDateTime createdAt;
}
