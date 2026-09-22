import 'package:flutter/material.dart';

import '../chat/chat_page.dart';
import '../tools/tools_page.dart';
import '../../core/theme/app_theme.dart';

class HomePage extends StatefulWidget {
  final String? userName;

  const HomePage({
    super.key,
    this.userName,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<_AivoraTool> _tools = const [
    _AivoraTool(
      icon: Icons.chat_bubble_rounded,
      name: 'AI Chat',
      subtitle: 'Ask anything',
      accentColor: AppTheme.cyan,
    ),
    _AivoraTool(
      icon: Icons.edit_note_rounded,
      name: 'AI Writer',
      subtitle: 'Create content',
      accentColor: AppTheme.primary,
    ),
    _AivoraTool(
      icon: Icons.auto_fix_high_rounded,
      name: 'Rewriter',
      subtitle: 'Improve text',
      accentColor: AppTheme.secondary,
    ),
    _AivoraTool(
      icon: Icons.summarize_rounded,
      name: 'Summarizer',
      subtitle: 'Shorten text',
      accentColor: AppTheme.cyan,
    ),
    _AivoraTool(
      icon: Icons.translate_rounded,
      name: 'Translator',
      subtitle: 'Translate text',
      accentColor: AppTheme.primary,
    ),
    _AivoraTool(
      icon: Icons.image_rounded,
      name: 'Text to Image',
      subtitle: 'Create images',
      accentColor: AppTheme.secondary,
    ),
    _AivoraTool(
      icon: Icons.video_library_rounded,
      name: 'Text to Video',
      subtitle: 'Create videos',
      accentColor: AppTheme.cyan,
    ),
    _AivoraTool(
      icon: Icons.mic_rounded,
      name: 'Text to Voice',
      subtitle: 'Generate voice',
      accentColor: AppTheme.primary,
    ),
    _AivoraTool(
      icon: Icons.picture_as_pdf_rounded,
      name: 'PDF Chat',
      subtitle: 'Talk to PDFs',
      accentColor: AppTheme.secondary,
    ),
    _AivoraTool(
      icon: Icons.description_rounded,
      name: 'Documents',
      subtitle: 'Create documents',
      accentColor: AppTheme.cyan,
    ),
    _AivoraTool(
      icon: Icons.badge_rounded,
      name: 'Resume Builder',
      subtitle: 'Build your CV',
      accentColor: AppTheme.primary,
    ),
    _AivoraTool(
      icon: Icons.music_note_rounded,
      name: 'AI Music',
      subtitle: 'Create music',
      accentColor: AppTheme.secondary,
    ),
  ];

  String get _displayName {
    final name = widget.userName?.trim();

    if (name == null || name.isEmpty) {
      return 'there';
    }

    return name;
  }

  String get _greeting {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good Morning';
    }

    if (hour < 17) {
      return 'Good Afternoon';
    }

    if (hour < 21) {
      return 'Good Evening';
    }

    return 'Good Night';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHome(),
            const ToolsPage(),
            _buildHistory(),
            _buildProfile(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHome() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopHeader(),
          const SizedBox(height: 28),
          Text(
            '$_greeting, $_displayName 👋',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 27,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'What would you like to create today?',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 22),
          _buildMainAiCard(),
          const SizedBox(height: 25),
          _buildSectionHeader(
            'Quick Actions',
            'View all',
            () {
              setState(() => _selectedIndex = 1);
            },
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                child: _buildQuickAction(
                  icon: Icons.chat_rounded,
                  title: 'New Chat',
                  subtitle: 'Ask AIVORA',
                  color: AppTheme.cyan,
                  onTap: _openChat,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAction(
                  icon: Icons.auto_awesome_rounded,
                  title: 'Create',
                  subtitle: 'Make something',
                  color: AppTheme.secondary,
                  onTap: () {
                    setState(() => _selectedIndex = 1);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          _buildSectionHeader(
            'AI Tools',
            'Explore',
            () {
              setState(() => _selectedIndex = 1);
            },
          ),
          const SizedBox(height: 13),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.08,
            ),
            itemBuilder: (context, index) {
              return _buildToolCard(_tools[index]);
            },
          ),
          const SizedBox(height: 26),
          _buildSectionHeader(
            'Recent',
            'History',
            () {
              setState(() => _selectedIndex = 2);
            },
          ),
          const SizedBox(height: 13),
          _buildRecentCard(),
        ],
      ),
    );
  }

  Widget _buildTopHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppTheme.cyan,
                AppTheme.primary,
                AppTheme.secondary,
              ],
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.28),
                blurRadius: 18,
              ),
            ],
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AIVORA',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                'AI CREATIVE WORKSPACE',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.3,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppTheme.primary.withValues(alpha: 0.22),
            ),
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.workspace_premium_rounded,
              color: AppTheme.cyan,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainAiCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF102C55),
            Color(0xFF08172F),
            Color(0xFF170D35),
          ],
        ),
        borderRadius: BorderRadius.circular(27),
        border: Border.all(
          color: AppTheme.cyan.withValues(alpha: 0.22),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.16),
            blurRadius: 38,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      AppTheme.cyan,
                      AppTheme.primary,
                      AppTheme.secondary,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.cyan.withValues(alpha: 0.28),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 27,
                ),
              ),
              const SizedBox(width: 13),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AIVORA AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Your intelligent workspace',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Think. Create.\nGo beyond limits. ⚡',
            style: TextStyle(
              color: AppTheme.cyan,
              fontSize: 25,
              height: 1.12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 9),
          const Text(
            'Chat, write, create images, explore ideas and more with AIVORA.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 19),
          SizedBox(
            width: double.infinity,
            height: 49,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppTheme.cyan,
                    AppTheme.primary,
                    AppTheme.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ElevatedButton.icon(
                onPressed: _openChat,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.chat_rounded),
                label: const Text(
                  'Start AI Chat',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: color.withValues(alpha: 0.32),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard(_AivoraTool tool) {
    return InkWell(
      onTap: () {
        if (tool.name == 'AI Chat') {
          _openChat();
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${tool.name} will be connected next.',
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: tool.accentColor.withValues(alpha: 0.28),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: tool.accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                tool.icon,
                color: tool.accentColor,
                size: 23,
              ),
            ),
            const SizedBox(height: 11),
            Text(
              tool.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              tool.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.24),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.history_rounded,
            color: AppTheme.cyan,
            size: 30,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Activity',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Your latest AI creations will appear here.',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    String action,
    VoidCallback onAction,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        TextButton(
          onPressed: onAction,
          child: Text(
            action,
            style: const TextStyle(
              color: AppTheme.cyan,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTools() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI Tools',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Everything you need in one AI workspace.',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.15),
              ),
            ),
            child: const TextField(
              style: TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search AI tools...',
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppTheme.textSecondary,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _tools.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.08,
            ),
            itemBuilder: (context, index) {
              return _buildToolCard(_tools[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHistory() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                "History",
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.search_rounded,
                color: AppTheme.cyan,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppTheme.surface2,
                AppTheme.surface,
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppTheme.cyan.withValues(alpha: 0.18),
            ),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.history_rounded,
                color: AppTheme.cyan,
                size: 30,
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Recent Activity",
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Your AI conversations and creations will appear here.",
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          "RECENT",
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: 38,
            horizontal: 24,
          ),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppTheme.primary.withValues(alpha: 0.16),
            ),
          ),
          child: const Column(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: AppTheme.cyan,
                size: 42,
              ),
              SizedBox(height: 14),
              Text(
                "No recent activity",
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 7),
              Text(
                "Start a conversation or use an AI tool to see your activity here.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfile() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    AppTheme.cyan,
                    AppTheme.primary,
                    AppTheme.secondary,
                  ],
                ),
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 43,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              _displayName == 'there'
                  ? 'AIVORA User'
                  : _displayName,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 25,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Create. Chat. Imagine.',
              style: TextStyle(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.cyan,
                side: BorderSide(
                  color: AppTheme.cyan.withValues(alpha: 0.35),
                ),
              ),
              icon: const Icon(Icons.settings_rounded),
              label: const Text('Settings'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return NavigationBar(
      backgroundColor: AppTheme.surface,
      indicatorColor: AppTheme.primary.withValues(alpha: 0.18),
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        setState(() => _selectedIndex = index);
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
          icon: Icon(Icons.history_outlined),
          selectedIcon: Icon(Icons.history_rounded),
          label: 'History',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    );
  }

  void _openChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ChatPage(),
      ),
    );
  }
}

class _AivoraTool {
  final IconData icon;
  final String name;
  final String subtitle;
  final Color accentColor;

  const _AivoraTool({
    required this.icon,
    required this.name,
    required this.subtitle,
    this.accentColor = AppTheme.primary,
  });
}
