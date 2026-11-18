package com.realestate.backend.modules.client_leads;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.UUID;

@Repository
public interface LeadInteractionRepository extends JpaRepository<LeadInteraction, UUID> {
    List<LeadInteraction> findByLeadId(UUID leadId);
    List<LeadInteraction> findByBrokerId(UUID brokerId);
}
