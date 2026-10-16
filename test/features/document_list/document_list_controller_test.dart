import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacim_invoicer/domain/models/document_list_query.dart';
import 'package:pacim_invoicer/domain/models/document_type.dart';
import 'package:pacim_invoicer/features/document_list/document_list_controller.dart';

void main() {
  late ProviderContainer container;
  final provider = documentListControllerProvider(DocumentType.quotation);

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  test('setSort on same field toggles direction', () {
    final controller = container.read(provider.notifier);
    expect(container.read(provider).sortDescending, isTrue);

    controller.setSort(DocumentSortField.issueDate);
    expect(container.read(provider).sortDescending, isFalse);

    controller.setSort(DocumentSortField.issueDate);
    expect(container.read(provider).sortDescending, isTrue);
  });

  test('setSort on a new field sorts ascending', () {
    container.read(provider.notifier).setSort(DocumentSortField.customerName);
    final query = container.read(provider);
    expect(query.sortField, DocumentSortField.customerName);
    expect(query.sortDescending, isFalse);
  });

  test('loadMore adds 50 to the limit when every row is loaded', () {
    container.read(provider.notifier).loadMore(loadedCount: 50);
    expect(container.read(provider).limit, 100);
  });

  test('loadMore does nothing while the last page is still loading', () {
    final controller = container.read(provider.notifier);
    controller.loadMore(loadedCount: 50);
    controller.loadMore(loadedCount: 50);
    expect(container.read(provider).limit, 100);
  });

  test('loadMore does nothing when fewer rows than the limit exist', () {
    container.read(provider.notifier).loadMore(loadedCount: 12);
    expect(container.read(provider).limit, 50);
  });

  test('setSearchText and setIssuedRange update the query', () {
    final controller = container.read(provider.notifier);
    controller.setSearchText('acme');
    controller.setIssuedRange(DateTime(2026, 1, 1), DateTime(2026, 2, 1));
    final query = container.read(provider);
    expect(query.searchText, 'acme');
    expect(query.issuedFrom, DateTime(2026, 1, 1));
    expect(query.issuedTo, DateTime(2026, 2, 1));
    controller.setIssuedRange(null, null);
    expect(container.read(provider).issuedFrom, isNull);
  });
}
