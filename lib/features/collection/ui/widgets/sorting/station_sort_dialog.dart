import 'package:epimetheus/features/collection/ui/widgets/sorting/station_sort_icons.dart';
import 'package:flutter/material.dart';
import 'package:iapetus/iapetus.dart';

/// Builds a [SimpleDialog] with different station sort options, and pops with
/// the relevant [StationSortOrder].
class StationSortDialog extends StatelessWidget {
  final StationSortOrder selected;

  const StationSortDialog({
    Key? key,
    required this.selected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget _buildOption(StationSortOrder sortOrder, Widget text) {
      final selected = sortOrder == this.selected;
      return SimpleDialogOption(
        onPressed: () => Navigator.of(context)!.pop(sortOrder),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: selected
              ? IconTheme(
                  data: IconThemeData(color: Theme.of(context).accentColor),
                  child: stationSortIcons[sortOrder]!,
                )
              : stationSortIcons[sortOrder]!,
          title: selected
              ? DefaultTextStyle.merge(
                  style: TextStyle(
                    inherit: true,
                    color: Theme.of(context).accentColor,
                  ),
                  child: text,
                )
              : text,
        ),
      );
    }

    return SimpleDialog(
      title: const Text('Sort order'),
      children: [
        _buildOption(
          StationSortOrder.alphabetic,
          const Text('Alphabetic'),
        ),
        _buildOption(
          StationSortOrder.lastPlayed,
          const Text('Most recently played'),
        ),
        _buildOption(
          StationSortOrder.totalTimePlayed,
          const Text('Most time played'),
        ),
        _buildOption(
          StationSortOrder.createdTime,
          const Text('Most recently created'),
        ),
      ],
    );
  }
}
