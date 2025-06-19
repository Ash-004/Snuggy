package com.snuggy.backend.controller;

import com.snuggy.backend.entity.RfidMapping;
import com.snuggy.backend.exception.BadRequestException;
import com.snuggy.backend.exception.ResourceNotFoundException;
import com.snuggy.backend.payload.AdminRfidRegisterRequest;
import com.snuggy.backend.payload.RfidRegisterRequest;
import com.snuggy.backend.security.UserPrincipal;
import com.snuggy.backend.service.OtpService;
import com.snuggy.backend.service.RfidService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/rfid")
public class RfidController {

    @Autowired
    private RfidService rfidService;

    @Autowired
    private OtpService otpService;

    @PostMapping("/generate-otp")
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<?> generateOtp(@AuthenticationPrincipal UserPrincipal currentUser) {
        String otp = otpService.generateOtp(currentUser.getEmail());
        // In a real app, this would be sent via SMS or email.
        // For now, we'll return it in the response for testing.
        return ResponseEntity.ok(Map.of("otp", otp));
    }

    @PostMapping("/register")
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<?> registerRfid(@RequestBody RfidRegisterRequest request, @AuthenticationPrincipal UserPrincipal currentUser) {
        if (!otpService.validateOtp(currentUser.getEmail(), request.getOtp())) {
            throw new BadRequestException("Invalid OTP");
        }
        RfidMapping newMapping = new RfidMapping(request.getRfidUid(), currentUser.getId());
        rfidService.registerRfid(newMapping);
        return ResponseEntity.ok(Map.of("message", "RFID registered successfully"));
    }

    @PostMapping("/admin/register")
    @PreAuthorize("hasRole('STAFF')")
    public ResponseEntity<?> adminRegisterRfid(@RequestBody AdminRfidRegisterRequest request) {
        RfidMapping newMapping = new RfidMapping(request.getRfidUid(), request.getStudentId());
        rfidService.registerRfid(newMapping);
        return ResponseEntity.ok(Map.of("message", "RFID registered successfully for student " + request.getStudentId()));
    }

    @GetMapping("/{uid}")
    @PreAuthorize("hasAnyRole('STUDENT', 'STAFF')")
    public ResponseEntity<RfidMapping> getRfidMapping(@PathVariable String uid) {
        return rfidService.getRfidMapping(uid)
                .map(ResponseEntity::ok)
                .orElseThrow(() -> new ResourceNotFoundException("RFID mapping not found for UID: " + uid));
    }
} 