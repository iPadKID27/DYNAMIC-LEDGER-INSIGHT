import 'package:equatable/equatable.dart';
import '../model/financial_record.dart';

enum LedgerStatus { initial, loading, success, error }

class NetViewState extends Equatable {
  final LedgerStatus status;
  final List<FinancialRecord> records;
  final String? errorMessage;
  final Map<String, dynamic>? aiSuggestion;

  const NetViewState({
    this.status = LedgerStatus.initial,
    this.records = const [],
    this.errorMessage,
    this.aiSuggestion,
  });

  @override
  List<Object?> get props => [status, records, errorMessage, aiSuggestion];

  NetViewState copyWith({
    LedgerStatus? status,
    List<FinancialRecord>? records,
    String? errorMessage,
    Map<String, dynamic>? aiSuggestion,
  }) {
    return NetViewState(
      status: status ?? this.status,
      records: records ?? this.records,
      errorMessage: errorMessage ?? this.errorMessage,
      aiSuggestion: aiSuggestion ?? this.aiSuggestion,
    );
  }
}
