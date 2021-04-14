import 'package:boardview/board_item.dart';
import 'package:boardview/board_list.dart';
import 'package:boardview/boardview.dart';
import 'package:boardview/boardview_controller.dart';
import 'package:flutter/material.dart';
import 'package:invoiceninja_flutter/data/models/entities.dart';
import 'package:invoiceninja_flutter/data/models/models.dart';
import 'package:invoiceninja_flutter/ui/app/history_drawer_vm.dart';
import 'package:invoiceninja_flutter/ui/app/list_filter.dart';
import 'package:invoiceninja_flutter/ui/app/menu_drawer_vm.dart';
import 'package:invoiceninja_flutter/ui/kanban_screen_vm.dart';
import 'package:invoiceninja_flutter/utils/platforms.dart';

class KanbanScreen extends StatefulWidget {
  const KanbanScreen({
    Key key,
    @required this.viewModel,
  }) : super(key: key);

  final KanbanVM viewModel;

  @override
  _KanbanScreenState createState() => _KanbanScreenState();
}

class _KanbanScreenState extends State<KanbanScreen> {
  final _boardViewController = new BoardViewController();

  List<TaskStatusEntity> _statuses = [];
  List<TaskEntity> _tasks = [];

  @override
  void initState() {
    super.initState();
    print('## initState: ${_statuses.length}');

    final state = widget.viewModel.state;
    _statuses = state.taskStatusState.list
        .map((statusId) => state.taskStatusState.get(statusId))
        .where((status) => status.isActive)
        .toList();

    _statuses.sort((statusA, statusB) {
      if (statusA.statusOrder == statusB.statusOrder) {
        return statusA.updatedAt.compareTo(statusB.updatedAt);
      } else {
        return (statusA.statusOrder ?? 9999)
            .compareTo(statusB.statusOrder ?? 9999);
      }
    });
  }

  @override
  void didChangeDependencies() {
    print('## didChangeDependencies: ${_statuses.length}');
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    print('## BUILD: ${_statuses.length}');

    final state = widget.viewModel.state;
    final boardList = _statuses.map((status) {
      final items = state.taskState.list
          .map((taskId) => state.taskState.get(taskId))
          .where((task) => task.statusId == status.id)
          .toList();

      items.sort((taskA, taskB) =>
          (taskA.statusOrder ?? 9999).compareTo(taskB.statusOrder ?? 9999));

      return BoardList(
        backgroundColor: Theme.of(context).cardColor,
        headerBackgroundColor: Theme.of(context).cardColor,
        onDropList: (endIndex, startIndex) {
          setState(() {
            final status = _statuses[startIndex];
            _statuses.removeAt(startIndex);
            _statuses = [
              ..._statuses.sublist(0, endIndex),
              status,
              ..._statuses.sublist(endIndex),
            ];
          });
          widget.viewModel.onStatusOrderChanged(context, status.id, endIndex);
        },
        header: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Text('${status.statusOrder} - ${status.name}'),
            ),
          ),
        ],
        items: items
            .map(
              (task) => BoardItem(
                item: Card(
                  color: Theme.of(context).backgroundColor,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(task.description),
                  ),
                ),
              ),
            )
            .toList(),
      );
    }).toList();

    return Scaffold(
      drawer: isMobile(context) || state.prefState.isMenuFloated
          ? MenuDrawerBuilder()
          : null,
      endDrawer: isMobile(context) || state.prefState.isHistoryFloated
          ? HistoryDrawerBuilder()
          : null,
      appBar: AppBar(
        centerTitle: false,
        leading: isMobile(context) || state.prefState.isMenuFloated
            ? null
            : SizedBox(),
        title: ListFilter(
          key: ValueKey('__cleared_at_${state.uiState.filterClearedAt}__'),
          entityType: EntityType.kanban,
          entityIds: [],
          filter: state.uiState.filter,
          onFilterChanged: (value) {
            //store.dispatch(FilterCompany(value));
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: BoardView(
          boardViewController: _boardViewController,
          lists: boardList,
        ),
      ),
    );
  }
}