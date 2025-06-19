package com.snuggy.backend.controller;

import com.snuggy.backend.entity.User;
import com.snuggy.backend.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import com.snuggy.backend.security.UserPrincipal;

import java.util.Map;

@RestController
@RequestMapping("/api/user")
public class UserController {

    @Autowired
    private UserService userService;

    @GetMapping("/me")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<?> getCurrentUser(@AuthenticationPrincipal UserPrincipal userPrincipal) {
        User user = userService.getUserById(userPrincipal.getId());
        return ResponseEntity.ok(user);
    }

    @PostMapping("/fcm-token")
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<?> registerFcmToken(@RequestBody Map<String, String> payload, @AuthenticationPrincipal UserPrincipal userPrincipal) {
        String token = payload.get("token");
        if (token == null || token.isEmpty()) {
            return ResponseEntity.badRequest().body("FCM token is required.");
        }
        userService.updateFcmToken(userPrincipal.getId(), token);
        return ResponseEntity.ok("FCM token updated successfully.");
    }
} 