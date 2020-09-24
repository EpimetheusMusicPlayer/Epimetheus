import 'package:flutter/widgets.dart';

const _mobileLayoutThreshold = 800;

bool shouldDisplayMobileLayout(BuildContext context) => MediaQuery.of(context).size.width < _mobileLayoutThreshold;
