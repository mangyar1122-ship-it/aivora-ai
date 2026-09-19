import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidDebugProvider(
      debugToken: const String.fromEnvironment(
        'APP_CHECK_DEBUG_TOKEN',
      ),
    ),
  );

  runApp(const AivoraApp());
}

class AivoraApp extends StatelessWidget {
  const AivoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AIVORA AI',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF08090D),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C5CFF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  final List<Map<String, dynamic>> tools = [
    {'icon': Icons.chat_bubble_rounded, 'name': 'AI Chat'},
    {'icon': Icons.edit_note_rounded, 'name': 'AI Writer'},
    {'icon': Icons.auto_fix_high_rounded, 'name': 'AI Rewriter'},
    {'icon': Icons.summarize_rounded, 'name': 'Summarizer'},
    {'icon': Icons.translate_rounded, 'name': 'Translator'},
    {'icon': Icons.image_rounded, 'name': 'Text to Image'},
    {'icon': Icons.auto_awesome_motion_rounded, 'name': 'Image Editor'},
    {'icon': Icons.video_library_rounded, 'name': 'Text to Video'},
    {'icon': Icons.mic_rounded, 'name': 'Text to Voice'},
    {'icon': Icons.picture_as_pdf_rounded, 'name': 'PDF Chat'},
    {'icon': Icons.description_rounded, 'name': 'Document'},
    {'icon': Icons.badge_rounded, 'name': 'Resume Builder'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: selectedIndex == 0
            ? _home()
            : selectedIndex == 1
                ? _tools()
                : selectedIndex == 2
                    ? _library()
                    : _profile(),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF0D0F15),
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'Tools',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder_rounded),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _home() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF8B5CF6),
                      Color(0xFF4F46E5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AIVORA AI',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Create. Chat. Imagine.',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none_rounded),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Text(
            'What will you create?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'One AI workspace for your ideas, content and creativity.',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF24164A),
                  Color(0xFF11152A),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFFB99CFF),
                  size: 28,
                ),
                const SizedBox(height: 12),
                const Text(
                  'AI Assistant',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Ask anything, write anything, create anything.',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChatPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat_rounded),
                    label: const Text('Start AI Chat'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Popular Tools',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedIndex = 1;
                  });
                },
                child: const Text('View all'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.35,
            ),
            itemBuilder: (context, index) {
              return _toolCard(tools[index]);
            },
          ),
          const SizedBox(height: 28),
          const Text(
            'Everything you need',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          _feature(
            Icons.bolt_rounded,
            'Fast AI generation',
            'Create content in seconds',
          ),
          _feature(
            Icons.security_rounded,
            'Private workspace',
            'Your creations stay organized',
          ),
          _feature(
            Icons.devices_rounded,
            'All-in-one AI',
            'Text, image, video, voice and PDF tools',
          ),
        ],
      ),
    );
  }

  Widget _tools() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Text(
            'AI Tools',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Choose a tool and start creating.',
            style: TextStyle(color: Colors.white60),
          ),
          const SizedBox(height: 22),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search tools...',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: const Color(0xFF11131A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tools.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (context, index) {
              return _toolCard(tools[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _library() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_copy_outlined,
            size: 70,
            color: Colors.deepPurpleAccent,
          ),
          const SizedBox(height: 18),
          const Text(
            'Your Library',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your generated content will appear here.',
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _profile() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 42,
            backgroundColor: Color(0xFF6D4AFF),
            child: Icon(
              Icons.person_rounded,
              size: 42,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'AIVORA AI',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Create. Chat. Imagine.',
            style: TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 25),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.settings_rounded),
            label: const Text('Settings'),
          ),
        ],
      ),
    );
  }

  Widget _toolCard(Map<String, dynamic> tool) {
    return Material(
      color: const Color(0xFF11131A),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: const Color(0xFF6D4AFF)
                      .withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  tool['icon'],
                  color: const Color(0xFFB59AFF),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                tool['name'],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _feature(
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF11131A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFFAA8CFF),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller =
      TextEditingController();

  final List<Map<String, String>> _messages = [];

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();

    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'sender': 'user',
        'text': text,
      });
    });

    _controller.clear();

    try {
      final model = FirebaseAI.googleAI().generativeModel(
        model: 'gemini-3.8-flash',
      );

      final response = await model.generateContent([
        Content.text(text),
      ]);

      final aiText =
          response.text ?? 'I could not generate a response.';

      if (!mounted) return;

      setState(() {
        _messages.add({
          'sender': 'ai',
          'text': aiText,
        });
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _messages.add({
          'sender': 'ai',
          'text':
              'Sorry, something went wrong. Please try again.',
        });
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Text(
                      'Hello! I am AIVORA AI.\nHow can I help you?',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isUser =
                          message['sender'] == 'user';

                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(
                            bottom: 12,
                          ),
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isUser
                                ? const Color(0xFF7C4DFF)
                                : const Color(0xFF1B1B22),
                            borderRadius:
                                BorderRadius.circular(16),
                          ),
                          child: Text(
                            message['text']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Ask AIVORA AI...',
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(
                      Icons.send_rounded,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
