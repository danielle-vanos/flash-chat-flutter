import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;
late User loggedInUser;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen'; 
  
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  late String messageText;

  void getCurrentUser() async {
    try{
      final user = await _auth.currentUser;
      if (user != null){
        loggedInUser = user;
        print(loggedInUser.email);
      }
    }
    catch(e){
      print(e);
    }
  }


  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            streamBubble(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;                        
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _firestore.collection('messages').add(
                        {
                          'sender': loggedInUser.email, 
                          'text': messageText
                        }                        
                      );
                      messageTextController.clear();
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// streamBubble ---------------------------------------
class streamBubble extends StatelessWidget {
  streamBubble();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messages').snapshots(), 
      builder: (context, snapshot) {   
        List<messageBubble> messageWidgets = [];             
        if(!snapshot.hasData){
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent),
              );
        }
    
          final messages = snapshot.data!.docs;                  
          for(var message in messages){
            final messageText = message['text'];
            final messageSender = message['sender'];
            final currentUser = loggedInUser.email;
            final messageWidget = messageBubble(text: messageText, sender: messageSender, isMe: currentUser == messageSender,);
            print(currentUser);
            print(loggedInUser);
            messageWidgets.add(messageWidget);                    
                    
        }
        return Expanded(child: ListView(reverse: true, children: messageWidgets));
      }
      );
  }
}

// messageBubble --------------------------------------
class messageBubble extends StatelessWidget {

  messageBubble({required this.text, required this.sender, required this.isMe});

  final String text;
  final String sender;
  final bool isMe; 

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      child: Column(
        crossAxisAlignment: isMe? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            '$sender', 
            style: TextStyle(color: Colors.black54),
            ),
          Material(
            color: isMe? Colors.lightBlueAccent : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: isMe? Radius.circular(15) : Radius.circular(0),
              topRight: isMe? Radius.circular(0) : Radius.circular(15),
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15)
              ),
            elevation: 5,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(
                '$text',
                style: TextStyle(
                  color: isMe? Colors.white : Colors.black54
                ),    
              ),
            ),
          ),
        ],
      ),
    );
  }
}
