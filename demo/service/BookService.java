package com.example.demo.service;

import com.example.demo.model.Book;
import com.example.demo.repository.BookRepository;

import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;

@Service
public class BookService {

    private final BookRepository bookRepository;

    public BookService(BookRepository bookRepository) {
        this.bookRepository = bookRepository;
    }

    public List<Book> findAll() {
        return bookRepository.findAll();
    }

    public Book findById(Integer id) {
        validateId(id);

        return bookRepository.findById(id)
            .orElseThrow(() ->
                new BookNotFoundException(
                    "Không tìm thấy sách có ID = " + id
                )
            );
    }

    public Book create(Book book) {
        validateBook(book);

        // bookid do database tự sinh
        book.setBookid(null);

        int id = bookRepository.save(book);
        return findById(id);
    }

    public Book update(Integer id, Book book) {
        validateId(id);
        validateBook(book);

        if (bookRepository.findById(id).isEmpty()) {
            throw new BookNotFoundException(
                "Không tìm thấy sách có ID = " + id
            );
        }

        bookRepository.update(id, book);
        return findById(id);
    }

    public void delete(Integer id) {
        validateId(id);

        if (bookRepository.findById(id).isEmpty()) {
            throw new BookNotFoundException(
                "Không tìm thấy sách có ID = " + id
            );
        }

        bookRepository.deleteById(id);
    }

    private void validateId(Integer id) {
        if (id == null || id <= 0) {
            throw new IllegalArgumentException(
                "bookid phải là số nguyên dương."
            );
        }
    }

    private void validateBook(Book book) {
        if (book == null) {
            throw new IllegalArgumentException(
                "Thông tin sách không được để trống."
            );
        }

        if (book.getBookname() == null
                || book.getBookname().isBlank()) {
            throw new IllegalArgumentException(
                "Tên sách không được để trống."
            );
        }

        if (book.getBookname().trim().length() < 2) {
            throw new IllegalArgumentException(
                "Tên sách phải có ít nhất 2 ký tự."
            );
        }

        if (book.getPrice() == null
                || book.getPrice().compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException(
                "Giá sách phải lớn hơn hoặc bằng 0."
            );
        }

        if (book.getAuthor() == null
                || book.getAuthor().isBlank()) {
            throw new IllegalArgumentException(
                "Tác giả không được để trống."
            );
        }

        if (book.getPublisher() == null
                || book.getPublisher().isBlank()) {
            throw new IllegalArgumentException(
                "Nhà xuất bản không được để trống."
            );
        }

        if (book.getSummary() == null
                || book.getSummary().isBlank()) {
            throw new IllegalArgumentException(
                "Tóm tắt sách không được để trống."
            );
        }

        book.setBookname(book.getBookname().trim());
        book.setAuthor(book.getAuthor().trim());
        book.setPublisher(book.getPublisher().trim());
        book.setSummary(book.getSummary().trim());
    }
}