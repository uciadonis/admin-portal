// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_redux/flutter_redux.dart';

// Project imports:
import 'package:invoiceninja_flutter/data/models/models.dart';
import 'package:invoiceninja_flutter/main_app.dart';
import 'package:invoiceninja_flutter/redux/app/app_actions.dart';
import 'package:invoiceninja_flutter/redux/app/app_state.dart';
import 'package:invoiceninja_flutter/ui/app/entities/entity_actions_dialog.dart';
import 'package:invoiceninja_flutter/utils/completers.dart';
import 'package:invoiceninja_flutter/utils/localization.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:printing/printing.dart';

class ViewDocumentList implements PersistUI {
  ViewDocumentList({
    this.force = false,
    this.page = 0,
  });

  final bool force;
  final int page;
}

class ViewDocument implements PersistUI {
  ViewDocument({this.documentId, this.force});

  final String documentId;
  final bool force;
}

class EditDocument implements PersistUI {
  EditDocument({
    this.document,
    this.completer,
  });

  final DocumentEntity document;
  final Completer completer;
}

class UpdateDocument implements PersistUI {
  UpdateDocument(this.document);

  final DocumentEntity document;
}

class LoadDocument {
  LoadDocument({this.completer, this.documentId});

  final Completer completer;
  final String documentId;
}

class LoadDocumentData {
  LoadDocumentData({this.completer, this.documentId});

  final Completer completer;
  final String documentId;
}

class LoadDocumentActivity {
  LoadDocumentActivity({this.completer, this.documentId});

  final Completer completer;
  final String documentId;
}

class LoadDocuments {
  LoadDocuments({this.completer});

  final Completer completer;
}

class LoadDocumentRequest implements StartLoading {}

class LoadDocumentFailure implements StopLoading {
  LoadDocumentFailure(this.error);

  final dynamic error;

  @override
  String toString() {
    return 'LoadDocumentFailure{error: $error}';
  }
}

class LoadDocumentSuccess implements StopLoading, PersistData {
  LoadDocumentSuccess(this.document);

  final DocumentEntity document;

  @override
  String toString() {
    return 'LoadDocumentSuccess{document: $document}';
  }
}

class LoadDocumentDataRequest implements StartLoading {}

class LoadDocumentsRequest implements StartLoading {}

class LoadDocumentsFailure implements StopLoading {
  LoadDocumentsFailure(this.error);

  final dynamic error;

  @override
  String toString() {
    return 'LoadDocumentsFailure{error: $error}';
  }
}

class LoadDocumentsSuccess implements StopLoading {
  LoadDocumentsSuccess(this.documents);

  final List<DocumentEntity> documents;

  @override
  String toString() {
    return 'LoadDocumentsSuccess{documents: $documents}';
  }
}

class SaveDocumentRequest implements StartSaving {
  SaveDocumentRequest({
    @required this.completer,
    @required this.entity,
  });

  final Completer completer;
  final DocumentEntity entity;
}

class SaveDocumentSuccess implements StopSaving, PersistData, PersistUI {
  SaveDocumentSuccess(this.document);

  final DocumentEntity document;
}

class AddDocumentSuccess implements StopSaving, PersistData, PersistUI {
  AddDocumentSuccess(this.documents, this.parentType, this.parentId);

  final BuiltList<DocumentEntity> documents;
  final EntityType parentType;
  final String parentId;
}

class SaveDocumentFailure implements StopSaving {
  SaveDocumentFailure(this.error);

  final Object error;
}

class DownloadDocumentsRequest implements StartSaving {
  DownloadDocumentsRequest({this.completer, this.documentIds});

  final Completer completer;
  final List<String> documentIds;
}

class DownloadDocumentsSuccess implements StopSaving {}

class DownloadDocumentsFailure implements StopSaving {
  DownloadDocumentsFailure(this.error);

  final Object error;
}

class ArchiveDocumentRequest implements StartSaving {
  ArchiveDocumentRequest(this.completer, this.documentIds);

  final Completer completer;
  final List<String> documentIds;
}

class ArchiveDocumentSuccess implements StopSaving, PersistData {
  ArchiveDocumentSuccess(this.documents);

  final List<DocumentEntity> documents;
}

class ArchiveDocumentFailure implements StopSaving {
  ArchiveDocumentFailure(this.documents);

  final List<DocumentEntity> documents;
}

class DeleteDocumentRequest implements StartSaving {
  DeleteDocumentRequest({
    @required this.completer,
    @required this.documentIds,
    @required this.password,
    @required this.idToken,
  });

  final Completer completer;
  final List<String> documentIds;
  final String password;
  final String idToken;
}

class DeleteDocumentSuccess implements StopSaving, PersistData {
  DeleteDocumentSuccess({this.documentId});

  final String documentId;

//DeleteDocumentSuccess(this.documents);
//final List<DocumentEntity> documents;
}

class DeleteDocumentFailure implements StopSaving {
  //DeleteDocumentFailure(this.documents);
  //final List<DocumentEntity> documents;
}

class RestoreDocumentRequest implements StartSaving {
  RestoreDocumentRequest(this.completer, this.documentIds);

  final Completer completer;
  final List<String> documentIds;
}

class RestoreDocumentSuccess implements StopSaving, PersistData {
  RestoreDocumentSuccess(this.documents);

  final List<DocumentEntity> documents;
}

class RestoreDocumentFailure implements StopSaving {
  RestoreDocumentFailure(this.documents);

  final List<DocumentEntity> documents;
}

class FilterDocuments implements PersistUI {
  FilterDocuments(this.filter);

  final String filter;
}

class FilterDocumentsByStatus implements PersistUI {
  FilterDocumentsByStatus(this.status);

  final EntityStatus status;
}

class SortDocuments implements PersistUI, PersistPrefs {
  SortDocuments(this.field);

  final String field;
}

class FilterDocumentsByState implements PersistUI {
  FilterDocumentsByState(this.state);

  final EntityState state;
}

class FilterDocumentsByCustom1 implements PersistUI {
  FilterDocumentsByCustom1(this.value);

  final String value;
}

class FilterDocumentsByCustom2 implements PersistUI {
  FilterDocumentsByCustom2(this.value);

  final String value;
}

class FilterDocumentsByCustom3 implements PersistUI {
  FilterDocumentsByCustom3(this.value);

  final String value;
}

class FilterDocumentsByCustom4 implements PersistUI {
  FilterDocumentsByCustom4(this.value);

  final String value;
}

void handleDocumentAction(
    BuildContext context, List<BaseEntity> documents, EntityAction action) {
  if (documents.isEmpty) {
    return;
  }

  final store = StoreProvider.of<AppState>(context);
  final localization = AppLocalization.of(context);
  final documentIds = documents.map((document) => document.id).toList();
  final document = store.state.documentState.map[documentIds.first];

  switch (action) {
    case EntityAction.edit:
      editEntity(entity: document);
      break;
    case EntityAction.restore:
      final message = documentIds.length > 1
          ? localization.restoredDocuments
              .replaceFirst(':value', ':count')
              .replaceFirst(':count', documentIds.length.toString())
          : localization.restoredDocument;
      store.dispatch(RestoreDocumentRequest(
          snackBarCompleter<Null>(context, message), documentIds));
      break;
    case EntityAction.archive:
      final message = documentIds.length > 1
          ? localization.archivedDocuments
              .replaceFirst(':value', ':count')
              .replaceFirst(':count', documentIds.length.toString())
          : localization.archivedDocument;
      store.dispatch(ArchiveDocumentRequest(
          snackBarCompleter<Null>(context, message), documentIds));
      break;
    /*
    case EntityAction.delete:
      final message = documentIds.length > 1
          ? localization.deletedDocuments
              .replaceFirst(':value', ':count').replaceFirst(':count', documentIds.length.toString())
          : localization.deletedDocument;
      store.dispatch(DeleteDocumentRequest(
        completer: snackBarCompleter<Null>(context, message),
        documentIds: documentIds,      
      ));
      break;
      */
    case EntityAction.toggleMultiselect:
      if (!store.state.documentListState.isInMultiselect()) {
        store.dispatch(StartDocumentMultiselect());
      }

      if (documents.isEmpty) {
        break;
      }

      for (final document in documents) {
        if (!store.state.documentListState.isSelected(document.id)) {
          store.dispatch(AddToDocumentMultiselect(entity: document));
        } else {
          store.dispatch(RemoveFromDocumentMultiselect(entity: document));
        }
      }
      break;
    case EntityAction.more:
      showEntityActionsDialog(
        entities: [document],
      );
      break;
    case EntityAction.bulkDownload:
      store.dispatch(
        DownloadDocumentsRequest(
          documentIds: documentIds,
          completer: snackBarCompleter<Null>(
            context,
            localization.exportedData,
          ),
        ),
      );
      break;
    case EntityAction.viewDocument:
      void showDocument() {
        showDialog<void>(
            context: navigatorKey.currentContext,
            builder: (context) {
              final DocumentEntity document =
                  store.state.documentState.map[documentIds.first];
              return AlertDialog(
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(localization.close.toUpperCase())),
                ],
                content: document.isImage
                    ? PinchZoom(
                        child: Image.memory(document.data),
                      )
                    : SizedBox(
                        width: 600,
                        child: PdfPreview(
                          build: (format) => document.data,
                          canChangeOrientation: false,
                          canChangePageFormat: false,
                          allowPrinting: false,
                          allowSharing: false,
                          canDebug: false,
                        ),
                      ),
              );
            });
      }
      if (document.data == null) {
        store.dispatch(LoadDocumentData(
            documentId: document.id,
            completer: Completer<void>()
              ..future.then((value) => showDocument())));
      } else {
        showDocument();
      }
      break;
  }
}

class StartDocumentMultiselect {}

class AddToDocumentMultiselect {
  AddToDocumentMultiselect({@required this.entity});

  final BaseEntity entity;
}

class RemoveFromDocumentMultiselect {
  RemoveFromDocumentMultiselect({@required this.entity});

  final BaseEntity entity;
}

class ClearDocumentMultiselect {}
