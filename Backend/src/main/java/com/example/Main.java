package com.example;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class Main {

    public static void main(String[] args) {
        SpringApplication.run(Main.class, args);
        System.out.println("\n=================================");
        System.out.println("SmartLearn Backend démarré!");
        System.out.println("URL: http://localhost:8080");
        System.out.println("=================================\n");
    }
}