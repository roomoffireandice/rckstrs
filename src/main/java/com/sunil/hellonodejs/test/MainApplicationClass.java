package com.sunil.hellonodejs.test;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;


@SpringBootApplication
public class MainApplicationClass {

    public static void main(String[] args) {
        System.setProperty("https.protocols", "TLSv1");
        SpringApplication.run(MainApplicationClass.class, args);
    }

}
