import 'package:equatable/equatable.dart';
import '../model/financial_record.dart';

enum LedgerStatus { initial, loading, success, error }

class NetViewState extends Equatable {
  final LedgerStatus status;
  final List<FinancialRecord> records;
  final String? errorMessage;

  const NetViewState({
    this.status = LedgerStatus.initial,
    this.records = const [],
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, records, errorMessage];

  NetViewState copyWith({
    LedgerStatus? status,
    List<FinancialRecord>? records,
    String? errorMessage,
  }) {
    return NetViewState(
      status: status ?? this.status,
      records: records ?? this.records,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
