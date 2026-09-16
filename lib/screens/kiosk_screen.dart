import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class KioskScreen extends StatelessWidget {
  const KioskScreen({super.key});

  DateTime _calculateAdjustedCheckIn(DateTime actualCheckIn) {
    int minute = actualCheckIn.minute;
    if (minute <= 20) {
      return DateTime(
        actualCheckIn.year,
        actualCheckIn.month,
        actualCheckIn.day,
        actualCheckIn.hour,
        0,
      );
    }
    return actualCheckIn;
  }

  void _showPinDialog(BuildContext context, String docId, String name, String pin, bool isCheckedIn, Timestamp? lastCheckIn) {
    String enteredPin = "";
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.85),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('تأكيد الهوية: $name', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isCheckedIn ? 'تسجيل خروج من الوردية' : 'تسجيل دخول لوردية جديدة',
                style: TextStyle(color: isCheckedIn ? Colors.redAccent : Colors.teal, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, letterSpacing: 10, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: 'PIN',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.6),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onChanged: (val) => enteredPin = val,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isCheckedIn ? Colors.redAccent : Colors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                if (enteredPin == pin) {
                  DateTime now = DateTime.now();

                  if (isCheckedIn) {
                    DateTime rawCheckIn = lastCheckIn != null ? lastCheckIn.toDate() : now;
                    DateTime adjustedCheckIn = _calculateAdjustedCheckIn(rawCheckIn);

                    if (adjustedCheckIn.isAfter(now)) {
                      adjustedCheckIn = rawCheckIn;
                    }

                    int minutesWorked = now.difference(adjustedCheckIn).inMinutes;
                    if (minutesWorked <= 0) minutesWorked = 1;

                    DateTime shiftDate = DateTime(adjustedCheckIn.year, adjustedCheckIn.month, adjustedCheckIn.day);

                    await FirebaseFirestore.instance.collection('attendance_logs').add({
                      'employeeId': docId,
                      'employeeName': name,
                      'checkIn': Timestamp.fromDate(adjustedCheckIn),
                      'checkOut': Timestamp.fromDate(now),
                      'durationMinutes': minutesWorked,
                      'shiftDate': Timestamp.fromDate(shiftDate),
                      'createdAt': Timestamp.fromDate(now),
                    });

                    await FirebaseFirestore.instance.collection('employees').doc(docId).update({
                      'isCheckedIn': false,
                      'lastCheckIn': null,
                    });
                  } else {
                    await FirebaseFirestore.instance.collection('employees').doc(docId).update({
                      'isCheckedIn': true,
                      'lastCheckIn': Timestamp.fromDate(now),
                    });
                  }
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('الرمز السري خاطئ!'), backgroundColor: Colors.redAccent),
                  );
                }
              },
              child: const Text('تأكيد'),
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Text('تسجيل الحضور والإنصراف', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          const Icon(Icons.touch_app, color: Colors.tealAccent),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('employees').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.tealAccent));
                    }
                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return const Center(child: Text('لا يوجد موظفين مضافين.', style: TextStyle(color: Colors.white70)));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        final docId = docs[index].id;
                        final bool isCheckedIn = data['isCheckedIn'] ?? false;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isCheckedIn ? Colors.teal.withOpacity(0.18) : Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: isCheckedIn ? Colors.tealAccent.withOpacity(0.5) : Colors.white.withOpacity(0.15),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 26,
                                      backgroundColor: isCheckedIn ? Colors.tealAccent.withOpacity(0.2) : Colors.white.withOpacity(0.1),
                                      child: Icon(
                                        isCheckedIn ? Icons.check_circle : Icons.person_outline,
                                        color: isCheckedIn ? Colors.tealAccent : Colors.white70,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(data['name'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 4),
                                          Text(
                                            isCheckedIn ? 'متواجد في الدوام' : 'غير متواجد',
                                            style: TextStyle(color: isCheckedIn ? Colors.tealAccent : Colors.white54, fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isCheckedIn ? Colors.redAccent.withOpacity(0.85) : Colors.tealAccent.withOpacity(0.9),
                                        foregroundColor: isCheckedIn ? Colors.white : Colors.black87,
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      ),
                                      onPressed: () => _showPinDialog(context, docId, data['name'], data['pin'], isCheckedIn, data['lastCheckIn']),
                                      child: Text(isCheckedIn ? 'خروج' : 'دخول', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
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