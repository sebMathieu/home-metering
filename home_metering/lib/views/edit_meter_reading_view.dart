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
      var meterId = widget.initialMeter?.id ?? 0;
      if (meterId == 0 && widget.meters.isNotEmpty) {
        meterId = widget.meters[0].id ?? 0;
      }
      meterReading =
          MeterReading(meterId: meterId, dateTime: DateTime.now(), value: -1);
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
    await updateMeterReading(
        meterReading, widget.initialMeterReading!.dateTime);
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
      appBar: AppBar(
          title: Text(widget.initialMeterReading != null
              ? translator.editMeterReading
              : translator.newMeterReading)),
      body: SingleChildScrollView(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.all(defaultViewPadding),
              child: _buildForm(context)),
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
      child: Column(
        children: [
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
              validator: (v) => validateRequiredDateTime(
                  v, formatter: timeOfDayFormatter, translator),
              keyboardType: TextInputType.number,
              onSaved: (value) {
                meterReading.dateTime = timeOfDayFormatter.parseLoose(value!);
              },
              decoration: InputDecoration(
                labelText: "${translator.timeOfDay} *",
              )),
          TextFormField(
              initialValue:
                  meterReading.value < 0 ? null : meterReading.value.toString(),
              validator: (value) => validateRequiredFloat(value, translator),
              autofocus: true,
              keyboardType: TextInputType.number,
              onSaved: (value) => meterReading.value = num.parse(value!),
              decoration: InputDecoration(
                labelText: "${translator.meterIndex} *",
              )),
          const SizedBox(height: 18),
          CheckboxListTile(
            value: meterReading.isReset,
            title: Text(translator.isIndexReset),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
            onChanged: (value) {
              setState(() {
                meterReading.isReset = (value == true);
              });
            },
          ),
        ],
      ),
    );
  }

  ButtonStyleButton _buildActionButton(BuildContext context) {
    final translator = getTranslator(context);
    return ElevatedButton.icon(
      icon: Icon(widget.initialMeterReading != null ? Icons.edit : Icons.check,
          size: 18),
      label: Text(widget.initialMeterReading != null
          ? translator.update
          : translator.confirm),
      onPressed: widget.initialMeterReading != null
          ? _updateMeterReading
          : _addMeterReading,
    );
  }
}
