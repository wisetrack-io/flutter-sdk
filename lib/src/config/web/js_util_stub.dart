dynamic jsify(Object? object) =>
    throw UnsupportedError('Only supported on web');

Future<T> promiseToFuture<T>(Object promise) =>
    throw UnsupportedError('Only supported on web');

F allowInterop<F extends Function>(F f) =>
    throw UnsupportedError('Only supported on web');
