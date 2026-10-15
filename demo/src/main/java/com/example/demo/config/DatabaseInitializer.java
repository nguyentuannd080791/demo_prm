package com.example.demo.config;

import com.example.demo.model.Book;
import com.example.demo.repository.BookRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.util.List;

@Component
public class DatabaseInitializer implements CommandLineRunner {

    private final BookRepository bookRepository;

    public DatabaseInitializer(BookRepository bookRepository) {
        this.bookRepository = bookRepository;
    }

    @Override
    public void run(String... args) {
        List<Book> existingBooks = bookRepository.findAll();
        if (existingBooks.size() >= 15) {
            System.out.println("Cơ sở dữ liệu đã có " + existingBooks.size() + " cuốn sách. Bỏ qua khởi tạo mẫu.");
            return;
        }

        System.out.println("Đang bổ sung danh sách 18 cuốn sách mẫu đa dạng vào cơ sở dữ liệu...");

        List<Book> sampleBooks = List.of(
            new Book(
                null,
                "Clean Code: A Handbook of Agile Software Craftsmanship",
                BigDecimal.valueOf(185000),
                "Robert C. Martin",
                "NXB Thông tin và Truyền thông",
                "Cuốn sách kinh điển hướng dẫn các quy chuẩn viết mã nguồn sạch, dễ đọc, dễ bảo trì và mở rộng.",
                true
            ),
            new Book(
                null,
                "Design Patterns: Elements of Reusable Object-Oriented Software",
                BigDecimal.valueOf(220000),
                "Gang of Four (GoF)",
                "NXB Khoa học và Kỹ thuật",
                "Bộ cẩm nang mẫu thiết kế phần mềm hướng đối tượng nền tảng cho mọi kỹ sư phần mềm.",
                true
            ),
            new Book(
                null,
                "The Pragmatic Programmer: Your Journey To Mastery",
                BigDecimal.valueOf(195000),
                "Andrew Hunt, David Thomas",
                "NXB Thế Giới",
                "Tập hợp các bài học thực tế, tư duy kiến trúc và kỹ năng cốt lõi của một lập trình viên chuyên nghiệp.",
                true
            ),
            new Book(
                null,
                "Refactoring: Improving the Design of Existing Code",
                BigDecimal.valueOf(210000),
                "Martin Fowler",
                "NXB Đại học Quốc gia",
                "Phương pháp cải tiến và tái cấu trúc mã nguồn an toàn mà không làm thay đổi hành vi bên ngoài.",
                true
            ),
            new Book(
                null,
                "Nhà Giả Kim (The Alchemist)",
                BigDecimal.valueOf(79000),
                "Paulo Coelho",
                "NXB Hội Nhà Văn",
                "Câu chuyện ngụ ngôn tuyệt đẹp về hành trình đi tìm vận mệnh và lắng nghe tiếng gọi từ con tim.",
                true
            ),
            new Book(
                null,
                "Hoàng Tử Bé (Le Petit Prince)",
                BigDecimal.valueOf(55000),
                "Antoine de Saint-Exupéry",
                "NXB Kim Đồng",
                "Tác phẩm văn học kinh điển nuôi dưỡng tâm hồn, góc nhìn sâu sắc về tình bạn, tình yêu và cuộc sống.",
                true
            ),
            new Book(
                null,
                "Dế Mèn Phiêu Lưu Ký",
                BigDecimal.valueOf(45000),
                "Tô Hoài",
                "NXB Kim Đồng",
                "Tác phẩm thiếu nhi bất hủ của văn học Việt Nam về tình bạn, lòng quả cảm và khát vọng tự do.",
                true
            ),
            new Book(
                null,
                "Chiến Tranh và Hòa Bình",
                BigDecimal.valueOf(260000),
                "Lev Tolstoy",
                "NXB Văn Học",
                "Thiên anh hùng ca vĩ đại mô tả cuộc sống nước Nga trong giai đoạn kháng chiến chống Napoleon.",
                true
            ),
            new Book(
                null,
                "Đắc Nhân Tâm",
                BigDecimal.valueOf(86000),
                "Dale Carnegie",
                "NXB Tổng hợp TP.HCM",
                "Nghệ thuật giao tiếp, thấu hiểu lòng người và xây dựng các mối quan hệ bền vững trong cuộc đời.",
                true
            ),
            new Book(
                null,
                "Nghĩ Giàu và Làm Giàu (Think and Grow Rich)",
                BigDecimal.valueOf(110000),
                "Napoleon Hill",
                "NXB Trẻ",
                "13 nguyên tắc thành công được đúc kết từ các doanh nhân hàng đầu thế giới trong nhiều thập kỷ.",
                true
            ),
            new Book(
                null,
                "Atomic Habits - Thay Đổi Tí Hon, Hiệu Quả Bất Ngờ",
                BigDecimal.valueOf(149000),
                "James Clear",
                "NXB Thế Giới",
                "Phương pháp khoa học xây dựng thói quen tốt và loại bỏ thói quen xấu từng bước mỗi ngày.",
                true
            ),
            new Book(
                null,
                "Cha Giàu Cha Nghèo (Rich Dad Poor Dad)",
                BigDecimal.valueOf(125000),
                "Robert T. Kiyosaki",
                "NXB Trẻ",
                "Tư duy tài chính cá nhân đột phá, định nghĩa tài sản - tiêu sản và hành trình đạt tự do tài chính.",
                true
            ),
            new Book(
                null,
                "Tư Duy Nhanh và Chậm (Thinking, Fast and Slow)",
                BigDecimal.valueOf(198000),
                "Daniel Kahneman",
                "NXB Thế Giới",
                "Khám phá hai hệ thống tư duy chi phối cách con người đưa ra quyết định hàng ngày.",
                true
            ),
            new Book(
                null,
                "Kinh Tế Học Hài Hước (Freakonomics)",
                BigDecimal.valueOf(135000),
                "Steven D. Levitt, Stephen J. Dubner",
                "NXB Lao Động",
                "Góc nhìn dí dỏm và độc đáo lý giải những hiện tượng xã hội thông qua các quy luật kinh tế học.",
                true
            ),
            new Book(
                null,
                "Lược Sử Thời Gian (A Brief History of Time)",
                BigDecimal.valueOf(115000),
                "Stephen Hawking",
                "NXB Trẻ",
                "Khám phá các bí ẩn của vũ trụ từ vụ nổ Big Bang, không - thời gian đến lỗ đen bí ẩn.",
                true
            ),
            new Book(
                null,
                "Sapiens: Lược Sử Loài Người",
                BigDecimal.valueOf(189000),
                "Yuval Noah Harari",
                "NXB Tri Thức",
                "Bức tranh toàn cảnh về tiến trình phát triển của nhân loại từ thời kỳ đồ đá đến kỷ nguyên hiện đại.",
                true
            ),
            new Book(
                null,
                "Gen: Lược Sử Và Tương Lai Của Nhân Loại",
                BigDecimal.valueOf(215000),
                "Siddhartha Mukherjee",
                "NXB Dân Trí",
                "Lịch sử ngành di truyền học và những tác động to lớn của công nghệ chỉnh sửa gen đối với tương lai.",
                true
            ),
            new Book(
                null,
                "Trí Tuệ Nhân Tạo: Kỷ Nguyên Mới",
                BigDecimal.valueOf(168000),
                "Kai-Fu Lee",
                "NXB Trẻ",
                "Tác động sâu rộng của trí tuệ nhân tạo đến nền kinh tế, thị trường lao động và cuộc sống con người.",
                true
            )
        );

        for (Book b : sampleBooks) {
            try {
                bookRepository.save(b);
            } catch (Exception e) {
                System.err.println("Lỗi khi thêm sách: " + b.getBookname() + " -> " + e.getMessage());
            }
        }

        System.out.println("Đã thêm thành công các cuốn sách mẫu vào CSDL.");
    }
}
