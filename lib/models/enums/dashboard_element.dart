import 'package:hive/hive.dart';

import '../type_ids.dart';

part 'dashboard_element.g.dart';

@HiveType(typeId: TypeIDs.DashboardElement)
enum DashboardElement {
  @HiveField(0)
  ExposedProfile,

  @HiveField(1)
  ExposedControls,

  @HiveField(2)
  PTZControls,

  @HiveField(3)
  SceneButtons,

  @HiveField(4)
  StudioModeTransition,

  @HiveField(5)
  StudioModeConfig,

  @HiveField(6)
  ScenePreview,

  @HiveField(7)
  SceneItems,

  @HiveField(8)
  SceneItemsAudio,

  @HiveField(9)
  StreamChat,

  @HiveField(10)
  OBSStats;

  String get name => switch (this) {
        DashboardElement.ExposedProfile => 'Profiles',
        DashboardElement.ExposedControls => 'Controls',
        DashboardElement.PTZControls => 'PTZ Camera',
        DashboardElement.SceneButtons => 'Scene Buttons',
        DashboardElement.StudioModeTransition => 'Studio Mode Transition',
        DashboardElement.StudioModeConfig => 'Studio Mode Config',
        DashboardElement.ScenePreview => 'Scene Preview',
        DashboardElement.SceneItems => 'Scene Items',
        DashboardElement.SceneItemsAudio => 'Scene Audio',
        DashboardElement.StreamChat => 'Chat',
        DashboardElement.OBSStats => 'Stats',
      };
}
