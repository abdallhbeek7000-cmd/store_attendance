class Employee {
  final String id;
  final String name;
  final String pin;
  double weeklyBaseSalary; // الراتب الأسبوعي المتفق عليه (مثلاً 600)
  double dailyShiftHours;  // عدد ساعات الوردية اليومية (مثلاً 8)
  bool isCheckedIn;
  DateTime? lastCheckIn;

  Employee({
    required this.id,
    required this.name,
    required this.pin,
    this.weeklyBaseSalary = 0.0,
    this.dailyShiftHours = 8.0, // الافتراضي 8 ساعات
    this.isCheckedIn = false,
    this.lastCheckIn,
  });

  // 1. حساب أجرة اليوم الواحد (الراتب الأسبوعي ÷ 6 أيام عمل)
  double get dailyRate => weeklyBaseSalary / 6.0;

  // 2. حساب سعر الساعة (أجرة اليوم ÷ عدد ساعات الوردية)
  double get hourlyRate => dailyShiftHours > 0 ? dailyRate / dailyShiftHours : 0.0;

  // 3. حساب المستحق المالي بناءً على الدقائق المقطوعة (تُحسب الأيام الإضافية تلقائياً)
  double calculateEarnings(int totalMinutes) {
    double totalHours = totalMinutes / 60.0;
    return totalHours * hourlyRate;
  }
}