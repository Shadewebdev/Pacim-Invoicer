/// Produces unique identifiers for documents, chains and line items.
abstract interface class IdGenerator {
  String generateId();
}
