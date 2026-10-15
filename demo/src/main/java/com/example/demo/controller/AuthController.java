package com.example.demo.controller;

import com.example.demo.dto.LoginRequest;
import com.example.demo.dto.LoginResponse;
import com.example.demo.dto.RegisterRequest;
import com.example.demo.dto.RegisterResponse;
import com.example.demo.service.AuthService;

import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(
            @RequestBody LoginRequest request) {

        LoginResponse response = authService.login(request);

        if (!response.isSuccess()) {
            HttpStatus status =
                response.getMessage().contains("không được để trống")
                    ? HttpStatus.BAD_REQUEST
                    : HttpStatus.UNAUTHORIZED;

            return ResponseEntity.status(status).body(response);
        }

        return ResponseEntity.ok(response);
    }

    @PostMapping("/register")
    public ResponseEntity<RegisterResponse> register(
            @Valid @RequestBody RegisterRequest request) {

        RegisterResponse response = authService.register(request);

        System.out.print(response);

        if (!response.isSuccess()) {
            HttpStatus status =
                response.getMessage().contains("đã tồn tại")
                    ? HttpStatus.CONFLICT
                    : HttpStatus.BAD_REQUEST;

            return ResponseEntity.status(status).body(response);
        }

        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }
}