package com.realestate.backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import com.realestate.backend.modules.auth_tenant.Company;
import com.realestate.backend.modules.auth_tenant.BrokerUser;
import com.realestate.backend.modules.auth_tenant.CompanyRepository;
import com.realestate.backend.modules.auth_tenant.BrokerUserRepository;

import java.time.LocalDateTime;

@SpringBootApplication
public class RealEstateApplication {

    public static void main(String[] args) {
        SpringApplication.run(RealEstateApplication.class, args);
    }

    @Bean
    CommandLineRunner seedDemoData(CompanyRepository companyRepo, BrokerUserRepository brokerRepo) {
        return args -> {
            if (companyRepo.count() == 0) {
                Company company = Company.builder()
                        .companyName("Truecaller-for-Brokers")
                        .reraRegistrationNumber("UPRERA/AGT/2026/8941")
                        .createdAt(LocalDateTime.now())
                        .build();
                companyRepo.save(company);

                BrokerUser broker1 = BrokerUser.builder()
                        .company(company)
                        .fullName("Deepak Yadav (Lead Broker)")
                        .phoneNumber("+919876543210")
                        .role("ADMIN")
                        .localOnlyMode(false)
                        .createdAt(LocalDateTime.now())
                        .build();

                BrokerUser broker2 = BrokerUser.builder()
                        .company(company)
                        .fullName("Rajesh Sharma")
                        .phoneNumber("+919811122334")
                        .role("BROKER")
                        .localOnlyMode(false)
                        .createdAt(LocalDateTime.now())
                        .build();

                BrokerUser broker3 = BrokerUser.builder()
                        .company(company)
                        .fullName("Kavita Singh")
                        .phoneNumber("+919900055443")
                        .role("BROKER")
                        .localOnlyMode(true) // Demonstrates 100% local-only privacy mode
                        .createdAt(LocalDateTime.now())
                        .build();

                brokerRepo.save(broker1);
                brokerRepo.save(broker2);
                brokerRepo.save(broker3);
            }
        };
    }
}
