package com.sunil.hellonodejs.test;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@EnableAutoConfiguration
@RestController
public class BlogController {
    @Autowired
    BlogRespository blogRespository;

    @GetMapping("/blog")
    public List<Blog> index() {
        return blogRespository.findAll();
    }
}