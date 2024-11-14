import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

double fieldBorderRadius = 10;

class CustomWidget {
  static Widget buildTextFormField({
    Function(String)? onChanged,
    String? initialValue,
    String? validatorText,
    int minLines = 1,
    bool enable = true,
    bool autoValidate = false,
    bool obscureText = false,
    String? labelText,
    String? hintText,
    Widget? suffixIcon,
    TextInputType? textInputType,
    TextEditingController? controller,
    Color backgroundColor = Colors.white,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enable,
      obscureText: obscureText,
      initialValue: initialValue,
      onChanged: onChanged,
      autofocus: false,
      minLines: minLines,
      validator: (value) {
        if (value!.isEmpty) {
          return "TextField must not be empty";
        }
        return null;
      },
      maxLines: minLines,
      keyboardType: textInputType,
      style: const TextStyle(
        color: AppColors.subtitleColor,
        fontSize: 13,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        errorMaxLines: 2,
        hintText: hintText,
        filled: true,
        suffixIcon: suffixIcon,
        fillColor: enable ? backgroundColor : Colors.grey[300],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(fieldBorderRadius),
          borderSide: const BorderSide(color: AppColors.textFieldBorderColor),
          // borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      inputFormatters: inputFormatters,
      textInputAction: TextInputAction.done,
    );
  }

  static Widget buildTextArea(Function(String) onChanged,
      {String? initialValue,
      int minLines = 1,
      int maxLength = 150,
      bool enable = true,
      bool autoValidate = false,
      bool obscureText = false,
      String? hintText,
      TextInputType? textInputType,
      TextEditingController? controller,
      Color backgroundColor = Colors.white,
      List<TextInputFormatter>? inputFormatters}) {
    return TextFormField(
      controller: controller,
      enabled: enable,
      obscureText: obscureText,
      initialValue: initialValue,
      onChanged: onChanged,
      autofocus: false,
      minLines: minLines,
      maxLines: minLines,
      validator: (value) {
        if (value!.isEmpty) {
          return "TextField must not be empty";
        }
        return null;
      },
      maxLength: maxLength,
      keyboardType: textInputType,
      style: TextStyle(
        color: AppColors.black,
      ),
      decoration: InputDecoration(
        errorMaxLines: 2,
        hintText: hintText,
        filled: true,
        fillColor: enable ? backgroundColor : Colors.grey[300],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(fieldBorderRadius),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
      ),
      inputFormatters: inputFormatters,
      textInputAction: TextInputAction.done,
    );
  }

  static Widget buildDropdown(Function(dynamic) onChanged,
      {Key? key,
      dynamic value,
      String? hintText,
      List<CustomDropdownItem> items = const [
        CustomDropdownItem(label: "Item1", value: 0),
        CustomDropdownItem(label: "Item2", value: 1),
        CustomDropdownItem(label: "Item3", value: 2),
        CustomDropdownItem(label: "Item4", value: 3),
        CustomDropdownItem(label: "Item5", value: 4),
      ],
      bool? isVisible,
      required Function onClear,
      Color? iconColor,
      Color? textColor,
      Color? buttonColor,
      bool hasStyledBorder = false}) {
    bool visibility = isVisible == null ? false : isVisible;
    Color iconEnabledColor =
        iconColor == null ? AppColors.primaryColor : iconColor;
    Color textStyleColor = textColor == null ? AppColors.black : textColor;
    Color buttonStyleColor = buttonColor == null ? Colors.white : buttonColor;

    if (hasStyledBorder) {
      return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(fieldBorderRadius),
            color: items.isEmpty ? Colors.grey[350] : buttonStyleColor,
            border: Border.all(color: Colors.transparent),
          ),
          child: InputDecorator(
              decoration: const InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: AppColors.primaryColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: AppColors.primaryColor),
                ),
                labelStyle: TextStyle(color: AppColors.primaryColor),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton(
                    isExpanded: true,
                    value: value,
                    hint: Text(hintText ?? ""),
                    icon: _icon(visibility, onClear),
                    iconEnabledColor: iconEnabledColor,
                    style: TextStyle(color: textStyleColor),
                    underline: SizedBox(),
                    items: items
                        .map((item) => DropdownMenuItem(
                              value: item.value,
                              child: Text(item.label ?? "None"),
                            ))
                        .toList(),
                    onChanged: onChanged),
              )));
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(fieldBorderRadius),
        color: items.isEmpty ? Colors.grey[350] : buttonStyleColor,
        border: Border.all(color: Colors.transparent),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
            isExpanded: true,
            value: value,
            hint: Text(hintText ?? ""),
            icon: _icon(visibility, onClear),
            iconEnabledColor: iconEnabledColor,
            style: TextStyle(color: textStyleColor),
            underline: SizedBox(),
            items: items
                .map((item) => DropdownMenuItem(
                      value: item.value,
                      child: Text(item.label ?? "None"),
                    ))
                .toList(),
            onChanged: onChanged),
      ),
    );
  }

  static Widget _icon(bool isVisible, Function onClear) {
    return Row(
      children: [
        Visibility(
            visible: !isVisible,
            child: Icon(
              // Add this
              Icons.arrow_drop_down, // Add this
              color: AppColors.primaryColor, // Add this
              size: 30,
            )),
        GestureDetector(
          onTap: onClear(),
          child: Visibility(
              visible: isVisible,
              child: Icon(
                // Add this
                Icons.clear, // Add this
                color: AppColors.primaryColor, // Add this
                size: 20,
              )),
        )
      ],
    );
  }

  static Widget buildLabeledLoadingScreen({String message = ""}) {
    return Container(
      constraints: BoxConstraints.expand(),
      color: AppColors.primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(35),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 130,
              width: 130,
              child: Stack(
                children: [
                  Container(
                    constraints: BoxConstraints.expand(),
                    child: CircularProgressIndicator(
                      valueColor:
                          new AlwaysStoppedAnimation<Color>(Colors.white54),
                    ),
                  ),
                  Center(
                    child: Text(
                      "Loading",
                      style: TextStyle(color: AppColors.white, fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 30,
            ),
            message != null
                ? Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                    ),
                  )
                : SizedBox()
          ],
        ),
      ),
    );
  }

  static Widget textBuilder(
    String text, {
    Color? color = AppColors.white,
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return Text(
      text,
      textAlign: TextAlign.left,
      style: TextStyle(
        color: color,
        fontWeight: fontWeight,
        fontSize: fontSize,
        fontFamily: 'Roboto',
      ),
    );
  }

  static Widget buidLoadingScreen() {
    return Container(
      constraints: const BoxConstraints.expand(),
      color: Colors.black12,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class CustomDropdownItem {
  final String? label;
  final dynamic value;
  const CustomDropdownItem({this.label, this.value});
}

class CustomBottomNavBarItem {
  CustomBottomNavBarItem({
    this.iconData,
    this.text,
    this.notificationCount = 0,
  });

  IconData? iconData;
  String? text;
  int notificationCount;
}

class CustomBottomNavBar extends StatefulWidget {
  CustomBottomNavBar({
    Key? key,
    required this.items,
    required this.onTabSelected,
    this.selectedIndex,
    this.hasMiddleSpace = false,
  }) : super(key: key);

  final List<CustomBottomNavBarItem> items;
  final double height = 60;
  final double iconSize = 26;
  final Color backgroundColor = Colors.grey[200] ?? Colors.grey;
  final Color color = Colors.grey;
  final Color selectedColor = AppColors.brandingColor;
  final ValueChanged<int> onTabSelected;
  final bool hasMiddleSpace;
  final int? selectedIndex;

  @override
  State<StatefulWidget> createState() => CustomBottomNavBarState();
}

class CustomBottomNavBarState extends State<CustomBottomNavBar> {
  int _selectedIndex = 1;

  _updateIndex(int index) {
    widget.onTabSelected(index);
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      _selectedIndex = widget.selectedIndex ?? 1;
    });
    List<Widget> items = List.generate(widget.items.length, (int index) {
      return _buildTabItem(
        item: widget.items[index],
        index: index,
        onPressed: _updateIndex,
      );
    });
    if (widget.hasMiddleSpace) {
      items.insert(items.length >> 1, _buildMiddleTabItem());
    }

    return BottomAppBar(
      color: widget.backgroundColor,
      elevation: 2,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items,
      ),
    );
  }

  Widget _buildMiddleTabItem() {
    return SizedBox(
      height: widget.height,
      width: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: widget.iconSize),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required CustomBottomNavBarItem item,
    int? index,
    required ValueChanged<int> onPressed,
  }) {
    Color color = _selectedIndex == index ? widget.selectedColor : widget.color;
    return Expanded(
      child: SizedBox(
        height: widget.height,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => onPressed(index ?? 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(item.iconData, color: color, size: widget.iconSize),
                Text(
                  item.text ?? "None",
                  maxLines: 1,
                  style: TextStyle(color: color, fontSize: 10),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
