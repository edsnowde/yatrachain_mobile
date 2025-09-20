import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yatrachain/models/trip.dart';
import 'package:yatrachain/providers/app_provider.dart';

class TripCard extends StatefulWidget {
  final Trip trip;

  const TripCard({super.key, required this.trip});

  @override
  State<TripCard> createState() => _TripCardState();
}

class _TripCardState extends State<TripCard> {
  bool _expanded = false;

  late TextEditingController fromCtrl;
  late TextEditingController toCtrl;
  late TextEditingController distanceCtrl;
  late TextEditingController fareCtrl;
  late TextEditingController companionsCtrl;

  late TripPurpose purpose;
  late TransportMode mode;

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
      startTime: widget.trip.startTime,
      endTime: widget.trip.endTime,
      mode: mode,
      purpose: purpose,
      distance: double.tryParse(distanceCtrl.text) ?? 0,
      fare: double.tryParse(fareCtrl.text) ?? 0,
      companions: int.tryParse(companionsCtrl.text) ?? 1,
      route: [fromCtrl.text.trim(), toCtrl.text.trim()],
    );

    await Provider.of<AppProvider>(context, listen: false).updateTrip(updatedTrip);

    if (mounted) {
      setState(() => _expanded = false); // collapse after saving
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip updated successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: _getModeColor(mode).withOpacity(0.1),
              child: Text(mode.emoji, style: const TextStyle(fontSize: 20)),
            ),
            title: Text(
              '${widget.trip.from} → ${widget.trip.to}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              '${_formatDate(widget.trip.startTime)} • ${widget.trip.mode.name}',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            trailing: IconButton(
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () => setState(() => _expanded = !_expanded),
            ),
          ),

          if (_expanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: fromCtrl,
                    decoration: const InputDecoration(labelText: 'From'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: toCtrl,
                    decoration: const InputDecoration(labelText: 'To'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: distanceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Distance (km)'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: fareCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Fare (₹)'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: companionsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Companions'),
                  ),

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
                          onPressed: () => setState(() => _expanded = false),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _saveChanges,
                          icon: const Icon(Icons.save),
                          label: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
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
}
