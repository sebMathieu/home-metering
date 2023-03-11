import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:home_metering/controller/meter_controller.dart';
import 'package:home_metering/model/meter.dart';
import 'package:home_metering/utils/validators.dart';
import 'package:home_metering/utils/widgets.dart';
import 'package:home_metering/views/meter_view.dart';
import 'package:home_metering/widgets/view_subtitle_widget.dart';

class EditMeterView extends StatefulWidget {
  const EditMeterView({this.initialMeter, super.key, this.defaultColor = defaultMeterColor});

  final Meter? initialMeter;
  final Color defaultColor;

  @override
  State<EditMeterView> createState() => _EditMeterViewState();
}

class _EditMeterViewState extends State<EditMeterView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Meter meter;
  Color? pickerColor;

  @override
  void initState() {
    super.initState();

    if (widget.initialMeter != null) {
      meter = copyMeter(widget.initialMeter!);
    } else {
      meter = Meter(name: "", unit: "", unitCost: -1);
    }

    // Color
    if (meter.color != null) {
      pickerColor = Color(meter.color!);
    }
  }

  void _navigateToMeterView(BuildContext context, [int? meterId]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MeterView(initialMeterId: meterId),
      ),
    );
  }

  void _addMeter(BuildContext context) async {
    if (meter.id != null) throw ("Cannot add an existing meter.");
    if (!_isFormValid()) return;
    _formKey.currentState!.save();

    final registeredMeter = await registerMeter(meter);
    if (!mounted) return;
    _navigateToMeterView(context, registeredMeter.id);
  }

  void _updateMeter(BuildContext context) async {
    if (meter.id == null) throw ("Cannot edit a non existing meter.");
    if (!_isFormValid()) return;
    _formKey.currentState!.save();
    await updateMeter(meter);
    if (!mounted) return;
    _navigateToMeterView(context, meter.id);
  }

  bool _isFormValid() {
    return _formKey.currentState?.validate() ?? false;
  }

  void _showColorPicker(BuildContext context) {
    final translator = getTranslator(context);
    showDialog<String?>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(translator.meterColor),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor ?? widget.defaultColor,
            onColorChanged: (value) => setState(() => {pickerColor = value}),
            colorHistory: const [defaultMeterColor, Colors.pink, Colors.blue, Colors.green, Colors.orange, Colors.deepOrange, Colors.purple, Colors.deepPurple],
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: Text(translator.confirm),
            onPressed: () {
              setState(() => meter.color = pickerColor?.value);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final translator = getTranslator(context);
    final ButtonStyle headerButtonStyle = TextButton.styleFrom(
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
    );

    return Scaffold(
      appBar: AppBar(
          title: Text(widget.initialMeter == null ? translator.newMeter : translator.editMeter),
          actions: <Widget>[
            TextButton(
              style: headerButtonStyle,
              onPressed: () => _navigateToMeterView(context),
              child: const Icon(Icons.close),
            ),
          ]),
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
    final translator = getTranslator(context);
    return Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
                initialValue: meter.name,
                onChanged: (value) => meter.name = value.trim(),
                validator: (value) => validateRequired(value, translator),
                decoration: InputDecoration(
                  labelText: "${translator.name} *",
                )),
            ViewSubtitleWidget(translator.meterIndexProperties, marginTop: defaultViewPadding*2, marginBottom: defaultMargin / 2,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Flexible(
                    flex: 3,
                    child: TextFormField(
                        initialValue: meter.unit,
                        onChanged: (value) => meter.unit = value,
                        validator: (value) => validateRequired(value, translator),
                        decoration: InputDecoration(
                          labelText: "${translator.unit} *",
                        ))),
                const SizedBox(
                  width: 30.0,
                ),
                /* // For possible future use
                Flexible(
                    flex: 2,
                    child: TextFormField(
                        initialValue: meter.decimals.toString(),
                        validator: validateRequiredPositiveInteger,
                        onSaved: (value) =>
                            meter.decimals = int.tryParse(value ?? '') ?? 0,
                        decoration: const InputDecoration(
                          labelText: "${translator.decimals} *",
                        ))),
                const SizedBox(
                  width: 30.0,
                ),
                 */
                Flexible(
                    flex: 3,
                    child: TextFormField(
                        initialValue: meter.unitCost >= 0
                            ? meter.unitCost.toString()
                            : null,
                        validator: (value) => validateRequiredFloat(value, translator),
                        keyboardType: TextInputType.number,
                        onSaved: (value) =>
                            meter.unitCost = num.tryParse(value ?? '') ?? 0,
                        decoration: InputDecoration(
                          labelText: "${translator.unitCost} *",
                        ))),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Transform.scale(
                    scale: 1.1,
                    child: SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                            value: meter.isDecreasing,
                            onChanged: (value) {
                              setState(() {
                                meter.isDecreasing = (value == true);
                              });
                            }))),
                const SizedBox(width: 6),
                Text(translator.isDecreasing)
              ],
            ),
            ViewSubtitleWidget(translator.display, marginTop: defaultViewPadding*2, marginBottom: defaultMargin / 2,),
            Row(
              children: [
                SizedBox(
                  width: 32,
                  height: 32,
                  child: IconButton(
                    onPressed: () => _showColorPicker(context),
                    icon: Icon(
                      Icons.circle,
                      color: pickerColor ?? widget.defaultColor,
                      size: 32,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 20,
                  ),
                ),
                const SizedBox(width: 6),
                Text(translator.meterColor,
                    style: TextStyle(color: pickerColor ?? widget.defaultColor))
              ],
            ),
            ViewSubtitleWidget(translator.other, marginTop: defaultViewPadding*2, marginBottom: defaultMargin / 2,),
            TextFormField(
                initialValue: meter.serialNumber,
                onChanged: (value) => meter.serialNumber = value,
                decoration: InputDecoration(
                  labelText: translator.serialNumber,
                )),
            TextFormField(
                initialValue: meter.description?.toString(),
                onChanged: (value) => meter.description = value,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText:translator.description,
                ))
          ],
        ));
  }

  ButtonStyleButton _buildActionButton(BuildContext context) {
    final translator = getTranslator(context);
    return ElevatedButton.icon(
      icon: Icon(meter.id != null ? Icons.edit : Icons.add, size: 18),
      label: Text(meter.id != null ? translator.update : translator.add),
      onPressed: () {
        meter.id != null ? _updateMeter(context) : _addMeter(context);
      },
    );
  }
}
