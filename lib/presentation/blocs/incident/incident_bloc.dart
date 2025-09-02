import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/incident_model.dart';
import '../../../data/services/incident_service.dart';

// Events
abstract class IncidentEvent extends Equatable {
  const IncidentEvent();

  @override
  List<Object?> get props => [];
}

class LoadTourIncidents extends IncidentEvent {
  final String tourSlotId;
  final bool refresh;

  const LoadTourIncidents({
    required this.tourSlotId,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [tourSlotId, refresh];
}

class LoadMoreIncidents extends IncidentEvent {
  final String tourSlotId;

  const LoadMoreIncidents({required this.tourSlotId});

  @override
  List<Object?> get props => [tourSlotId];
}

class RefreshIncidents extends IncidentEvent {
  final String tourSlotId;

  const RefreshIncidents({required this.tourSlotId});

  @override
  List<Object?> get props => [tourSlotId];
}

// States
abstract class IncidentState extends Equatable {
  final List<TourIncident> incidents;
  final bool hasReachedMax;
  final int currentPage;

  const IncidentState({
    this.incidents = const [],
    this.hasReachedMax = false,
    this.currentPage = 0,
  });

  @override
  List<Object?> get props => [incidents, hasReachedMax, currentPage];
}

class IncidentInitial extends IncidentState {}

class IncidentLoading extends IncidentState {
  const IncidentLoading({
    super.incidents,
    super.hasReachedMax,
    super.currentPage,
  });
}

class IncidentLoaded extends IncidentState {
  const IncidentLoaded({
    required super.incidents,
    super.hasReachedMax,
    super.currentPage,
  });
}

class IncidentError extends IncidentState {
  final String message;

  const IncidentError({
    required this.message,
    super.incidents,
    super.hasReachedMax,
    super.currentPage,
  });

  @override
  List<Object?> get props => [message, incidents, hasReachedMax, currentPage];
}

// BLoC
class IncidentBloc extends Bloc<IncidentEvent, IncidentState> {
  final IncidentService _incidentService;
  static const int _pageSize = 10;

  IncidentBloc({required IncidentService incidentService})
      : _incidentService = incidentService,
        super(IncidentInitial()) {
    on<LoadTourIncidents>(_onLoadTourIncidents);
    on<LoadMoreIncidents>(_onLoadMoreIncidents);
    on<RefreshIncidents>(_onRefreshIncidents);
  }

  Future<void> _onLoadTourIncidents(
    LoadTourIncidents event,
    Emitter<IncidentState> emit,
  ) async {
    if (event.refresh) {
      emit(const IncidentLoading());
    } else {
      emit(IncidentLoading(
        incidents: state.incidents,
        hasReachedMax: state.hasReachedMax,
        currentPage: state.currentPage,
      ));
    }

    try {
      final response = await _incidentService.getTourSlotIncidentsWithRetry(
        tourSlotId: event.tourSlotId,
        pageIndex: 0,
        pageSize: _pageSize,
      );

      if (response.success && response.data != null) {
        final incidentsResponse = response.data!;
        emit(IncidentLoaded(
          incidents: incidentsResponse.incidents,
          hasReachedMax: incidentsResponse.incidents.length < _pageSize ||
              incidentsResponse.isLastPage,
          currentPage: 0,
        ));
      } else {
        emit(IncidentError(
          message: response.message ?? 'Có lỗi xảy ra khi tải danh sách sự cố',
          incidents: event.refresh ? [] : state.incidents,
          hasReachedMax: state.hasReachedMax,
          currentPage: state.currentPage,
        ));
      }
    } catch (e) {
      emit(IncidentError(
        message: 'Có lỗi không xác định xảy ra: ${e.toString()}',
        incidents: event.refresh ? [] : state.incidents,
        hasReachedMax: state.hasReachedMax,
        currentPage: state.currentPage,
      ));
    }
  }

  Future<void> _onLoadMoreIncidents(
    LoadMoreIncidents event,
    Emitter<IncidentState> emit,
  ) async {
    if (state.hasReachedMax) return;

    emit(IncidentLoading(
      incidents: state.incidents,
      hasReachedMax: state.hasReachedMax,
      currentPage: state.currentPage,
    ));

    try {
      final nextPage = state.currentPage + 1;
      final response = await _incidentService.getTourSlotIncidentsWithRetry(
        tourSlotId: event.tourSlotId,
        pageIndex: nextPage,
        pageSize: _pageSize,
      );

      if (response.success && response.data != null) {
        final incidentsResponse = response.data!;
        final newIncidents = <TourIncident>[...state.incidents, ...incidentsResponse.incidents];

        emit(IncidentLoaded(
          incidents: newIncidents,
          hasReachedMax: incidentsResponse.incidents.length < _pageSize ||
              incidentsResponse.isLastPage,
          currentPage: nextPage,
        ));
      } else {
        emit(IncidentError(
          message: response.message ?? 'Có lỗi xảy ra khi tải thêm sự cố',
          incidents: state.incidents,
          hasReachedMax: state.hasReachedMax,
          currentPage: state.currentPage,
        ));
      }
    } catch (e) {
      emit(IncidentError(
        message: 'Có lỗi không xác định xảy ra: ${e.toString()}',
        incidents: state.incidents,
        hasReachedMax: state.hasReachedMax,
        currentPage: state.currentPage,
      ));
    }
  }

  Future<void> _onRefreshIncidents(
    RefreshIncidents event,
    Emitter<IncidentState> emit,
  ) async {
    // Trigger a refresh by calling the load method directly
    await _onLoadTourIncidents(
      LoadTourIncidents(tourSlotId: event.tourSlotId, refresh: true),
      emit,
    );
  }
}

// Extension for easier access to incident statistics
extension IncidentStateExtension on IncidentState {
  int get totalIncidents => incidents.length;
  
  int get unresolvedIncidents => 
      incidents.where((incident) => !incident.isResolved).length;
  
  int get criticalIncidents => 
      incidents.where((incident) => incident.isCritical).length;
  
  int get resolvedIncidents => 
      incidents.where((incident) => incident.isResolved).length;
  
  bool get hasIncidents => incidents.isNotEmpty;
  
  bool get hasUnresolvedIncidents => unresolvedIncidents > 0;
  
  bool get hasCriticalIncidents => criticalIncidents > 0;
  
  List<TourIncident> get unresolvedIncidentsList => 
      incidents.where((incident) => !incident.isResolved).toList();
  
  List<TourIncident> get criticalIncidentsList => 
      incidents.where((incident) => incident.isCritical).toList();
  
  List<TourIncident> get recentIncidents {
    final sortedIncidents = List<TourIncident>.from(incidents);
    sortedIncidents.sort((a, b) => b.reportedAt.compareTo(a.reportedAt));
    return sortedIncidents.take(5).toList();
  }
}
