import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nutriapp/services/firestore_service.dart';

// Define the Firestore provider
final firestoreProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});
