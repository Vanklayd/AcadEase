import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/schedule_entry.dart' as models;
import 'models/assignment.dart' as models_assign;
import 'services/user_repository.dart';
import 'package:intl/intl.dart';

class AddSchedulePage extends StatefulWidget {
  const AddSchedulePage({super.key});

  @override
  State<AddSchedulePage> createState() => _AddSchedulePageState();
}

class _AddSchedulePageState extends State<AddSchedulePage> {
  String selectedReminder = '15 mins before class';
  List<String> selectedDays = ['M', 'W', 'F'];
  String selectedPriority = 'High';
  bool notificationsEnabled = true;
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _profRoomController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _assignmentTitleController =
      TextEditingController();
  final TextEditingController _assignmentDescController =
      TextEditingController();
  final TextEditingController _assignmentDueController =
      TextEditingController();
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back_ios, size: 20),
                  ),
                  Expanded(
                    child: Text(
                      'Add Schedule',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                ],
              ),
            ),
            Divider(height: 1, thickness: 1, color: Colors.grey[300]),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subject Details
                    Text(
                      'Subject Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Subject Name',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _subjectController,
                      decoration: InputDecoration(
                        hintText: 'Introduction to React Native',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Professor / Room',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _profRoomController,
                      decoration: InputDecoration(
                        hintText: 'Prof. A. Smith / Room 201',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                    // Time & Days
                    Text(
                      'Time & Days',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Start Date',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              TextField(
                                controller: _startDateController,
                                decoration: InputDecoration(
                                  hintText: '09/04/2024',
                                  suffixIcon: Icon(
                                    Icons.calendar_today,
                                    size: 20,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'End Date',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              TextField(
                                controller: _endDateController,
                                decoration: InputDecoration(
                                  hintText: '12/15/2024',
                                  suffixIcon: Icon(
                                    Icons.calendar_today,
                                    size: 20,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Start Time',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              TextField(
                                controller: _startTimeController,
                                decoration: InputDecoration(
                                  hintText: '10:00 AM',
                                  suffixIcon: Icon(Icons.access_time, size: 20),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'End Time',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              TextField(
                                controller: _endTimeController,
                                decoration: InputDecoration(
                                  hintText: '11:30 AM',
                                  suffixIcon: Icon(Icons.access_time, size: 20),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Days of Week',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildDayButton('M'),
                        SizedBox(width: 8),
                        _buildDayButton('T'),
                        SizedBox(width: 8),
                        _buildDayButton('W'),
                        SizedBox(width: 8),
                        _buildDayButton('T'),
                        SizedBox(width: 8),
                        _buildDayButton('F'),
                        SizedBox(width: 8),
                        _buildDayButton('S'),
                        SizedBox(width: 8),
                        _buildDayButton('S'),
                      ],
                    ),
                    SizedBox(height: 32),
                    // Reminders
                    Text(
                      'Reminders',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildReminderOption('15 mins before class'),
                    SizedBox(height: 12),
                    _buildReminderOption('30 mins before class'),
                    SizedBox(height: 12),
                    _buildReminderOption('1 hour before class'),
                    SizedBox(height: 12),
                    _buildReminderOption('Custom Time'),
                    SizedBox(height: 32),
                    // Assignment Details
                    Text(
                      'Assignment Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Assignment Title',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _assignmentTitleController,
                      decoration: InputDecoration(
                        hintText: 'Mobile App Project Proposal',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _assignmentDescController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText:
                            'Outline the concept, features, and\ntechnology stack for the final project.',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Due Date',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _assignmentDueController,
                      decoration: InputDecoration(
                        hintText: '10/20/2024',
                        suffixIcon: Icon(Icons.calendar_today, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Priority',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        value: selectedPriority,
                        isExpanded: true,
                        underline: SizedBox(),
                        items: ['High', 'Medium', 'Low'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedPriority = newValue!;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 24),
                    // Enable Notifications
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Enable Notifications',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Switch(
                          value: notificationsEnabled,
                          onChanged: (bool value) {
                            setState(() {
                              notificationsEnabled = value;
                            });
                          },
                          activeColor: Color(0xFF03A9F4),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    // Add new assignment link
                    GestureDetector(
                      onTap: () {
                        // Focus assignment title for quick add
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                      child: Text(
                        '+ Add new assignment',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF03A9F4),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    // Save Schedule Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_isSaving) return;
                          final user = FirebaseAuth.instance.currentUser;
                          if (user == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Please sign in first')),
                            );
                            return;
                          }

                          // Basic validation
                          if (_startDateController.text.trim().isEmpty ||
                              _endDateController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Please enter start and end dates (MM/dd/yyyy)',
                                ),
                              ),
                            );
                            return;
                          }

                          setState(() {
                            _isSaving = true;
                          });

                          try {
                            String subject =
                                _subjectController.text.trim().isEmpty
                                ? 'Untitled Subject'
                                : _subjectController.text.trim();
                            String profRoom = _profRoomController.text.trim();

                            DateTime startDate = DateFormat(
                              'MM/dd/yyyy',
                            ).parse(_startDateController.text.trim());
                            DateTime endDate = DateFormat(
                              'MM/dd/yyyy',
                            ).parse(_endDateController.text.trim());

                            final entry = models.ScheduleEntry(
                              id: '',
                              title: subject,
                              instructor: profRoom,
                              location: profRoom,
                              startDate: startDate,
                              endDate: endDate,
                              startTime: _startTimeController.text.trim(),
                              endTime: _endTimeController.text.trim(),
                              days: selectedDays,
                              tag: selectedReminder,
                              note: null,
                            );

                            await UserRepository.instance.addScheduleEntry(
                              user.uid,
                              entry,
                            );

                            // If assignment title present, save assignment
                            if (_assignmentTitleController.text
                                .trim()
                                .isNotEmpty) {
                              DateTime due = DateFormat(
                                'MM/dd/yyyy',
                              ).parse(_assignmentDueController.text.trim());
                              final assignment = models_assign.AssignmentItem(
                                id: '',
                                title: _assignmentTitleController.text.trim(),
                                description: _assignmentDescController.text
                                    .trim(),
                                dueDate: due,
                                priority: selectedPriority,
                                notificationsEnabled: notificationsEnabled,
                              );
                              await UserRepository.instance.addAssignment(
                                user.uid,
                                assignment,
                              );
                            }

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text('Saved')));
                            Navigator.pop(context, true);
                          } on FormatException catch (_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Invalid date format. Use MM/dd/yyyy',
                                ),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Failed to save: ${e.toString()}',
                                ),
                              ),
                            );
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isSaving = false;
                              });
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF03A9F4),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Save Schedule',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayButton(String day) {
    bool isSelected = selectedDays.contains(day);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedDays.remove(day);
          } else {
            selectedDays.add(day);
          }
        });
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF03A9F4) : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Color(0xFF03A9F4) : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            day,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReminderOption(String reminder) {
    bool isSelected = selectedReminder == reminder;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedReminder = reminder;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Color(0xFF03A9F4) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? Color(0xFF03A9F4).withOpacity(0.05)
              : Colors.white,
        ),
        child: Text(
          reminder,
          style: TextStyle(
            fontSize: 14,
            color: isSelected ? Color(0xFF03A9F4) : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
