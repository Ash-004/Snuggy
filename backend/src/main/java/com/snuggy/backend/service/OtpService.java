package com.snuggy.backend.service;

import org.springframework.stereotype.Service;

import java.util.Random;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.TimeUnit;

@Service
public class OtpService {

    private static final long OTP_VALID_DURATION = 5; // 5 minutes

    private static class OtpData {
        String otp;
        long timestamp;

        OtpData(String otp) {
            this.otp = otp;
            this.timestamp = System.currentTimeMillis();
        }

        boolean isExpired() {
            return (System.currentTimeMillis() - timestamp) > TimeUnit.MINUTES.toMillis(OTP_VALID_DURATION);
        }
    }

    private final ConcurrentHashMap<String, OtpData> otpCache = new ConcurrentHashMap<>();
    private final Random random = new Random();

    public String generateOtp(String key) {
        String otp = String.format("%06d", random.nextInt(999999));
        otpCache.put(key, new OtpData(otp));
        return otp;
    }

    public boolean validateOtp(String key, String otp) {
        OtpData otpData = otpCache.get(key);
        if (otpData == null || otpData.isExpired()) {
            otpCache.remove(key); // Clean up expired or non-existent entry
            return false;
        }
        
        if (otpData.otp.equals(otp)) {
            otpCache.remove(key);
            return true;
        }
        
        return false;
    }
} 