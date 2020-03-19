package com.sunil.hellonodejs.test;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
public class BlogController {
    @Autowired
    BlogRespository blogRespository;

    @GetMapping("/blog")
    public List<Blog> index() {
        return blogRespository.findAll();
    }
}