import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  int _currentStreak = 0;
  int _longestStreak = 0;
  int _totalDaysClean = 0;
  String _addictionType = '';
  List<Map<String, dynamic>> _weeklyCheckIns = [];
  bool _isLoading = true;
  
  final List<Achievement> _achievements = [
    Achievement(
      id: '1',
      title: 'First Day',
      description: 'Complete your first day',
      icon: Icons.flag,
      isUnlocked: true,
      unlockedDate: DateTime.now().subtract(const Duration(days: 14)),
    ),
    Achievement(
      id: '2',
      title: 'Week Warrior',
      description: '7 days streak',
      icon: Icons.calendar_today,
      isUnlocked: true,
      unlockedDate: DateTime.now().subtract(const Duration(days: 7)),
    ),
    Achievement(
      id: '3',
      title: 'Two Weeks Strong',
      description: '14 days streak',
      icon: Icons.fitness_center,
      isUnlocked: true,
      unlockedDate: DateTime.now(),
    ),
    Achievement(
      id: '4',
      title: 'Monthly Master',
      description: '30 days streak',
      icon: Icons.star,
      isUnlocked: false,
    ),
    Achievement(
      id: '5',
      title: 'Quarter Champion',
      description: '90 days streak',
      icon: Icons.military_tech,
      isUnlocked: false,
    ),
    Achievement(
      id: '6',
      title: 'Yearly Legend',
      description: '365 days streak',
      icon: Icons.emoji_events,
      isUnlocked: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProgress();
  }
  
  Future<void> _loadUserProgress() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.isAnonymous) {
        final doc = await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .get();
        
        if (doc.exists && mounted) {
          final data = doc.data()!;
          setState(() {
            _addictionType = data['addictionType'] ?? '';
            
            // Calculate streaks
            if (data['recoveryStartDate'] != null) {
              final startDate = (data['recoveryStartDate'] as Timestamp).toDate();
              _currentStreak = DateTime.now().difference(startDate).inDays;
              _totalDaysClean = _currentStreak;
            }
            
            _longestStreak = data['bestStreak'] ?? _currentStreak;
            
            // Update achievements based on streak
            _updateAchievements();
            
            _isLoading = false;
          });
          
          // Load weekly check-ins
          _loadWeeklyCheckIns();
        } else {
          // No user data yet, set default values
          if (mounted) {
            setState(() {
              _isLoading = false;
              _loadWeeklyCheckIns();
            });
          }
        }
      } else {
        // Guest user or not signed in
        if (mounted) {
          setState(() {
            _isLoading = false;
            _currentStreak = 0;
            _longestStreak = 0;
            _totalDaysClean = 0;
            _loadWeeklyCheckIns();
          });
        }
      }
    } catch (e) {
      print('Error loading progress: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  Future<void> _loadWeeklyCheckIns() async {
    // For now, generate sample data
    // In production, this would fetch actual check-in data from Firestore
    setState(() {
      _weeklyCheckIns = [
        {'day': 0, 'craving': 8, 'mood': 'Bad'},
        {'day': 1, 'craving': 6, 'mood': 'Neutral'},
        {'day': 2, 'craving': 7, 'mood': 'Neutral'},
        {'day': 3, 'craving': 4, 'mood': 'Good'},
        {'day': 4, 'craving': 5, 'mood': 'Neutral'},
        {'day': 5, 'craving': 3, 'mood': 'Good'},
        {'day': 6, 'craving': 2, 'mood': 'Good'},
      ];
    });
  }
  
  void _updateAchievements() {
    setState(() {
      _achievements[0].isUnlocked = _currentStreak >= 1;
      _achievements[1].isUnlocked = _currentStreak >= 7;
      _achievements[2].isUnlocked = _currentStreak >= 14;
      _achievements[3].isUnlocked = _currentStreak >= 30;
      _achievements[4].isUnlocked = _currentStreak >= 90;
      _achievements[5].isUnlocked = _currentStreak >= 365;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Progress'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'reset') {
                _showResetDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.refresh, size: 20),
                    SizedBox(width: 8),
                    Text('Reset Streak'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Overview
            _buildStatsOverview(),
            const SizedBox(height: 30),
            
            // Progress Chart
            _buildProgressChart(),
            const SizedBox(height: 30),
            
            // Achievements Section
            Text(
              'Achievements',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 15),
            _buildAchievements(),
            
            const SizedBox(height: 30),
            
            // Milestones Timeline
            Text(
              'Milestones',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 15),
            _buildMilestones(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsOverview() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Current Streak',
            value: '$_currentStreak',
            unit: 'days',
            icon: Icons.local_fire_department,
            color: AppTheme.primaryColor,
            gradient: AppTheme.primaryGradient,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _StatCard(
            title: 'Longest Streak',
            value: '$_longestStreak',
            unit: 'days',
            icon: Icons.trending_up,
            color: AppTheme.secondaryColor,
            gradient: LinearGradient(
              colors: [
                AppTheme.secondaryColor,
                AppTheme.secondaryColor.withOpacity(0.7),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }

  Widget _buildProgressChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Progress',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return Text(
                            days[value.toInt()],
                            style: const TextStyle(fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _weeklyCheckIns.map((checkIn) {
                      return FlSpot(
                        checkIn['day'].toDouble(),
                        checkIn['craving'].toDouble(),
                      );
                    }).toList(),
                    isCurved: true,
                    color: AppTheme.primaryColor,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: AppTheme.primaryColor,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.primaryColor.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Craving Level',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildAchievements() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1,
      ),
      itemCount: _achievements.length,
      itemBuilder: (context, index) {
        final achievement = _achievements[index];
        return GestureDetector(
          onTap: () {
            if (achievement.isUnlocked) {
              _showAchievementDetails(achievement);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: achievement.isUnlocked
                  ? AppTheme.primaryColor.withOpacity(0.1)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: achievement.isUnlocked
                    ? AppTheme.primaryColor.withOpacity(0.3)
                    : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  achievement.icon,
                  size: 32,
                  color: achievement.isUnlocked
                      ? AppTheme.primaryColor
                      : Colors.grey.shade400,
                ),
                const SizedBox(height: 8),
                Text(
                  achievement.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: achievement.isUnlocked
                        ? AppTheme.textPrimary
                        : Colors.grey.shade400,
                  ),
                ),
                if (!achievement.isUnlocked) ...[
                  const SizedBox(height: 4),
                  Icon(
                    Icons.lock,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                ],
              ],
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: 100 * index)),
        );
      },
    );
  }

  Widget _buildMilestones() {
    final milestones = [
      {'days': 1, 'title': 'First Day', 'completed': _currentStreak >= 1},
      {'days': 7, 'title': 'One Week', 'completed': _currentStreak >= 7},
      {'days': 14, 'title': 'Two Weeks', 'completed': _currentStreak >= 14},
      {'days': 30, 'title': 'One Month', 'completed': _currentStreak >= 30},
      {'days': 90, 'title': 'Three Months', 'completed': _currentStreak >= 90},
      {'days': 365, 'title': 'One Year', 'completed': _currentStreak >= 365},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: milestones.map((milestone) {
          final isCompleted = milestone['completed'] as bool;
          final days = milestone['days'] as int;
          final title = milestone['title'] as String;
          final isLast = milestones.last == milestone;

          return Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppTheme.successColor
                          : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            )
                          : Text(
                              '$days',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isCompleted
                                ? AppTheme.textPrimary
                                : AppTheme.textTertiary,
                          ),
                        ),
                        Text(
                          isCompleted
                              ? 'Completed!'
                              : '${days - _currentStreak} days to go',
                          style: TextStyle(
                            fontSize: 12,
                            color: isCompleted
                                ? AppTheme.successColor
                                : AppTheme.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isCompleted)
                    Icon(
                      Icons.emoji_events,
                      color: Colors.amber.shade600,
                      size: 24,
                    ),
                ],
              ),
              if (!isLast) ...[
                const SizedBox(height: 10),
                Container(
                  margin: const EdgeInsets.only(left: 20),
                  height: 30,
                  width: 2,
                  color: isCompleted
                      ? AppTheme.successColor.withOpacity(0.3)
                      : Colors.grey.shade300,
                ),
                const SizedBox(height: 10),
              ],
            ],
          );
        }).toList(),
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0);
  }

  void _showAchievementDetails(Achievement achievement) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  achievement.icon,
                  size: 48,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                achievement.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              Text(
                achievement.description,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Unlocked on ${_formatDate(achievement.unlockedDate!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Great!'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
  
  void _showResetDialog() {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to reset your progress'),
        ),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Streak?'),
        content: const Text(
          'This will reset your current streak to 0 days. Your longest streak record will be preserved. Are you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _resetStreak();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _resetStreak() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.isAnonymous) {
        // Update longest streak if current is higher
        if (_currentStreak > _longestStreak) {
          await _firestore
              .collection(AppConstants.usersCollection)
              .doc(user.uid)
              .update({
            'longestStreak': _currentStreak,
          });
        }
        
        // Reset current streak
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .update({
          'recoveryStartDate': FieldValue.serverTimestamp(),
          'currentStreak': 0,
        });
        
        // Reload data
        await _loadUserProgress();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Streak has been reset. Stay strong!'),
            ),
          );
        }
      }
    } catch (e) {
      print('Error resetting streak: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to reset streak. Please try again.'),
          ),
        );
      }
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final Gradient gradient;

  const _StatCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 5),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  unit,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  bool isUnlocked;
  final DateTime? unlockedDate;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    this.unlockedDate,
  });
}
