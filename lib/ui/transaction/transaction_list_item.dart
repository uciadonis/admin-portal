// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_redux/flutter_redux.dart';

// Project imports:
import 'package:invoiceninja_flutter/constants.dart';
import 'package:invoiceninja_flutter/data/models/models.dart';
import 'package:invoiceninja_flutter/redux/app/app_actions.dart';
import 'package:invoiceninja_flutter/redux/app/app_state.dart';
import 'package:invoiceninja_flutter/ui/app/actions_menu_button.dart';
import 'package:invoiceninja_flutter/ui/app/dismissible_entity.dart';
import 'package:invoiceninja_flutter/ui/app/entity_state_label.dart';
import 'package:invoiceninja_flutter/utils/formatting.dart';
import 'package:invoiceninja_flutter/utils/platforms.dart';

class TransactionListItem extends StatelessWidget {
  const TransactionListItem({
    @required this.user,
    @required this.transaction,
    @required this.filter,
    this.onTap,
    this.onLongPress,
    this.onCheckboxChanged,
    this.isChecked = false,
  });

  final UserEntity user;
  final GestureTapCallback onTap;
  final GestureTapCallback onLongPress;
  final TransactionEntity transaction;
  final String filter;
  final Function(bool) onCheckboxChanged;
  final bool isChecked;

  @override
  Widget build(BuildContext context) {
    final store = StoreProvider.of<AppState>(context);
    final state = store.state;
    final uiState = state.uiState;
    final transactionUIState = uiState.transactionUIState;
    final filterMatch = filter != null && filter.isNotEmpty
        ? transaction.matchesFilterValue(filter)
        : null;
    final listUIState = transactionUIState.listUIState;
    final isInMultiselect = listUIState.isInMultiselect();
    final showCheckbox = onCheckboxChanged != null || isInMultiselect;
    final textStyle = TextStyle(fontSize: 16);
    final textColor = Theme.of(context).textTheme.bodyText1.color;

    return DismissibleEntity(
      isSelected: isDesktop(context) &&
          transaction.id ==
              (uiState.isEditing
                  ? transactionUIState.editing.id
                  : transactionUIState.selectedId),
      userCompany: store.state.userCompany,
      entity: transaction,
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return constraints.maxWidth > kTableListWidthCutoff
            ? InkWell(
                onTap: () =>
                    onTap != null ? onTap() : selectEntity(entity: transaction),
                onLongPress: () => onLongPress != null
                    ? onLongPress()
                    : selectEntity(entity: transaction, longPress: true),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 28,
                    top: 4,
                    bottom: 4,
                  ),
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: showCheckbox
                            ? Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: IgnorePointer(
                                  ignoring: listUIState.isInMultiselect(),
                                  child: Checkbox(
                                    value: isChecked,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    onChanged: (value) =>
                                        onCheckboxChanged(value),
                                    activeColor:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              )
                            : ActionMenuButton(
                                entityActions: transaction.getActions(
                                  userCompany: state.userCompany,
                                  includeEdit: true,
                                ),
                                isSaving: false,
                                entity: transaction,
                                onSelected: (context, action) =>
                                    handleEntityAction(transaction, action),
                              ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(transaction.description, style: textStyle),
                                Text(
                                  filterMatch ?? transaction.category,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle2
                                      .copyWith(
                                        color: textColor
                                            .withOpacity(kLighterOpacity),
                                      ),
                                ),
                              ],
                            ),
                            if (filterMatch != null)
                              Text(
                                filterMatch,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.subtitle2,
                              ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        formatNumber(transaction.amount, context,
                            currencyId: transaction.currencyId),
                        style: textStyle,
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ),
                ),
              )
            : ListTile(
                onTap: () =>
                    onTap != null ? onTap() : selectEntity(entity: transaction),
                onLongPress: () => onLongPress != null
                    ? onLongPress()
                    : selectEntity(entity: transaction, longPress: true),
                leading: showCheckbox
                    ? IgnorePointer(
                        ignoring: listUIState.isInMultiselect(),
                        child: Checkbox(
                          value: isChecked,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          onChanged: (value) => onCheckboxChanged(value),
                          activeColor: Theme.of(context).colorScheme.secondary,
                        ),
                      )
                    : null,
                title: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          transaction.description,
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                      ),
                      Text(
                          formatNumber(transaction.amount, context,
                              currencyId: transaction.currencyId),
                          style: Theme.of(context).textTheme.subtitle1),
                    ],
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    filterMatch != null
                        ? Text(
                            filterMatch,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          )
                        : Text(transaction.category),
                    EntityStateLabel(transaction),
                  ],
                ),
              );
      }),
    );
  }
}
