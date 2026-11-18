package com.realestate.backend.modules.inventory;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.UUID;

@Repository
public interface InventoryRepository extends JpaRepository<InventoryUnit, UUID> {
    List<InventoryUnit> findByCompanyId(UUID companyId);
    List<InventoryUnit> findByCompanyIdAndStatus(UUID companyId, String status);
}
