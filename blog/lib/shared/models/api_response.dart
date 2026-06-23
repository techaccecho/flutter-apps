class ApiResponse<T> {
  final String code;
  final String message;
  final T data;
  final ApiMeta? meta;

  ApiResponse({
    required this.code,
    required this.message,
    required this.data,
    this.meta,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    return ApiResponse<T>(
      code: json['code'] ?? '',
      message: json['message'] ?? '',
      data: fromJsonT(json['data']),
      meta: json['meta'] != null ? ApiMeta.fromJson(json['meta']) : null,
    );
  }
}

class ApiMeta {
  final String? nextCursor;
  final bool hasMore;

  ApiMeta({this.nextCursor, required this.hasMore});

  factory ApiMeta.fromJson(Map<String, dynamic> json) {
    return ApiMeta(
      nextCursor: json['nextCursor'],
      hasMore: json['hasMore'] ?? false
    );
  }
}