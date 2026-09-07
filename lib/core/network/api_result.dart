/// Sealed union type representing either a successful result or a failure
abstract class ApiResult<T> {
  const ApiResult();

  factory ApiResult.success(T data) = ApiSuccess<T>;
  factory ApiResult.failure(String message, {String? code, int? statusCode}) = ApiFailure<T>;

  bool get isSuccess => this is ApiSuccess<T>;
  bool get isFailure => this is ApiFailure<T>;

  T? get dataOrNull {
    if (this is ApiSuccess<T>) {
      return (this as ApiSuccess<T>).data;
    }
    return null;
  }

  String? get errorMessageOrNull {
    if (this is ApiFailure<T>) {
      return (this as ApiFailure<T>).message;
    }
    return null;
  }

  R when<R>({
    required R Function(T data) success,
    required R Function(String message, String? code, int? statusCode) failure,
  }) {
    if (this is ApiSuccess<T>) {
      return success((this as ApiSuccess<T>).data);
    } else {
      final f = this as ApiFailure<T>;
      return failure(f.message, f.code, f.statusCode);
    }
  }
}

class ApiSuccess<T> extends ApiResult<T> {
  final T data;
  const ApiSuccess(this.data);
}

class ApiFailure<T> extends ApiResult<T> {
  final String message;
  final String? code;
  final int? statusCode;

  const ApiFailure(this.message, {this.code, this.statusCode});
}
