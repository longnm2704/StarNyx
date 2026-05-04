import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:starnyx/core/services/core_services.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver(this._logger);

  final AppLogService _logger;

  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);
    _logger.debug('Bloc', 'create ${bloc.runtimeType}');
  }

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    _logger.debug('Bloc', '${bloc.runtimeType} event ${event.runtimeType}');
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    _logger.debug('Bloc', '${bloc.runtimeType} state changed');
  }

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    _logger.debug(
      'Bloc',
      '${bloc.runtimeType} transition ${transition.event.runtimeType}',
    );
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    _logger.error(
      'Bloc',
      '${bloc.runtimeType} error',
      error: error,
      stackTrace: stackTrace,
    );
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    _logger.debug('Bloc', 'close ${bloc.runtimeType}');
    super.onClose(bloc);
  }
}
