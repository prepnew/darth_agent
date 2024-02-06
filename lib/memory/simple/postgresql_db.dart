import 'package:darth_agent/memory/util/datastore.dart';

class PostgresqlDb extends DataStore {
  @override
  Future<void> clear() async {}

  @override
  Future<bool> delete(String key) async => false;

  @override
  Future<void> insert(String key, value) async {}

  @override
  Future<dynamic> read(String key) async {}

  @override
  Future<void> update(String key, value) async {}
}
