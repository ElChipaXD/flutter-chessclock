import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/time_bar.dart'; // Ruta relativa correcta
import '../widgets/delay_indicator.dart'; // Ruta relativa correcta
import 'settings_screen.dart';

class StartScreen extends StatefulWidget {
  @override
  _StartScreenState createState() => _StartScreenState();
}

enum Gamestate { running, paused, before, over, settings }

const millisecondsstep = 25;

class _StartScreenState extends State<StartScreen> {
  final audioplayer = AudioPlayer();

  void playAudio() async {
    await audioplayer.setAsset('assets/bum.mp3');
    audioplayer.play();
  }

  num _timespeedup = 1;
  late Duration timePlayer1;
  late num delayPlayer1;
  late Duration timePlayer2;
  late num delayPlayer2;
  num playerToMove = 0;

  num player1Moves = 0;
  num player2Moves = 0;

  int settingsDelay = 0;
  Duration settingsTimePlayer1 = Duration(minutes: 3);
  Duration settingsTimePlayer2 = Duration(minutes: 3);
  int settingsIncrement = 0;

  late Timer _timer;

  late Gamestate gamestate;

  bool timeIndicatorsVisible = true;
  bool moveCounterVisible = true;

  @override
  void initState() {
    super.initState();
    _loadConfigurations();
  }

  Future<void> _loadConfigurations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      settingsTimePlayer1 =
          Duration(seconds: prefs.getInt('defaultTimePlayer1') ?? 180);
      settingsTimePlayer2 =
          Duration(seconds: prefs.getInt('defaultTimePlayer2') ?? 180);
      settingsIncrement = prefs.getInt('defaultIncrement') ?? 0;
      settingsDelay = prefs.getInt('defaultDelay') ?? 0;
      timeIndicatorsVisible =
          prefs.getBool('defaultTimeIndicatorsVisible') ?? true;
      moveCounterVisible = prefs.getBool('defaultMoveCounterVisible') ?? true;

      // Inicializa los temporizadores después de cargar las configuraciones
      initialization();
    });
  }

  void initialization() {
    timePlayer1 = Duration(microseconds: settingsTimePlayer1.inMicroseconds);
    timePlayer2 = Duration(microseconds: settingsTimePlayer2.inMicroseconds);
    delayPlayer1 = delayPlayer2 = 0;
    gamestate = Gamestate.before;
    player1Moves = 0;
    player2Moves = 0;
  }

  void restartButtonPressed(BuildContext context) {
    if (gamestate == Gamestate.paused) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Reset Clock"),
          content: Text("Are you sure you want to reset the chess clock?"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
            ),
            TextButton(
              child: Text("Reset"),
              onPressed: () {
                setState(() {
                  initialization();
                });
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        ),
        barrierDismissible: true,
      );
    } else if (gamestate == Gamestate.over) {
      setState(() {
        initialization();
      });
    }
  }

  void enterSettings(BuildContext context) {
    Navigator.of(context, rootNavigator: true)
        .push(MaterialPageRoute(builder: (BuildContext c) {
      return SettingsScreen(
        settingsTimePlayer1: settingsTimePlayer1,
        settingsTimePlayer2: settingsTimePlayer2,
        settingsIncrement: settingsIncrement,
        settingsDelay: settingsDelay,
        timeIndicatorsVisible: timeIndicatorsVisible,
        moveCounterVisible: moveCounterVisible,
        onSettingsChanged:
            (time1, time2, increment, delay, timeBar, moveCounter) {
          setState(() {
            settingsTimePlayer1 = time1;
            settingsTimePlayer2 = time2;
            settingsIncrement = increment;
            settingsDelay = delay;
            timeIndicatorsVisible = timeBar;
            moveCounterVisible = moveCounter;
            initialization();
          });
        },
      );
    }));
  }

  void pauseButtonPressed() {
    if (gamestate == Gamestate.running) {
      setState(() {
        gamestate = Gamestate.paused;
        this._timer.cancel();
      });
    } else if (gamestate == Gamestate.paused) {
      setState(() {
        gamestate = Gamestate.running;
        this._timer = Timer.periodic(
            Duration(milliseconds: millisecondsstep), timerTickHandler);
      });
    }
  }

  void timerTickHandler(Timer timer) {
    if (gamestate == Gamestate.running) {
      setState(() {
        if (playerToMove == 1) {
          if (delayPlayer1 > 0) {
            delayPlayer1 -= millisecondsstep * 0.001;
          } else {
            timePlayer1 -= Duration(
                    milliseconds: (millisecondsstep - delayPlayer1).toInt()) *
                _timespeedup;
            if (timePlayer1.inMilliseconds <= 0) {
              gamestate = Gamestate.over;
              playAudio();
            }
          }
        } else if (playerToMove == 2) {
          if (delayPlayer2 > 0) {
            delayPlayer2 -= millisecondsstep * 0.001;
          } else {
            timePlayer2 -= Duration(
                    milliseconds: (millisecondsstep - delayPlayer2).toInt()) *
                _timespeedup;
            if (timePlayer2.inMilliseconds <= 0) {
              gamestate = Gamestate.over;
              playAudio();
            }
          }
        }
      });
    } else
      timer.cancel();
  }

  void whiteStartsGameWithFirstTap() {
    if (gamestate != Gamestate.before) return;
    setState(() {
      gamestate = Gamestate.running;
      player1Moves++;
      playerToMove = 2;
      delayPlayer2 = settingsDelay;
      delayPlayer1 = 0;
      this._timer = Timer.periodic(
          Duration(milliseconds: millisecondsstep), timerTickHandler);
    });
  }

  void playerTapsField(int player) {
    if (this.gamestate == Gamestate.before && player == 1) {
      whiteStartsGameWithFirstTap();
    }
    if (this.gamestate == Gamestate.running) {
      if (player == playerToMove) {
        setState(() {
          if (playerToMove == 1) {
            player1Moves++;
            playerToMove = 2;
            delayPlayer2 = settingsDelay;
            delayPlayer1 = 0;
            timePlayer1 += Duration(seconds: settingsIncrement.toInt());
          } else if (playerToMove == 2) {
            player2Moves++;
            playerToMove = 1;
            delayPlayer1 = settingsDelay;
            delayPlayer2 = 0;
            timePlayer2 += Duration(seconds: settingsIncrement.toInt());
          }
        });
      }
    }
  }

  String durationToString(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    int hours = d.inHours.remainder(60);
    int minutes = d.inMinutes.remainder(60);
    int seconds = d.inSeconds.remainder(60);
    int milliseconds = d.inMilliseconds.remainder(1000);

    if (d.inSeconds >= 10) {
      return (hours != 0
              ? "${hours.toString()}:${twoDigits(minutes)}"
              : minutes.toString()) +
          ":${twoDigits(seconds)}";
    } else {
      return "${seconds}.${(milliseconds / 100).toStringAsFixed(1).substring(0, 1)}";
    }
  }

  @override
  Widget build(BuildContext context) {
    String displayedTimePlayer1 = durationToString(timePlayer1);
    String displayedTimePlayer2 = durationToString(timePlayer2);

    num player1Progress =
        (timePlayer1.inMilliseconds / settingsTimePlayer1.inMilliseconds)
            .clamp(0, 1);
    num player2Progress =
        (timePlayer2.inMilliseconds / settingsTimePlayer2.inMilliseconds)
            .clamp(0, 1);

    num player1DelayProgress =
        settingsDelay != 0 ? (delayPlayer1 / settingsDelay).clamp(0, 1) : 0;
    num player2DelayProgress =
        settingsDelay != 0 ? (delayPlayer2 / settingsDelay).clamp(0, 1) : 0;

    List<Widget> middleButtons = [];

    if (gamestate == Gamestate.over || gamestate == Gamestate.paused) {
      middleButtons.add(
        FloatingActionButton(
          heroTag: null,
          onPressed: () => restartButtonPressed(context),
          child: Icon(Icons.replay),
        ),
      );
    }
    if (gamestate == Gamestate.running)
      middleButtons.add(FloatingActionButton(
        heroTag: null,
        onPressed: pauseButtonPressed,
        child: Icon(Icons.pause),
      ));
    if (gamestate == Gamestate.paused)
      middleButtons.add(FloatingActionButton(
        heroTag: null,
        onPressed: pauseButtonPressed,
        child: Icon(Icons.play_arrow),
      ));
    if (gamestate == Gamestate.before ||
        gamestate == Gamestate.over ||
        gamestate == Gamestate.paused) {
      middleButtons.add(FloatingActionButton(
        heroTag: null,
        onPressed: () => enterSettings(context),
        child: Icon(Icons.settings),
      ));
    }

    Color? playermessagecolor = Colors.grey[400];
    List<String> playermessages = ["", ""];
    if (gamestate == Gamestate.before) {
      playermessages = ["(Tap to start.)", ""];
    } else if (gamestate == Gamestate.over) {
      playermessagecolor = Colors.red;
      if (timePlayer1.inSeconds <= 0) {
        playermessages = ["You lost on Time!", ""];
      } else if (timePlayer2.inSeconds <= 0) {
        playermessages = ["", "You lost on time!"];
      }
    } else if (gamestate == Gamestate.paused) {
      playermessages = playerToMove == 1
          ? ["(It's your move.)", ""]
          : ["", "(It's your move.)"];
    }

    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.all(0),
          padding: EdgeInsets.all(0),
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: Transform.rotate(
                      angle: 3.14,
                      child: Stack(
                        children: [
                          Material(
                            color: Colors.grey[900],
                            child: InkWell(
                              highlightColor: Colors.grey[800],
                              splashColor: Colors.grey[800],
                              onTap: () {
                                playerTapsField(2);
                              },
                              child: Stack(
                                children: [
                                  Center(
                                    child: Text(
                                      displayedTimePlayer2,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 90,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  moveCounterVisible
                                      ? Align(
                                          alignment: Alignment(-0.8, 0.75),
                                          child: Text(
                                            player2Moves.toString(),
                                            style: TextStyle(
                                              color: playermessagecolor,
                                              fontSize: 30,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        )
                                      : SizedBox.shrink(),
                                ],
                              ),
                            ),
                          ),
                          timeIndicatorsVisible
                              ? Align(
                                  alignment: Alignment.bottomCenter,
                                  child: TimeBar(
                                    progress: player2Progress.toDouble(),
                                    barColor: Colors.red,
                                  ),
                                )
                              : SizedBox.shrink(),
                          DelayIndicator(player2DelayProgress.toDouble(), 2),
                          playermessages[1] != ""
                              ? IgnorePointer(
                                  child: Align(
                                    alignment: Alignment(0, -0.6),
                                    child: Text(
                                      playermessages[1],
                                      style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: playermessagecolor,
                                      ),
                                    ),
                                  ),
                                )
                              : SizedBox.shrink(),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Stack(
                      children: [
                        Material(
                          color: Colors.white,
                          child: InkWell(
                            highlightColor: Colors.grey[500],
                            splashColor: Colors.grey[300],
                            onTap: () {
                              playerTapsField(1);
                            },
                            child: Stack(
                              children: [
                                Center(
                                  child: Text(
                                    displayedTimePlayer1,
                                    style: TextStyle(
                                      color: Colors.grey[900],
                                      fontSize: 90,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                moveCounterVisible
                                    ? Align(
                                        alignment: Alignment(-0.8, 0.75),
                                        child: Text(
                                          player1Moves.toString(),
                                          style: TextStyle(
                                            color: playermessagecolor,
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    : SizedBox.shrink(),
                              ],
                            ),
                          ),
                        ),
                        timeIndicatorsVisible
                            ? Align(
                                alignment: Alignment.bottomCenter,
                                child: TimeBar(
                                  progress: player1Progress.toDouble(),
                                  barColor: Colors.blue,
                                ),
                              )
                            : SizedBox.shrink(),
                        DelayIndicator(player1DelayProgress.toDouble(), 1),
                        playermessages[0] != ""
                            ? IgnorePointer(
                                child: Align(
                                  alignment: Alignment(0, -0.6),
                                  child: Text(
                                    playermessages[0],
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      color: playermessagecolor,
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox.shrink(),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: middleButtons,
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
