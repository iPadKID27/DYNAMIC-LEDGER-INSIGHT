import 'package:equatable/equatable.dart';
import '../model/financial_record.dart';

abstract class NetViewEvent extends Equatable {
  const NetViewEvent();

  @override
  List<Object?> get props => [];
}

class LedgerSubscriptionRequested extends NetViewEvent {
  final String userId;
  const LedgerSubscriptionRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

class LedgerRecordAdded extends NetViewEvent {
  final FinancialRecord record;
  const LedgerRecordAdded(this.record);

  @override
  List<Object?> get props => [record];
}

class LedgerRecordDeleted extends NetViewEvent {
  final String recordId;
  const LedgerRecordDeleted(this.recordId);

  @override
  List<Object?> get props => [recordId];
}
