import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getDocument(String collection, String documentId) async {
    try {
      final doc = await _firestore.collection(collection).doc(documentId).get();
      if (doc.exists) return doc.data();
      return null;
    } catch (e) {
      print('Error getting document: $e');
      rethrow;
    }
  }

  Future<List<QueryDocumentSnapshot>> getCollection(String collection) async {
    try {
      final snapshot = await _firestore.collection(collection).get();
      return snapshot.docs;
    } catch (e) {
      print('Error getting collection: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getCollectionWithFilter(
    String collection,
    String field,
    dynamic value,
  ) async {
    try {
      final querySnapshot = await _firestore.collection(collection).where(field, isEqualTo: value).get();
      return querySnapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      print('Error getting collection with filter: $e');
      rethrow;
    }
  }

  Future<List<QueryDocumentSnapshot>> getFilteredCollection(String collection, String field, dynamic value) async {
    try {
      final querySnapshot = await _firestore.collection(collection).where(field, isEqualTo: value).get();
      return querySnapshot.docs;
    } catch (e) {
      print('Error getting filtered collection: $e');
      rethrow;
    }
  }

  Future<DocumentReference> addDocument(String collection, Map<String, dynamic> data) async {
    try {
      final result = await _firestore.collection(collection).add(data);
      return result;
    } catch (e) {
      print('Error in addDocument: $e');
      rethrow;
    }
  }

  Future<void> updateDocument(String collection, String documentId, Map<String, dynamic> data) {
    return _firestore.collection(collection).doc(documentId).update(data);
  }

  Future<void> deleteDocument(String collection, String documentId) {
    return _firestore.collection(collection).doc(documentId).delete();
  }

  Future<void> setDocument(String collection, String documentId, Map<String, dynamic> data) {
    return _firestore.collection(collection).doc(documentId).set(data);
  }

  // ⬇️ PENTING: ini tadinya di luar class
  Future<List<QueryDocumentSnapshot>> queryDocuments(
    String collection, {
    List<Map<String, dynamic>>? where,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    try {
      Query query = _firestore.collection(collection);

      if (where != null) {
        for (final w in where) {
          final field = w['field'] as String;
          final op = w['operator'] as String;
          final value = w['value'];
          switch (op) {
            case '==': query = query.where(field, isEqualTo: value); break;
            case '>=': query = query.where(field, isGreaterThanOrEqualTo: value); break;
            case '<=': query = query.where(field, isLessThanOrEqualTo: value); break;
            case '>':  query = query.where(field, isGreaterThan: value); break;
            case '<':  query = query.where(field, isLessThan: value); break;
            case 'array-contains': query = query.where(field, arrayContains: value); break;
          }
        }
      }

      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }
      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs;
    } catch (e) {
      print('Error querying documents: $e');
      return [];
    }
  }
}