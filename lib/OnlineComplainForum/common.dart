import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class T_T extends StatelessWidget {
  T_T({
    super.key,
    required this.heading,
    required this.hint_text,
    this.keyboard_type,
    required this.SecondWidget,
    required this.controller,
    required this.maxlength,
    required this.maxlines,
    required this.isCnic,
    required this.needFormatter,
  });

  final String heading;
  final String hint_text;
  final TextInputType? keyboard_type;
  final bool SecondWidget;
  final TextEditingController controller;
  final int maxlength;
  final int maxlines;
  final bool isCnic;
  final bool needFormatter;





  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: Text(
            heading,
            textAlign: TextAlign.left,
            style: const TextStyle(color: Colors.black, fontSize: 15),
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        SecondWidget
            ? Container()
            : TextFormField(
                inputFormatters: needFormatter
                    ? [
                        FilteringTextInputFormatter.digitsOnly,
                        inputFormater(isCnic),
                      ]
                    : [],
                minLines: 1,
                maxLines: maxlines,
                maxLength: maxlength, // Set the maximum length
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                buildCounter: (BuildContext context,
                    {required int currentLength,
                    required bool isFocused,
                    required int? maxLength}) {
                  return const SizedBox();
                },
                controller: controller,
                keyboardType: keyboard_type ?? TextInputType.text,
                decoration: InputDecoration(
                  focusedBorder:  OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    borderSide: BorderSide(
                        color:  Colors.blue), // Border color when focused
                  ),
                  enabledBorder:  OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    borderSide: BorderSide(
                        color: Colors.grey), // Border color when not focused
                  ),
                  hintText: hint_text,
                ),
                         //     validator: needFormatter ? _validateInput : null,
                         //     autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
      ],
    );
  }
}

// this class will be called, when their is change in textField
class inputFormater extends TextInputFormatter {
  inputFormater(this.isCnic);

  final bool isCnic;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }
    String enteredData = newValue.text; // get data enter by used in textField
    StringBuffer buffer = StringBuffer();

    for (int i = 0; i < enteredData.length; i++) {
      // add each character into String buffer
      buffer.write(enteredData[i]);
      int index = i + 1;
      if (isCnic && index == 12 && enteredData.length != index) {
        // add space after 4th digit
        buffer.write("-");
      }
      if (isCnic && index == 5 && enteredData.length != index) {
        // add space after 4th digit
        buffer.write("-");
      }
      if (!isCnic && index == 4 && enteredData.length != index) {
        // add space after 4th digit
        buffer.write("-");
      }
    }

    return TextEditingValue(
        text: buffer.toString(), // final generated credit card number
        selection: TextSelection.collapsed(
            offset: buffer.toString().length) // keep the cursor at end
        );
  }
}
