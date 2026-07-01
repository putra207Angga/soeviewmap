part of 'main.models.dart';

class MetaModel {
  final int currentPage;
  final int pageSize;
  final int totalItems;
  final int totalPages;

  MetaModel({
    required this.currentPage,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });

  factory MetaModel.fromJson(Map<String, dynamic> json) {
    return MetaModel(
      currentPage: json['current_page'] is num
          ? (json['current_page'] as num).toInt()
          : int.tryParse(json['current_page']?.toString() ?? '') ?? 0,
      pageSize: json['page_size'] is num
          ? (json['page_size'] as num).toInt()
          : int.tryParse(json['page_size']?.toString() ?? '') ?? 0,
      totalItems: json['total_items'] is num
          ? (json['total_items'] as num).toInt()
          : int.tryParse(json['total_items']?.toString() ?? '') ?? 0,
      totalPages: json['total_pages'] is num
          ? (json['total_pages'] as num).toInt()
          : int.tryParse(json['total_pages']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'page_size': pageSize,
      'total_items': totalItems,
      'total_pages': totalPages,
    };
  }
}

class ApiResponseList<T> {
  final bool success;
  final String message;
  final int code;
  final List<T> items;
  final MetaModel meta;

  ApiResponseList({
    required this.success,
    required this.message,
    required this.code,
    required this.items,
    required this.meta,
  });

  factory ApiResponseList.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final rawData = json['data'];

    if (rawData is List) {
      return ApiResponseList<T>(
        success: json['success'] as bool? ?? false,
        message: json['message'] as String? ?? '',
        code: json['code'] as int? ?? 0,
        items: rawData
            .map((e) => fromJsonT(Map<String, dynamic>.from(e as Map)))
            .toList(),
        meta: MetaModel(
          currentPage: 1,
          pageSize: rawData.length,
          totalItems: rawData.length,
          totalPages: 1,
        ),
      );
    }

    final dataMap = rawData as Map? ?? {};
    final itemsList = dataMap['items'] as List? ?? [];

    return ApiResponseList<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      code: json['code'] as int? ?? 0,
      items: itemsList
          .map((e) => fromJsonT(Map<String, dynamic>.from(e as Map)))
          .toList(),
      meta: MetaModel.fromJson(
        Map<String, dynamic>.from(dataMap['meta'] as Map? ?? {}),
      ),
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'success': success,
      'message': message,
      'code': code,
      'data': {
        'items': items.map((e) => toJsonT(e)).toList(),
        'meta': meta.toJson(),
      },
    };
  }
}
