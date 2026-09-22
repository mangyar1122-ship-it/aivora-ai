import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'AI Tools',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.search_rounded,
              color: AppTheme.cyan,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
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
                color: AppTheme.cyan.withValues(alpha: 0.20),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.cyan.withValues(alpha: 0.08),
                  blurRadius: 28,
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: AppTheme.cyan,
                  size: 30,
                ),
                SizedBox(height: 14),
                Text(
                  'Create more with AIVORA',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Powerful AI tools for writing, images, documents, voice and more.',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'ALL AI TOOLS',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          _toolCard(
            icon: Icons.chat_bubble_rounded,
            title: 'AI Chat',
            subtitle: 'Ask, learn and solve',
            color: AppTheme.cyan,
          ),
          _toolCard(
            icon: Icons.edit_note_rounded,
            title: 'AI Writer',
            subtitle: 'Create high-quality content',
            color: AppTheme.primary,
          ),
          _toolCard(
            icon: Icons.autorenew_rounded,
            title: 'Rewriter',
            subtitle: 'Rewrite and improve text',
            color: AppTheme.secondary,
          ),
          _toolCard(
            icon: Icons.summarize_rounded,
            title: 'Summarizer',
            subtitle: 'Get quick key points',
            color: AppTheme.cyan,
          ),
          _toolCard(
            icon: Icons.translate_rounded,
            title: 'Translator',
            subtitle: 'Translate languages instantly',
            color: AppTheme.primary,
          ),
          _toolCard(
            icon: Icons.image_rounded,
            title: 'Text to Image',
            subtitle: 'Turn ideas into images',
            color: AppTheme.secondary,
          ),
          _toolCard(
            icon: Icons.movie_creation_rounded,
            title: 'Text to Video',
            subtitle: 'Create AI videos',
            color: AppTheme.cyan,
          ),
          _toolCard(
            icon: Icons.record_voice_over_rounded,
            title: 'Text to Voice',
            subtitle: 'Generate natural voice',
            color: AppTheme.primary,
          ),
          _toolCard(
            icon: Icons.picture_as_pdf_rounded,
            title: 'PDF Chat',
            subtitle: 'Ask questions from PDFs',
            color: AppTheme.secondary,
          ),
          _toolCard(
            icon: Icons.description_rounded,
            title: 'Documents',
            subtitle: 'Work with your documents',
            color: AppTheme.cyan,
          ),
          _toolCard(
            icon: Icons.badge_rounded,
            title: 'Resume Builder',
            subtitle: 'Build a professional resume',
            color: AppTheme.primary,
          ),
          _toolCard(
            icon: Icons.music_note_rounded,
            title: 'AI Music',
            subtitle: 'Create music with AI',
            color: AppTheme.secondary,
          ),
        ],
      ),
    );
  }

  Widget _toolCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.22),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 7,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: color.withValues(alpha: 0.22),
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          color: AppTheme.textSecondary,
          size: 16,
        ),
      ),
    );
  }
}
