import 'package:chat_app/pages/chat/chat_page.dart';
import 'package:chat_app/service/auth_service.dart';
import 'package:chat_app/service/user_service.dart';
import 'package:chat_app/widget/common_text.dart';
import 'package:chat_app/widget/common_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class ChatHomePage extends StatefulWidget {
  const ChatHomePage({Key? key}) : super(key: key);

  @override
  _ChatHomePageState createState() => _ChatHomePageState();
}

class _ChatHomePageState extends State<ChatHomePage> with WidgetsBindingObserver {




  String chatRoomId(String user1, String user2) {
    if (user1[0]
        .toLowerCase()
        .codeUnits[0] > user2
        .toLowerCase()
        .codeUnits[0]) {
      return '$user1$user2';
    }
    else {
      return '$user2$user1';
    }
  }

  GlobalKey<FormState> formKey2 = GlobalKey<FormState>();

  UserService userService = UserService();
  AuthService authService = AuthService();

  TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  String? email;
  List? filterList = [];
  final List allUser = [];

  Stream<QuerySnapshot>? _usersStream;


  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addObserver(this);
    _usersStream = userService.collectionReference.snapshots();

    email = FirebaseAuth.instance.currentUser!.email!
        .split('@')
        .first
        .toUpperCase();
  }

      void setStatus(String status)async{
        userService.collectionReference.doc(authService.auth.currentUser!.uid).update({
          "status" : status,
      });



  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state){
      if(state == AppLifecycleState.resumed){
          setStatus('Online');

      }
      else{
        setStatus('Offline');
      }
  }

  @override
  Widget build(BuildContext context) {

    double height = MediaQuery
        .of(context)
        .size
        .height;
    double width = MediaQuery
        .of(context)
        .size
        .width;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(onPressed: () =>
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/', (route) => false), icon: const Icon(Icons.arrow_back),),
        title: Text('Welcome $email'),
        actions: [
          IconButton(
              onPressed: () async {
                await authService.signOut();

                Navigator.of(context)
                    .pushNamedAndRemoveUntil('chat_login', (route) => false);
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: (isLoading)
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : Container(
        margin: EdgeInsets.all(width * 0.02).copyWith(top: height * 0.06),
        child: Column(
          children: [
            Card(
              shape: const StadiumBorder(),
              elevation: 5,
              margin: EdgeInsets.symmetric(horizontal: width * 0.05),
              child: Form(
                key: formKey2,
                child:ChatTextField(
                  title: 'Search a friend',
                  keyBordType: TextInputType.emailAddress,
                  controller: searchController,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: CircleAvatar(
                      radius: 19,
                      backgroundColor: Colors.teal,
                      child: Icon(Icons.search,color: Colors.white,size: 20,)
                    ),
                  ),
                  onChanged:(val){
                    filterList!.clear();
                    allUser.forEach((e) {
                      if(e['email'].toString().toLowerCase().contains(searchController.text.toLowerCase())){
                        filterList!.add(e);
                      }
                    });

                    setState(() {});
                  } ,
                )
              ),
            ),
            SizedBox(
              height: height * 0.05,
            ),
            Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.centerLeft,
                child: const TextData(text: 'Conversations',fontWeight: FontWeight.w500,fontSize: 25,),),
            SizedBox(height: height * 0.02,),
            Expanded(
              child: Container(
                child: StreamBuilder(
                    stream: _usersStream,
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('${snapshot.error}'),);
                      }
                      if (snapshot.hasData) {
                        allUser.clear();

                        snapshot.data!.docs.map((DocumentSnapshot snapshot) {
                          Map a = snapshot.data() as Map<String, dynamic>;
                          allUser.add(a);
                        }).toList();


                        List chatUserList = [];

                        (searchController.text.isNotEmpty) ? chatUserList = filterList! : chatUserList = allUser;
                        return ListView.builder(
                            itemCount: chatUserList.length,
                            itemBuilder: (context, i) {
                              if(snapshot.data!.docs[i]['uid'] == FirebaseAuth.instance.currentUser!.uid){
                                return const SizedBox();
                              }
                              else{
                                return ListTile(
                                  onTap: () {


                                    String roomId = chatRoomId(
                                        '${FirebaseAuth.instance.currentUser!
                                            .displayName}', chatUserList[i]['name']);


                                    Navigator.push(context, MaterialPageRoute(
                                        builder: (context) {
                                          return ChatScreen(chatRoomId: roomId,
                                            userMap: chatUserList[i],);
                                        })
                                    );
                                    FocusScope.of(context).unfocus();
                                    searchController.clear();
                                  },
                                  leading: CircleAvatar(
                                    radius: height * 0.040,
                                    backgroundColor: Colors.teal,
                                    child: TextData(text: chatUserList[i]['name'][0]
                                        .toString()
                                        .toUpperCase(),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 30,),
                                  ),
                                  title: TextData(text: '${chatUserList[i]['name'][0]
                                      .toString()
                                      .toUpperCase()}${chatUserList[i]['name']
                                      .toString()
                                      .substring(1)} ',),
                                  subtitle: Text(chatUserList[i]['email']),
                                );
                              }
                            }
                        );
                      }
                      return const Center(child: CircularProgressIndicator(),);
                    }
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
