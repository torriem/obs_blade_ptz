import 'dart:convert';

import 'package:obs_blade/types/enums/request_batch_type.dart';
import 'package:obs_blade/types/enums/web_socket_codes/request_batch_execution_type.dart';
import 'package:obs_blade/types/enums/web_socket_codes/web_socket_op_code.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/connection.dart';
import '../types/enums/request_type.dart';
import 'general_helper.dart';
import 'websocket_helper.dart' as ws_helper;

class RequestBatchObject {
  String uuid;
  RequestType type;
  Map<String, dynamic>? body;

  RequestBatchObject(this.type, [this.body]) : uuid = const Uuid().v4();
}

class NetworkHelper {
  static Map<String, Map<String, dynamic>?> _requestBodyByUUID = {};
  static Map<String, List<RequestBatchObject>> _requestBatchByUUID = {};

  /// Establish and return an instance of [WebSocketChannel] based on the
  /// information inside a connection (IP and port). Currently using a
  /// [pingInterval] of 3 seconds which will check if the WebSocket connection
  /// is still alive in a 3 seconds interval - this will result in being able
  /// to check for [closeStatus] or [closeResult] whether the connection is
  /// alive or not. Mainly used in [DashboardStore] where a [Timer] is periodically
  /// checking this to be able to reconnect if possible or navigate back to
  /// [HomeView] otherwise
  static WebSocketChannel establishWebSocket(Connection connection,
      [Duration pingInterval = const Duration(seconds: 3)]) {
    /// Clear the map for a new connection
    NetworkHelper._requestBodyByUUID = {};
    NetworkHelper._requestBatchByUUID = {};

    return ws_helper.createWebSocket(connection, pingInterval);
  }

  static Map<String, dynamic>? getRequestBodyForUUID(String uuid) =>
      NetworkHelper._requestBodyByUUID.remove(uuid);

  static Iterable<RequestBatchObject>? getRequestBatchBodyForUUID(
          String uuid) =>
      NetworkHelper._requestBatchByUUID.remove(uuid);

  /// Making a request to the OBS WebSocket to trigger a request being
  /// sent back through the stream so we every listener can act accordingly
  static void makeRequest(
    WebSocketChannel channel,
    RequestType request, [
    Map<String, dynamic>? fields,
    bool customContent = false,
  ]) {
    if (request != RequestType.GetSourceScreenshot) {
      GeneralHelper.advLog(
        'Outgoing: $request',
      );
    }

    String requestUUID = const Uuid().v4();

    /// If we send a request which has fields, we want to
    /// be able to know, once we receive the response, what
    /// information we sent initially (like input name etc.) since
    /// in the new protocol (>= 5.X) we don't get this information
    /// in the response anymore
    if (fields != null && request.name.startsWith('Get')) {
      NetworkHelper._requestBodyByUUID[requestUUID] = fields;
    }

    channel.sink.add(
      json.encode(
        _requestObject(
          customContent
              ? fields!
              : {
                  'requestType': request.name,
                  'requestId': requestUUID,
                  'requestData': {
                    if (fields != null) ...fields,
                  },
                },
        ),
      ),
    );
  }

  /// Make a vendor-specific request to OBS WebSocket.
  /// Used for plugin-specific commands like PTZ camera controls.
  ///
  /// [channel] - The WebSocket channel to send the request through
  /// [vendorName] - Name of the vendor/plugin (e.g., "obs-ptz")
  /// [requestType] - Vendor-specific request type (e.g., "ptz_move")
  /// [requestData] - Optional vendor-specific request data
  static void makeVendorRequest(
    WebSocketChannel channel,
    String vendorName,
    String requestType, [
    Map<String, dynamic>? requestData,
  ]) {
    GeneralHelper.advLog(
      'Outgoing Vendor Request: $vendorName.$requestType',
    );

    String requestUUID = const Uuid().v4();

    channel.sink.add(
      json.encode(
        _requestObject({
          'requestType': 'CallVendorRequest',
          'requestId': requestUUID,
          'requestData': {
            'vendorName': vendorName,
            'requestType': requestType,
            if (requestData != null) 'requestData': requestData,
          },
        }),
      ),
    );
  }

  /// Making use of the batch request capability to request information
  /// bundled together - useful since now the API divided information
  /// in several entities so we can choose what exactly we need
  static void makeBatchRequest(
    WebSocketChannel channel,
    RequestBatchType batchRequest,
    List<RequestBatchObject> batch,
  ) {
    if (batchRequest != RequestBatchType.Stats) {
      GeneralHelper.advLog(
        'Outgoing Batch: $batchRequest',
      );
    }

    String requestUUID = const Uuid().v4();

    if (batchRequest.lookup) {
      NetworkHelper._requestBatchByUUID[requestUUID] = batch;
    }

    channel.sink.add(
      json.encode(
        _requestBatchObject(requestUUID, batch),
      ),
    );
  }

  static Map<String, dynamic> _requestObject(Map<String, dynamic> body,
          [WebSocketOpCode op = WebSocketOpCode.Request]) =>
      {
        'op': op.identifier,
        'd': body,
      };

  static Map<String, dynamic> _requestBatchObject(
    String uuid,
    Iterable<RequestBatchObject> batch, [
    bool haltOnFailure = false,
    RequestBatchExecutionType executionType =
        RequestBatchExecutionType.SerialRealtime,
  ]) =>
      {
        'op': WebSocketOpCode.RequestBatch.identifier,
        'd': {
          'requestId': uuid,
          'haltOnFailure': haltOnFailure,
          'executionType': executionType.identifier,
          'requests': batch
              .map(
                (batchEntry) => _requestObject(
                  {
                    'requestType': batchEntry.type.name,
                    'requestId': batchEntry.uuid,
                    'requestData': batchEntry.body,
                  },
                )['d'],
              )
              .toList(),
        },
      };
}
