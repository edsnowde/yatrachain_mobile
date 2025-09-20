import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yatrachain/providers/app_provider.dart';
import 'package:yatrachain/models/trip.dart';
import 'package:yatrachain/widgets/quick_action_chip.dart';
import 'package:yatrachain/widgets/stats_card.dart';
import 'package:yatrachain/widgets/live_trip_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  expandedHeight: 120,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${provider.getGreeting()} 👋',
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      provider.userName,
                                      style: theme.textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.notifications_outlined,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (provider.totalSavings > 0)
                            Text(
                              'You saved ₹${provider.totalSavings.toStringAsFixed(0)} this week by choosing smart routes! 💰',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.secondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Quick Actions
                      Text(
                        'Quick Actions',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          QuickActionChip(
                            label: 'Start Trip',
                            icon: Icons.play_arrow,
                            color: theme.colorScheme.secondary,
                            onTap: () => _showStartTripDialog(context, provider),
                          ),
                          QuickActionChip(
                            label: 'View Trips',
                            icon: Icons.route,
                            color: theme.colorScheme.tertiary,
                            onTap: () {
                              DefaultTabController.of(context).animateTo(1);
                            },
                          ),
                          QuickActionChip(
                            label: 'Ask YatraBot',
                            icon: Icons.smart_toy,
                            color: theme.colorScheme.primary,
                            onTap: () {
                              DefaultTabController.of(context).animateTo(3);
                            },
                          ),
                          QuickActionChip(
                            label: provider.currentLanguage == 'en' ? 'മലയാളം' : 'English',
                            icon: Icons.translate,
                            color: Colors.orange,
                            onTap: () => provider.toggleLanguage(),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Live Trip Card
                      if (provider.currentTrip != null) ...[
                        Text(
                          'Live Trip',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        LiveTripCard(trip: provider.currentTrip!),
                        const SizedBox(height: 32),
                      ],
                      
                      // Stats Overview
                      Text(
                        'Your Travel Stats',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: StatsCard(
                              title: 'Distance',
                              value: '${provider.totalDistance.toStringAsFixed(1)} km',
                              icon: Icons.straighten,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatsCard(
                              title: 'Saved',
                              value: '₹${provider.totalSavings.toStringAsFixed(0)}',
                              icon: Icons.savings,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: StatsCard(
                              title: 'CO₂ Saved',
                              value: '${provider.carbonSaved.toStringAsFixed(1)} kg',
                              icon: Icons.eco,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatsCard(
                              title: 'Badges',
                              value: '${provider.unlockedBadgesCount}/${provider.badges.length}',
                              icon: Icons.emoji_events,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Recent Trips
                      Text(
                        'Recent Trips',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...provider.trips.take(3).map((trip) => 
                        _buildTripTile(context, trip, theme)),
                      
                      if (provider.trips.length > 3)
                        TextButton(
                          onPressed: () {
                            DefaultTabController.of(context).animateTo(1);
                          },
                          child: const Text('View All Trips →'),
                        ),
                      
                      const SizedBox(height: 100), // Bottom padding
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

  Widget _buildTripTile(BuildContext context, Trip trip, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              trip.mode.emoji,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${trip.from} → ${trip.to}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${trip.distance.toStringAsFixed(1)} km • ${trip.mode.name} • ₹${trip.fare.toStringAsFixed(0)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${trip.startTime.hour.toString().padLeft(2, '0')}:${trip.startTime.minute.toString().padLeft(2, '0')}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  void _showStartTripDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start New Trip'),
        content: const Text('Trip detection is active! We\'ll automatically track your journey and show a summary when you arrive.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // Simulate starting a trip
              final mockTrip = Trip(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                from: 'Current Location',
                to: 'Destination',
                startTime: DateTime.now(),
                endTime: DateTime.now().add(const Duration(hours: 1)),
                mode: TransportMode.bus,
                purpose: TripPurpose.work,
                distance: 15.0,
                fare: 25.0,
              );
              provider.startTrip(mockTrip);
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }
}