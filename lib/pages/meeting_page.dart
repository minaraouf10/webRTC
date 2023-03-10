import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_webrtc_wrapper/flutter_webrtc_wrapper.dart';
import 'package:untitled10/models/meeting_details.dart';
import 'package:untitled10/pages/home_screen.dart';
import 'package:untitled10/utils/user.utils.dart';
import 'package:untitled10/widgets/control_panel.dart';

import '../widgets/remote_connection.dart';

class MeetingPage extends StatefulWidget {
  final String? meetingId;
  final String? name;
  final MeetingDetail meetingDetail;

  const MeetingPage(
      {Key? key, this.meetingId, this.name, required this.meetingDetail})
      : super(key: key);

  @override
  State<MeetingPage> createState() => _MeetingPageState();
}

class _MeetingPageState extends State<MeetingPage> {
  final _localRenderer = RTCVideoRenderer();
  final Map<String, dynamic> mediaConstraints = {"audio": true, "video": true};
  bool isConnectionFailed = false;
  WebRTCMeetingHelper? meetingHelper;

  @override
  Widget build(BuildContext context) {
    log(widget.meetingDetail.toString(), name: "log body");
    return Scaffold(
      backgroundColor: Colors.black87,
      body: _buildMeetingRoom(),
      bottomNavigationBar: ControlPanel(
        onAudioToggle: onAudioToggle,
        onVideoToggle: onVideoToggle,
        videoEnabled: isVideoEnabled(),
        audioEnabled: isAudioEnabled(),
        isConnectionFailed: isConnectionFailed,
        onReconnect: handleReconnect,
        onMeetingEnd: onMeetingEnd,
      ),
    );
  }

  void startMeeting() async {
    log(widget.meetingDetail.toString(), name: "log startMeeting");
    final String userId = await loadUserId();

    log(widget.meetingDetail.id.toString(),name: "anas stream");
    log(userId.toString());

    meetingHelper = WebRTCMeetingHelper(
        url: "http://192.168.81.37:4000", //IP your PC
        meetingId: widget.meetingDetail.id,
        userId: userId,
        name: widget.name);
    log(widget.meetingDetail.id.toString(),name: "ahmed stream");
    log(userId.toString());

    MediaStream localStream =
        await navigator.mediaDevices.getUserMedia(mediaConstraints);

    _localRenderer.srcObject = localStream;
    meetingHelper!.stream = localStream;

    meetingHelper!.on("open", context, (ev, context) {
      log("open", name: "log start meeting");
      setState(() {
        isConnectionFailed = false;
      });
    });

    meetingHelper!.on("connection", context, (ev, context) {
      log("connection", name: "log connection");
      setState(() {
        isConnectionFailed = false;
      });
    });

    meetingHelper!.on("user-left", context, (ev, context) {
      log("user-left", name: "log user-left");
      setState(() {
        isConnectionFailed = false;
      });
    });

    meetingHelper!.on("video-toggle", context, (ev, context) {
      log("video-toggle", name: "log video-toggle");
      setState(() {});
    });

    meetingHelper!.on("audio-toggle", context, (ev, context) {
      log("audio-toggle", name: "log audio-toggle");
      setState(() {});
    });

    meetingHelper!.on("meeting-ended", context, (ev, context) {
      log("meeting-ended", name: "log meeting-ended");
      onMeetingEnd();
    });

    meetingHelper!.on("connection-setting-changed", context, (ev, context) {
      log("connection-setting-changed", name: "log meeting-ended");
      setState(() {
        isConnectionFailed = false;
      });
    });

    meetingHelper!.on("stream-changed", context, (ev, context) {
      log("stream-changed", name: "log meeting-ended");
      setState(() {
        isConnectionFailed = false;
      });
    });

    setState(() {});
  }

  initRenderers() async {
    await _localRenderer.initialize();
  }

  @override
  void initState() {
    // TODO: implement initState
    log(widget.meetingDetail.toString(), name: "log iniState");
    super.initState();
    initRenderers();
    startMeeting();
  }

  @override
  void deactivate() {
    super.deactivate();
    _localRenderer.dispose();
    if (meetingHelper != null) {
      meetingHelper!.destroy();
      meetingHelper = null;
    }
  }

  void onMeetingEnd() {
    if (meetingHelper != null) {
      meetingHelper!.endMeeting();
      meetingHelper = null;
      goToHomePage();
    }
  }

  _buildMeetingRoom() {
    return Stack(
      children: [
        meetingHelper != null && meetingHelper!.connections.isNotEmpty
            ? GridView.count(
                crossAxisCount: meetingHelper!.connections.length < 3 ? 1 : 2,
                children:
                    List.generate(meetingHelper!.connections.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.all(1),
                    child: RemoteConnection(
                        renderer: meetingHelper!.connections[index].renderer,
                        connection: meetingHelper!.connections[index]),
                  );
                }),
              )
            : const Center(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "Waiting for participants to join the meeting",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 24.0),
                  ),
                ),
              ),
        Positioned(
          bottom: 10.0,
          right: 0,
          child: SizedBox(
            width: 150.0,
            height: 200.0,
            child: RTCVideoView(_localRenderer),
          ),
        )
      ],
    );
  }

  void onAudioToggle() {
    if (meetingHelper != null) {
      setState(() {
        meetingHelper!.toggleAudio();
      });
    }
  }

  void onVideoToggle() {
    if (meetingHelper != null) {
      setState(() {
        meetingHelper!.toggleVideo();
      });
    }
  }

  bool isVideoEnabled() {
    return meetingHelper != null ? meetingHelper!.videoEnabled! : false;
  }

  bool isAudioEnabled() {
    return meetingHelper != null ? meetingHelper!.audioEnabled! : false;
  }

  void handleReconnect() {
    if (meetingHelper != null) {
      meetingHelper!.reconnect();
    }
  }

  void goToHomePage() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const HomeScreenState()));
  }
}
