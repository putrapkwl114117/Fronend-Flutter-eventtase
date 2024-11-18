import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // Memungkinkan null
  final bool isOutlined;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 700, // Atur lebar tombol menjadi lebih kecil
      child: ElevatedButton(
        onPressed: onPressed, // Dapat null jika loading
        style: ElevatedButton.styleFrom(
          foregroundColor: isOutlined ? Colors.black : Colors.white,
          backgroundColor: isOutlined ? Colors.white : Colors.black,
          side: isOutlined ? const BorderSide(color: Colors.black) : null,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Mengurangi bulatnya tombol
          ),
        ),
        child: Text(text),
      ),
    );
  }
}
