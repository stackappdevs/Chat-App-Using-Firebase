import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';


class ShowVideo extends StatefulWidget {
  final String? videoUrl;
  final String? name;

  ShowVideo({Key? key,this.videoUrl,this.name}) : super(key: key);

  @override
  _ShowVideoState createState() => _ShowVideoState();
}

class _ShowVideoState extends State<ShowVideo> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;


  @override
  void initState() {
    super.initState();

    getVideo();
  }

  getVideo()async{
    _videoPlayerController = VideoPlayerController.network(widget.videoUrl!);
    await _videoPlayerController.initialize().then((value) {setState(() {});});
    _chewieController=ChewieController(videoPlayerController: _videoPlayerController,autoPlay: true,);
  }
  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.name}'.toUpperCase()),),
      body: Container(
        color: Colors.black,
        height: double.infinity,
        width: double.infinity,
        child: (_videoPlayerController.value.isInitialized) ?
        AspectRatio(
          aspectRatio: _videoPlayerController.value.aspectRatio,
          child: Chewie(controller: _chewieController,),
        )
            :
        Center(child: CircularProgressIndicator()),
      ),
    );
  }
}