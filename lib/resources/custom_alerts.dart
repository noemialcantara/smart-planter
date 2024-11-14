import 'colors.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:hortijoy_mobile_app/custom_widgets/custom_outlined_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomAlerts extends StatelessWidget {
  final bool? hasClose;
  final bool? hasIcon;
  final bool? hasDivider;
  final Widget? addMessage;
  final String? outlinedButtonText;
  final String? higlightedButtonText;
  final String? message;
  final String? headerText;
  final Function onCancel;
  final Function onSubmit;

  CustomAlerts(
      {this.hasClose,
      this.hasIcon,
      this.hasDivider,
      this.addMessage,
      this.outlinedButtonText,
      this.higlightedButtonText,
      this.message,
      this.headerText,
      required this.onCancel,
      required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Container(
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _close(context),
                _headerText(headerText!, context),
                _divider(),
                _message(this.message ?? ''),
                _addMessage(),
                _buttons(context)
              ],
            ),
            _headerIcon(),
          ],
        ),
      ),
    );
  }

  Widget _headerText(String header, BuildContext context) {
    return Visibility(
      visible: header == null ? false : true,
      child: Container(
        padding: EdgeInsets.all(20),
        alignment: Alignment.center,
        child: Text(header == null ? '' : header,
            style: Theme.of(context).textTheme.headline6),
      ),
    );
  }

  Widget _addMessage() {
    return this.addMessage ?? Container();
  }

  Widget _close(BuildContext context) {
    return Visibility(
      visible: this.hasClose == null ? false : true,
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          padding: EdgeInsets.all(20),
          child: Icon(
            Icons.close,
            color: AppColors.primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _divider() {
    return Visibility(
      visible: this.hasDivider == null ? false : true,
      child: Container(
        margin: EdgeInsets.only(bottom: 20),
        child: Divider(
          thickness: 1,
          endIndent: 0,
        ),
      ),
    );
  }

  Widget _message(String message) {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      margin: EdgeInsets.only(top: 20),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
      ),
    );
  }

  Widget _headerIcon() {
    return Visibility(
      visible: this.hasIcon == null ? false : true,
      child: Positioned.fill(
        top: 45,
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            height: 50,
            child: FloatingActionButton(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: AppColors.white,
              onPressed: () {},
              child: Text(
                'i',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 36),
              ),
              elevation: 3.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buttons(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          _outlinedButton(context),
          SizedBox(width: 15),
          _highlightedButton()
        ],
      ),
    );
  }

  Widget _outlinedButton(BuildContext context) {
    return Visibility(
      visible: this.outlinedButtonText == null ? false : true,
      child: Expanded(
        child: OutlinedButtonStandard(
          buttonStyle: outlinedButtonStandardStyle(),
          onPressed: onCancel(),
          child: AutoSizeText(
            this.outlinedButtonText == null ? '' : this.outlinedButtonText,
          ),
        ),
      ),
    );
  }

  Widget _highlightedButton() {
    return Visibility(
      visible: this.higlightedButtonText == null ? false : true,
      child: Expanded(
        child: OutlinedButtonStandard(
          buttonStyle: outlinedButtonStandardStyle(),
          onPressed: onSubmit(),
          child: AutoSizeText(
            this.higlightedButtonText == null ? '' : this.higlightedButtonText,
          ),
        ),
      ),
    );
  }
}
