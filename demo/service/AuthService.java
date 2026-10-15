package com.example.demo.service;

import com.example.demo.dto.LoginRequest;
import com.example.demo.dto.LoginResponse;
import com.example.demo.dto.RegisterRequest;
import com.example.demo.dto.RegisterResponse;
import com.example.demo.model.UserModel;
import com.example.demo.repository.UserRepository;
import java.time.Instant;
import java.time.temporal.ChronoUnit;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.oauth2.jose.jws.MacAlgorithm;
import org.springframework.security.oauth2.jwt.JwsHeader;
import org.springframework.security.oauth2.jwt.JwtClaimsSet;
import org.springframework.security.oauth2.jwt.JwtEncoder;
import org.springframework.security.oauth2.jwt.JwtEncoderParameters;
import org.springframework.stereotype.Service;

@Service
public class AuthService {

    private final UserRepository userRepository;
    private final JwtEncoder jwtEncoder;
    private final BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();

    @Autowired
    public AuthService(UserRepository userRepository, JwtEncoder jwtEncoder) {
        this.userRepository = userRepository;
        this.jwtEncoder = jwtEncoder;
    }

    public AuthService(UserRepository userRepository) {
        this(userRepository, null);
    }

    public LoginResponse login(LoginRequest request) {
        if (request == null
                || request.getUsername() == null
                || request.getUsername().isBlank()
                || request.getPassword() == null
                || request.getPassword().isBlank()) {
            return new LoginResponse(
                false, "Username và password không được để trống", null
            );
        }

        UserModel user = userRepository
            .findByUsername(request.getUsername().trim())
            .orElse(null);

        if (user == null || user.getPassword() == null) {
            return new LoginResponse(
                false, "Username hoặc password không đúng", null
            );
        }

        boolean passwordMatches = request.getPassword().equals(user.getPassword())
                || encoder.matches(request.getPassword(), user.getPassword());

        if (!passwordMatches) {
            return new LoginResponse(
                false, "Username hoặc password không đúng", null
            );
        }

        String token = null;
        if (jwtEncoder != null) {
            Instant now = Instant.now();
            JwtClaimsSet claims = JwtClaimsSet.builder()
                .issuer("self")
                .issuedAt(now)
                .expiresAt(now.plus(1, ChronoUnit.DAYS))
                .subject(user.getUsername())
                .claim("username", user.getUsername())
                .build();

            JwsHeader jwsHeader = JwsHeader.with(MacAlgorithm.HS256).build();
            token = jwtEncoder.encode(JwtEncoderParameters.from(jwsHeader, claims)).getTokenValue();
        }

        return new LoginResponse(
            true,
            "Đăng nhập thành công",
            user.getUsername(),
            token
        );
    }

    public RegisterResponse register(RegisterRequest request) {
        if (request == null
                || request.getUsername() == null
                || request.getUsername().isBlank()
                || request.getPassword() == null
                || request.getPassword().isBlank()) {
            return new RegisterResponse(
                false, "Username và password không được để trống", null
            );
        }

        String username = request.getUsername().trim();
        String rawPassword = request.getPassword().trim();

        if (rawPassword.length() < 6) {
            return new RegisterResponse(
                false, "Password phải có ít nhất 6 ký tự", null
            );
        }

        if (userRepository.exists(username)) {
            return new RegisterResponse(
                false, "Username đã tồn tại", null
            );
        }

        String encodedPassword = encoder.encode(rawPassword);
        userRepository.insert(username, encodedPassword, true);

        return new RegisterResponse(
            true,
            "Đăng ký tài khoản thành công",
            username
        );
    }
}