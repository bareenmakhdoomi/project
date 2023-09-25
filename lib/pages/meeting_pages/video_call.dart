import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter/material.dart';

class VideoCall extends StatefulWidget {
  String channelName = "salook";

  VideoCall({required this.channelName});
  @override
  _VideoCallState createState() => _VideoCallState();
}

class _VideoCallState extends State<VideoCall> {
  final AgoraClient client = AgoraClient(
      agoraConnectionData: AgoraConnectionData(
          appId: "ca5ee2a556864ff5ba576233d7c89983",
          channelName: "salook11",
          tempToken:
              "007eJxTYJCefuTly7zWlwukdCPPtj5sfRIZ/OZAtImPUMOsk9XzuHIVGJITTVNTjRJNTc0szEzS0kyTEk3NzYyMjVPMky0sLS2Mjyy8k9IQyMiQ8eUsKyMDBIL4HAzFiTn5+dmGhgwMAG4uIxA="),
      enabledPermission: [Permission.camera, Permission.microphone]);

  bool _loading = true;
  String tempToken = "";

  @override
  void initState() {
    getToken();
    initAgora();
    super.initState();
    initAgora();
  }

  void initAgora() async {
    await client.initialize();
  }

  Future<void> getToken() async {
     String link =
        "https://agora-node-tokenserver-1.davidcaleb.repl.co/access_token?channelName=${widget.channelName}";
    
     Response _response = await get(Uri.parse(link));
      Map data = jsonDecode(_response.body);
      setState(() {
     tempToken = data["token"];
    });
     _client = AgoraClient(
         agoraConnectionData: AgoraConnectionData(
           appId: "c25e3b5bab074d4da60302e5043c222d",
           tempToken: "007eJxTYDiz9VTKq0e6D5ZvPWxcrVZh25mvtqkrszQ+Uz7i69l8jaMKDMlGpqnGSaZJiUkG5iYpJimJZgbGBkappgYmxslGRkYp/+bfSWkIZGTYxK7HwsgAgSA+G0NxYk5+fjYDAwAUkSGk",
           channelName: "salook",
         ),
         enabledPermission: [Permission.camera, Permission.microphone]);
    Future.delayed(Duration(seconds: 1)).then(
      (value) => setState(() => _loading = false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: _loading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Stack(
                  children: [
                    AgoraVideoViewer(
                      client: client,
                      layoutType: Layout.floating,
                      enableHostControls: true,
                    ),
                    AgoraVideoButtons(
                      client: client,
                      addScreenSharing: true,
                    )
                  ],
                ),
        ),
      ),
    );
  }
}
