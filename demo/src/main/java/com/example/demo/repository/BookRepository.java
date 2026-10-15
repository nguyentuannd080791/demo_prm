package com.example.demo.repository;

import com.example.demo.model.Book;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Repository;

import java.sql.PreparedStatement;
import java.sql.Statement;
import java.util.List;
import java.util.Optional;

@Repository
public class BookRepository {

    private final JdbcTemplate jdbcTemplate;

    public BookRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    private final RowMapper<Book> bookRowMapper = (rs, rowNum) ->
        new Book(
            rs.getInt("bookid"),
            rs.getString("bookname"),
            rs.getBigDecimal("price"),
            rs.getString("author"),
            rs.getString("publisher"),
            rs.getString("summary"),
            rs.getBoolean("status")
        );

    // 1. Lấy tất cả sách
    public List<Book> findAll() {
        String sql = """
            SELECT [bookid], [bookname], [price],
                   [author], [publisher], [summary], [status]
            FROM [Books]
            ORDER BY [bookid]
            """;

        return jdbcTemplate.query(sql, bookRowMapper);
    }

    // 2. Lấy sách theo ID
    public Optional<Book> findById(Integer id) {
        String sql = """
            SELECT [bookid], [bookname], [price],
                   [author], [publisher], [summary], [status]
            FROM [Books]
            WHERE [bookid] = ?
            """;

        List<Book> books = jdbcTemplate.query(
            sql, bookRowMapper, id
        );

        return books.stream().findFirst();
    }

    // 3. Thêm sách
    public int save(Book book) {
        String sql = """
            INSERT INTO [Books]
                ([bookname], [price], [author],
                 [publisher], [summary], [status])
            VALUES (?, ?, ?, ?, ?, ?)
            """;

        KeyHolder keyHolder = new GeneratedKeyHolder();

        jdbcTemplate.update(connection -> {
            PreparedStatement ps = connection.prepareStatement(
                sql, Statement.RETURN_GENERATED_KEYS
            );

            ps.setString(1, book.getBookname());
            ps.setBigDecimal(2, book.getPrice());
            ps.setString(3, book.getAuthor());
            ps.setString(4, book.getPublisher());
            ps.setString(5, book.getSummary());
            ps.setBoolean(6, book.isStatus());

            return ps;
        }, keyHolder);

        Number key = keyHolder.getKey();

        if (key == null) {
            throw new IllegalStateException(
                "Không lấy được bookid sau khi thêm sách."
            );
        }

        return key.intValue();
    }

    // 4. Cập nhật sách
    public int update(Integer id, Book book) {
        String sql = """
            UPDATE [Books]
            SET [bookname] = ?,
                [price] = ?,
                [author] = ?,
                [publisher] = ?,
                [summary] = ?,
                [status] = ?
            WHERE [bookid] = ?
            """;

        return jdbcTemplate.update(
            sql,
            book.getBookname(),
            book.getPrice(),
            book.getAuthor(),
            book.getPublisher(),
            book.getSummary(),
            book.isStatus(),
            id
        );
    }

    // 5. Xóa sách
    public int deleteById(Integer id) {
        String sql = """
            DELETE FROM [Books]
            WHERE [bookid] = ?
            """;

        return jdbcTemplate.update(sql, id);
    }
}