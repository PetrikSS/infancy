import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';

class EditItemScreen extends StatefulWidget {
  final dynamic item;
  final String itemType;

  const EditItemScreen({
    super.key,
    required this.item,
    required this.itemType,
  });

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  final _dateController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    _titleController.text = widget.item.title;
    _categoryController.text = widget.item.category ?? '';
    _descriptionController.text = widget.item.description ?? '';

    if (widget.item.date != null) {
      _dateController.text = DateFormat('yyyy-MM-dd').format(widget.item.date!);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: widget.item.date ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      _dateController.text = DateFormat('yyyy-MM-dd').format(date);
    }
  }

  Future<void> _handleSave() async {
    if (_titleController.text.isEmpty) {
      _showError('Введите название');
      return;
    }

    setState(() => _isLoading = true);

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    try {
      // Используем метод updateTask из TaskProvider вместо прямого доступа к Supabase
      final error = await taskProvider.updateTask(
        taskId: widget.item.id,
        title: _titleController.text,
        category: _categoryController.text.isNotEmpty ? _categoryController.text : null,
        description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
        date: _dateController.text.isNotEmpty ? DateTime.parse(_dateController.text) : null,
      );

      if (error != null) {
        _showError(error);
      } else {
        if (mounted) {
          Navigator.pop(context);
        }
      }

    } catch (e) {
      _showError('Ошибка обновления: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _getAppBarTitle() {
    switch (widget.itemType) {
      case 'task':
        return 'Редактировать задачу';
      case 'purchase':
        return 'Редактировать покупку';
      case 'wish':
        return 'Редактировать желание';
      default:
        return 'Редактировать';
    }
  }

  String _getScreenTitle() {
    switch (widget.itemType) {
      case 'task':
        return 'Редактировать задачу';
      case 'purchase':
        return 'Редактировать покупку';
      case 'wish':
        return 'Редактировать желание';
      default:
        return 'Редактировать';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Назад',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _getScreenTitle(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _CustomTextField(
              controller: _titleController,
              hint: 'Название',
            ),
            const SizedBox(height: 16),
            if (widget.itemType == 'task' || widget.itemType == 'wish')
              GestureDetector(
                onTap: _selectDate,
                child: AbsorbPointer(
                  child: _CustomTextField(
                    controller: _dateController,
                    hint: 'Дата',
                  ),
                ),
              ),
            if (widget.itemType == 'task' || widget.itemType == 'wish')
              const SizedBox(height: 16),
            _CustomTextField(
              controller: _descriptionController,
              hint: 'Описание',
              maxLines: 1,
            ),
            const SizedBox(height: 40),
            _GradientButton(
              text: 'Сохранить',
              onPressed: _isLoading ? () {} : _handleSave,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  const _CustomTextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(28),
      ),
      child: TextField(
        controller: controller,
        cursorColor: Color(0xFFFFB2B2),
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black38),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const _GradientButton({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFC0CB), Color(0xFFFFD4A3)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(28),
          child: Center(
            child: isLoading
                ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}