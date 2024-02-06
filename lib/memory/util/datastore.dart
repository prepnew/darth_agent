/// Basic DataStore for all types of data. Using basic CRUD
abstract class DataStore {
  Future<void> insert(String key, dynamic value) async {}
  Future<dynamic> read(String key) async {}
  Future<bool> delete(String key) async => false;
  Future<void> update(String key, dynamic value) async {}
  Future<void> clear() async {}
}
