import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';

import 'package:bu_pulse/data/models/online/questions_model.dart';
import 'package:bu_pulse/data/models/online/surveys_model.dart';
import 'package:bu_pulse/helpers/functions.dart';
import 'package:bu_pulse/helpers/variables.dart';
import 'package:bu_pulse/screens/online/question_screen.dart';
import 'package:bu_pulse/screens/online/review_screen.dart';
import 'package:bu_pulse/services/online/sound_player_service.dart';
import 'package:bu_pulse/services/online/sound_recorder_service.dart';
import 'package:bu_pulse/widgets/audio_button_widget.dart';
import 'package:bu_pulse/widgets/timer_widget.dart';

class RecordScreen extends StatefulWidget {
  final Questions question;
  final Surveys survey;
  final String screen;
  final List<String> addresses;
  final int? index;

  const RecordScreen({
    super.key,
    required this.question,
    required this.survey,
    required this.screen,
    required this.addresses,
    this.index,
  });

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  final timerController = TimerController();
  final recorder = SoundRecorderService();
  final player = SoundPlayerService();

  @override
  void initState() {
    super.initState();

    recorder.init(question: widget.question);
    player.init(question: widget.question);
  }

  @override
  void dispose() {
    player.dispose();
    recorder.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Local to API not yet sent items submission
    Functions.localToApi();

    return FutureBuilder(
      future: Functions.buildAudioFileWidget(
        questionId: widget.question.id,
        surveyId: widget.question.surveyId ?? 0
      ),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            appBar: _buildAppBar(context),
            body: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPlayer(),
                    const SizedBox(height: 16),
                    _buildStart(),
                    const SizedBox(height: 20),
                    _buildPlay(),
                    const SizedBox(height: 20),
                    snapshot.data
                  ],
                ),
              ),
            ),
          );
        } else {
          return const CircularProgressIndicator();
        }
      }
    );
  }

  Widget _buildPlay() {
    bool isPlaying = player.isPlaying;
    IconData icon = isPlaying ? Icons.stop : Icons.play_arrow;
    String text = isPlaying ? 'Stop Playing' : 'Play Recording';
    Color backgroundC = isPlaying ? AppColor.darkError : AppColor.primary;

    return AudioButtonWidget(
      text: text,
      color: AppColor.subPrimary,
      backgroundColor: backgroundC,
      icon: icon,
      onClicked: () async {
        if (recorder.isRecording) return;

        await player.togglePlaying(whenFinished: () => setState(() {}));
        setState(() {});
      },
    );
  }

  Widget _buildStart() {
    bool isRecording = recorder.isRecording;
    IconData icon = isRecording ? Icons.stop : Icons.mic;
    String text = isRecording ? 'Stop Recording' : 'Record';
    Color backgroundC = isRecording ? AppColor.darkError : AppColor.primary;

    return AudioButtonWidget(
      text: text,
      color: AppColor.subPrimary,
      backgroundColor: backgroundC,
      icon: icon,
      onClicked: () async {
        if (player.isPlaying) return;

        await recorder.toggleRecording();
        final isRecording = recorder.isRecording;
        setState(() {});

        if (isRecording) {
          timerController.startTimer();
        } else {
          timerController.stopTimer();
        }
      },
    );
  }

  Widget _buildPlayer() {
    String text = recorder.isRecording ? 'Now Recording' : 'Press Record';
    bool animate = player.isPlaying || recorder.isRecording;

    return AvatarGlow(
      endRadius: 140,
      animate: animate,
      repeatPauseDuration: const Duration(seconds: 1),
      glowColor: AppColor.subSecondary,
      child: CircleAvatar(
        radius: 105,
        backgroundColor: AppColor.warning,
        child: CircleAvatar(
          radius: 92,
          backgroundColor: AppColor.primary,
          child: player.isPlaying
            ? Icon(
              Icons.audiotrack_outlined,
              size: 120,
              color: AppColor.subPrimary,
            ) : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.mic,
                  size: 32,
                  color: AppColor.subPrimary,
                ),
                TimerWidget(controller: timerController),
                const SizedBox(height: 8),
                Text(
                  text,
                  style: TextStyle(color: AppColor.subPrimary),
                ),
              ],
            ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(context) {
    return AppBar(
      foregroundColor: AppColor.subPrimary,
      title: const Text('Record Answer'),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColor.linearGradient,
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
      ),
      leading: BackButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => widget.screen == "Question" ?
                QuestionScreen(
                  survey: widget.survey,
                  addresses: widget.addresses,
                  index: widget.index,
                ) : ReviewScreen(
                  survey: widget.survey,
                  addresses: widget.addresses,
                ),
            ),
          );
        },
      ),
    );
  }
}
