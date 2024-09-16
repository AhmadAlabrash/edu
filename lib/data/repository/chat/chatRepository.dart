import 'package:dio/dio.dart';
import 'package:e_demand/data/model/chat/chatMessage.dart';
import 'package:e_demand/data/model/chat/chatUser.dart';
import 'package:path/path.dart' as p;

import '../../../app/generalImports.dart';

class ChatRepository {
  Future<Map<String, dynamic>> fetchChatUsers({required int offset, String? searchString}) async {
    try {
      final response = await Api.post(
        url: Api.getChatUsers,
        useAuthToken: true,
        parameter: {
          "offset": offset.toString(),
          "limit": "25",
          if (searchString != null) "search": searchString
        },
      );

      List<ChatUser> chatUsers = [];

      for (int i = 0; i < response['data'].length; i++) {
        chatUsers.add(ChatUser.fromJson(response['data'][i]));
      }

      return {
        "chatUsers": chatUsers,
        "totalItems": int.tryParse((response['total'] ?? "1").toString()),
        "totalUnreadUsers": 0, //unused response['total_unread_users'] ??
      };
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      throw ApiException(error.toString());
    }
  }

  Future<Map<String, dynamic>> fetchChatMessages({
    required int offset,
    required String bookingId,
    required String type,
  }) async {
    try {
      Map<String, dynamic> parameter = {
        "offset": offset.toString(),
        "limit": "25",
        "booking_id": bookingId,
        "type": type
      };

      final response =
          await Api.post(url: Api.getChatMessages, useAuthToken: true, parameter: parameter);

      List<ChatMessage> chatMessage = [];

      for (int i = 0; i < response['data'].length; i++) {
        chatMessage.add(ChatMessage.fromJsonAPI(response['data'][i]));
      }

      return {
        "chatMessages": chatMessage,
        "totalItems": int.tryParse((response['total'] ?? "0").toString()),
      };
    } catch (error, st) {
      if (kDebugMode) {
        print(st.toString());
        print(error);
      }
      throw ApiException(error.toString());
    }
  }

  Future<ChatMessage> sendChatMessage({
    required String message,
    List<String> filePaths = const [],
    required String receiverId,

    ///0 : Admin 1: Provider
    required String sendMessageTo,
    String? bookingId,
  }) async {
    try {
      //
      Map<String, dynamic> parameter = {
        "receiver_id": receiverId,
        "message": message,
        "receiver_type": sendMessageTo,
        "booking_id": bookingId,
      };
      if (bookingId == "0") {
        parameter.remove("booking_id");
      }
      if (receiverId == "-" || sendMessageTo == "0") {
        parameter.remove("receiver_id");
      }
      if (message.isEmpty) {
        parameter.remove("message");
      }
      if (filePaths.isNotEmpty) {
        for (int i = 0; i < filePaths.length; i++) {
          //
          final mimeType = lookupMimeType(filePaths[i]);
          final extension = mimeType!.split("/");
          //

          final imagePart = await MultipartFile.fromFile(
            filePaths[i],
            filename: p.basename(filePaths[i]),
            contentType: MediaType(extension[0], extension[1]),
          );
          parameter["attachment[$i]"] = imagePart;
        }
      }

      final response =
          await Api.post(url: Api.sendChatMessage, parameter: parameter, useAuthToken: true);

      return ChatMessage.fromJsonAPI(response['data']);
    } catch (e) {

      throw ApiException("somethingWentWrong");
    }
  }
}
