import 'package:flutter/material.dart';

class ContainedButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  const ContainedButton({
    required this.title,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(
          backgroundColor ?? Colors.indigoAccent.shade400,
        ),
        foregroundColor: WidgetStatePropertyAll(
          onPressed == null ? Colors.grey.shade300 : Colors.white,
        ),
        padding: const WidgetStatePropertyAll(EdgeInsets.all(14)),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide.none,
          ),
        ),
      ),
      onPressed: isLoading ? null : onPressed,
      child:
          isLoading
              ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
              : Text(title),
    );
  }
}

class OutlineButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  final bool isLoading;
  const OutlineButton({
    required this.title,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(
          onPressed == null ? Colors.grey.shade400 : null,
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        padding: const WidgetStatePropertyAll(EdgeInsets.all(14)),
      ),
      onPressed: isLoading ? null : onPressed,
      child:
          isLoading
              ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context)
                      .textButtonTheme
                      .style
                      ?.foregroundColor
                      ?.resolve({WidgetState.pressed}),
                ),
              )
              : Text(title),
    );
  }
}
