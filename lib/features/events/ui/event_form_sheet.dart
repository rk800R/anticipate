import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/tokens/app_tokens.dart';
import '../domain/models.dart';
import '../logic/event_book.dart';

/// Bottom sheet form for adding/editing events.
class EventFormSheet extends ConsumerStatefulWidget {
  final CalEvent? existingEvent;

  const EventFormSheet({
    Key? key,
    this.existingEvent,
  }) : super(key: key);

  @override
  ConsumerState<EventFormSheet> createState() => _EventFormSheetState();
}

class _EventFormSheetState extends ConsumerState<EventFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late DateTime _selectedDate;
  late EventKind _selectedKind;
  late EventColor _selectedColor;
  bool _isSaving = false;
  String? _error;

  // Color presets
  static const List<EventColor> _colorPresets = [
    EventColor.amber,
    EventColor.blue,
    EventColor.green,
    EventColor.purple,
    EventColor.red,
    EventColor.pink,
    EventColor.teal,
    EventColor.orange,
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existingEvent?.title ?? '');
    _selectedDate = widget.existingEvent?.date ?? DateTime.now();
    _selectedKind = widget.existingEvent?.kind ?? EventKind.once;
    _selectedColor = widget.existingEvent?.color ?? EventColor.defaultColor;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      final event = CalEvent(
        id: widget.existingEvent?.id ?? const Uuid().v4(),
        title: _titleController.text.trim(),
        date: _selectedDate,
        kind: _selectedKind,
        color: _selectedColor,
      );

      final eventBook = ref.read(eventBookProvider);
      final idempotencyKey = const Uuid().v4();

      if (widget.existingEvent == null) {
        await eventBook.add(event, idempotencyKey);
      } else {
        await eventBook.edit(event, idempotencyKey);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTokens.spacingLg),
      decoration: BoxDecoration(
        color: AppTokens.backgroundSecondary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTokens.spacingLg)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppTokens.spacingLg),
                  decoration: BoxDecoration(
                    color: AppTokens.textSecondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Title field
              TextFormField(
                controller: _titleController,
                style: AppTokens.bodyLarge,
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: AppTokens.bodyMedium,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTokens.spacingSm),
                  ),
                  errorStyle: AppTokens.bodyMedium.copyWith(
                    color: AppTokens.errorColor,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTokens.spacingMd),
              // Date picker
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(AppTokens.spacingSm),
                child: Padding(
                  padding: const EdgeInsets.all(AppTokens.spacingMd),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: AppTokens.textSecondary,
                      ),
                      const SizedBox(width: AppTokens.spacingMd),
                      Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: AppTokens.bodyLarge,
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_drop_down,
                        color: AppTokens.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTokens.spacingMd),
              // Kind selector
              DropdownButtonFormField<EventKind>(
                value: _selectedKind,
                dropdownColor: AppTokens.backgroundTertiary,
                style: AppTokens.bodyLarge,
                decoration: InputDecoration(
                  labelText: 'Event Type',
                  labelStyle: AppTokens.bodyMedium,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTokens.spacingSm),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: EventKind.once, child: Text('One-time')),
                  DropdownMenuItem(value: EventKind.yearly, child: Text('Yearly')),
                  DropdownMenuItem(value: EventKind.birthday, child: Text('Birthday')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedKind = value;
                    });
                  }
                },
              ),
              const SizedBox(height: AppTokens.spacingMd),
              // Color swatches
              Text(
                'Color',
                style: AppTokens.bodyMedium,
              ),
              const SizedBox(height: AppTokens.spacingSm),
              Wrap(
                spacing: AppTokens.spacingSm,
                runSpacing: AppTokens.spacingSm,
                children: _colorPresets.map((color) {
                  final isSelected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Color(color.value),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (_error != null) ...[
                const SizedBox(height: AppTokens.spacingMd),
                Text(
                  _error!,
                  style: AppTokens.bodyMedium.copyWith(color: AppTokens.errorColor),
                ),
              ],
              const SizedBox(height: AppTokens.spacingLg),
              // Save button
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTokens.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppTokens.spacingMd),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Save'),
              ),
              const SizedBox(height: AppTokens.spacingMd),
            ],
          ),
        ),
      ),
    );
  }
}
