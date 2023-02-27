import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movie_br/model/video.dart';
import 'package:movie_br/view/utils/color.dart';
import 'package:movie_br/view/utils/text_styles.dart';
import 'package:movie_br/view/widgets/CustomPesquisar.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlay extends StatefulWidget {
  Video video;
  VideoPlay(this.video, {super.key});

  @override
  State<VideoPlay> createState() => _VideoPlayState();
}

class _VideoPlayState extends State<VideoPlay> {
  late YoutubePlayerController controller;
  late PlayerState playerState;
  late TextEditingController idController;
  late TextEditingController seekToController;
  late YoutubeMetaData videoMetaData;

  double volume = 100;
  bool muted = false;
  bool isPlayerReady = false;
  Widget get space => const SizedBox(height: 10);
  Widget get minSpace => const SizedBox(height: 5);

  void listener() {
    if (isPlayerReady && mounted && !controller.value.isFullScreen) {
      setState(() {
        playerState = controller.value.playerState;
        videoMetaData = controller.metadata;
      });
    }
  }

  Widget buildLoading() => const Center(
        child: CircularProgressIndicator(
          color: Colors.redAccent,
        ),
      );

  @override
  void initState() {
    super.initState();
    controller = YoutubePlayerController(
      initialVideoId: widget.video.id,
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    )..addListener(listener);
    idController = TextEditingController();
    seekToController = TextEditingController();
    videoMetaData = const YoutubeMetaData();
    playerState = PlayerState.unknown;
  }

  void deactive() {
    // Pausa o vídeo enquanto navega para a próxima página.
    controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    controller.dispose();
    idController.dispose();
    seekToController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.grey),
        backgroundColor: Colors.white,
        title: Image.asset(
          "imagens/youtube.png",
          width: 98,
          height: 22,
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              String? res = await showSearch(
                  context: context, delegate: CustomSearchDelegate());
              setState(() {});
              print("resultado: digitado " + res!);
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: YoutubePlayerBuilder(
          player: YoutubePlayer(
            controller: controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: const Color(0xFF1E579B),
            topActions: <Widget>[
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  widget.video.titulo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
            onReady: () {
              isPlayerReady = true;
            },
            onEnded: (data) {
              controller.load(widget.video.id);
            },
          ),
          builder: (context, player) => Scaffold(
            body: ListView(
              children: [
                GestureDetector(
                  onDoubleTap: () => controller.seekTo(
                    controller.value.position + const Duration(seconds: 10),
                  ),
                  child: player,
                ),
                Container(
                  color: Colors.black,
                  height: 68,
                  child: Column(
                    children: [
                      space,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: Icon(
                              controller.value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Colors.white,
                              size: 30,
                            ),
                            onPressed: isPlayerReady
                                ? () {
                                    controller.value.isPlaying
                                        ? controller.pause()
                                        : controller.play();
                                    setState(() {});
                                  }
                                : null,
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 100),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    muted ? Icons.volume_off : Icons.volume_up,
                                    color: Colors.white,
                                    size: 25,
                                  ),
                                  onPressed: isPlayerReady
                                      ? () {
                                          muted
                                              ? controller.unMute()
                                              : controller.mute();
                                          setState(() {
                                            muted = !muted;
                                          });
                                        }
                                      : null,
                                ),
                                const SizedBox(width: 10),
                                IconButton(
                                  icon: const Icon(
                                    Icons.content_copy,
                                    size: 22,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    Clipboard.setData(
                                      ClipboardData(
                                        text:
                                            'https://www.youtube.com/watch?v=${controller.metadata.videoId}',
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 10),
                                FullScreenButton(
                                  controller: controller,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      space,
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
                  child: Text(
                    controller.metadata.title,
                    style: TextStyles.articleTitleBold
                        .copyWith(color: Colors.black),
                  ),
                ),
                minSpace,
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15, top: 5),
                  child: Row(
                    children: [
                      Text(
                        "Por: ${widget.video.canal}",
                        style: TextStyles.link.copyWith(
                            color: Colors.blue[800],
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 5),
                      const Icon(
                        Icons.verified,
                        color: Color(0xFF1E579B),
                        size: 20,
                      ),
                    ],
                  ),
                ),
                space,
              ],
            ),
            bottomNavigationBar: IgnorePointer(
              ignoring: false,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20.0),
                        topLeft: Radius.circular(20.0)),
                  ),
                  minimumSize: Size(MediaQuery.of(context).size.width, 70),
                  primary: Colors.redAccent,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Assista na integra',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
                onPressed: () {},
              ),
            ),
          ),
        ),
      ),
    );
  }
}
