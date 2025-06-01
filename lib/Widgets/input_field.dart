import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

class InputField extends StatefulWidget {
  const InputField({
    super.key,
    required this.label,
    required this.hintText,
    this.isObscureText = false,
    this.validator,
    required this.controller,
  });

  final String label;
  final String hintText;
  final bool isObscureText;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isObscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: GoogleFonts.lato(
            color: Color(0xFFFFFFFF).withOpacity(0.87),
            fontSize: 16,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: widget.controller,
          validator: widget.validator,
          obscureText: widget.isObscureText ? _obscureText : false,
          cursorColor: Color(0xFFFFFFFF),
          style: GoogleFonts.lato(
            letterSpacing: 1,
            fontSize: 16,
            color: Color(0xFFFFFFFF),
          ),
          decoration: InputDecoration(
            errorStyle: GoogleFonts.lato(color: Colors.red, fontSize: 12),
            errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
            suffixIcon: widget.isObscureText
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                    icon: _obscureText
                        ? const HugeIcon(
                            icon: HugeIcons.strokeRoundedView,
                            color: Color(0xFFBDBDBD),
                          )
                        : const HugeIcon(
                            icon: HugeIcons.strokeRoundedViewOffSlash,
                            color: Color(0xFFBDBDBD),
                          ),
                  )
                : null,
            filled: true,
            fillColor: Color(0xFF1D1D1D),
            hintText: widget.hintText,
            hintStyle: GoogleFonts.lato(color: Color(0xFF535353), fontSize: 16),
            contentPadding: EdgeInsets.all(12),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF979797)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF979797)),
            ),
          ),
        ),
      ],
    );
  }
}
