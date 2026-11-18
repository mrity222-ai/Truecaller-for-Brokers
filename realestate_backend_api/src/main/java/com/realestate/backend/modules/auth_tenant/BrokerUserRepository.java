package com.realestate.backend.modules.auth_tenant;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;
import java.util.List;
import java.util.UUID;

@Repository
public interface BrokerUserRepository extends JpaRepository<BrokerUser, UUID> {
    Optional<BrokerUser> findByPhoneNumber(String phoneNumber);
    List<BrokerUser> findByCompanyId(UUID companyId);
}
