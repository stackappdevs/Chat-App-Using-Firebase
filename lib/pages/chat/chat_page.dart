import 'dart:convert';
import 'dart:io';

import 'package:chat_app/pages/chat/show_video/show_video_page.dart';
import 'package:chat_app/service/auth_service.dart';
import 'package:chat_app/service/user_service.dart';
import 'package:chat_app/widget/common_text.dart';
import 'package:chat_app/widget/common_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'package:video_thumbnail/video_thumbnail.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> userMap;
  final String chatRoomId;

  ChatScreen({Key? key, required this.userMap, required this.chatRoomId})
      : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController messageController = TextEditingController();
  bool isTapText = false;
  File? _image;
  String token =
      "coZVQYAoQf6XRO1WQ5VVDA:APA91bFm_aphExQ_94gxccFJblssGkB2Nxx9omlUfYpnI1-uQFoi7SYFsBb-oC23K65aziPbAUkHf6nXGU174SKWoPrDou-DGYwwhMfMGITRqwz_g0wXBINXfriOsLYBf0ESFlFyLAJV";

  AuthService authService = AuthService();
  UserService userService = UserService();

  String? loginUser;

  @override
  void initState() {
    loginUser = authService.auth.currentUser!.displayName;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            )),
        actions: [
          PopupMenuButton(
            icon: const Icon(
              Icons.more_vert,
              color: Colors.black,
            ),
            onSelected: (val) async {
              deleteAllMessage(val);
            },
            itemBuilder: (BuildContext context) {
              return {'Clear all chat', 'setting'}.map((String choice) {
                return PopupMenuItem(value: choice, child: Text(choice));
              }).toList();
            },
          )
        ],
      ),
      backgroundColor: Colors.teal.shade50,
      body: Stack(
        children: [
          SingleChildScrollView(
            reverse: true,
            child: Column(
              children: [
                Container(
                  height: height * 0.79,
                  padding: EdgeInsets.only(
                    top: height * 0.1,
                  ),
                  child: StreamBuilder(
                    stream: userService.collectionReferenceMessage
                        .doc(widget.chatRoomId)
                        .collection('chats')
                        .orderBy('time', descending: true)
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.data != null) {
                        return ListView.builder(
                            physics: BouncingScrollPhysics(),
                            reverse: true,
                            padding: EdgeInsets.symmetric(vertical: 10),
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, i) {
                              var day;


                              Map<String, dynamic> data = snapshot.data!.docs[i]
                                  .data() as Map<String, dynamic>;

                              data['id'] = snapshot.data!.docs[i].id;

                              DateTime hour = data['time'].toDate();

                              var now = hour;
                              String formattedTime =
                                  DateFormat('kk:mm:a').format(now);
                              String formattedDateTime =
                                  DateFormat('dd-MM-yyyy kk:mm:a').format(now);
                              /*  print(formattedTime);
                                print(formattedDateTime);*/

                              if (DateTime.now().day == hour.day) {
                                if (DateTime.now().minute == hour.minute) {
                                  day = 'Just now';
                                } else {
                                  day = 'Today $formattedTime';
                                }
                              } else if (DateTime.now()
                                      .subtract(Duration(days: 1))
                                      .day ==
                                  hour.day) {
                                day = 'Yesterday';
                              } else {
                                day = formattedDateTime;
                              }

                              // _videoPlayerController = VideoPlayerController.file(File(data["message"]));
                              return (data['type'] == "text")
                                  ? Container(
                                      margin: EdgeInsets.symmetric(
                                          vertical: height * 0.005,
                                          horizontal: width * 0.03),
                                      alignment: data['sendBy'] == loginUser
                                          ? Alignment.centerRight
                                          : Alignment.centerLeft,
                                      child: Column(
                                        crossAxisAlignment:
                                            data['sendBy'] == loginUser
                                                ? CrossAxisAlignment.end
                                                : CrossAxisAlignment.start,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                isTapText = !isTapText;
                                              });
                                            },
                                            onLongPress: () {
                                              deleteMessage(data['id']);
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: height * 0.01,
                                                  horizontal: width * 0.05),
                                              decoration: BoxDecoration(
                                                  borderRadius: data[
                                                              'sendBy'] ==
                                                          loginUser
                                                      ? BorderRadius.circular(
                                                              15)
                                                          .copyWith(
                                                              topRight:
                                                                  Radius.zero)
                                                      : BorderRadius.circular(
                                                              15)
                                                          .copyWith(
                                                              topLeft:
                                                                  Radius.zero),
                                                  color: data['sendBy'] ==
                                                          loginUser
                                                      ? Colors.teal.shade200
                                                      : Colors.teal),
                                              child: Text(
                                                data["message"],
                                                style: TextStyle(
                                                    color: data['sendBy'] ==
                                                            loginUser
                                                        ? Colors.black
                                                        : Colors.white),
                                              ),
                                            ),
                                          ),
                                          (isTapText)
                                              ? Container(
                                                  child: Row(
                                                  mainAxisAlignment: data[
                                                              'sendBy'] ==
                                                          loginUser
                                                      ? MainAxisAlignment.end
                                                      : MainAxisAlignment.start,
                                                  children: [
                                                    TextData(
                                                      text: '$day',
                                                      fontSize: 10,
                                                    ),
                                                    const SizedBox(width: 5,),
                                                    Icon(
                                                      Icons.done_all_rounded,
                                                      size: 15,
                                                      color:
                                                          data['read'] == 'true'
                                                              ? Colors.blue
                                                              : Colors.grey
                                                                  .shade500,
                                                    )
                                                  ],
                                                ))
                                              : SizedBox()
                                        ],
                                      ),
                                    )
                                  : (data['type'] == "img")
                                      ? Container(
                                          margin: EdgeInsets.symmetric(
                                              vertical: height * 0.005,
                                              horizontal: width * 0.03),
                                          alignment: data['sendBy'] == loginUser
                                              ? Alignment.centerRight
                                              : Alignment.centerLeft,
                                          child: Column(
                                            crossAxisAlignment:
                                                data['sendBy'] == loginUser
                                                    ? CrossAxisAlignment.end
                                                    : CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                height: height * 0.25,
                                                width: width,
                                                alignment:
                                                    data['sendBy'] == loginUser
                                                        ? Alignment.centerRight
                                                        : Alignment.centerLeft,
                                                child: InkWell(
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                ShowImage(
                                                                    imageUrl: data[
                                                                        'message'])));

                                                    isTapText = !isTapText;
                                                    setState(() {});
                                                  },
                                                  onLongPress: () {
                                                    deleteMessage(data['id']);
                                                  },
                                                  child: Container(
                                                      height: height * 0.25,
                                                      width: width * 0.35,
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                            color: Colors
                                                                .teal.shade200,
                                                            width: 2,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      15)),
                                                      child: (data['message'] !=
                                                              "")
                                                          ? ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15),
                                                              child:
                                                                  Image.network(
                                                                data['message'],
                                                                fit: BoxFit
                                                                    .cover,
                                                                height: height *
                                                                    0.25,
                                                                width: width *
                                                                    0.35,
                                                              ))
                                                          : const Center(
                                                              child:
                                                                  CircularProgressIndicator())),
                                                ),
                                              ),
                                              (isTapText)
                                                  ? Container(
                                                      child: Row(
                                                      mainAxisAlignment: data[
                                                                  'sendBy'] ==
                                                              loginUser
                                                          ? MainAxisAlignment
                                                              .end
                                                          : MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        TextData(
                                                          text: '$day',
                                                          fontSize: 10,
                                                        ),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        Icon(
                                                          Icons
                                                              .done_all_rounded,
                                                          size: 15,
                                                          color: data['read'] ==
                                                                  'true'
                                                              ? Colors.blue
                                                              : Colors.grey
                                                                  .shade500,
                                                        )
                                                      ],
                                                    ))
                                                  : const SizedBox()
                                            ],
                                          ),
                                        )
                                      : Container(
                                          margin: EdgeInsets.symmetric(
                                              vertical: height * 0.005,
                                              horizontal: width * 0.03),
                                          alignment: data['sendBy'] == loginUser
                                              ? Alignment.centerRight
                                              : Alignment.centerLeft,
                                          child: Column(
                                            crossAxisAlignment:
                                                data['sendBy'] == loginUser
                                                    ? CrossAxisAlignment.end
                                                    : CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                height: height * 0.25,
                                                width: width,
                                                alignment:
                                                    data['sendBy'] == loginUser
                                                        ? Alignment.centerRight
                                                        : Alignment.centerLeft,
                                                child: InkWell(
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    ShowVideo(
                                                                      videoUrl:
                                                                          data[
                                                                              'message'],
                                                                      name: data[
                                                                          'sendBy'],
                                                                    )));

                                                    isTapText = !isTapText;
                                                    setState(() {});
                                                  },
                                                  onLongPress: () {
                                                    deleteMessage(data['id']);
                                                  },
                                                  child: Container(
                                                      height: height * 0.25,
                                                      width: width * 0.35,
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                            color: Colors
                                                                .teal.shade200,
                                                            width: 2,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      15)),
                                                      child: (data['message'] !=
                                                              "")
                                                          ? ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15),
                                                              child: Stack(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                children: [
                                                                  Image.network(
                                                                    data[
                                                                        'thumbnail'],
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    height:
                                                                        height *
                                                                            0.25,
                                                                    width:
                                                                        width *
                                                                            0.35,
                                                                  ),
                                                                  const CircleAvatar(
                                                                    backgroundColor:
                                                                        Colors
                                                                            .black26,
                                                                    child: Icon(
                                                                      Icons
                                                                          .play_arrow,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  )
                                                                ],
                                                              ))
                                                          : const Center(
                                                              child:
                                                                  CircularProgressIndicator())),
                                                ),
                                              ),
                                              (isTapText)
                                                  ? Container(
                                                      child: Row(
                                                      mainAxisAlignment: data[
                                                                  'sendBy'] ==
                                                              loginUser
                                                          ? MainAxisAlignment
                                                              .end
                                                          : MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        TextData(
                                                          text: '$day',
                                                          fontSize: 10,
                                                        ),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        Icon(
                                                          Icons
                                                              .done_all_rounded,
                                                          size: 15,
                                                          color: data['read'] ==
                                                                  'true'
                                                              ? Colors.blue
                                                              : Colors.grey
                                                                  .shade500,
                                                        )
                                                      ],
                                                    ))
                                                  : const SizedBox()
                                            ],
                                          ),
                                        );
                            });
                      } else {
                        return Container();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: height * 0.10,
            padding: EdgeInsets.only(left: width * 0.03, right: width * 0.04),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                )),
            child: StreamBuilder<DocumentSnapshot>(
              stream: userService.collectionReference
                  .doc(widget.userMap['uid'])
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.data != null) {
                  if (snapshot.data!['status'] == "Online") {
                    readMessage();
                  }

                  print("======>${snapshot.data!['status']}");
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                  width: width * 0.7,
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.symmetric(
                                      horizontal: width * 0.04),
                                  child: TextData(
                                    text:
                                        '${widget.userMap['name'][0].toString().toUpperCase()}${widget.userMap['name'].toString().substring(1)}',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 25,
                                  )),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  width: width * 0.7,
                                  child: TextData(
                                    text: '${snapshot.data!['status']}',
                                    fontSize: 12,
                                    color: Colors.teal,
                                  )),
                            ],
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.teal,
                            radius: width * 0.07,
                            child: TextData(
                              text: widget.userMap['name'][0]
                                  .toString()
                                  .toUpperCase(),
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontSize: 25,
                            ),
                          )
                        ],
                      )
                    ],
                  );
                }
                return SizedBox();
              },
            ),
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          color: Colors.teal.shade50,
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Expanded(
                child: Card(
                    elevation: 5,
                    shape: const StadiumBorder(),
                    child: ChatTextField(
                      title: 'Write a message',
                      controller: messageController,
                      prefixIcon: IconButton(
                        onPressed: () {
                          showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return Container(
                                  child: Wrap(
                                    children: [
                                      ListTile(
                                        leading: const Icon(Icons.camera_alt),
                                        title: const Text('Camera'),
                                        onTap: () {
                                          getImage(source: ImageSource.camera);
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.photo_library),
                                        title: const Text('Gallery'),
                                        onTap: () {
                                          getImage(source: ImageSource.gallery);
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.video_call_rounded),
                                        title: const Text('Video'),
                                        onTap: () {
                                          getVideo();
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              });
                          FocusScope.of(context).unfocus();
                        },
                        icon: Icon(
                          Icons.attach_file,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.teal,
                          child: IconButton(
                              onPressed: () {
                                onSendMessage();
                                FocusManager.instance.primaryFocus!.unfocus();
                              },
                              splashRadius: 1,
                              icon: const Icon(
                                Icons.send,
                                color: Colors.white,
                                size: 20,
                              )),
                        ),
                      ),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onSendMessage() async {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> message = {
        "sendBy": loginUser,
        "type": "text",
        "message": messageController.text,
        "read": 'false',
        "time": DateTime.now(),
      };

      pushNotification(
          message: messageController.text,
          receiverName: widget.userMap['name'],
          token: token);

      messageController.clear();

      await userService.collectionReferenceMessage
          .doc(widget.chatRoomId)
          .collection('chats')
          .add(message);
    } else {
      print('enter Some text');
    }
  }

  Future getImage({required ImageSource source}) async {
    ImagePicker picker = ImagePicker();

    final pickImage = await picker.pickImage(source: source);

    if (pickImage != null) {
      _image = File(pickImage.path);

      uploadImage();
      setState(() {});
    }
  }

  Future uploadImage() async {
    var fileName = DateTime.now().millisecondsSinceEpoch;
    int status = 1;

    await userService.collectionReferenceMessage
        .doc(widget.chatRoomId)
        .collection('chats')
        .doc('$fileName')
        .set({
      "sendBy": loginUser,
      "type": "img",
      "message": "",
      "read": "false",
      "time": DateTime.now(),
    });

    var ref = firebase_storage.FirebaseStorage.instance
        .ref('images')
        .child('$fileName.jpg');

    var uploadTask = await ref.putFile(_image!).catchError((error) async {
      await userService.collectionReferenceMessage
          .doc(widget.chatRoomId)
          .collection('chats')
          .doc('$fileName')
          .delete();

      status = 0;
    });

    if (status == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();

      await userService.collectionReferenceMessage
          .doc(widget.chatRoomId)
          .collection('chats')
          .doc('$fileName')
          .update({"message": imageUrl});
    }
  }

  getVideo() async {
    ImagePicker picker = ImagePicker();

    final pickVideo = await picker.pickVideo(source: ImageSource.gallery);

    if (pickVideo != null) {
      _image = File(pickVideo.path);
      uploadVideo();
      setState(() {});
    }
  }

  Future uploadVideo() async {
    var fileName = DateTime.now().millisecondsSinceEpoch;
    int status = 1;

    var thumbnailFile = await VideoThumbnail.thumbnailFile(
      video: _image!.path,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 512,
      quality: 100,
    );

    await userService.collectionReferenceMessage
        .doc(widget.chatRoomId)
        .collection('chats')
        .doc('$fileName')
        .set({
      "sendBy": loginUser,
      "type": "video",
      "thumbnail": thumbnailFile,
      "message": "",
      "read": "false",
      "time": DateTime.now(),
    });

    var ref = firebase_storage.FirebaseStorage.instance
        .ref('videos')
        .child('$fileName.mp4');

    var uploadTask = await ref.putFile(_image!).catchError((error) async {
      await userService.collectionReferenceMessage
          .doc(widget.chatRoomId)
          .collection('chats')
          .doc('$fileName')
          .delete();

      status = 0;
    });

    var ref1 = firebase_storage.FirebaseStorage.instance
        .ref('thumbnails')
        .child('$fileName.mp4');

    var uploadTaskThumbnail =
        await ref1.putFile(File(thumbnailFile!)).catchError((error) async {
      await userService.collectionReferenceMessage
          .doc(widget.chatRoomId)
          .collection('chats')
          .doc('$fileName')
          .delete();
    });

    if (status == 1) {
      String videoUrl = await uploadTask.ref.getDownloadURL();
      String thumbnail = await uploadTaskThumbnail.ref.getDownloadURL();

      await userService.collectionReferenceMessage
          .doc(widget.chatRoomId)
          .collection('chats')
          .doc('$fileName')
          .update({"message": videoUrl, "thumbnail": thumbnail});
    }
  }

  deleteAllMessage(Object? value) async {
    if (value == 'Clear all chat') {
      final batch = FirebaseFirestore.instance.batch();

      var collection = userService.collectionReferenceMessage
          .doc(widget.chatRoomId)
          .collection('chats');
      var snapshots = await collection.get();
      for (var doc in snapshots.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      setState(() {});
    }
  }

  deleteMessage(String id) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const TextData(text: 'Delete'),
            content: const TextData(text: 'Are you sure you want to delete massage?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const TextData(text: 'Cancel')),
              TextButton(
                  onPressed: () {
                    FirebaseFirestore.instance
                        .collection('ChatRoom')
                        .doc(widget.chatRoomId)
                        .collection('chats')
                        .doc(id)
                        .delete();
                    Navigator.of(context).pop();
                  },
                  child: const TextData(
                    text: 'Delete',
                  ))
            ],
          );
        });
  }

  Future pushNotification(
      {String? message, String? receiverName, String? token}) async {
    String baseUrl = 'https://fcm.googleapis.com/fcm/send';
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization':
          'key=AAAAlEDRV9M:APA91bEH6GUMHAYfH4Xtzr-C0t3-1Rz-3QptKx0x0UjYct7-L-u6v3n6HlqJejynJnMx9KJYFhx4TaykGdtfF5Bd8NCRRUuZb_cM4KRgDbnshTIF1zVn7QqQV2gM_Ub5AuM5-PIAww-L',
    };
    String body = jsonEncode({
      "notification": {
        "body": message,
        "title": receiverName!.toUpperCase(),
      },
      "priority": "high",
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "id": "1",
        "status": "done",
        "open_val": "B",
      },
      "registration_ids": [token]
    });
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: body,
    );
    print('Status code : ${response.statusCode}');
    print('Body : ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      var message = jsonDecode(response.body);
      return message;
    } else {
      print('Status code : ${response.statusCode}');
    }
  }

  void readMessage() async {
    var collection = userService.collectionReferenceMessage
        .doc(widget.chatRoomId)
        .collection(('chats'));
    var querySnapshots = await collection.get();
    for (var doc in querySnapshots.docs) {
      await doc.reference.update({
        'read': 'true',
      });
    }

    // await  AuthHelper.collectionReferenceMessage.doc(widget.chatRoomId).collection('chats').doc().update({"read" : "true"});
  }
}

class ShowImage extends StatelessWidget {
  final String? imageUrl;

  ShowImage({Key? key, this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
          body: Container(
        height: height,
        width: double.infinity,
        color: Colors.black,
        child: Image.network(imageUrl!),
      )),
    );
  }
}
