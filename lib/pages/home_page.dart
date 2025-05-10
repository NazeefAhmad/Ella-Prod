import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gemini_chat_app_tutorial/pages/settings.dart';
import '../services/chat_service.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import '../models/chat_user.dart' as model;
import '../models/chat_media.dart' as model;
import '../models/chat_message.dart' as model;
// import 'package:audioplayers/audioplayers.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final ChatService _chatService = ChatService();
  // final AudioPlayer _audioPlayer = AudioPlayer();
  List<model.ChatMessage> messages = [];
  bool isApiHealthy = false;
  bool hasChatStarted = false;
  bool isBotTyping = false;

  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final model.ChatUser currentUser = model.ChatUser(id: "user123", firstName: "User");
  final model.ChatUser botUser = model.ChatUser(
    id: "bot",
    firstName: "Ella",
    profileImage: "assets/images/Ella-Bot.jpeg",
  );

  final List<String> templates = [
    // 'Why is the sky blue?',
    // 'Will AI ever bond emotionally?',
    // 'Write a poem about a lonely robot.',
    // 'Who wrote the Harry Potter series?',
    // 'Can you suggest a personalized workout plan using AI',
  ];

  @override
  void initState() {
    super.initState();
    _checkApiHealth();
    _loadMessages();
  }

  // @override
  // void dispose() {
  //   _audioPlayer.dispose();
  //   super.dispose();
  // }

  Future<void> _checkApiHealth() async {
    try {
      isApiHealthy = await _chatService.checkHealth();
      if (!isApiHealthy) {
        Get.snackbar('Connection Error', 'Chat server is offline.',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      isApiHealthy = false;
    }
  }

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('chat_messages');
    if (saved != null) {
      final decoded = json.decode(saved) as List;
      setState(() {
        messages = decoded
            .map((m) => model.ChatMessage(
                  user: model.ChatUser(
                    id: m['user']['id'],
                    firstName: m['user']['firstName'],
                    profileImage: m['user']['profileImage'],
                  ),
                  createdAt: DateTime.parse(m['createdAt']),
                  text: m['text'],
                  medias: m['medias'] != null
                      ? List<model.ChatMedia>.from(
                          m['medias'].map((x) => model.ChatMedia(
                                url: x['url'],
                                fileName: x['fileName'],
                                type: model.MediaType.image,
                              )))
                      : null,
                ))
            .toList()
            .reversed
            .toList();
        hasChatStarted = messages.isNotEmpty;
      });
    }
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final toSave = messages.reversed.map((m) => {
          'user': {
            'id': m.user.id,
            'firstName': m.user.firstName,
            'profileImage': m.user.profileImage,
          },
          'createdAt': m.createdAt.toIso8601String(),
          'text': m.text,
          'medias': m.medias?.map((x) => {
                'url': x.url,
                'fileName': x.fileName,
                'type': 'image',
              }).toList(),
        }).toList();
    await prefs.setString('chat_messages', json.encode(toSave));
  }

  void _sendMessage(model.ChatMessage chatMessage) async {
    if (!isApiHealthy) {
      Get.snackbar('Error', 'Server unavailable. Try again later.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    setState(() {
      messages.insert(0, chatMessage);
      hasChatStarted = true;
      isBotTyping = true;
    });

    // await _audioPlayer.play(AssetSource('sounds/send.mp3'));
    _saveMessages();

    try {
      final response = await _chatService.sendMessage(
        userId: currentUser.id,
        message: chatMessage.text,
      );

      final botResponse = response['response'] ??
          'Sorry, I could not process your message.';

      final botMessage = model.ChatMessage(
        user: botUser,
        createdAt: DateTime.now(),
        text: botResponse,
      );

      setState(() {
        messages.insert(0, botMessage);
        isBotTyping = false;
      });

      // await _audioPlayer.play(AssetSource('sounds/receive.mp3'));
      _saveMessages();
    } catch (e) {
      setState(() {
        isBotTyping = false;
      });
      Get.snackbar('Error', 'Failed to send message.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _sendMediaMessage() async {
    final picker = ImagePicker();
    XFile? file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      final userText = _textEditingController.text.trim();

      final mediaMsg = model.ChatMessage(
        user: currentUser,
        createdAt: DateTime.now(),
        text: userText.isEmpty ? " " : userText,
        medias: [
          model.ChatMedia(
            url: file.path,
            fileName: file.name,
            type: model.MediaType.image,
          ),
        ],
      );

      _textEditingController.clear();
      _sendMessage(mediaMsg);
    }
  }

  Widget _buildTemplateItem(String title) {
    return Column(
      children: [
        Container(
         color: const Color.fromRGBO(251, 252, 254, .6),
          child: ListTile(
            leading: const Icon(Icons.edit, color: Colors.black),
            title: Text(title, style: const TextStyle(color: Colors.black)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black),
            onTap: () {
              _textEditingController.text = title;
              _focusNode.requestFocus();
              setState(() => hasChatStarted = true);
            },
          ),
        ),
        const Divider(
          color: Color.fromRGBO(212, 217, 227, 1),
          thickness: 1,
          height: 1,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mock user data for demonstration
    final String chatUserName = "Jasleen";
    final String chatUserProfilePic = 'assets/images/Ella-Bot.jpeg';
    final bool chatUserIsTyping = isBotTyping;
    return Scaffold(
      backgroundColor: const Color.fromARGB(250, 4, 1, 55),
      // Replace AppBar with custom ChatAppBar
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: ChatAppBar(
          userName: chatUserName,
          profilePicUrl: chatUserProfilePic,
          isTyping: chatUserIsTyping,
          onBack: () => Navigator.of(context).pop(),
          onMenu: () {},
          onProfileTap: () {
            // Placeholder for profile tap action
            Get.snackbar('Profile', 'Profile tapped!', snackPosition: SnackPosition.BOTTOM);
          },
        ),
      ),
      body: Stack(
        children: [
          _buildGradient(),
          SafeArea(
            child: Column(
              children: [
                if (!hasChatStarted) 
                  Expanded(child: _buildWelcomeSection())
                else
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              Container(
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage('assets/images/chat_bg2.png'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              DashChat(
                                currentUser: toDashChatUser(currentUser),
                                messages: messages.map(toDashChatMessage).toList(),
                                onSend: (msg) => _sendMessage(fromDashChatMessage(msg)),
                                inputOptions: InputOptions(
                                  textController: _textEditingController,
                                  focusNode: _focusNode,
                                  inputTextStyle: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF989898),
                                  ),
                                  inputDecoration: InputDecoration(
                                    hintText: 'Type a message...',
                                    hintStyle: TextStyle(
                                      color: Color(0xFF989898),
                                      fontSize: 16,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: Color(0xFFF3F4F6),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 18,
                                    ),
                                  ),
                                  inputToolbarPadding: const EdgeInsets.fromLTRB(0, 12, 16, 36),
                                  inputToolbarStyle: const BoxDecoration(
                                    color: Colors.white,
                                    border: Border(top: BorderSide(color: Color(0xFFF3F4F6), width: 0)),
                                    //border: Border(top: BorderSide(color: Color(0xFFF3F4F6), width: 0)),
                                  ),
                                  leading: [
                                    IconButton(
                                      onPressed: _sendMediaMessage,
                                      icon: Image.asset(
                                        'assets/images/camera.png',
                                        width: 28,
                                        height: 28,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ],
                                  sendButtonBuilder: (onSend) {
                                    return IconButton(
                                      icon: Image.asset(
                                        'assets/images/send.png',
                                        width: 32,
                                        height: 32,
                                      ),
                                      onPressed: onSend,
                                    );
                                  },
                                ),
                                messageOptions: MessageOptions(
                                  currentUserContainerColor: const Color(0xFFFF204E),
                                  containerColor: const Color(0xFFFFFFFF),
                                  currentUserTextColor: Colors.white,
                                  textColor: const Color(0xFF989898),
                                  borderRadius: 12,
                                  showOtherUsersName: false,
                                ),
                                typingUsers: [],
                              ),
                              if (isBotTyping)
                                Positioned(
                                  left: 16,
                                  right: 16,
                                  bottom: 140,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            image: AssetImage(botUser.profileImage ?? 'assets/images/Ella-Bot.jpeg'),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      _TypingBubble(),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradient() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(250, 251, 254, 1),
            Color.fromRGBO(218, 229, 249, 1),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(86.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Hello, Ask Me Anything...",
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'Comic_Neue',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.circle, color: Colors.green, size: 14),
                SizedBox(width: 6),
                Text(
                  "Online",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w200,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 38),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: templates.length,
              itemBuilder: (context, index) =>
                  _buildTemplateItem(templates[index]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingBubble() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage(botUser.profileImage ?? 'assets/images/Ella-Bot.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                botUser.firstName ?? 'Ella',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.blue.withOpacity(0.7),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'typing...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _dot1Anim;
  late Animation<double> _dot2Anim;
  late Animation<double> _dot3Anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _dot1Anim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );
    _dot2Anim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.8, curve: Curves.easeIn)),
    );
    _dot3Anim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 1.0, curve: Curves.easeIn)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Opacity(
              opacity: _dot1Anim.value,
              child: _buildDot(),
            ),
          ),
          const SizedBox(width: 6),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Opacity(
              opacity: _dot2Anim.value,
              child: _buildDot(),
            ),
          ),
          const SizedBox(width: 6),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Opacity(
              opacity: _dot3Anim.value,
              child: _buildDot(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot() {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: const Color(0xFFBDBDBD),
        shape: BoxShape.circle,
      ),
    );
  }
}

class ChatAppBar extends StatelessWidget {
  final String userName;
  final String profilePicUrl;
  final bool isTyping;
  final VoidCallback onBack;
  final VoidCallback onMenu;
  final VoidCallback onProfileTap;

  const ChatAppBar({
    required this.userName,
    required this.profilePicUrl,
    required this.isTyping,
    required this.onBack,
    required this.onMenu,
    required this.onProfileTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: onBack,
              ),
              GestureDetector(
                onTap: onProfileTap,
                child: CircleAvatar(
                  radius: 24,
                  backgroundImage: AssetImage(profilePicUrl),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (isTyping)
                      Row(
                        children: [
                          ...List.generate(
                            3,
                            (index) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: Icon(Icons.circle, size: 10, color: Colors.grey[400]),
                            ),
                          ),
                          // const SizedBox(width: 8),
                          const Text(
                            'Jasleen is typing...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_horiz, color: Color(0xFF181A2A)),
                onPressed: onMenu,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Conversion functions between our models and dash_chat_2
ChatUser toDashChatUser(model.ChatUser user) => ChatUser(
  id: user.id,
  firstName: user.firstName,
  profileImage: user.profileImage,
);

model.ChatUser fromDashChatUser(ChatUser user) => model.ChatUser(
  id: user.id,
  firstName: user.firstName ?? '',
  profileImage: user.profileImage,
);

ChatMessage toDashChatMessage(model.ChatMessage msg) => ChatMessage(
  user: toDashChatUser(msg.user),
  createdAt: msg.createdAt,
  text: msg.text,
  medias: msg.medias?.map((m) => ChatMedia(
    url: m.url,
    fileName: m.fileName,
    type: MediaType.image, // Only image supported for now
  )).toList(),
);

model.ChatMessage fromDashChatMessage(ChatMessage msg) => model.ChatMessage(
  user: fromDashChatUser(msg.user),
  createdAt: msg.createdAt,
  text: msg.text,
  medias: msg.medias?.map((m) => model.ChatMedia(
    url: m.url,
    fileName: m.fileName,
    type: model.MediaType.image,
  )).toList(),
);
