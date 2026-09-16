import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/kiosk_screen.dart';
import 'screens/admin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AttendanceSystemApp());
}

class AttendanceSystemApp extends StatelessWidget {
  const AttendanceSystemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'نظام دوام المتجر',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        fontFamily: 'sans-serif',
      ),
      home: const LoginSelectionScreen(),
    );
  }
}

class LoginSelectionScreen extends StatefulWidget {
  const LoginSelectionScreen({super.key});

  @override
  State<LoginSelectionScreen> createState() => _LoginSelectionScreenState();
}

class _LoginSelectionScreenState extends State<LoginSelectionScreen> {
  final _adminPassController = TextEditingController();

  void _loginAdmin() {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.85),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('دخول الإدارة', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: _adminPassController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'كلمة مرور الإدارة',
              filled: true,
              fillColor: Colors.white.withOpacity(0.5),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (_adminPassController.text == '123456') {
                  Navigator.pop(context);
                  _adminPassController.clear();
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminScreen()));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('كلمة المرور خاطئة!'), backgroundColor: Colors.redAccent),
                  );
                }
              },
              child: const Text('دخول'),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: const Icon(Icons.storefront, size: 80, color: Colors.tealAccent),
            ),
            const SizedBox(height: 20),
            const Text(
              'نظام إدارة الحضور والإنصراف',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 50),
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent.withOpacity(0.85),
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KioskScreen())),
                  icon: const Icon(Icons.touch_app, size: 28),
                  label: const Text('دخول جهاز الكاشير', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withOpacity(0.4), width: 1.5),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  onPressed: _loginAdmin,
                  icon: const Icon(Icons.admin_panel_settings, size: 28),
                  label: const Text('دخول لوحة الإدارة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}