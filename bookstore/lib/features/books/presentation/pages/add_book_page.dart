import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/error/app_exception.dart';
import '../providers/add_book_controller.dart';
import '../providers/book_provider.dart';
import '../widgets/book_basic_info_card.dart';
import '../widgets/book_status_card.dart';
import '../widgets/submit_book_button.dart';

/// Trang tạo sách mới
/// Áp dụng SOLID: Tách biệt logic sang [AddBookController] và giao diện thành các Widget chuyên biệt
class AddBookPage extends StatefulWidget {
  const AddBookPage({super.key});

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  late final AddBookController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AddBookController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    try {
      final bookProvider = context.read<BookProvider>();
      final book = await _controller.submit(bookProvider);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Đã thêm thành công sách "${book.bookName}"!'),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pop(true);
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Thêm sách thất bại: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm sách mới'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BookBasicInfoCard(
                  nameController: _controller.nameController,
                  authorController: _controller.authorController,
                  publisherController: _controller.publisherController,
                  priceController: _controller.priceController,
                  summaryController: _controller.summaryController,
                ),
                const SizedBox(height: 16),
                ListenableBuilder(
                  listenable: _controller,
                  builder: (context, _) => BookStatusCard(
                    status: _controller.status,
                    onChanged: _controller.setStatus,
                  ),
                ),
                const SizedBox(height: 24),
                ListenableBuilder(
                  listenable: _controller,
                  builder: (context, _) => SubmitBookButton(
                    isSubmitting: _controller.isSubmitting,
                    onPressed: _handleSubmit,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
