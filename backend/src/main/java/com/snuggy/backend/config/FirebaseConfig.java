package com.snuggy.backend.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.messaging.FirebaseMessaging;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;

import java.io.IOException;
import java.io.InputStream;

@Configuration
public class FirebaseConfig {

    @Bean
    public FirebaseApp firebaseApp() throws IOException {
        ClassPathResource serviceAccountResource = new ClassPathResource("firebase-service-account.json");

        if (!serviceAccountResource.exists()) {
            // Log a warning or throw a specific exception if the file is essential
            System.out.println("Firebase service account key not found. Firebase features will be disabled.");
            return null; // Or handle as appropriate
        }

        try (InputStream serviceAccount = serviceAccountResource.getInputStream()) {
            FirebaseOptions options = new FirebaseOptions.Builder()
                    .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                    .build();

            if (FirebaseApp.getApps().isEmpty()) {
                return FirebaseApp.initializeApp(options);
            } else {
                return FirebaseApp.getInstance();
            }
        }
    }

    @Bean
    public FirebaseMessaging firebaseMessaging(FirebaseApp firebaseApp) {
        if (firebaseApp == null) {
            return null; // Or a mock/dummy implementation
        }
        return FirebaseMessaging.getInstance(firebaseApp);
    }
} 