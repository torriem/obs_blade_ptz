import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../../shared/general/base/card.dart';
import '../../../../../shared/general/custom_expansion_tile.dart';
import '../../../../../stores/shared/network.dart';
import '../../../../../utils/network_helper.dart';

class PTZControls extends StatefulWidget {
  const PTZControls({super.key});

  @override
  State<PTZControls> createState() => _PTZControlsState();
}

class _PTZControlsState extends State<PTZControls> {
  double _pan = 0.0;
  double _tilt = 0.0;
  double _zoom = 0.0;

  void _sendPTZMove() {
    final network = GetIt.instance<NetworkStore>();
    if (network.activeSession?.socket != null) {
      NetworkHelper.makeVendorRequest(
        network.activeSession!.socket,
        'obs-ptz',
        'ptz_move',
        {
          'pan': _pan.clamp(-1.0, 1.0),
          'tilt': _tilt.clamp(-1.0, 1.0),
          'zoom': _zoom.clamp(-1.0, 1.0),
        },
      );
    }
  }

  void _sendPTZStop() {
    final network = GetIt.instance<NetworkStore>();
    if (network.activeSession?.socket != null) {
      NetworkHelper.makeVendorRequest(
        network.activeSession!.socket,
        'obs-ptz',
        'ptz_stop',
        {},
      );
    }
  }

  void _resetAndStop() {
    setState(() {
      _pan = 0.0;
      _tilt = 0.0;
      _zoom = 0.0;
    });
    _sendPTZStop();
  }

  Widget _buildControlSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
    required VoidCallback onChangeEnd,
    required bool enabled,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: enabled
                          ? Theme.of(context).textTheme.bodyMedium?.color
                          : Theme.of(context).disabledColor,
                    ),
              ),
              Text(
                value.toStringAsFixed(2),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: enabled
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).disabledColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
            ),
            child: Slider(
              value: value,
              min: -1.0,
              max: 1.0,
              divisions: 200,
              onChanged: enabled
                  ? (newValue) {
                      onChanged(newValue);
                      _sendPTZMove();
                    }
                  : null,
              onChangeEnd: enabled
                  ? (_) {
                      onChangeEnd();
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final network = GetIt.instance<NetworkStore>();
    final bool isConnected = network.activeSession?.socket != null;

    return BaseCard(
      bottomPadding: 0.0,
      paddingChild: const EdgeInsets.symmetric(vertical: 18.0),
      child: CustomExpansionTile(
        headerText: 'PTZ Camera Controls',
        expandedBody: Padding(
          padding: const EdgeInsets.only(
            left: 18.0,
            right: 18.0,
            top: 12.0,
            bottom: 18.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!isConnected)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    'Not connected to OBS',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                          fontStyle: FontStyle.italic,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Pan Control
              _buildControlSlider(
                label: 'Pan (Left/Right)',
                value: _pan,
                onChanged: (value) => setState(() => _pan = value),
                onChangeEnd: () {
                  setState(() => _pan = 0.0);
                  _sendPTZStop();
                },
                enabled: isConnected,
              ),

              // Tilt Control
              _buildControlSlider(
                label: 'Tilt (Up/Down)',
                value: _tilt,
                onChanged: (value) => setState(() => _tilt = value),
                onChangeEnd: () {
                  setState(() => _tilt = 0.0);
                  _sendPTZStop();
                },
                enabled: isConnected,
              ),

              // Zoom Control
              _buildControlSlider(
                label: 'Zoom (In/Out)',
                value: _zoom,
                onChanged: (value) => setState(() => _zoom = value),
                onChangeEnd: () {
                  setState(() => _zoom = 0.0);
                  _sendPTZStop();
                },
                enabled: isConnected,
              ),

              const SizedBox(height: 12.0),

              // Stop Button
              ElevatedButton.icon(
                onPressed: isConnected ? _resetAndStop : null,
                icon: const Icon(Icons.stop),
                label: const Text('STOP'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  disabledBackgroundColor: Colors.grey.shade700,
                  disabledForegroundColor: Colors.grey.shade500,
                ),
              ),

              const SizedBox(height: 8.0),

              // Help Text
              Text(
                'Move sliders to control camera. Sliders auto-reset when released.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color
                          ?.withValues(alpha: 0.6),
                      fontStyle: FontStyle.italic,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
