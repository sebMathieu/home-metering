import 'package:flutter/material.dart';
import 'package:home_metering/controller/meter_reading_controller.dart';
import 'package:home_metering/model/meter.dart';
import 'package:home_metering/model/meter_reading.dart';
import 'package:home_metering/utils/validators.dart';
import 'package:home_metering/utils/widgets.dart';
import 'package:intl/intl.dart';

class EditMeterReadingView extends StatefulWidget {
  const EditMeterReadingView(this.meters,
      {super.key, this.initialMeter, this.initialMeterReading});

  final List<Meter> meters;
  final Meter? initialMeter;
  final MeterReading? initialMeterReading;

  @override
  State<EditMeterReadingView> createState() => _EditMeterReadingViewState();
}

class _EditMeterReadingViewState extends State<EditMeterReadingView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late MeterReading meterReading;

  @override
  void initState() {
    super.initState();

    if (widget.initialMeterReading != null) {
      meterReading = copyMeterReading(widget.initialMeterReading!);
    } else {
      meterReading = MeterReading(meterId: widget.initialMeter?.id ?? widget.meters[0].id ?? 0, dateTime: DateTime.now(), value: -1);
    }
  }

  void _addMeterReading() async {
    if (widget.initialMeterReading != null) {
      throw ("Cannot add an already existing meter reading.");
    }
    if (!_isFormValid()) return;
    _formKey.currentState!.save();

    await registerMeterReading(meterReading);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _updateMeterReading() async {
    if (widget.initialMeterReading == null) {
      throw ("Cannot edit a non existing meter reading");
    }
    if (!_isFormValid()) return;
    _formKey.currentState!.save();
    await updateMeterReading(meterReading);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  bool _isFormValid() {
    return _formKey.currentState?.validate() ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final translator = getTranslator(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.initialMeterReading != null ? translator.editMeterReading : translator.newMeterReading)),
      body: SingleChildScrollView(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(padding: const EdgeInsets.all(defaultViewPadding), child: _buildForm(context)),
          _buildActionButton(context)
        ],
      )),
    );
  }

  Form _buildForm(BuildContext context) {
    final timeOfDayFormatter = DateFormat.yMd().add_jm();
    int? meterId;
    if (meterReading.meterId > 0) {
      meterId = meterReading.meterId;
    } else if (widget.meters.length == 1) {
      meterId = widget.meters[0].id;
    }

    final translator = getTranslator(context);
    return Form(
        key: _formKey,
        child: Column(children: [
          DropdownButtonFormField<int>(
            value: meterId,
            validator: (value) => validateDynamicRequired(value, translator),
            onChanged: (value) => meterReading.meterId = value!,
            items: widget.meters.map<DropdownMenuItem<int>>((meter) {
              return DropdownMenuItem<int>(
                value: meter.id,
                child: Text(meter.name),
              );
            }).toList(),
            decoration: InputDecoration(
              labelText: "${translator.meter} *",
            ),
          ),
          TextFormField(
              initialValue: timeOfDayFormatter.format(meterReading.dateTime),
              validator: (v) => validateRequiredDateTime(v, formatter: timeOfDayFormatter, translator),
              keyboardType: TextInputType.number,
              onSaved: (value) {
                meterReading.dateTime = timeOfDayFormatter.parseLoose(value!);
                },
              decoration: InputDecoration(
                labelText: "${translator.timeOfDay} *",
              )),
          TextFormField(
              initialValue: meterReading.value < 0 ? null : meterReading.value.toString(),
              validator: (value) => validateRequiredFloat(value, translator),
              autofocus: true,
              keyboardType: TextInputType.number,
              onSaved: (value) =>
              meterReading.value = num.parse(value!),
              decoration: InputDecoration(
                labelText: "${translator.meterIndex} *",
              )),
          const SizedBox(height: 18),
          Row(
            children: [
              Transform.scale(
                  scale: 1.1,
                  child: SizedBox(
                      width: 24,
                      height: 24,
                      child:Checkbox(
                          value: meterReading.isReset,
                          onChanged: (value) {
                            setState(() {
                              meterReading.isReset = (value == true);
                            });
                          }
                      ))),
              const SizedBox(width: 6),
              Text(translator.isIndexReset)
            ],
          ),
        ])
    );
  }

  ButtonStyleButton _buildActionButton(BuildContext context) {
    final translator = getTranslator(context);
    return ElevatedButton.icon(
      icon: Icon(
          widget.initialMeterReading != null ? Icons.edit : Icons.add,
          size: 18),
      label: Text(widget.initialMeterReading != null ? translator.update : translator.add),
      onPressed: widget.initialMeterReading != null
          ? _updateMeterReading
          : _addMeterReading,
    );
  }
}
