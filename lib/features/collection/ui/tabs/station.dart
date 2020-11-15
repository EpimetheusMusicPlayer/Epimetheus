import 'package:epimetheus/core/ui/utils/sharing.dart';
import 'package:epimetheus/core/ui/widgets/menu_items.dart';
import 'package:epimetheus/core/ui/widgets/positional_menu_wrapper.dart';
import 'package:epimetheus/features/collection/ui/utils/collection_modifications.dart';
import 'package:epimetheus/features/collection/ui/widgets/list_tiles/station.dart';
import 'package:epimetheus/features/collection/ui/widgets/list_wrapper.dart';
import 'package:epimetheus/routes.dart';
import 'package:epimetheus_nullable/mobx/collection/collection_store.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iapetus/iapetus.dart';
import 'package:pedantic/pedantic.dart';
import 'package:popup_menu_title/popup_menu_title.dart';

class StationTab extends StatefulWidget {
  final CollectionStore _collectionStore;

  const StationTab({
    Key? key,
    required CollectionStore collectionStore,
  })   : _collectionStore = collectionStore,
        super(key: key);

  @override
  _StationTabState createState() => _StationTabState();
}

class _StationTabState extends State<StationTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final stationStore = widget._collectionStore.stations;

    return Observer(
      builder: (context) {
        return TabListWrapper(
          typeName: 'station',
          hasError: stationStore.hasError,
          errorMessage: stationStore.errorMessage,
          showProgressIndicator:
              stationStore.isLoading && !stationStore.anyItemsLoaded,
          hasData: stationStore.anyItemsLoaded,
          isEmpty: stationStore.loadedItems?.isEmpty ?? true,
          onRefresh: stationStore.refresh,
          child: StationList(
            stations: stationStore.loadedItems,
            onRefresh: stationStore.refresh,
            onStationSelected: (index) {
              stationStore.xbox(index);
              Navigator.of(context)!
                  .pushReplacementNamed(RouteNames.nowPlaying);
            },
            rename: stationStore.renameStation,
            remove: stationStore.removeStation,
          ),
        );
      },
    );
  }
}

class StationList extends StatelessWidget {
  final List<Station>? stations;
  final RefreshCallback onRefresh;
  final void Function(int index) onStationSelected;
  final Future<String?> Function(int index, String name) rename;
  final Future<void> Function(Station station) remove;

  const StationList({
    Key? key,
    required this.stations,
    required this.onRefresh,
    required this.onStationSelected,
    required this.rename,
    required this.remove,
  }) : super(key: key);

  void _showMenu(
    BuildContext context,
    ShowMenu showMenu,
    int index,
  ) async {
    final station = stations![index];
    final menuResult = await showMenu<Object>(
      context: context,
      initialValue: CommonMenuItem.add,
      items: [
        PopupMenuTitle(
          title: station.name,
          overflow: TextOverflow.fade,
        ),
        if (station.allowRename) CommonMenuItem.rename.menuEntry,
        CommonMenuItem.delete.menuEntry,
        CommonMenuItem.share.menuEntry,
      ],
    );

    switch (menuResult) {
      case CommonMenuItem.rename:
        handleRename(
          context: context,
          oldName: station.name,
          rename: (name) => rename(index, name),
        );
        break;
      case CommonMenuItem.delete:
        unawaited(remove(station));
        break;
      case CommonMenuItem.share:
        unawaited(shareMedia(station, context));
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: PositionalMenuWrapper(
        builder: (context, tapDownCallback, showMenu, child) {
          return ListView.separated(
            itemBuilder: (context, index) => InkWell(
              onTap: () => onStationSelected(index),
              onLongPress: () {
                _showMenu(context, showMenu, index);
              },
              onTapDown: (details) {
                tapDownCallback(details.menuOffset);
              },
              child: StationListTile(
                station: stations![index],
              ),
            ),
            separatorBuilder: (context, _) => StationListTile.separator,
            itemCount: stations!.length,
          );
        },
      ),
    );
  }
}
