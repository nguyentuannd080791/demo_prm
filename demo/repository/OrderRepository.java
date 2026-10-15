package com.example.demo.repository;

import com.example.demo.model.Order;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Repository;

import java.sql.PreparedStatement;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.List;
import java.util.Optional;

@Repository
public class OrderRepository {

    private final JdbcTemplate jdbcTemplate;

    public OrderRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    private final RowMapper<Order> mapper = (rs, rowNum) -> {
        Timestamp timestamp = rs.getTimestamp("date");

        return new Order(
            rs.getInt("id"),
            rs.getString("username"),
            timestamp == null ? null : timestamp.toLocalDateTime(),
            rs.getString("status")
        );
    };

    public List<Order> findAll() {
        String sql = """
            SELECT [id], [username], [date], [status]
            FROM [Orders]
            ORDER BY [id] DESC
            """;

        return jdbcTemplate.query(sql, mapper);
    }

    public Optional<Order> findById(Integer id) {
        String sql = """
            SELECT [id], [username], [date], [status]
            FROM [Orders]
            WHERE [id] = ?
            """;

        return jdbcTemplate.query(sql, mapper, id)
            .stream().findFirst();
    }

    public List<Order> findByUsername(String username) {
        String sql = """
            SELECT [id], [username], [date], [status]
            FROM [Orders]
            WHERE [username] = ?
            ORDER BY [date] DESC
            """;

        return jdbcTemplate.query(sql, mapper, username);
    }

    public int save(Order order) {
        String sql = """
            INSERT INTO [Orders]
                ([username], [date], [status])
            VALUES (?, ?, ?)
            """;

        KeyHolder keyHolder = new GeneratedKeyHolder();

        jdbcTemplate.update(connection -> {
            PreparedStatement ps = connection.prepareStatement(
                sql, Statement.RETURN_GENERATED_KEYS
            );

            ps.setString(1, order.getUsername());
            ps.setTimestamp(
                2, Timestamp.valueOf(order.getDate())
            );
            ps.setString(3, order.getStatus());

            return ps;
        }, keyHolder);

        Number key = keyHolder.getKey();

        if (key == null) {
            throw new IllegalStateException(
                "Không lấy được ID của đơn hàng mới."
            );
        }

        return key.intValue();
    }

    public int updateStatus(Integer id, String status) {
        String sql = """
            UPDATE [Orders]
            SET [status] = ?
            WHERE [id] = ?
            """;

        return jdbcTemplate.update(sql, status, id);
    }

    public int deleteById(Integer id) {
        return jdbcTemplate.update(
            "DELETE FROM [Orders] WHERE [id] = ?", id
        );
    }
}