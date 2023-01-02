import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

abstract class IFromUntilDatesPicker {
  void setDateEvent(DateTime fromDt, DateTime untilDt);
}

class FromUntilDatesPicker extends StatefulWidget {
  final IFromUntilDatesPicker listener;

  const FromUntilDatesPicker(this.listener, {super.key});

  @override
  State<FromUntilDatesPicker> createState() => _FromUntilDatesPickerState();
}

class _FromUntilDatesPickerState extends State<FromUntilDatesPicker> {
  final TextEditingController _fromDateTextEditCtrl = TextEditingController();
  final TextEditingController _untilDateTextEditCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _registerListener();
    _initDate();
  }

  void _initDate() {
    _fromDateTextEditCtrl.text =
        _defFormat().format(DateTime.now().add(const Duration(days: -7)));
    _untilDateTextEditCtrl.text = _defFormat().format(DateTime.now());
  }

  void _registerListener() {
    _fromDateTextEditCtrl.addListener(onTextCtrlChangedEventCb);
    _untilDateTextEditCtrl.addListener(onTextCtrlChangedEventCb);
  }

  void onTextCtrlChangedEventCb() {
    try {
      String f = _fromDateTextEditCtrl.text;
      DateTime fdt = DateTime.parse(f);
      if (f != _defFormat().format(fdt)) {
        return;
      }
      String u = _untilDateTextEditCtrl.text;
      DateTime udt = DateTime.parse(u);
      if (u != _defFormat().format(udt)) {
        return;
      }

      widget.listener.setDateEvent(fdt, udt);
    } catch (_) {}
  }

  DateFormat _defFormat() {
    return DateFormat('yyyy-MM-dd');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        height: 150,
        child: Row(
          children: [
            SizedBox(
              width: 200,
              child: TextField(
                controller: _fromDateTextEditCtrl,
                textInputAction: TextInputAction.next,
                enabled: true,
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: "From",
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        DateTime initDate = DateTime.now();
                        try {
                          DateTime dt =
                              DateTime.parse(_fromDateTextEditCtrl.text);
                          initDate = dt;
                        } catch (_) {}

                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: initDate,
                          firstDate: DateTime(2010),
                          lastDate: DateTime.now().add(
                            const Duration(days: 31),
                          ),
                        );

                        if (picked != null) {
                          try {
                            _fromDateTextEditCtrl.text =
                                _defFormat().format(picked);
                          } catch (_) {}
                        }
                      },
                    )),
              ),
            ),
            const SizedBox(width: 100),
            SizedBox(
              width: 200,
              child: TextField(
                controller: _untilDateTextEditCtrl,
                textInputAction: TextInputAction.next,
                enabled: true,
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: "to",
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        DateTime initDate = DateTime.now();
                        try {
                          DateTime dt =
                              DateTime.parse(_untilDateTextEditCtrl.text);
                          initDate = dt;
                        } catch (_) {}

                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: initDate,
                          firstDate: DateTime(2010),
                          lastDate: DateTime.now().add(
                            const Duration(days: 31),
                          ),
                        );

                        if (picked != null) {
                          try {
                            _untilDateTextEditCtrl.text =
                                _defFormat().format(picked);
                          } catch (_) {}
                        }
                      },
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
