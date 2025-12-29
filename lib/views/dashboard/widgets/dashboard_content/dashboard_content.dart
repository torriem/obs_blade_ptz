import 'package:flutter/material.dart';

import '../../../../shared/general/base/card.dart';
import '../../../../shared/general/base/divider.dart';
import '../../../../shared/general/custom_expansion_tile.dart';
import '../../../../shared/general/custom_sliver_list.dart';
import '../../../../shared/general/responsive_widget_wrapper.dart';
import '../obs_widgets/obs_widgets.dart';
import '../obs_widgets/obs_widgets_mobile.dart';
import 'exposed_controls/exposed_controls.dart';
import 'profile_scene_collection/profile_scene_collection.dart';
import 'ptz_controls/ptz_controls.dart';
import 'scene_buttons/scene_buttons.dart';
import 'scene_content/scene_content.dart';
import 'scene_content/scene_content_mobile.dart';
import 'scene_preview/scene_preview.dart';
import 'studio_mode_checkbox.dart';
import 'studio_mode_transition_button.dart';
import 'transition_controls.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomSliverList(
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 24.0),
          child: Column(
            children: [
              ProfileSceneCollection(),
              ExposedControls(),
              SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  StudioModeCheckbox(),
                  SizedBox(width: 24.0),
                ],
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 32.0,
                    left: 18.0,
                    right: 18.0,
                  ),
                  child: SceneButtons(),
                ),
              ),
              // BaseButton(
              //   onPressed: () => NetworkHelper.makeRequest(
              //       GetIt.instance<NetworkStore>().activeSession.socket,
              //       RequestType.PlayPauseMedia,
              //       {'sourceName': 'was geht ab', 'playPause': false}),
              //   text: 'SOUND',
              // ),
              SizedBox(height: 24.0),
              StudioModeTransitionButton(),
              SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TransitionControls(),
                  SizedBox(width: 24.0),
                ],
              ),
              SizedBox(height: 24.0),
              ScenePreview(),
              SizedBox(height: 24.0),
              PTZControls(),
              SizedBox(height: 24.0),
              ResponsiveWidgetWrapper(
                mobileWidget: SceneContentMobile(),
                tabletWidget: SceneContent(),
              ),
            ],
          ),
        ),
        BaseCard(
          bottomPadding: 0.0,
          paddingChild: const EdgeInsets.symmetric(vertical: 18.0),
          child: CustomExpansionTile(
            headerText: 'Widgets',
            initiallyExpanded: false,
            expandedBody: const Padding(
              padding: EdgeInsets.only(
                left: 18.0,
                right: 18.0,
                top: 12.0,
                bottom: 18.0,
              ),
              child: ResponsiveWidgetWrapper(
                mobileWidget: OBSWidgetsMobile(),
                tabletWidget: OBSWidgets(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
