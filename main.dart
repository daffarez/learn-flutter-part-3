// import 'dart:developer';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

void main() {
  runApp(
    const FriendlyChatApp(),
  );
}

final ThemeData kIOSTheme = ThemeData(
    primarySwatch: Colors.orange,
    primaryColor: Colors.grey[100],
    primaryColorBrightness: Brightness.light);

final ThemeData kDefaultTheme = ThemeData(
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.teal)
        .copyWith(secondary: Colors.indigoAccent[400]));

class FriendlyChatApp extends StatelessWidget {
  const FriendlyChatApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FriendlyChat',
      theme: Platform.isIOS ? kIOSTheme : kDefaultTheme,
      home: const ChatScreen(),
    );
  }
}

class ChatMessage extends StatelessWidget {
  const ChatMessage(
      {required this.text, required this.animationController, Key? key})
      : super(key: key);
  final String text;
  final AnimationController animationController;

  @override
  Widget build(BuildContext context) {
    String _name = "John Doe";
    var _nameArray = _name.split(" ");
    String _firstName = _nameArray[0];
    String _lastName = _nameArray[1];
    return SizeTransition(
      sizeFactor:
          CurvedAnimation(parent: animationController, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  margin: const EdgeInsets.only(right: 16.0),
                  child: CircleAvatar(
                      child: Text('${_firstName[0]}${_lastName[0]}'),
                      backgroundColor:
                          Platform.isIOS ? Colors.orange : Colors.teal)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_name, style: Theme.of(context).textTheme.subtitle1),
                    Container(
                      margin: const EdgeInsets.only(top: 5.0),
                      child: Text(text),
                    )
                  ],
                ),
              )
            ],
          )),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final List<ChatMessage> _message = [];
  final _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isComposing = false;

  @override
  void dispose() {
    for (var message in _message) {
      message.animationController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void _clearChat() {
      setState(() {
        _message.clear();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friendly Chat'),
        elevation: Platform.isIOS ? 0.0 : 4.0,
        actions: [
          Container(
            margin:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 17.0),
            child: InkWell(
              child: const Text('Clear',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: _clearChat,
            ),
          )
        ],
      ),
      body: Container(
        child: Column(
          children: [
            Flexible(
                child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              reverse: true,
              itemBuilder: (_, index) => _message[index],
              itemCount: _message.length,
            )),
            const Divider(height: 1.0),
            Container(
              decoration: BoxDecoration(color: Theme.of(context).cardColor),
              child: _buildTextComposer(),
            )
          ],
        ),
        decoration: Platform.isIOS
            ? BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[200]!)))
            : null,
      ),
    );
  }

  Widget _buildTextComposer() {
    bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom != 0.0;
    void _handleSubmitted(String text) {
      _textController.clear();
      setState(() {
        _isComposing = false;
      });
      var message = ChatMessage(
        text: text,
        animationController: AnimationController(
            duration: const Duration(milliseconds: 500), vsync: this),
      );
      setState(() {
        _message.insert(0, message);
      });
      _focusNode.requestFocus();
      message.animationController.forward();
    }

    _onClickSendButton() {
      return _isComposing ? () => _handleSubmitted(_textController.text) : null;
    }

    return Container(
      margin: EdgeInsets.only(
          left: 10.0, bottom: Platform.isIOS && !isKeyboardOpen ? 18.0 : 0.0),
      child: Row(
        children: [
          Flexible(
            child: TextField(
                controller: _textController,
                onChanged: (text) {
                  setState(() {
                    _isComposing = text.isNotEmpty;
                  });
                },
                onSubmitted: _isComposing ? _handleSubmitted : null,
                decoration:
                    const InputDecoration.collapsed(hintText: 'Send a Message'),
                focusNode: _focusNode),
          ),
          IconTheme(
              data: const IconThemeData(),
              child: CupertinoButton(
                  child: const Text('Send'), onPressed: _onClickSendButton()))
        ],
      ),
    );
  }
}
