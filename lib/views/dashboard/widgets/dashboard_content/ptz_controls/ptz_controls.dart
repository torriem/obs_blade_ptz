import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../../shared/general/base/card.dart';
import '../../../../../stores/shared/network.dart';
import '../../../../../utils/general_helper.dart';
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
  List<PTZPreset> _presets = [];
  bool _loadingPresets = false;
  bool _setMode = false;

  @override
  void initState() {
    super.initState();
    _fetchPresets();
  }

  void _fetchPresets() async {
    final network = GetIt.instance<NetworkStore>();
    if (network.activeSession?.socket == null) return;

    setState(() => _loadingPresets = true);

    try {
      GeneralHelper.advLog('PTZ: Fetching presets...');
      final response = await NetworkHelper.makeVendorRequestAsync(
        network.activeSession!.socket,
        'obs-ptz',
        'ptz_get_presets',
        {},
      );

      GeneralHelper.advLog('PTZ: Response received: $response');

      if (response != null) {
        // Response structure: {requestType: ..., responseData: {presets: [...], success: true}, vendorName: ...}
        final responseData = response['responseData'] as Map<String, dynamic>?;
        final presetsData = responseData?['presets'] as List<dynamic>?;
        GeneralHelper.advLog('PTZ: Presets data: $presetsData');
        if (presetsData != null) {
          GeneralHelper.advLog('PTZ: Found ${presetsData.length} presets');
          setState(() {
            _presets = presetsData
                .map((p) => PTZPreset(
                      id: p['id'] as int,
                      name: p['name'] as String,
                    ))
                .toList();
          });
          GeneralHelper.advLog('PTZ: Presets set to state: $_presets');
        } else {
          GeneralHelper.advLog('PTZ: presetsData is null');
        }
      } else {
        GeneralHelper.advLog('PTZ: response is null');
      }
    } catch (e) {
      GeneralHelper.advLog('PTZ: Error fetching presets: $e');
    } finally {
      setState(() => _loadingPresets = false);
    }
  }

  void _recallPreset(int presetId) {
    final network = GetIt.instance<NetworkStore>();
    if (network.activeSession?.socket != null) {
      NetworkHelper.makeVendorRequest(
        network.activeSession!.socket,
        'obs-ptz',
        'ptz_recall_preset',
        {'preset_id': presetId},
      );
    }
  }

  void _setPreset(int presetId) {
    final network = GetIt.instance<NetworkStore>();
    if (network.activeSession?.socket != null) {
      NetworkHelper.makeVendorRequest(
        network.activeSession!.socket,
        'obs-ptz',
        'ptz_set_preset',
        {'preset_id': presetId},
      );
      // Deactivate set mode after setting
      setState(() => _setMode = false);
    }
  }

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
    required String negativeLabel,
    required String positiveLabel,
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: enabled
                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
                      : Theme.of(context).disabledColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  value.toStringAsFixed(2),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: enabled
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).disabledColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4.0),
          // Direction labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                negativeLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: enabled
                          ? (value < 0
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.5))
                          : Theme.of(context).disabledColor,
                      fontSize: 11.0,
                    ),
              ),
              Text(
                'CENTER',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: enabled
                          ? (value == 0.0
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.5))
                          : Theme.of(context).disabledColor,
                      fontSize: 10.0,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Text(
                positiveLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: enabled
                          ? (value > 0
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.5))
                          : Theme.of(context).disabledColor,
                      fontSize: 11.0,
                    ),
              ),
            ],
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              // Center line indicator
              Positioned(
                top: 12,
                child: Container(
                  width: 2.0,
                  height: 24.0,
                  color: enabled
                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
                      : Theme.of(context).disabledColor.withValues(alpha: 0.2),
                ),
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
                  trackHeight: 6.0,
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
        ],
      ),
    );
  }

  Widget _buildCameraControls(bool isConnected) {
    return Column(
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
                label: 'Pan',
                negativeLabel: '◄ LEFT',
                positiveLabel: 'RIGHT ►',
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
                label: 'Tilt',
                negativeLabel: '▼ DOWN',
                positiveLabel: 'UP ▲',
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
                label: 'Zoom',
                negativeLabel: '◄ OUT',
                positiveLabel: 'IN ►',
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
    );
  }

  Widget _buildPresetsSection(bool isConnected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
              if (isConnected) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Presets',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (_loadingPresets)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 20),
                        onPressed: _fetchPresets,
                        tooltip: 'Refresh presets',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),

                const SizedBox(height: 12.0),

                // Set Mode Toggle Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => setState(() => _setMode = !_setMode),
                    icon: Icon(_setMode ? Icons.check_box : Icons.check_box_outline_blank),
                    label: Text(_setMode ? 'SET MODE: ON' : 'Set'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _setMode
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surface,
                      foregroundColor: _setMode
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurface,
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                    ),
                  ),
                ),

                const SizedBox(height: 12.0),

                if (_presets.isEmpty && !_loadingPresets)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      'No presets available',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color
                                ?.withValues(alpha: 0.6),
                            fontStyle: FontStyle.italic,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: 1.6,
                    ),
                    itemCount: _presets.length,
                    itemBuilder: (context, index) {
                      final preset = _presets[index];
                      return ElevatedButton(
                        onPressed: () => _setMode
                            ? _setPreset(preset.id)
                            : _recallPreset(preset.id),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 8.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${preset.id + 1}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              preset.name,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 11,
                                  ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final network = GetIt.instance<NetworkStore>();
    final bool isConnected = network.activeSession?.socket != null;

    return BaseCard(
      constrained: false,
      paddingChild: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'PTZ Camera Controls',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12.0),
          // Use wide layout if width is sufficient OR device is a tablet
          MediaQuery.sizeOf(context).width >= 500 ||
                  MediaQuery.sizeOf(context).shortestSide >= 600
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: _buildCameraControls(isConnected),
                    ),
                    const SizedBox(width: 24.0),
                    Expanded(
                      flex: 1,
                      child: _buildPresetsSection(isConnected),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildCameraControls(isConnected),
                    if (isConnected) ...[
                      const SizedBox(height: 24.0),
                      const Divider(),
                      const SizedBox(height: 12.0),
                    ],
                    _buildPresetsSection(isConnected),
                  ],
                ),
        ],
      ),
    );
  }
}

// Model class for PTZ presets
class PTZPreset {
  final int id;
  final String name;

  PTZPreset({required this.id, required this.name});
}
