import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
    ),
    _AivoraTool(
      icon: Icons.edit_note_rounded,
      name: 'AI Writer',
      subtitle: 'Create content',
    ),
    _AivoraTool(
      icon: Icons.auto_fix_high_rounded,
      name: 'Rewriter',
      subtitle: 'Improve text',
    ),
    _AivoraTool(
      icon: Icons.summarize_rounded,
      name: 'Summarizer',
      subtitle: 'Shorten text',
    ),
    _AivoraTool(
      icon: Icons.translate_rounded,
      name: 'Translator',
      subtitle: 'Translate text',
    ),
    _AivoraTool(
      icon: Icons.image_rounded,
      name: 'Text to Image',
      subtitle: 'Create images',
    ),
    _AivoraTool(
      icon: Icons.video_library_rounded,
      name: 'Text to Video',
      subtitle: 'Create videos',
    ),
    _AivoraTool(
      icon: Icons.mic_rounded,
      name: 'Text to Voice',
      subtitle: 'Generate voice',
    ),
    _AivoraTool(
      icon: Icons.picture_as_pdf_rounded,
      name: 'PDF Chat',
      subtitle: 'Talk to PDFs',
    ),
    _AivoraTool(
      icon: Icons.description_rounded,
      name: 'Documents',
      subtitle: 'Create documents',
    ),
    _AivoraTool(
      icon: Icons.badge_rounded,
      name: 'Resume Builder',
      subtitle: 'Build your CV',
    ),
    _AivoraTool(
      icon: Icons.music_note_rounded,
      name: 'AI Music',
      subtitle: 'Create music',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHome(),
            _buildTools(),
            _buildLibrary(),
            _buildProfile(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
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

  Widget _buildHome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),

          const SizedBox(height: 28),

          Text(
            'What will you create?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),

          const SizedBox(height: 8),

          Text(
            'One AI workspace for your ideas, content and creativity.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),

          const SizedBox(height: 22),

          _buildAssistantCard(),

          const SizedBox(height: 28),

          _buildSectionTitle(
            title: 'Popular Tools',
            action: 'View all',
            onAction: () {
              setState(() {
                _selectedIndex = 1;
              });
            },
          ),

          const SizedBox(height: 14),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.08,
            ),
            itemBuilder: (context, index) {
              return _buildToolCard(_tools[index]);
            },
          ),

          const SizedBox(height: 30),

          _buildSectionTitle(
            title: 'Why AIVORA?',
          ),

          const SizedBox(height: 14),

          _buildFeature(
            icon: Icons.bolt_rounded,
            title: 'Fast AI generation',
            subtitle: 'Create content quickly with AI.',
          ),

          _buildFeature(
            icon: Icons.auto_awesome_rounded,
            title: 'All-in-one workspace',
            subtitle: 'Text, image, video, voice and PDF tools.',
          ),

          _buildFeature(
            icon: Icons.folder_rounded,
            title: 'Organized library',
            subtitle: 'Keep your generated work in one place.',
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppTheme.primary,
                AppTheme.secondary,
              ],
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              Text(
                AppConstants.tagline,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          tooltip: 'Notifications',
          icon: const Icon(Icons.notifications_none_rounded),
        ),
      ],
    );
  }

  Widget _buildAssistantCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF24164A),
            Color(0xFF11152A),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Color(0xFFBFA8FF),
              size: 27,
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'AI Assistant',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            'Ask anything, write anything, create anything.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'AI Chat will be connected next.',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.chat_rounded),
              label: const Text('Start AI Chat'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({
    required String title,
    String? action,
    VoidCallback? onAction,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        if (action != null)
          TextButton(
            onPressed: onAction,
            child: Text(action),
          ),
      ],
    );
  }

  Widget _buildToolCard(_AivoraTool tool) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${tool.name} will be connected next.'),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  tool.icon,
                  color: AppTheme.primary,
                  size: 24,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                tool.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                tool.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeature({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: AppTheme.primary,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTools() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Tools',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),

          const SizedBox(height: 7),

          Text(
            'Choose a tool and start creating.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),

          const SizedBox(height: 20),

          TextField(
            decoration: InputDecoration(
              hintText: 'Search tools...',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(17),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 20),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _tools.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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

  Widget _buildLibrary() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_copy_outlined,
              size: 72,
              color: AppTheme.primary,
            ),
            const SizedBox(height: 18),
            const Text(
              'Your Library',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your generated content will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfile() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 43,
              backgroundColor: AppTheme.primary,
              child: const Icon(
                Icons.person_rounded,
                size: 43,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'AIVORA AI',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'Create. Chat. Imagine.',
              style: TextStyle(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.settings_rounded),
              label: const Text('Settings'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AivoraTool {
  final IconData icon;
  final String name;
  final String subtitle;

  const _AivoraTool({
    required this.icon,
    required this.name,
    required this.subtitle,
  });
}
