import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/donation.dart';

class SettingsScreen extends StatefulWidget {
  final Duration settingsTimePlayer1;
  final Duration settingsTimePlayer2;
  final int settingsIncrement;
  final int settingsDelay;
  final bool timeIndicatorsVisible;
  final bool moveCounterVisible;
  final Function(Duration, Duration, int, int, bool, bool) onSettingsChanged;

  SettingsScreen({
    required this.settingsTimePlayer1,
    required this.settingsTimePlayer2,
    required this.settingsIncrement,
    required this.settingsDelay,
    required this.timeIndicatorsVisible,
    required this.moveCounterVisible,
    required this.onSettingsChanged,
  });

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Duration tempSettingsTimePlayer1;
  late Duration tempSettingsTimePlayer2;
  late int tempSettingsIncrement;
  late int tempSettingsDelay;
  late bool tempTimeIndicatorsVisible;
  late bool tempMoveCounterVisible;

  final TextEditingController _hoursController1 = TextEditingController();
  final TextEditingController _minutesController1 = TextEditingController();
  final TextEditingController _secondsController1 = TextEditingController();
  final TextEditingController _hoursController2 = TextEditingController();
  final TextEditingController _minutesController2 = TextEditingController();
  final TextEditingController _secondsController2 = TextEditingController();
  final TextEditingController _incrementMinutesController =
      TextEditingController();
  final TextEditingController _incrementSecondsController =
      TextEditingController();
  final TextEditingController _delayMinutesController = TextEditingController();
  final TextEditingController _delaySecondsController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int selectedTimeIndex = 0;
  int selectedIncrementIndex = 0;
  int selectedDelayIndex = 0;

  @override
  void initState() {
    super.initState();
    tempSettingsTimePlayer1 = widget.settingsTimePlayer1;
    tempSettingsTimePlayer2 = widget.settingsTimePlayer2;
    tempSettingsIncrement = widget.settingsIncrement;
    tempSettingsDelay = widget.settingsDelay;
    tempTimeIndicatorsVisible = widget.timeIndicatorsVisible;
    tempMoveCounterVisible = widget.moveCounterVisible;

    _updateSelectedIndices();
    _updateTextControllers();
    _loadSavedConfigurations(); // Load configurations on init
  }

  void _updateSelectedIndices() {
    bool foundMatch = false;

    int player1TimeInSeconds = tempSettingsTimePlayer1.inSeconds;
    int player2TimeInSeconds = tempSettingsTimePlayer2.inSeconds;

    for (var key in timesDictionary.keys) {
      if (_durationFromIndex(key, timesDictionary).inSeconds ==
              player1TimeInSeconds &&
          _durationFromIndex(key, timesDictionary).inSeconds ==
              player2TimeInSeconds) {
        selectedTimeIndex = key;
        foundMatch = true;
        break;
      }
    }

    if (!foundMatch) {
      selectedTimeIndex = 19; // Custom
    }

    selectedIncrementIndex = incrementsDictionary.keys.firstWhere(
        (key) =>
            _durationFromIndex(key, incrementsDictionary).inSeconds ==
            tempSettingsIncrement,
        orElse: () => 19);
    selectedDelayIndex = delaysDictionary.keys.firstWhere(
        (key) =>
            _durationFromIndex(key, delaysDictionary).inSeconds ==
            tempSettingsDelay,
        orElse: () => 19);
  }

  void _updateTextControllers() {
    // Controladores para Time Player 1 y Player 2
    _hoursController1.text = (tempSettingsTimePlayer1.inHours).toString();
    _minutesController1.text =
        (tempSettingsTimePlayer1.inMinutes % 60).toString();
    _secondsController1.text =
        (tempSettingsTimePlayer1.inSeconds % 60).toString();

    _hoursController2.text = (tempSettingsTimePlayer2.inHours).toString();
    _minutesController2.text =
        (tempSettingsTimePlayer2.inMinutes % 60).toString();
    _secondsController2.text =
        (tempSettingsTimePlayer2.inSeconds % 60).toString();

    // Controladores para Increment y Delay
    final incrementDuration = Duration(seconds: tempSettingsIncrement);
    _incrementMinutesController.text =
        (incrementDuration.inMinutes % 60).toString();
    _incrementSecondsController.text =
        (incrementDuration.inSeconds % 60).toString();

    final delayDuration = Duration(seconds: tempSettingsDelay);
    _delayMinutesController.text = (delayDuration.inMinutes % 60).toString();
    _delaySecondsController.text = (delayDuration.inSeconds % 60).toString();
  }

  void _updatePlayer1Time() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        final hours = int.tryParse(_hoursController1.text) ?? 0;
        final minutes = int.tryParse(_minutesController1.text) ?? 0;
        final seconds = int.tryParse(_secondsController1.text) ?? 0;

        print("Updating Player 1 Time to: ${hours}h ${minutes}m ${seconds}s");
        tempSettingsTimePlayer1 =
            Duration(hours: hours, minutes: minutes, seconds: seconds);
        _updateSelectedIndices();
      });
    }
  }

  void _updatePlayer2Time() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        final hours = int.tryParse(_hoursController2.text) ?? 0;
        final minutes = int.tryParse(_minutesController2.text) ?? 0;
        final seconds = int.tryParse(_secondsController2.text) ?? 0;

        tempSettingsTimePlayer2 =
            Duration(hours: hours, minutes: minutes, seconds: seconds);
        _updateSelectedIndices();
      });
    }
  }

  void _updateIncrement() {
    setState(() {
      final minutes = int.tryParse(_incrementMinutesController.text) ?? 0;
      final seconds = int.tryParse(_incrementSecondsController.text) ?? 0;

      tempSettingsIncrement =
          Duration(minutes: minutes, seconds: seconds).inSeconds;
      _updateSelectedIndices();
    });
  }

  void _updateDelay() {
    setState(() {
      final minutes = int.tryParse(_delayMinutesController.text) ?? 0;
      final seconds = int.tryParse(_delaySecondsController.text) ?? 0;

      tempSettingsDelay =
          Duration(minutes: minutes, seconds: seconds).inSeconds;
      _updateSelectedIndices();
    });
  }

  Future<void> _saveConfigurations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('defaultTimePlayer1', tempSettingsTimePlayer1.inSeconds);
    await prefs.setInt('defaultTimePlayer2', tempSettingsTimePlayer2.inSeconds);
    await prefs.setInt('defaultIncrement', tempSettingsIncrement);
    await prefs.setInt('defaultDelay', tempSettingsDelay);
    await prefs.setBool(
        'defaultTimeIndicatorsVisible', tempTimeIndicatorsVisible);
    await prefs.setBool('defaultMoveCounterVisible', tempMoveCounterVisible);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Configuration saved as default!'),
      ),
    );
  }

  Future<void> _loadSavedConfigurations() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      tempSettingsTimePlayer1 =
          Duration(seconds: prefs.getInt('defaultTimePlayer1') ?? 180);
      tempSettingsTimePlayer2 =
          Duration(seconds: prefs.getInt('defaultTimePlayer2') ?? 180);
      tempSettingsIncrement = prefs.getInt('defaultIncrement') ?? 0;
      tempSettingsDelay = prefs.getInt('defaultDelay') ?? 0;
      tempTimeIndicatorsVisible = prefs.getBool('defaultTimeBar') ?? true;
      tempMoveCounterVisible = prefs.getBool('defaultMoveCounter') ?? true;
    });
    _updateSelectedIndices();
    _updateTextControllers();
  }

  String _durationToString(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours} Hours';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} Minutes';
    } else {
      return '${duration.inSeconds} Seconds';
    }
  }

  Duration _durationFromIndex(int index, Map<int, String> dictionary) {
    final value = dictionary[index];
    if (value == null) return Duration(seconds: 0);

    if (value.contains("Seconds")) {
      return Duration(seconds: int.parse(value.split(" ")[0]));
    } else if (value.contains("Minutes")) {
      return Duration(minutes: int.parse(value.split(" ")[0]));
    } else if (value.contains("Hours")) {
      return Duration(hours: int.parse(value.split(" ")[0]));
    }
    return Duration(seconds: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.grey[900],
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Colors.blueAccent,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.grey[850],
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.blueAccent,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(
              color: Colors.white), // Reemplaza bodyText1 con bodyLarge
          bodyMedium: TextStyle(
              color: Colors.white), // Reemplaza bodyText2 con bodyMedium
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              widget.onSettingsChanged(
                tempSettingsTimePlayer1,
                tempSettingsTimePlayer2,
                tempSettingsIncrement,
                tempSettingsDelay,
                tempTimeIndicatorsVisible,
                tempMoveCounterVisible,
              );
              Navigator.of(context).pop();
            },
          ),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(20),
              children: [
                Text("Time",
                    style: TextStyle(
                        fontSize: 20,
                        color: const Color.fromARGB(255, 255, 255, 255))),
                Container(
                  margin: EdgeInsets.only(top: 10, bottom: 10),
                  child: Text(
                      "The time each player is given for the entire game. When a players time reaches zero the game is lost.",
                      style: TextStyle(fontSize: 15, color: Colors.grey[400])),
                ),
                // Slider para el tiempo
                Slider(
                  value: selectedTimeIndex.toDouble(),
                  min: 0,
                  max: timesDictionary.length - 1.toDouble(),
                  divisions: timesDictionary.length - 1,
                  label: timesDictionary[selectedTimeIndex],
                  onChanged: (double value) {
                    setState(() {
                      selectedTimeIndex = value.toInt();
                      if (selectedTimeIndex != 19) {
                        tempSettingsTimePlayer1 = _durationFromIndex(
                            selectedTimeIndex, timesDictionary);
                        tempSettingsTimePlayer2 = _durationFromIndex(
                            selectedTimeIndex, timesDictionary);
                        _updateTextControllers();
                      }
                    });
                  },
                ),

                Container(
                  margin: EdgeInsets.only(top: 10, bottom: 10),
                  child: Text("Player 2",
                      style: TextStyle(fontSize: 15, color: Colors.grey[400])),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _hoursController2,
                        decoration: InputDecoration(
                          labelText: 'Hours',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: Colors.white),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(1),
                          FilteringTextInputFormatter.allow(RegExp(r'^[0-5]$')),
                        ],
                        onChanged: (value) {
                          _updatePlayer2Time();
                        },
                        validator: (value) {
                          final intVal = int.tryParse(value ?? '') ?? 0;
                          if (intVal < 0 || intVal > 5) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _minutesController2,
                        decoration: InputDecoration(
                          labelText: 'Minutes',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: Colors.white),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2),
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^([0-5]?[0-9]?)$')),
                        ],
                        onChanged: (value) {
                          _updatePlayer2Time();
                        },
                        validator: (value) {
                          final intVal = int.tryParse(value ?? '') ?? 0;
                          if (intVal < 0 || intVal > 59) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _secondsController2,
                        decoration: InputDecoration(
                          labelText: 'Seconds',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: Colors.white),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2),
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^([0-5]?[0-9]?)$')),
                        ],
                        onChanged: (value) {
                          _updatePlayer2Time();
                        },
                        validator: (value) {
                          final intVal = int.tryParse(value ?? '') ?? 0;
                          if (intVal < 0 || intVal > 59) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: 10, bottom: 10),
                  child: Text("Player 1",
                      style: TextStyle(fontSize: 15, color: Colors.grey[400])),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _hoursController1,
                        decoration: InputDecoration(
                          labelText: 'Hours',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: Colors.white),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(1),
                          FilteringTextInputFormatter.allow(RegExp(r'^[0-5]$')),
                        ],
                        onChanged: (value) {
                          _updatePlayer1Time();
                        },
                        validator: (value) {
                          final intVal = int.tryParse(value ?? '') ?? 0;
                          if (intVal < 0 || intVal > 5) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _minutesController1,
                        decoration: InputDecoration(
                          labelText: 'Minutes',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: Colors.white),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2),
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^([0-5]?[0-9]?)$')),
                        ],
                        onChanged: (value) {
                          _updatePlayer1Time();
                        },
                        validator: (value) {
                          final intVal = int.tryParse(value ?? '') ?? 0;
                          if (intVal < 0 || intVal > 59) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _secondsController1,
                        decoration: InputDecoration(
                          labelText: 'Seconds',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: Colors.white),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2),
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^([0-5]?[0-9]?)$')),
                        ],
                        onChanged: (value) {
                          _updatePlayer1Time();
                        },
                        validator: (value) {
                          final intVal = int.tryParse(value ?? '') ?? 0;
                          if (intVal < 0 || intVal > 59) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: 15, bottom: 15),
                ),
                Text("Increment",
                    style: TextStyle(
                        fontSize: 20,
                        color: const Color.fromARGB(255, 255, 255, 255))),
                Container(
                  margin: EdgeInsets.only(top: 10, bottom: 10),
                  child: Text(
                      "The amount of time each player gets added to their clock every time they pass the move to the other player.",
                      style: TextStyle(fontSize: 15, color: Colors.grey[400])),
                ),
                Slider(
                  value: selectedIncrementIndex.toDouble(),
                  min: 0,
                  max: incrementsDictionary.length - 1.toDouble(),
                  divisions: incrementsDictionary.length - 1,
                  label: incrementsDictionary[selectedIncrementIndex],
                  onChanged: (double value) {
                    setState(() {
                      selectedIncrementIndex = value.toInt();
                      if (selectedIncrementIndex != 19) {
                        tempSettingsIncrement = _durationFromIndex(
                                selectedIncrementIndex, incrementsDictionary)
                            .inSeconds;
                        _updateTextControllers();
                      }
                    });
                  },
                ),
                Container(
                  margin: EdgeInsets.only(top: 10, bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _incrementMinutesController,
                          decoration: InputDecoration(
                            labelText: 'Minutes',
                            labelStyle: TextStyle(color: Colors.white),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: Colors.white),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(2),
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^([0-5]?[0-9]?)$')),
                          ],
                          onChanged: (value) {
                            _updateIncrement();
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _incrementSecondsController,
                          decoration: InputDecoration(
                            labelText: 'Seconds',
                            labelStyle: TextStyle(color: Colors.white),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: Colors.white),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(2),
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^([0-5]?[0-9]?)$')),
                          ],
                          onChanged: (value) {
                            _updateIncrement();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 15, bottom: 15),
                ),
                Text("Delay",
                    style: TextStyle(
                        fontSize: 20,
                        color: const Color.fromARGB(255, 255, 255, 255))),
                Container(
                  margin: EdgeInsets.only(top: 10, bottom: 10),
                  child: Text(
                      "On every move there is a certain delay (free time) that passes before the clock starts counting down.",
                      style: TextStyle(fontSize: 15, color: Colors.grey[400])),
                ),
                Slider(
                  value: selectedDelayIndex.toDouble(),
                  min: 0,
                  max: delaysDictionary.length - 1.toDouble(),
                  divisions: delaysDictionary.length - 1,
                  label: delaysDictionary[selectedDelayIndex],
                  onChanged: (double value) {
                    setState(() {
                      selectedDelayIndex = value.toInt();
                      if (selectedDelayIndex != 19) {
                        tempSettingsDelay = _durationFromIndex(
                                selectedDelayIndex, delaysDictionary)
                            .inSeconds;
                        _updateTextControllers();
                      }
                    });
                  },
                ),
                Container(
                  margin: EdgeInsets.only(top: 10, bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _delayMinutesController,
                          decoration: InputDecoration(
                            labelText: 'Minutes',
                            labelStyle: TextStyle(color: Colors.white),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: Colors.white),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(2),
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^([0-5]?[0-9]?)$')),
                          ],
                          onChanged: (value) {
                            _updateDelay();
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _delaySecondsController,
                          decoration: InputDecoration(
                            labelText: 'Seconds',
                            labelStyle: TextStyle(color: Colors.white),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: Colors.white),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(2),
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^([0-5]?[0-9]?)$')),
                          ],
                          onChanged: (value) {
                            _updateDelay();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 15, bottom: 15),
                ),
                Text("Time Bar",
                    style: TextStyle(
                        fontSize: 20,
                        color: const Color.fromARGB(255, 255, 255, 255))),
                Container(
                  margin: EdgeInsets.only(top: 10, bottom: 10),
                  child: Text(
                      "Visibility of time bar at the bottom/top of the screen. You can disable it if it annoys you.",
                      style: TextStyle(fontSize: 15, color: Colors.grey[400])),
                ),
                SwitchListTile(
                  title: Text(
                    'Time Bar Visibility',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: tempTimeIndicatorsVisible,
                  onChanged: (bool value) {
                    setState(() {
                      tempTimeIndicatorsVisible = value;
                    });
                  },
                ),
                Container(
                  margin: EdgeInsets.only(top: 15, bottom: 15),
                ),
                Text("Move Counter",
                    style: TextStyle(
                        fontSize: 20,
                        color: const Color.fromARGB(255, 255, 255, 255))),
                Container(
                  margin: EdgeInsets.only(top: 10, bottom: 10),
                  child: Text(
                      "Visibility of the move counter in the bottom left corner. You can disable it if it annoys you.",
                      style: TextStyle(fontSize: 15, color: Colors.grey[400])),
                ),
                SwitchListTile(
                  title: Text(
                    'Move Counter Visibility',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: tempMoveCounterVisible,
                  onChanged: (bool value) {
                    setState(() {
                      tempMoveCounterVisible = value;
                    });
                  },
                ),
                SizedBox(height: 20),

// El botón de guardar configuración
                Container(
                  margin: EdgeInsets.only(top: 15, bottom: 15),
                  child: ElevatedButton(
                    onPressed: _saveConfigurations,
                    child: Text('Save Configuration as Default'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 255,
                          255), // Usar backgroundColor en lugar de primary
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

// Mover DonationWidget al final
                SizedBox(height: 20),
                DonationWidget(),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Dictionarios de configuraciones
Map<int, String> timesDictionary = {
  0: "15 Seconds",
  1: "30 Seconds",
  2: "1 Minutes",
  3: "2 Minutes",
  4: "3 Minutes",
  5: "5 Minutes",
  6: "10 Minutes",
  7: "15 Minutes",
  8: "20 Minutes",
  9: "25 Minutes",
  10: "30 Minutes",
  11: "40 Minutes",
  12: "45 Minutes",
  13: "60 Minutes",
  14: "75 Minutes",
  15: "90 Minutes",
  16: "120 Minutes",
  17: "150 Minutes",
  18: "180 Minutes",
  19: "Custom"
};

Map<int, String> incrementsDictionary = {
  0: "0 Seconds",
  1: "1 Seconds",
  2: "2 Seconds",
  3: "3 Seconds",
  4: "4 Seconds",
  5: "5 Seconds",
  6: "6 Seconds",
  7: "10 Seconds",
  8: "12 Seconds",
  9: "15 Seconds",
  10: "20 Seconds",
  11: "25 Seconds",
  12: "30 Seconds",
  13: "45 Seconds",
  14: "60 Seconds",
  15: "90 Seconds",
  16: "120 Seconds",
  17: "150 Seconds",
  18: "180 Seconds",
  19: "Custom"
};

Map<int, String> delaysDictionary =
    incrementsDictionary; // Similar options for Delay
