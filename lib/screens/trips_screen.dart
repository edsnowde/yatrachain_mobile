import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yatrachain/providers/app_provider.dart';
import 'package:yatrachain/models/trip.dart';

class TripsScreen extends StatelessWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Diary'),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          final trips = provider.trips.reversed.toList();

          if (trips.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.route_outlined,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No trips yet',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start a trip to see your journey history here',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: trips.length,
            itemBuilder: (context, index) {
              final trip = trips[index];
              return TripCard(
                trip: trip,
                onTap: () => _showTripDetails(context, trip),
              );
            },
          );
        },
      ),

      // ✅ Add Trip Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTripSheet(context),
        icon: const Icon(Icons.add),
        label: const Text("Add Trip"),
      ),
    );
  }

  void _showTripDetails(BuildContext context, Trip trip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => EditTripSheet(trip: trip),
    );
  }

  void _showAddTripSheet(BuildContext context) {
    // ✅ Open the same sheet but with empty fields for new trip
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddTripSheet(),
    );
  }
}

class TripCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback onTap;

  const TripCard({
    super.key,
    required this.trip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _getModeColor(trip.mode).withOpacity(0.1),
                    child: Text(trip.mode.emoji,
                        style: const TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      '${trip.from} → ${trip.to}',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    _formatDate(trip.startTime),
                    style:
                        theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildMetric(Icons.straighten,
                      '${trip.distance.toStringAsFixed(1)} km'),
                  const SizedBox(width: 16),
                  _buildMetric(
                      Icons.access_time, _formatDuration(trip.duration)),
                  const SizedBox(width: 16),
                  _buildMetric(
                      Icons.currency_rupee, '₹${trip.fare.toStringAsFixed(0)}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetric(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Color _getModeColor(TransportMode mode) {
    switch (mode) {
      case TransportMode.bus:
        return Colors.blue;
      case TransportMode.walk:
        return Colors.green;
      case TransportMode.metro:
        return Colors.purple;
      case TransportMode.bike:
        return Colors.orange;
      case TransportMode.auto:
        return Colors.yellow.shade700;
      case TransportMode.car:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
  }
}

//  for adding trip manually

class AddTripSheet extends StatefulWidget {
  const AddTripSheet({super.key});

  @override
  State<AddTripSheet> createState() => _AddTripSheetState();
}

class _AddTripSheetState extends State<AddTripSheet> {
  final fromCtrl = TextEditingController();
  final toCtrl = TextEditingController();
  final distanceCtrl = TextEditingController();
  final fareCtrl = TextEditingController();
  final companionsCtrl = TextEditingController(text: "1");

  TripPurpose purpose = TripPurpose.leisure;
  TransportMode mode = TransportMode.bus;
  DateTime start = DateTime.now();
  DateTime end = DateTime.now();

  void _saveTrip() async {
    final newTrip = Trip(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      from: fromCtrl.text.trim(),
      to: toCtrl.text.trim(),
      startTime: start,
      endTime: end,
      mode: mode,
      purpose: purpose,
      distance: double.tryParse(distanceCtrl.text) ?? 0,
      fare: double.tryParse(fareCtrl.text) ?? 0,
      companions: int.tryParse(companionsCtrl.text) ?? 1,
      route: [fromCtrl.text.trim(), toCtrl.text.trim()],
    );

    await Provider.of<AppProvider>(context, listen: false).addTrip(newTrip);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add Trip', style: theme.textTheme.headlineSmall),
                const SizedBox(height: 20),
                TextField(
                    controller: fromCtrl,
                    decoration: const InputDecoration(labelText: 'From')),
                const SizedBox(height: 12),
                TextField(
                    controller: toCtrl,
                    decoration: const InputDecoration(labelText: 'To')),
                const SizedBox(height: 12),
                TextField(
                    controller: distanceCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Distance (km)'),
                    keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                TextField(
                    controller: fareCtrl,
                    decoration: const InputDecoration(labelText: 'Fare (₹)'),
                    keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                TextField(
                    controller: companionsCtrl,
                    decoration: const InputDecoration(labelText: 'Companions'),
                    keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                Text('Purpose', style: theme.textTheme.labelLarge),
                Wrap(
                  spacing: 8,
                  children: TripPurpose.values.map((p) {
                    return ChoiceChip(
                      label: Text(p.name),
                      selected: purpose == p,
                      onSelected: (_) => setState(() => purpose = p),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text('Mode', style: theme.textTheme.labelLarge),
                Wrap(
                  spacing: 8,
                  children: TransportMode.values.map((m) {
                    return ChoiceChip(
                      label: Text('${m.emoji} ${m.name}'),
                      selected: mode == m,
                      onSelected: (_) => setState(() => mode = m),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _saveTrip,
                        icon: const Icon(Icons.save),
                        label: const Text('Save Trip'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// =================== EDIT TRIP SHEET ===================
class EditTripSheet extends StatefulWidget {
  final Trip trip;
  const EditTripSheet({super.key, required this.trip});

  @override
  State<EditTripSheet> createState() => _EditTripSheetState();
}

class _EditTripSheetState extends State<EditTripSheet> {
  late TextEditingController fromCtrl;
  late TextEditingController toCtrl;
  late TextEditingController distanceCtrl;
  late TextEditingController fareCtrl;
  late TextEditingController companionsCtrl;

  late TripPurpose purpose;
  late TransportMode mode;
  late DateTime start;
  late DateTime end;

  @override
  void initState() {
    super.initState();
    final trip = widget.trip;

    fromCtrl = TextEditingController(text: trip.from);
    toCtrl = TextEditingController(text: trip.to);
    distanceCtrl = TextEditingController(text: trip.distance.toString());
    fareCtrl = TextEditingController(text: trip.fare.toString());
    companionsCtrl = TextEditingController(text: trip.companions.toString());

    purpose = trip.purpose;
    mode = trip.mode;
    start = trip.startTime;
    end = trip.endTime;
  }

  @override
  void dispose() {
    fromCtrl.dispose();
    toCtrl.dispose();
    distanceCtrl.dispose();
    fareCtrl.dispose();
    companionsCtrl.dispose();
    super.dispose();
  }

  void _saveChanges() async {
    final updatedTrip = Trip(
      id: widget.trip.id,
      from: fromCtrl.text.trim(),
      to: toCtrl.text.trim(),
      startTime: start,
      endTime: end,
      mode: mode,
      purpose: purpose,
      distance: double.tryParse(distanceCtrl.text) ?? 0,
      fare: double.tryParse(fareCtrl.text) ?? 0,
      companions: int.tryParse(companionsCtrl.text) ?? 1,
      route: [fromCtrl.text.trim(), toCtrl.text.trim()],
    );

    await Provider.of<AppProvider>(context, listen: false)
        .updateTrip(updatedTrip);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Edit Trip', style: theme.textTheme.headlineSmall),
                const SizedBox(height: 20),
                TextField(
                    controller: fromCtrl,
                    decoration: const InputDecoration(labelText: 'From')),
                const SizedBox(height: 12),
                TextField(
                    controller: toCtrl,
                    decoration: const InputDecoration(labelText: 'To')),
                const SizedBox(height: 12),
                TextField(
                    controller: distanceCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Distance (km)'),
                    keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                TextField(
                    controller: fareCtrl,
                    decoration: const InputDecoration(labelText: 'Fare (₹)'),
                    keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                TextField(
                    controller: companionsCtrl,
                    decoration: const InputDecoration(labelText: 'Companions'),
                    keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                Text('Purpose', style: theme.textTheme.labelLarge),
                Wrap(
                  spacing: 8,
                  children: TripPurpose.values.map((p) {
                    return ChoiceChip(
                      label: Text(p.name),
                      selected: purpose == p,
                      onSelected: (_) => setState(() => purpose = p),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text('Mode', style: theme.textTheme.labelLarge),
                Wrap(
                  spacing: 8,
                  children: TransportMode.values.map((m) {
                    return ChoiceChip(
                      label: Text('${m.emoji} ${m.name}'),
                      selected: mode == m,
                      onSelected: (_) => setState(() => mode = m),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _saveChanges,
                        icon: const Icon(Icons.save),
                        label: const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
