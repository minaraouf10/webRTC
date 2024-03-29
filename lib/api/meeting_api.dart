import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:untitled10/utils/user.utils.dart';

String MEETING_API_URL = "http://192.168.1.3:4000/api/meeting";

var client = http.Client();

Future<http.Response?> startMeeting() async {
  Map<String, String> requestHeaders = {'Content-Type': 'application/json'};

  var userId = await loadUserId();

  var response = await client.post(
    Uri.parse('$MEETING_API_URL/start'),
    headers: requestHeaders,
    body: jsonEncode(
      {'hostId': userId, 'hostName': ' Mina Pc'},
    ),
  );

  if (response.statusCode == 200) {
    log(response.body,name: "log startMeeting");
    return response;
  } else {
    return null;
  }
}

Future<http.Response> joinMeeting(String meetingId) async {
  var response =
      await http.get(Uri.parse('$MEETING_API_URL/join?meetingId=$meetingId'));
 log(response.body,name: "log join meeting");
  if (response.statusCode >= 200 && response.statusCode < 400) {
    return response;
  }
  throw UnsupportedError('Not a valid Meeting');
}
