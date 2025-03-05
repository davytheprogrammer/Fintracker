import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'relapsehistory.dart';

class RelapseFormScreen extends StatefulWidget {
  @override
  _RelapseFormScreenState createState() => _RelapseFormScreenState();
}

class _RelapseFormScreenState extends State<RelapseFormScreen> {
  final PageController _pageController = PageController();
  final List<String> _answers = List.filled(7, '');
  int _currentPage = 0;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What emotions were you experiencing before the relapse?',
      'type': 'multiSelect',
      'options': ['Stress', 'Loneliness', 'Boredom', 'Anger', 'Anxiety', 'Joy', 'Other'],
    },
    {
      'question': 'Where were you when the urge started?',
      'type': 'text',
      'hint': 'Describe your environment...',
    },
    {
      'question': 'Were you alone or with others?',
      'type': 'radio',
      'options': ['Alone', 'With friends', 'With family', 'With strangers'],
    },
    {
      'question': 'What triggers did you notice?',
      'type': 'text',
      'hint': 'Describe any triggers you noticed...',
    },
    {
      'question': 'Did you try any coping strategies?',
      'type': 'multiSelect',
      'options': ['Deep breathing', 'Called someone', 'Went for a walk', 'Meditation', 'None', 'Other'],
    },
    {
      'question': 'How strong was the urge? (1-10)',
      'type': 'slider',
      'min': 1,
      'max': 10,
    },
    {
      'question': 'What could you do differently next time?',
      'type': 'text',
      'hint': 'Share your thoughts...',
    },
  ];

  Widget _buildQuestionWidget(Map<String, dynamic> question, int index) {
    switch (question['type']) {
      case 'text':
        return TextField(
          onChanged: (value) => _answers[index] = value,
          decoration: InputDecoration(
            hintText: question['hint'],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          maxLines: 4,
          style: GoogleFonts.poppins(),
        );
      case 'multiSelect':
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: question['options'].map<Widget>((option) {
            final List<String> selectedOptions =
            _answers[index].split(',').where((e) => e.isNotEmpty).toList();
            return FilterChip(
              label: Text(option),
              selected: selectedOptions.contains(option),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedOptions.add(option);
                  } else {
                    selectedOptions.remove(option);
                  }
                  _answers[index] = selectedOptions.join(',');
                });
              },
            );
          }).toList(),
        );
      case 'radio':
        return Column(
          children: question['options'].map<Widget>((option) {
            return RadioListTile(
              title: Text(option),
              value: option,
              groupValue: _answers[index],
              onChanged: (value) {
                setState(() {
                  _answers[index] = value.toString();
                });
              },
            );
          }).toList(),
        );
      case 'slider':
        return Column(
          children: [
            Text(
              _answers[index].isEmpty ? '5' : _answers[index],
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Slider(
              value: double.tryParse(_answers[index]) ?? 5,
              min: question['min'].toDouble(),
              max: question['max'].toDouble(),
              divisions: 9,
              onChanged: (value) {
                setState(() {
                  _answers[index] = value.toString();
                });
              },
            ),
          ],
        );
      default:
        return Container();
    }
  }

  Future<void> _saveRelapseData() async {
    final prefs = await SharedPreferences.getInstance();
    final relapseData = {
      'timestamp': DateTime.now().toIso8601String(),
      'answers': _answers,
      'questions': _questions.map((q) => q['question']).toList(),
    };

    List<String> existingRelapses =
        prefs.getStringList('relapses') ?? [];
    existingRelapses.add(jsonEncode(relapseData));
    await prefs.setStringList('relapses', existingRelapses);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Understanding Relapse',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[900],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentPage + 1) / _questions.length,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[900]!),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _questions.length,
              onPageChanged: (page) {
                setState(() => _currentPage = page);
              },
              itemBuilder: (context, index) {
                return SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Question ${index + 1} of ${_questions.length}',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _questions[index]['question'],
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                      SizedBox(height: 24),
                      _buildQuestionWidget(_questions[index], index),
                    ],
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    ElevatedButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text('Previous'),
                    )
                  else
                    SizedBox(width: 0),
                  ElevatedButton(
                    onPressed: () async {
                      if (_currentPage < _questions.length - 1) {
                        _pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        await _saveRelapseData();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RelapseHistoryScreen(),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      _currentPage == _questions.length - 1
                          ? 'Submit'
                          : 'Next',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}