import 'package:fluent_ui/fluent_ui.dart';

class InputForm extends StatefulWidget {
  final String title;
  final String placeholder;
  final TextEditingController controller;
  final bool isPassword;

  const InputForm({
    super.key,
    required this.title,
    required this.placeholder,
    required this.controller,
    this.isPassword = false,
  });

  @override
  State<InputForm> createState() => _InputFormState();
}

class _InputFormState extends State<InputForm> {
  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 1,
      child: InfoLabel(
        label: widget.title,
        labelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        child: !widget.isPassword
            ? TextFormBox(
                placeholder: widget.placeholder,
                controller: widget.controller,
                validator: (value) =>
                    widget.title != 'Database' && value!.isEmpty
                        ? 'El ${widget.title} es requerido.'
                        : null,
              )
            : PasswordBox(
                placeholder: widget.placeholder,
                controller: widget.controller,
                revealMode: PasswordRevealMode.peekAlways,
              ),
      ),
    );
  }
}
