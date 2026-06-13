import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/financial_record.dart';
import '../repository/ledger_repository.dart';
import '../repository/ai_repository.dart';
import 'netview_event.dart';
import 'netview_state.dart';

class NetViewBloc extends Bloc<NetViewEvent, NetViewState> {
  final LedgerRepository _ledgerRepository;
  final AIRepository _aiRepository;
  StreamSubscription? _ledgerSubscription;

  NetViewBloc({
    required LedgerRepository ledgerRepository,
    required AIRepository aiRepository,
  })  : _ledgerRepository = ledgerRepository,
        _aiRepository = aiRepository,
        super(const NetViewState()) {
    on<LedgerSubscriptionRequested>(_onSubscriptionRequested);
    on<_LedgerRecordsUpdated>(_onRecordsUpdated);
    on<LedgerRecordAdded>(_onRecordAdded);
    on<LedgerRecordDeleted>(_onRecordDeleted);
    on<AICategoryMappingRequested>(_onAICategoryMappingRequested);
  }

  Future<void> _onSubscriptionRequested(LedgerSubscriptionRequested event, Emitter<NetViewState> emit) async {
    emit(state.copyWith(status: LedgerStatus.loading));
    await _ledgerSubscription?.cancel();
    _ledgerSubscription = _ledgerRepository.getRecords(event.userId).listen(
      (records) => add(_LedgerRecordsUpdated(records)),
      onError: (e) => emit(state.copyWith(status: LedgerStatus.error, errorMessage: e.toString())),
    );
  }

  // Internal event for stream updates
  void _onRecordsUpdated(_LedgerRecordsUpdated event, Emitter<NetViewState> emit) {
    emit(state.copyWith(status: LedgerStatus.success, records: event.records));
  }

  Future<void> _onRecordAdded(LedgerRecordAdded event, Emitter<NetViewState> emit) async {
    try {
      await _ledgerRepository.addRecord(event.record);
    } catch (e) {
      emit(state.copyWith(status: LedgerStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onRecordDeleted(LedgerRecordDeleted event, Emitter<NetViewState> emit) async {
    try {
      await _ledgerRepository.deleteRecord(event.recordId);
    } catch (e) {
      emit(state.copyWith(status: LedgerStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onAICategoryMappingRequested(AICategoryMappingRequested event, Emitter<NetViewState> emit) async {
    try {
      final suggestion = await _aiRepository.mapCategory(event.note);
      final decoded = jsonDecode(suggestion['raw']!);
      emit(state.copyWith(aiSuggestion: decoded));
    } catch (e) {
      // Don't fail the whole bloc for AI error, just don't suggest
      print('AI Error: $e');
    }
  }

  @override
  Future<void> close() {
    _ledgerSubscription?.cancel();
    return super.close();
  }
}

// Private event for stream updates
class _LedgerRecordsUpdated extends NetViewEvent {
  final List<FinancialRecord> records;
  const _LedgerRecordsUpdated(this.records);

  @override
  List<Object?> get props => [records];
}
