// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
// import '../providers/auth_provider.dart';
// import 'home_screen.dart';
//
//   Future<void> _selectDate() async {
//     final date = await showDatePicker(
//       context: context,
//       initialDate: DateTime(2000),
//       firstDate: DateTime(1920),
//       lastDate: DateTime.now(),
//       builder: (context, child) {
//         return Theme(
//           data: ThemeData.light().copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: Color(0xFFFF8989), // Основной цвет
//               onPrimary: Colors.white, // Цвет текста на основном фоне
//               surface: Colors.white, // Цвет поверхности
//               onSurface: Colors.black, // Цвет текста на поверхности
//             ),
//             dialogBackgroundColor: Colors.white, // Цвет фона диалога
//           ),
//           child: child!,
//         );
//       },
//     );
//
//     if (date != null) {
//       _birthDateController.text = DateFormat('yyyy-MM-dd').format(date);
//     }
//   }
//
//   Future<void> _handleRegister() async {
//     if (_nameController.text.isEmpty ||
//         _birthDateController.text.isEmpty ||
//         _emailController.text.isEmpty ||
//         _passwordController.text.isEmpty) {
//       _showError('Пожалуйста, заполните все поля');
//       return;
//     }
//
//     setState(() => _isLoading = true);
//
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     final error = await authProvider.signUp(
//       email: _emailController.text.trim(),
//       password: _passwordController.text,
//       name: _nameController.text,
//       birthDate: _birthDateController.text,
//       userType: _userType,
//     );
//
//     setState(() => _isLoading = false);
//
//     if (error != null) {
//       _showError(error);
//     } else {
//       if (mounted) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const HomeScreen()),
//         );
//       }
//     }
//   }
//
//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message)),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [
//                 Color(0xFFFFEDC9),
//                 Color(0xFFFFD8BE),
//                 Color(0xFFFFB2B2),
//               ],
//             ),
//           ),
//           child: SafeArea(
//             child: SingleChildScrollView(
//               child: Container(
//                 height: MediaQuery.of(context).size.height, // ЗАПОЛНЯЕМ ВСЮ ВЫСОТУ
//                 padding: const EdgeInsets.all(24.0),
//                 child: Column(
//                   children: [
//                     const SizedBox(height: 40),
//                     Container(
//                       padding: const EdgeInsets.all(32),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(24),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.stretch,
//                         children: [
//                           const Text(
//                             'Регистрация',
//                             style: TextStyle(
//                               fontSize: 24,
//                               fontWeight: FontWeight.w600,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                           const SizedBox(height: 32),
//                           _CustomTextField(
//                             controller: _nameController,
//                             hint: 'Имя',
//                           ),
//                           const SizedBox(height: 16),
//                           GestureDetector(
//                             onTap: _selectDate,
//                             child: AbsorbPointer(
//                               child: _CustomTextField(
//                                 controller: _birthDateController,
//                                 hint: 'Дата рождения',
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                           _CustomTextField(
//                             controller: _emailController,
//                             hint: 'Почта',
//                             keyboardType: TextInputType.emailAddress,
//                           ),
//                           const SizedBox(height: 16),
//                           _CustomTextField(
//                             controller: _passwordController,
//                             hint: 'Пароль',
//                             obscureText: true,
//                           ),
//                           const SizedBox(height: 24),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: _TypeButton(
//                                   text: 'Родитель',
//                                   isSelected: _userType == 'parent',
//                                   onTap: () => setState(() => _userType = 'parent'),
//                                 ),
//                               ),
//                               const SizedBox(width: 16),
//                               Expanded(
//                                 child: _TypeButton(
//                                   text: 'Ребенок',
//                                   isSelected: _userType == 'child',
//                                   onTap: () => setState(() => _userType = 'child'),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 32),
//                           _GradientButton(
//                             text: 'Зарегистрироваться',
//                             onPressed: _isLoading ? () {} : _handleRegister,
//                             isLoading: _isLoading,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         )
//         );
//     }
// }
//
// class _CustomTextField extends StatelessWidget {
//   final TextEditingController controller;
//   final String hint;
//   final bool obscureText;
//   final TextInputType? keyboardType;
//
//   const _CustomTextField({
//     required this.controller,
//     required this.hint,
//     this.obscureText = false,
//     this.keyboardType,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.black26),
//         borderRadius: BorderRadius.circular(28),
//       ),
//       child: TextField(
//         controller: controller,
//         cursorColor: const Color(0xFFFD9791),
//         obscureText: obscureText,
//         keyboardType: keyboardType,
//         decoration: InputDecoration(
//           hintText: hint,
//           hintStyle: const TextStyle(color: Colors.black38),
//           border: InputBorder.none,
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 24,
//             vertical: 16,
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _TypeButton extends StatelessWidget {
//   final String text;
//   final bool isSelected;
//   final VoidCallback onTap;
//
//   const _TypeButton({
//     required this.text,
//     required this.isSelected,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 16),
//         decoration: BoxDecoration(
//           gradient: isSelected
//               ? const LinearGradient(
//             colors: [Color(0xFFFFE4A3), Color(0xFFFFC0CB)],
//           )
//               : null,
//           border: isSelected ? null : Border.all(color: Colors.black26),
//           borderRadius: BorderRadius.circular(28),
//           color: isSelected ? null : Colors.white,
//         ),
//         child: Center(
//           child: Text(
//             text,
//             style: const TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _GradientButton extends StatelessWidget {
//   final String text;
//   final VoidCallback onPressed;
//   final bool isLoading;
//
//   const _GradientButton({
//     required this.text,
//     required this.onPressed,
//     this.isLoading = false,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 56,
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFFFFC0CB), Color(0xFFFFD4A3)],
//         ),
//         borderRadius: BorderRadius.circular(28),
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: isLoading ? null : onPressed,
//           borderRadius: BorderRadius.circular(28),
//           child: Center(
//             child: isLoading
//                 ? const SizedBox(
//               height: 24,
//               width: 24,
//               child: CircularProgressIndicator(
//                 strokeWidth: 2,
//                 color: Colors.white,
//               ),
//             )
//                 : Text(
//               text,
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }