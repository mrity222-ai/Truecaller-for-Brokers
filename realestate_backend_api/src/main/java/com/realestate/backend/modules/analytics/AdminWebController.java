package com.realestate.backend.modules.analytics;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class AdminWebController {

    @GetMapping({"/", "/admin", "/dashboard"})
    public String forwardToAdminDashboard() {
        return "forward:/admin/index.html";
    }

    @GetMapping({"/user", "/broker", "/portal"})
    public String forwardToUserPortal() {
        return "forward:/user/index.html";
    }
}
