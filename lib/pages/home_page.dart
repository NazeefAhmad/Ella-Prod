import 'dart:async';
import 'package:gemini_chat_app_tutorial/pages/settings.dart';
import 'package:get/get.dart';

import '../imports.dart'; // Ensure this path is correct for your project structure


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Gemini gemini = Gemini.instance;

  List<ChatMessage> messages = [];

  ChatUser currentUser = ChatUser(id: "0", firstName: "User");
  ChatUser geminiUser = ChatUser(
    id: "1",
    firstName: "Ella",
    profileImage: "assets/images/Ella-Bot.jpeg",
  );

  // Sample list of template items
  final List<String> templates = [
    'Why is the sky blue?',
    'Will AI ever bond emotionally?',
    'Write a poem about a lonely robot.',
    'Who wrote the Harry Potter series?',
    'Can you suggest a personalized workout plan using AI',
  ];

  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode =
      FocusNode(); // FocusNode to manage keyboard focus

  bool hasChatStarted =
      false; // Flag to control visibility of the list and header
  bool isEllaTyping = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(250, 4, 1, 55),
      appBar: AppBar(
  title: Text(
    "Ask Me Anything",
    style: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.5,
      color: Colors.transparent,
      fontFamily: 'Comic_Neue',
    ),
  ),
  actions: [
    IconButton(
      icon: Icon(Icons.settings), // Settings icon
      onPressed: () {
        // Navigate to the settings page
        Get.to(SettingsPage());
      },
    ),
  ],
),

      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Stack(
      children: [
        // Gradient Background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(250, 251, 254, 1),
                Color.fromRGBO(218, 229, 249, 1)
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Column(
          children: [
            if (!hasChatStarted) ...[
              // Header Text
              Padding(
                padding: const EdgeInsets.all(86.0),
                child: Column(
                  children: [
                    Text(
                      "Hello, Ask Me Anything...",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.6,
                        color: Colors.black,
                        fontFamily: 'Comic_Neue',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                        height:
                            8), // Space between the text and the status indicator
                    // Online Status Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.circle, // Green dot or online indicator
                          color: Colors
                              .green, // Change to Colors.blue for a blue tick
                          size: 14, // Adjust the size as needed
                        ),
                        SizedBox(width: 6), // Space between icon and text
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
                  ],
                ),
              ),
              SizedBox(height: 38), // Space below the status indicator
              // Template ListView with white background
              Expanded(
                flex: 2, // Give some space to the ListView
                child: Container(
                  child: ListView.builder(
                    itemCount: templates.length,
                    itemBuilder: (context, index) {
                      return _buildTemplateItem(templates[index]);
                    },
                  ),
                ),
              ),
            ],
            // Chat UI
            Expanded(
              flex: 1, // Allocate more space for the chat area
              child: DashChat(
                inputOptions: InputOptions(
                  textController:
                      _textEditingController, // Attach the controller
                  focusNode: _focusNode, // Attach the focus node
                  trailing: [
                    IconButton(
                      onPressed: _sendMediaMessage,
                      icon: Image.asset(
                        'assets/icons/gallery.png', // Path to your custom icon
                        width: 42,
                        height: 42,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
                currentUser: currentUser,
                onSend: _sendMessage,
                messages: messages,
                messageOptions: MessageOptions(
                  currentUserContainerColor:
                      const Color.fromRGBO(60, 97, 221, 1),
                  borderRadius: 10.0, // Pass a double value for borderRadius
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTemplateItem(String title) {
    return Column(
      children: [
        Container(
          color: Color.fromRGBO(
              251, 252, 254, .6), // White background for each list item
          child: ListTile(
            leading: Icon(Icons.edit, color: Colors.black),
            title: Text(
              title,
              style: TextStyle(color: Colors.black),
            ),
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.black),
            onTap: () {
              _textEditingController.text =
                  title; // Set the template text in the input field
              _focusNode.requestFocus(); // Automatically open the keyboard
              setState(() {
                hasChatStarted =
                    true; // Hide the list and header once the chat starts
              });
            },
          ),
        ),
        Divider(
          color:
              Color.fromRGBO(212, 217, 227, 1), // Color of the separator line
          thickness: 1.0, // Thickness of the line
          height: 1.0, // Space around the divider
        ),
      ],
    );
  }

  void _sendMessage(ChatMessage chatMessage) {
    setState(() {
      messages.insert(0, chatMessage); // Add the new message at the top
      hasChatStarted = true; // Hide the list and header once the chat starts
    });

    try {
      String question = chatMessage.text;
      List<Uint8List>? images;

      if (chatMessage.medias?.isNotEmpty ?? false) {
        images = [
          File(chatMessage.medias!.first.url).readAsBytesSync(),
        ];
      }

      var fullResponse = "";
      bool isComplete = false; // Flag to track if the response is complete

      // Set a timeout duration (e.g., 3 seconds)
      const Duration timeoutDuration = Duration(seconds: 5);
      Timer? timeoutTimer;

      // Listen to the response stream
      gemini
          .streamGenerateContent(
        question,
        images: images,
      )
          .listen((event) {
        if (event != null) {
          // Log the current event content for debugging
          print("Received event: ${event.content}");

          // Append current part to fullResponse
          fullResponse +=
              event.content?.parts?.map((part) => part.text).join(" ") ?? "";

          // Log the current fullResponse for debugging
          print("Current full response: $fullResponse");

          // Reset the timeout timer whenever we receive a new event
          timeoutTimer?.cancel();
          timeoutTimer = Timer(timeoutDuration, () {
            // Consider the response complete if we hit the timeout
            isComplete = true;
            _addFinalResponse(fullResponse);
          });
        } else {
          print("Received null event.");
        }
      });

      // Cleanup the timer if no more events are received
      timeoutTimer
          ?.cancel(); // Cancel timer when unsubscribing or on completion if necessary
    } catch (e) {
      print("Error occurred: $e");
    }
  }

  void _addFinalResponse(String fullResponse) {
    // Create the final ChatMessage
    ChatMessage message = ChatMessage(
      user: geminiUser,
      createdAt: DateTime.now(),
      text: fullResponse,
    );

    setState(() {
      messages.insert(0, message); // Add the final AI response at the top
    });

    // Log the final response after it's added
    print("Final AI response added: $fullResponse");
  }

  void _sendMediaMessage() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (file != null) {
      ChatMessage chatMessage = ChatMessage(
        user: currentUser,
        createdAt: DateTime.now(),
        text: "Describe this picture?",
        medias: [
          ChatMedia(
            url: file.path,
            fileName: "",
            type: MediaType.image,
          ),
        ],
      );
      _sendMessage(chatMessage);
    }
  }
}
