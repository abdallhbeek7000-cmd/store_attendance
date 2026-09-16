import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  DateTime _getStartOfWeek(DateTime date) {
    int daysToSubtract = (date.weekday - DateTime.friday + 7) % 7;
    DateTime start = date.subtract(Duration(days: daysToSubtract));
    return DateTime(start.year, start.month, start.day, 0, 0, 0);
  }

  DateTime _getEndOfWeek(DateTime startOfWeek) {
    DateTime end = startOfWeek.add(const Duration(days: 6));
    return DateTime(end.year, end.month, end.day, 23, 59, 59);
  }

  String _formatMinutes(int totalMinutes) {
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;

    if (hours == 0) {
      return "$minutes دقيقة";
    } else if (minutes == 0) {
      return "$hours ساعات";
    } else {
      return "$hours ساعات و $minutes د";
    }
  }

  void _showAddOrEditEmployeeDialog({
    String? docId,
    String? currentName,
    String? currentPin,
    double? currentWeeklySalary,
    double? currentDailyHours,
  }) {
    String name = currentName ?? "";
    String pin = currentPin ?? "";
    String salaryStr = currentWeeklySalary != null && currentWeeklySalary > 0 ? currentWeeklySalary.toString() : "";
    String hoursStr = currentDailyHours != null && currentDailyHours > 0 ? currentDailyHours.toString() : "8";

    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.85),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(docId == null ? 'إضافة موظف جديد' : 'تعديل بيانات الموظف', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: name,
                  decoration: InputDecoration(labelText: 'اسم الموظف', filled: true, fillColor: Colors.white.withOpacity(0.5), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
                  onChanged: (val) => name = val,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: pin,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  decoration: InputDecoration(labelText: 'الرمز السري (PIN)', filled: true, fillColor: Colors.white.withOpacity(0.5), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
                  onChanged: (val) => pin = val,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: salaryStr,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: 'الراتب الأسبوعي (لـ 6 أيام)', filled: true, fillColor: Colors.white.withOpacity(0.5), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
                  onChanged: (val) => salaryStr = val,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: hoursStr,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: 'ساعات الوردية اليومية (مثلاً: 8)', filled: true, fillColor: Colors.white.withOpacity(0.5), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
                  onChanged: (val) => hoursStr = val,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.tealAccent.shade700, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () async {
                double parsedSalary = double.tryParse(salaryStr) ?? 0.0;
                double parsedHours = double.tryParse(hoursStr) ?? 8.0;

                if (name.isNotEmpty && pin.length == 4) {
                  if (docId == null) {
                    await FirebaseFirestore.instance.collection('employees').add({
                      'name': name,
                      'pin': pin,
                      'weeklyBaseSalary': parsedSalary,
                      'dailyShiftHours': parsedHours,
                      'isCheckedIn': false,
                    });
                  } else {
                    await FirebaseFirestore.instance.collection('employees').doc(docId).update({
                      'name': name,
                      'pin': pin,
                      'weeklyBaseSalary': parsedSalary,
                      'dailyShiftHours': parsedHours,
                    });
                  }
                  Navigator.pop(context);
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.2))),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white), onPressed: () => Navigator.pop(context)),
                              const Text('لوحة تحكم الإدارة', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              const Icon(Icons.admin_panel_settings, color: Colors.tealAccent),
                            ],
                          ),
                          TabBar(
                            controller: _tabController,
                            indicatorColor: Colors.tealAccent,
                            labelColor: Colors.tealAccent,
                            unselectedLabelColor: Colors.white60,
                            dividerColor: Colors.transparent,
                            tabs: const [
                              Tab(icon: Icon(Icons.payments), text: 'الأسبوع'),
                              Tab(icon: Icon(Icons.folder_shared), text: 'الأرشيف'),
                              Tab(icon: Icon(Icons.people), text: 'العمال'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCurrentWeekTab(),
                    _buildArchiveEmployeesListTab(),
                    _buildEmployeeManagementTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.tealAccent.shade700,
        onPressed: () => _showAddOrEditEmployeeDialog(),
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('إضافة موظف', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildCurrentWeekTab() {
    DateTime now = DateTime.now();
    DateTime startOfWeek = _getStartOfWeek(now);
    DateTime endOfWeek = _getEndOfWeek(startOfWeek);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('attendance_logs').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.tealAccent));
        }

        final logs = snapshot.data?.docs ?? [];
        Map<String, int> employeeMinutes = {};

        for (var log in logs) {
          final data = log.data() as Map<String, dynamic>;
          if (data['shiftDate'] != null) {
            DateTime shiftDate = (data['shiftDate'] as Timestamp).toDate();
            if (shiftDate.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) && shiftDate.isBefore(endOfWeek)) {
              String empName = data['employeeName'] ?? 'غير معروف';
              int mins = data['durationMinutes'] ?? 0;
              employeeMinutes[empName] = (employeeMinutes[empName] ?? 0) + mins;
            }
          }
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('employees').snapshots(),
          builder: (context, empSnapshot) {
            final employees = empSnapshot.data?.docs ?? [];
            double totalWeeklyPayout = 0.0;

            for (var empDoc in employees) {
              final empData = empDoc.data() as Map<String, dynamic>;
              String name = empData['name'] ?? '';
              double weeklyBaseSalary = (empData['weeklyBaseSalary'] ?? 0.0).toDouble();
              double dailyShiftHours = (empData['dailyShiftHours'] ?? 8.0).toDouble();

              double dailyRate = weeklyBaseSalary / 6.0;
              double hourlyRate = dailyShiftHours > 0 ? dailyRate / dailyShiftHours : 0.0;
              int mins = employeeMinutes[name] ?? 0;

              totalWeeklyPayout += (mins / 60.0) * hourlyRate;
            }

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.teal.withOpacity(0.15), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.tealAccent.withOpacity(0.3))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('الأسبوع الحالي (${startOfWeek.day}/${startOfWeek.month} - ${endOfWeek.day}/${endOfWeek.month})', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 8),
                          Text('المطلوب للتسليم: ${totalWeeklyPayout.toStringAsFixed(2)}', style: const TextStyle(color: Colors.tealAccent, fontSize: 26, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (employees.isEmpty)
                  const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('لا يوجد موظفين مضافين حالياً.', style: TextStyle(color: Colors.white70))))
                else
                  ...employees.map((empDoc) {
                    final empData = empDoc.data() as Map<String, dynamic>;
                    String name = empData['name'] ?? '';
                    double weeklyBaseSalary = (empData['weeklyBaseSalary'] ?? 0.0).toDouble();
                    double dailyShiftHours = (empData['dailyShiftHours'] ?? 8.0).toDouble();

                    double dailyRate = weeklyBaseSalary / 6.0;
                    double hourlyRate = dailyShiftHours > 0 ? dailyRate / dailyShiftHours : 0.0;
                    int mins = employeeMinutes[name] ?? 0;
                    double salary = (mins / 60.0) * hourlyRate;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.15))),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                    Text('المبلغ: ${salary.toStringAsFixed(2)}', style: const TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                                  ],
                                ),
                                Divider(color: Colors.white.withOpacity(0.15), height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('الدوام: ${_formatMinutes(mins)}', style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                                    Text('اليومية: ${dailyRate.toStringAsFixed(1)} (الساعة: ${hourlyRate.toStringAsFixed(1)})', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildArchiveEmployeesListTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('employees').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.tealAccent));
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('لا يوجد موظفين لعرض أرشيفهم.', style: TextStyle(color: Colors.white70)));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final empDoc = docs[index];
            final emp = empDoc.data() as Map<String, dynamic>;
            String empName = emp['name'] ?? '';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.15))),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(backgroundColor: Colors.tealAccent.withOpacity(0.2), child: const Icon(Icons.folder_open, color: Colors.tealAccent)),
                      title: Text(empName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: const Text('عرض السجلات الأسبوعية وتأكيد الرواتب', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.tealAccent),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EmployeeArchiveDetailScreen(
                              employeeName: empName,
                              employeeDoc: empDoc,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmployeeManagementTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('employees').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.tealAccent));
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('اضغط على "إضافة موظف" لإنشاء أول موظف.', style: TextStyle(color: Colors.white70)));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final docId = doc.id;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.15))),
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(data['name'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text('PIN: ${data['pin']} | الراتب: ${data['weeklyBaseSalary']}', style: const TextStyle(color: Colors.white54)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.tealAccent),
                            onPressed: () => _showAddOrEditEmployeeDialog(
                              docId: docId,
                              currentName: data['name'],
                              currentPin: data['pin'],
                              currentWeeklySalary: (data['weeklyBaseSalary'] ?? 0.0).toDouble(),
                              currentDailyHours: (data['dailyShiftHours'] ?? 8.0).toDouble(),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () async {
                              await FirebaseFirestore.instance.collection('employees').doc(docId).delete();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// -------------------------------------------------------------
// شاشة أرشيف الموظف (يدعم إضافة المكافأة وتعديل عملية التسديد)
// -------------------------------------------------------------
// -------------------------------------------------------------
// شاشة أرشيف الموظف بتصميم Liquid Glass متناسق وبدون تداخل
// -------------------------------------------------------------
class EmployeeArchiveDetailScreen extends StatelessWidget {
  final String employeeName;
  final QueryDocumentSnapshot employeeDoc;

  const EmployeeArchiveDetailScreen({
    super.key,
    required this.employeeName,
    required this.employeeDoc,
  });

  String _getDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday: return 'الإثنين';
      case DateTime.tuesday: return 'الثلاثاء';
      case DateTime.wednesday: return 'الأربعاء';
      case DateTime.thursday: return 'الخميس';
      case DateTime.friday: return 'الجمعة';
      case DateTime.saturday: return 'السبت';
      case DateTime.sunday: return 'الأحد';
      default: return '';
    }
  }

  String _formatTime(DateTime dt) {
    String hour = dt.hour.toString().padLeft(2, '0');
    String minute = dt.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  String _formatMinutes(int totalMinutes) {
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;

    if (hours == 0) {
      return "$minutes دقيقة";
    } else if (minutes == 0) {
      return "$hours ساعات";
    } else {
      return "$hours ساعات و $minutes د";
    }
  }

  Map<String, List<QueryDocumentSnapshot>> _groupLogsByWeek(List<QueryDocumentSnapshot> docs) {
    Map<String, List<QueryDocumentSnapshot>> grouped = {};

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['shiftDate'] != null) {
        DateTime shiftDate = (data['shiftDate'] as Timestamp).toDate();

        int daysToSubtract = (shiftDate.weekday - DateTime.friday + 7) % 7;
        DateTime startOfWeek = shiftDate.subtract(Duration(days: daysToSubtract));

        String weekKey = "${startOfWeek.year}_${startOfWeek.month}_${startOfWeek.day}";

        if (!grouped.containsKey(weekKey)) {
          grouped[weekKey] = [];
        }
        grouped[weekKey]!.add(doc);
      }
    }

    return grouped;
  }

  void _showRecordPaymentDialog({
    required BuildContext context,
    required String weekKey,
    required String weekTitle,
    required double calculatedSalary,
    String? existingDocId,
    double? initialBaseSalary,
    double? initialBonus,
  }) {
    final baseSalaryController = TextEditingController(
      text: (initialBaseSalary ?? calculatedSalary).toStringAsFixed(2),
    );
    final bonusController = TextEditingController(
      text: initialBonus != null && initialBonus > 0 ? initialBonus.toStringAsFixed(2) : "",
    );

    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.92),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            existingDocId == null ? 'تسديد راتب أسبوع:\n$employeeName' : 'تعديل تسديد راتب:\n$employeeName',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(weekTitle, style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: baseSalaryController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: 'الراتب المستحق عن الدوام',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.6),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bonusController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                  decoration: InputDecoration(
                    labelText: 'مكافأة إضافية (إن وجدت)',
                    hintText: '0.0',
                    filled: true,
                    fillColor: Colors.teal.shade50.withOpacity(0.5),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.tealAccent.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                double baseSalary = double.tryParse(baseSalaryController.text) ?? calculatedSalary;
                double bonus = double.tryParse(bonusController.text) ?? 0.0;
                double totalPaid = baseSalary + bonus;

                if (existingDocId == null) {
                  await FirebaseFirestore.instance.collection('salary_payments').add({
                    'employeeName': employeeName,
                    'weekKey': weekKey,
                    'baseSalary': baseSalary,
                    'bonus': bonus,
                    'paidAmount': totalPaid,
                    'paidAt': Timestamp.now(),
                  });
                } else {
                  await FirebaseFirestore.instance.collection('salary_payments').doc(existingDocId).update({
                    'baseSalary': baseSalary,
                    'bonus': bonus,
                    'paidAmount': totalPaid,
                    'updatedAt': Timestamp.now(),
                  });
                }

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم حفظ وتحديث بيانات التسديد بنجاح!'), backgroundColor: Colors.teal),
                );
              },
              child: const Text('حفظ وتسجيل'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final empData = employeeDoc.data() as Map<String, dynamic>;
    double weeklyBaseSalary = (empData['weeklyBaseSalary'] ?? 0.0).toDouble();
    double dailyShiftHours = (empData['dailyShiftHours'] ?? 8.0).toDouble();

    double dailyRate = weeklyBaseSalary / 6.0;
    double hourlyRate = dailyShiftHours > 0 ? dailyRate / dailyShiftHours : 0.0;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Glass Header Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.2))),
                      child: Row(
                        children: [
                          IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white), onPressed: () => Navigator.pop(context)),
                          Text('أرشيف: $employeeName', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('attendance_logs').where('employeeName', isEqualTo: employeeName).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.tealAccent));
                    }
                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return const Center(child: Text('لا يوجد سجلات مسبقة لهذا الموظف.', style: TextStyle(color: Colors.white70)));
                    }

                    final groupedLogs = _groupLogsByWeek(docs);

                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('salary_payments').where('employeeName', isEqualTo: employeeName).snapshots(),
                      builder: (context, paymentSnapshot) {
                        Map<String, Map<String, dynamic>> paymentsMap = {};
                        if (paymentSnapshot.hasData) {
                          for (var pDoc in paymentSnapshot.data!.docs) {
                            final pData = pDoc.data() as Map<String, dynamic>;
                            String wKey = pData['weekKey'] ?? '';
                            paymentsMap[wKey] = {
                              'docId': pDoc.id,
                              'paidAmount': (pData['paidAmount'] ?? 0.0).toDouble(),
                              'baseSalary': (pData['baseSalary'] ?? 0.0).toDouble(),
                              'bonus': (pData['bonus'] ?? 0.0).toDouble(),
                            };
                          }
                        }

                        return ListView(
                          padding: const EdgeInsets.all(16),
                          children: groupedLogs.entries.map((entry) {
                            String weekKey = entry.key;
                            List<QueryDocumentSnapshot> weekDocs = entry.value;

                            final firstDocData = weekDocs.first.data() as Map<String, dynamic>;
                            DateTime shiftDate = (firstDocData['shiftDate'] as Timestamp).toDate();
                            int daysToSubtract = (shiftDate.weekday - DateTime.friday + 7) % 7;
                            DateTime startOfWeek = shiftDate.subtract(Duration(days: daysToSubtract));
                            DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));

                            String weekTitle = "أسبوع (${startOfWeek.day}/${startOfWeek.month}) إلى (${endOfWeek.day}/${endOfWeek.month})";

                            int totalWeekMins = 0;
                            for (var d in weekDocs) {
                              totalWeekMins += ((d.data() as Map<String, dynamic>)['durationMinutes'] ?? 0) as int;
                            }
                            double weekCalculatedSalary = (totalWeekMins / 60.0) * hourlyRate;

                            bool isPaid = paymentsMap.containsKey(weekKey);
                            Map<String, dynamic>? paymentData = paymentsMap[weekKey];

                            return Container(
                              margin: const EdgeInsets.only(bottom: 18),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(color: Colors.white.withOpacity(0.18)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // 1. شريط العنوان والأزرار السفلي
                                        Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    weekTitle,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.tealAccent,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  ElevatedButton.icon(
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: isPaid ? Colors.orangeAccent.shade700 : Colors.tealAccent.shade700,
                                                      foregroundColor: Colors.white,
                                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                      elevation: 0,
                                                    ),
                                                    onPressed: () => _showRecordPaymentDialog(
                                                      context: context,
                                                      weekKey: weekKey,
                                                      weekTitle: weekTitle,
                                                      calculatedSalary: weekCalculatedSalary,
                                                      existingDocId: paymentData?['docId'],
                                                      initialBaseSalary: paymentData?['baseSalary'],
                                                      initialBonus: paymentData?['bonus'],
                                                    ),
                                                    icon: Icon(isPaid ? Icons.edit : Icons.payments_outlined, size: 16),
                                                    label: Text(isPaid ? 'تعديل الدفع' : 'تسجيل الدفع', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),

                                              // 2. كروت التفاصيل المالية بتنسيق منظم وقابل للقراءة
                                              Wrap(
                                                spacing: 10,
                                                runSpacing: 10,
                                                children: [
                                                  // كرت الدوام والمستحق الأساسي
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white.withOpacity(0.08),
                                                      borderRadius: BorderRadius.circular(12),
                                                      border: Border.all(color: Colors.white.withOpacity(0.12)),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        const Icon(Icons.access_time, color: Colors.white70, size: 16),
                                                        const SizedBox(width: 6),
                                                        Text('الدوام: ${_formatMinutes(totalWeekMins)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                                        const SizedBox(width: 10),
                                                        Text('| المستحق: ${weekCalculatedSalary.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                                      ],
                                                    ),
                                                  ),

                                                  // كرت حالة الدفع والمكافأة (عند التسديد)
                                                  if (isPaid) ...[
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                      decoration: BoxDecoration(
                                                        color: Colors.tealAccent.withOpacity(0.15),
                                                        borderRadius: BorderRadius.circular(12),
                                                        border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          const Icon(Icons.check_circle, color: Colors.tealAccent, size: 16),
                                                          const SizedBox(width: 6),
                                                          Text('المستلم: ${paymentData!['paidAmount'].toStringAsFixed(2)}', style: const TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                                                        ],
                                                      ),
                                                    ),
                                                    if ((paymentData['bonus'] ?? 0.0) > 0)
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                        decoration: BoxDecoration(
                                                          color: Colors.amber.withOpacity(0.15),
                                                          borderRadius: BorderRadius.circular(12),
                                                          border: Border.all(color: Colors.amberAccent.withOpacity(0.3)),
                                                        ),
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            const Text('🎁', style: TextStyle(fontSize: 12)),
                                                            const SizedBox(width: 6),
                                                            Text('مكافأة: ${paymentData['bonus'].toStringAsFixed(2)}', style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                                                          ],
                                                        ),
                                                      ),
                                                  ],
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        Divider(color: Colors.white.withOpacity(0.1), height: 1),

                                        // 3. قائمة ورديات الأسبوع المنسدلة
                                        ExpansionTile(
                                          initiallyExpanded: false,
                                          iconColor: Colors.tealAccent,
                                          collapsedIconColor: Colors.white70,
                                          title: const Text('عرض تفاصيل ورديات الأسبوع', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                                          subtitle: Text('عدد الورديات: ${weekDocs.length}', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                                          children: weekDocs.map((doc) {
                                            final data = doc.data() as Map<String, dynamic>;
                                            DateTime checkIn = (data['checkIn'] as Timestamp).toDate();
                                            DateTime checkOut = (data['checkOut'] as Timestamp).toDate();
                                            DateTime shiftDate = (data['shiftDate'] as Timestamp).toDate();
                                            int mins = data['durationMinutes'] ?? 0;

                                            return Container(
                                              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.04),
                                                borderRadius: BorderRadius.circular(14),
                                                border: Border.all(color: Colors.white.withOpacity(0.08)),
                                              ),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                    decoration: BoxDecoration(color: Colors.tealAccent.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                                                    child: Column(
                                                      children: [
                                                        Text(_getDayName(shiftDate.weekday), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.tealAccent, fontSize: 13)),
                                                        Text('${shiftDate.day}/${shiftDate.month}', style: const TextStyle(fontSize: 10, color: Colors.white70)),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 14),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text('الدخول: ${_formatTime(checkIn)}', style: const TextStyle(fontSize: 12, color: Colors.tealAccent, fontWeight: FontWeight.bold)),
                                                        Text('الخروج: ${_formatTime(checkOut)}', style: const TextStyle(fontSize: 12, color: Colors.redAccent, fontWeight: FontWeight.bold)),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                                    child: Text(_formatMinutes(mins), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}