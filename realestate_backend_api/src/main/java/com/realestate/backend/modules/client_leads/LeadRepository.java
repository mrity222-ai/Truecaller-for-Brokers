package com.realestate.backend.modules.client_leads;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface LeadRepository extends JpaRepository<LeadEntity, UUID> {
    List<LeadEntity> findByCompanyId(UUID companyId);
    List<LeadEntity> findByBrokerId(UUID brokerId);
    Optional<LeadEntity> findByClientPhoneAndCompanyId(String clientPhone, UUID companyId);

    @Query("SELECT l FROM LeadEntity l WHERE l.companyId = :companyId AND l.updatedAt > :since")
    List<LeadEntity> findDeltasSince(@Param("companyId") UUID companyId, @Param("since") LocalDateTime since);

    @Query("SELECT l.preferredLocation, COUNT(l), AVG(l.budgetInr) FROM LeadEntity l WHERE l.companyId = :companyId GROUP BY l.preferredLocation")
    List<Object[]> getSpatialLocalityAggregates(@Param("companyId") UUID companyId);
}
