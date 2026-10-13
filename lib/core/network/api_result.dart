sealed class ApiResult<T> {
  const ApiResult();
}

class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess(this.value);

  final T value;
}

class ApiFailure<T> extends ApiResult<T> {
  const ApiFailure(this.message);

  final String message;
}
