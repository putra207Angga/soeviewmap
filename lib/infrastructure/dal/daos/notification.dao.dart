part of 'main.daos.dart';

class NotificationDao extends ApiService {
  static NotificationDao get use => NotificationDao();

  // Get notifications history
  Future<Response<ApiResponseList<NotificationModel>>> getNotifications({
    int? limit,
    bool? unreadOnly,
  }) async {
    final query = <String, dynamic>{};
    if (limit != null) query['limit'] = limit.toString();
    if (unreadOnly != null) query['unread_only'] = unreadOnly.toString();

    return await getRequest<ApiResponseList<NotificationModel>>(
      '/api/notifications',
      query: query.isNotEmpty ? query : null,
      decoder: (data) {
        print(
          'NotificationDao.getNotifications: decoder received data of type ${data.runtimeType}: $data',
        );
        dynamic decoded = data;
        if (data is String) {
          try {
            decoded = jsonDecode(data);
          } catch (e) {
            print('NotificationDao.getNotifications: jsonDecode error: $e');
          }
        }
        if (decoded is Map) {
          return ApiResponseList<NotificationModel>.fromJson(
            Map<String, dynamic>.from(decoded),
            (itemJson) => NotificationModel.fromJson(itemJson),
          );
        }
        return ApiResponseList<NotificationModel>(
          success: false,
          message: 'Failed to decode notifications data',
          code: 500,
          items: [],
          meta: MetaModel(
            currentPage: 1,
            pageSize: 0,
            totalItems: 0,
            totalPages: 0,
          ),
        );
      },
    );
  }

  // Get unread notification count
  Future<Response<int>> getUnreadCount() async {
    return await getRequest<int>(
      '/api/notifications/unread-count',
      decoder: (data) {
        print(
          'NotificationDao.getUnreadCount: decoder received data of type ${data.runtimeType}: $data',
        );
        dynamic decoded = data;
        if (data is String) {
          try {
            decoded = jsonDecode(data);
          } catch (e) {
            print('NotificationDao.getUnreadCount: jsonDecode error: $e');
          }
        }
        if (decoded is Map) {
          final dataVal = decoded['data'];
          if (dataVal is Map) {
            final count = dataVal['unread_count'] ?? dataVal['unreadCount'] ?? dataVal['count'];
            if (count is num) return count.toInt();
            if (count != null) return int.tryParse(count.toString()) ?? 0;
          } else if (dataVal is num) {
            return dataVal.toInt();
          } else if (dataVal is String) {
            return int.tryParse(dataVal) ?? 0;
          }
          final countTop = decoded['unread_count'] ?? decoded['unreadCount'] ?? decoded['count'];
          if (countTop is num) return countTop.toInt();
          if (countTop != null) return int.tryParse(countTop.toString()) ?? 0;
        }
        return 0;
      },
    );
  }

  // Mark notification as read
  Future<Response<bool>> markAsRead(int notificationId) async {
    return await patchRequest<bool>(
      '/api/notifications/$notificationId/read',
      null,
      decoder: (data) {
        print(
          'NotificationDao.markAsRead: decoder received data of type ${data.runtimeType}: $data',
        );
        dynamic decoded = data;
        if (data is String) {
          try {
            decoded = jsonDecode(data);
          } catch (e) {
            print('NotificationDao.markAsRead: jsonDecode error: $e');
          }
        }
        if (decoded is Map) {
          return decoded['success'] as bool? ?? false;
        }
        return false;
      },
    );
  }

  // Mark all notifications as read
  Future<Response<bool>> markAllAsRead() async {
    return await patchRequest<bool>(
      '/api/notifications/read-all',
      null,
      decoder: (data) {
        print(
          'NotificationDao.markAllAsRead: decoder received data of type ${data.runtimeType}: $data',
        );
        dynamic decoded = data;
        if (data is String) {
          try {
            decoded = jsonDecode(data);
          } catch (e) {
            print('NotificationDao.markAllAsRead: jsonDecode error: $e');
          }
        }
        if (decoded is Map) {
          return decoded['success'] as bool? ?? false;
        }
        return false;
      },
    );
  }

  // Get VAPID Public Key for service worker registration
  Future<Response<String>> getVapidPublicKey() async {
    return await getRequest<String>(
      '/api/notifications/vapid-public-key',
      decoder: (data) {
        print(
          'NotificationDao.getVapidPublicKey: decoder received data of type ${data.runtimeType}: $data',
        );
        dynamic decoded = data;
        if (data is String) {
          try {
            decoded = jsonDecode(data);
          } catch (e) {
            print('NotificationDao.getVapidPublicKey: jsonDecode error: $e');
          }
        }
        if (decoded is Map && decoded['data'] is Map) {
          return decoded['data']['public_key'] as String? ?? '';
        }
        return '';
      },
    );
  }

  // Subscribe device for push notifications
  Future<Response<bool>> subscribeDevice(PushSubscriptionCreate subscription) async {
    return await postRequest<bool>(
      '/api/notifications/subscribe',
      subscription.toJson(),
      decoder: (data) {
        print(
          'NotificationDao.subscribeDevice: decoder received data of type ${data.runtimeType}: $data',
        );
        dynamic decoded = data;
        if (data is String) {
          try {
            decoded = jsonDecode(data);
          } catch (e) {
            print('NotificationDao.subscribeDevice: jsonDecode error: $e');
          }
        }
        if (decoded is Map) {
          return decoded['success'] as bool? ?? false;
        }
        return false;
      },
    );
  }

  // Unsubscribe device from push notifications
  Future<Response<bool>> unsubscribeDevice(String endpoint) async {
    return await postRequest<bool>(
      '/api/notifications/unsubscribe',
      {'endpoint': endpoint},
      decoder: (data) {
        print(
          'NotificationDao.unsubscribeDevice: decoder received data of type ${data.runtimeType}: $data',
        );
        dynamic decoded = data;
        if (data is String) {
          try {
            decoded = jsonDecode(data);
          } catch (e) {
            print('NotificationDao.unsubscribeDevice: jsonDecode error: $e');
          }
        }
        if (decoded is Map) {
          return decoded['success'] as bool? ?? false;
        }
        return false;
      },
    );
  }
}

