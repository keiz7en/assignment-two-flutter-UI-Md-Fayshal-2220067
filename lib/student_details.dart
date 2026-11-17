/// Local app defaults. Do not publish this file without reviewing its contents.
/// Phone, department and semester were not supplied; enter them via Edit Profile
/// or set their defaults below before making the submission recording.
class StudentDetails {
  const StudentDetails({required this.fullName, required this.studentId,
    required this.email, required this.phone, required this.department,
    required this.semester});
  final String fullName, studentId, email, phone, department, semester;

  factory StudentDetails.initial() => const StudentDetails(
    fullName: 'Md. Fayshal', studentId: '2220067',
    email: '2220067@iub.edu.bd', phone: '', department: '', semester: '',
  );

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'MF';
    return (parts.length > 1 ? '${parts.first[0]}${parts.last[0]}' : parts.first.substring(0, 1)).toUpperCase();
  }
}
