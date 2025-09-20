import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yatrachain/providers/app_provider.dart';
import 'package:yatrachain/models/badge.dart';
import 'package:yatrachain/models/trip.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Consumer<AppProvider>(
          builder: (context, provider, child) {
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  expandedHeight: 220,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.primaryContainer,
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Hero(
                            tag: 'profile_avatar',
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              child: Text(
                                provider.userName.isNotEmpty
                                    ? provider.userName[0].toUpperCase()
                                    : "?",
                                style: theme.textTheme.headlineLarge?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            provider.userName.isNotEmpty
                                ? "Traveller: ${provider.userName}"
                                : "Traveller",
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            provider.userEmail.isNotEmpty
                                ? "Email: ${provider.userEmail}"
                                : "No Email Added",
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            provider.userPhone.isNotEmpty
                                ? "Number: ${provider.userPhone}"
                                : "No Mobile Number",
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    IconButton(
                      onPressed: () => _showSettingsDialog(context, provider),
                      icon: const Icon(Icons.settings, color: Colors.white),
                    ),
                  ],
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildStatisticsCard(context, provider, theme),
                      const SizedBox(height: 20),
                      _buildBadgesSection(context, provider, theme),
                      const SizedBox(height: 20),
                      _buildSettingsCard(context, provider),
                      const SizedBox(height: 20),
                      _buildAboutSection(theme),
                      const SizedBox(height: 100),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(
      BuildContext context, AppProvider provider, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Travel Statistics',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Total Distance',
                    '${provider.totalDistance.toStringAsFixed(1)} km',
                    Icons.straighten,
                    theme.colorScheme.primary,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Money Saved',
                    '₹${provider.totalSavings.toStringAsFixed(0)}',
                    Icons.savings,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'CO₂ Saved',
                    '${provider.carbonSaved.toStringAsFixed(1)} kg',
                    Icons.eco,
                    Colors.teal,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Total Trips',
                    '${provider.trips.length}',
                    Icons.route,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesSection(
      BuildContext context, AppProvider provider, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Badges & Achievements',
          style:
              theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          'Collect badges by traveling smart and eco-friendly!',
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: provider.badges.length,
          itemBuilder: (context, index) {
            final badge = provider.badges[index];
            return UserBadgeCard(
              badge: badge,
              onTap: () => _showBadgeDetails(context, badge, provider),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSettingsCard(BuildContext context, AppProvider provider) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.translate),
            title: const Text('Language'),
            subtitle:
                Text(provider.currentLanguage == 'en' ? 'English' : 'മലയാളം'),
            trailing: Switch(
              value: provider.currentLanguage == 'ml',
              onChanged: (_) => provider.toggleLanguage(),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: provider.isDarkMode,
              onChanged: (_) => provider.toggleDarkMode(),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Profile'),
            subtitle: const Text('Update name, email, phone'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showEditProfileDialog(context, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.info_outline,
                      color: theme.colorScheme.onPrimaryContainer),
                ),
                const SizedBox(width: 12),
                Text(
                  'About YatraChain',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'YatraChain makes transportation in Kerala smarter through AI-powered insights, community-driven data, and gamified sustainable travel.',
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                Chip(
                  label: const Text('Version 1.0.0'),
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
                Chip(
                  label: const Text('Kerala, India'),
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value,
      IconData icon, Color color) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ------- DIALOGS -------

  void _showSettingsDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: SingleChildScrollView(
          // ✅ prevent overflow
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              ListTile(
                title: Text('Privacy'),
                subtitle: Text('Manage data sharing preferences'),
                leading: Icon(Icons.privacy_tip),
              ),
              ListTile(
                title: Text('Notifications'),
                subtitle: Text('Customize notification settings'),
                leading: Icon(Icons.notifications),
              ),
              ListTile(
                title: Text('Help & Support'),
                subtitle: Text('Get help with YatraChain'),
                leading: Icon(Icons.help),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, AppProvider provider) {
    final nameController = TextEditingController(text: provider.userName);
    final emailController = TextEditingController(text: provider.userEmail);
    final phoneController = TextEditingController(text: provider.userPhone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          // ✅ fix overflow
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              provider.setUserName(nameController.text.trim());
              provider.setUserEmail(emailController.text.trim());
              provider.setUserPhone(phoneController.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showBadgeDetails(
      BuildContext context, UserBadge badge, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.star,
                color: badge.unlocked ? Colors.amber : Colors.grey),
            const SizedBox(width: 8),
            Expanded(child: Text(badge.title)),
          ],
        ),
        content: SingleChildScrollView(
          // ✅ prevent overflow
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(badge.description),
              const SizedBox(height: 16),
              if (badge.unlocked) ...[
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      'Unlocked on ${badge.unlockedAt!.day}/${badge.unlockedAt!.month}/${badge.unlockedAt!.year}',
                      style: const TextStyle(color: Colors.green),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    const Icon(Icons.flag, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text('Goal: ${badge.requirement}'),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _getBadgeProgress(badge, provider),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _getBadgeProgress(UserBadge badge, AppProvider provider) {
    switch (badge.type) {
      case BadgeType.distance:
        return 'Progress: ${provider.totalDistance.toStringAsFixed(1)}/${badge.requirement} km';
      case BadgeType.savings:
        return 'Progress: ₹${provider.totalSavings.toStringAsFixed(0)}/₹${badge.requirement}';
      case BadgeType.eco:
        final ecoTrips = provider.trips
            .where((t) =>
                t.mode == TransportMode.walk || t.mode == TransportMode.bike)
            .length;
        return 'Progress: $ecoTrips/${badge.requirement} eco trips';
      case BadgeType.social:
        final socialTrips =
            provider.trips.where((t) => t.companions > 1).length;
        return 'Progress: $socialTrips/${badge.requirement} group trips';
      default:
        return 'Keep traveling to unlock!';
    }
  }
}

// ---------------- BADGE CARD ----------------

// ---------------- BADGE CARD ----------------
class UserBadgeCard extends StatefulWidget {
  final UserBadge badge;
  final VoidCallback onTap;

  const UserBadgeCard({
    super.key,
    required this.badge,
    required this.onTap,
  });

  @override
  State<UserBadgeCard> createState() => _UserBadgeCardState();
}

class _UserBadgeCardState extends State<UserBadgeCard>
    with SingleTickerProviderStateMixin {
  bool _animate = false;

  @override
  void initState() {
    super.initState();

    // Trigger animation if badge is unlocked
    if (widget.badge.unlocked) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) setState(() => _animate = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: _animate ? 1.2 : 0.8, // bounce effect
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                child: AnimatedOpacity(
                  opacity: widget.badge.unlocked ? 1.0 : 0.4,
                  duration: const Duration(milliseconds: 400),
                  child: CircleAvatar(
                    radius: 25,
                    backgroundColor: widget.badge.unlocked
                        ? Colors.amber.withOpacity(0.2)
                        : theme.colorScheme.surfaceContainerHighest,
                    child: Text(
                      _getBadgeEmoji(widget.badge.type),
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.badge.title,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: widget.badge.unlocked
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🎯 Fun emojis per badge type
  String _getBadgeEmoji(BadgeType type) {
    switch (type) {
      case BadgeType.distance:
        return "🛣️";
      case BadgeType.savings:
        return "💰";
      case BadgeType.eco:
        return "🌱";
      case BadgeType.social:
        return "🤝";
      default:
        return "⭐";
    }
  }
}
