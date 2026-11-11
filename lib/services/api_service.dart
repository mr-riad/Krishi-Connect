// ignore_for_file: constant_identifier_names
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../helpers/all_routes.dart';
import '../helpers/di.dart';
import '../helpers/navigation_service.dart';

/// Base URL for Krishi Connect backend
const String kBaseUrl = 'https://krishi-connect-backend.onrender.com';

/// Singleton Dio instance configured for Krishi Connect API.
/// Auth token is injected via interceptor by calling Firebase Auth's
/// [getIdToken] on every request so the token is always fresh.
class KrishiApiService {
  KrishiApiService._();
  static final KrishiApiService instance = KrishiApiService._();

  late final Dio _dio = _buildDio();

  Dio get dio => _dio;

  Dio _buildDio() {
    final d = Dio(
      BaseOptions(
        baseUrl: kBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // Inject Firebase ID token or saved access token before every request
    d.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            String? token;
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              // getIdToken(false) uses cache; only hits network if expired.
              // On 401 the interceptor below will force-refresh with getIdToken(true).
              token = await user.getIdToken(false);
              if (token != null && token.isNotEmpty) {
                // Keep local cache fresh
                appData.write(kKeyAccessToken, token);
              }
            }
            // Fallback to saved token (e.g. dev/token-login mode)
            if (token == null || token.isEmpty) {
              final saved = appData.read(kKeyAccessToken)?.toString();
              if (saved != null && saved.isNotEmpty) {
                token = saved;
              }
            }
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            if (kDebugMode) {
              print(
                '[KrishiApi] ${options.method} ${options.baseUrl}${options.path}'
                ' | Auth: ${options.headers['Authorization'] != null ? 'Bearer [PRESENT]' : 'NONE'}',
              );
            }
          } catch (e) {
            if (kDebugMode) print('[KrishiApi] Token error: $e');
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (kDebugMode) {
            print(
              '[KrishiApi] Error ${error.response?.statusCode}: '
              '${error.response?.data}',
            );
          }

          // ── 401: Token expired → force-refresh and retry once ──────────────
          if (error.response?.statusCode == 401 &&
              error.requestOptions.extra['retried'] != true) {
            try {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                // Force a fresh token from Firebase server
                final freshToken = await user.getIdToken(true);
                if (freshToken != null && freshToken.isNotEmpty) {
                  appData.write(kKeyAccessToken, freshToken);

                  // Retry the original request with the fresh token
                  final opts = error.requestOptions;
                  opts.headers['Authorization'] = 'Bearer $freshToken';
                  opts.extra['retried'] = true;
                  final response = await d.fetch(opts);
                  return handler.resolve(response);
                }
              }
            } catch (refreshError) {
              if (kDebugMode) {
                print('[KrishiApi] Token refresh/retry failed: $refreshError');
              }
            }
          }

          return handler.next(error);
        },
      ),
    );

    return d;
  }

  // ─── Session ──────────────────────────────────────────────────────────────

  /// Called when a 401 cannot be recovered (token refresh also failed).
  /// Clears local session and sends the user back to the login screen.
  void _handleSessionExpired() {
    if (kDebugMode) print('[KrishiApi] Session expired — redirecting to login');
    // Sign out from Firebase
    FirebaseAuth.instance.signOut().catchError((_) {});
    // Clear local storage
    appData.remove(kKeyAccessToken);
    appData.remove(kKeyIsLoggedIn);
    appData.remove(selectedRole);
    appData.remove(kPhone);
    // Navigate to login (remove all previous routes)
    NavigationService.navigateToUntilReplacement(Routes.loginScreen);
  }

  // ─── Users ────────────────────────────────────────────────────────────────

  /// GET /users/me
  Future<Map<String, dynamic>> getMe() async {
    final res = await _dio.get('/users/me');
    return res.data as Map<String, dynamic>;
  }

  /// PUT /users/me – update profile (name, phone, role, district, upazila, lat, lng)
  Future<Map<String, dynamic>> updateMe(Map<String, dynamic> body) async {
    final res = await _dio.put('/users/me', data: body);
    return res.data as Map<String, dynamic>;
  }

  // ─── Listings ─────────────────────────────────────────────────────────────

  /// POST /listings – create a crop listing (farmer only)
  Future<Map<String, dynamic>> createListing(Map<String, dynamic> body) async {
    final res = await _dio.post('/listings', data: body);
    return res.data as Map<String, dynamic>;
  }

  /// GET /listings – search/filter listings (buyer view)
  Future<Map<String, dynamic>> searchListings({
    String? q,
    String? category,
    String? district,
    String? upazila,
    double? minPrice,
    double? maxPrice,
    double? minQuantity,
    double? maxQuantity,
    String? harvestFrom,
    String? harvestTo,
    double? lat,
    double? lng,
    double? radiusKm,
    String sort = 'newest',
    int limit = 20,
    int offset = 0,
  }) async {
    final params = <String, dynamic>{
      'sort': sort,
      'limit': limit,
      'offset': offset,
    };
    if (q != null && q.isNotEmpty) params['q'] = q;
    if (category != null) params['category'] = category;
    if (district != null && district.isNotEmpty) params['district'] = district;
    if (upazila != null && upazila.isNotEmpty) params['upazila'] = upazila;
    if (minPrice != null) params['min_price'] = minPrice;
    if (maxPrice != null) params['max_price'] = maxPrice;
    if (minQuantity != null) params['min_quantity'] = minQuantity;
    if (maxQuantity != null) params['max_quantity'] = maxQuantity;
    if (harvestFrom != null) params['harvest_from'] = harvestFrom;
    if (harvestTo != null) params['harvest_to'] = harvestTo;
    if (lat != null) params['lat'] = lat;
    if (lng != null) params['lng'] = lng;
    if (radiusKm != null) params['radius_km'] = radiusKm;

    final res = await _dio.get('/listings', queryParameters: params);
    return res.data as Map<String, dynamic>;
  }

  /// GET /listings/mine – farmer's own listings
  Future<List<dynamic>> getMyListings() async {
    final res = await _dio.get('/listings/mine');
    return res.data as List<dynamic>;
  }

  /// PATCH /listings/{id}
  Future<Map<String, dynamic>> updateListing(
      String id, Map<String, dynamic> body) async {
    final res = await _dio.patch('/listings/$id', data: body);
    return res.data as Map<String, dynamic>;
  }

  /// DELETE /listings/{id}
  Future<void> deleteListing(String id) async {
    await _dio.delete('/listings/$id');
  }

  /// GET /listings/{id}/matching-rates – farmer: which buyers match
  Future<List<dynamic>> getMatchingRates(String listingId,
      {double radiusKm = 50}) async {
    final res = await _dio.get('/listings/$listingId/matching-rates',
        queryParameters: {'radius_km': radiusKm});
    return res.data as List<dynamic>;
  }

  // ─── Rates ────────────────────────────────────────────────────────────────

  /// POST /rates – publish a buying rate (buyer only)
  Future<Map<String, dynamic>> createRate(Map<String, dynamic> body) async {
    final res = await _dio.post('/rates', data: body);
    return res.data as Map<String, dynamic>;
  }

  /// GET /rates – rate board (farmer view)
  Future<Map<String, dynamic>> getRates({
    String? q,
    String? category,
    String? district,
    String? upazila,
    double? minRate,
    double? maxRate,
    double? lat,
    double? lng,
    double? radiusKm,
    String sort = 'newest',
    int limit = 20,
    int offset = 0,
  }) async {
    final params = <String, dynamic>{
      'sort': sort,
      'limit': limit,
      'offset': offset,
    };
    if (q != null && q.isNotEmpty) params['q'] = q;
    if (category != null) params['category'] = category;
    if (district != null && district.isNotEmpty) params['district'] = district;
    if (upazila != null && upazila.isNotEmpty) params['upazila'] = upazila;
    if (minRate != null) params['min_rate'] = minRate;
    if (maxRate != null) params['max_rate'] = maxRate;
    if (lat != null) params['lat'] = lat;
    if (lng != null) params['lng'] = lng;
    if (radiusKm != null) params['radius_km'] = radiusKm;

    final res = await _dio.get('/rates', queryParameters: params);
    return res.data as Map<String, dynamic>;
  }

  /// GET /rates/mine – buyer's own rates
  Future<List<dynamic>> getMyRates() async {
    final res = await _dio.get('/rates/mine');
    return res.data as List<dynamic>;
  }

  /// PATCH /rates/{id}
  Future<Map<String, dynamic>> updateRate(
      String id, Map<String, dynamic> body) async {
    final res = await _dio.patch('/rates/$id', data: body);
    return res.data as Map<String, dynamic>;
  }

  /// DELETE /rates/{id}
  Future<void> deleteRate(String id) async {
    await _dio.delete('/rates/$id');
  }

  /// GET /rates/{id}/matching-listings – buyer: which farmers match
  Future<List<dynamic>> getMatchingListings(String rateId,
      {double radiusKm = 50}) async {
    final res = await _dio.get('/rates/$rateId/matching-listings',
        queryParameters: {'radius_km': radiusKm});
    return res.data as List<dynamic>;
  }

  // ─── Chat ─────────────────────────────────────────────────────────────────

  /// POST /chats – Get-or-create a 1:1 conversation
  Future<Map<String, dynamic>> startConversation({
    required String participantId,
    String? listingId,
  }) async {
    final body = <String, dynamic>{
      'participant_id': participantId,
    };
    if (listingId != null) body['listing_id'] = listingId;
    final res = await _dio.post('/chats', data: body);
    return res.data as Map<String, dynamic>;
  }

  /// GET /chats – List current user's conversations
  Future<List<dynamic>> getConversations() async {
    final res = await _dio.get('/chats');
    return res.data as List<dynamic>;
  }

  /// GET /chats/{cid}/messages – Load message history
  Future<List<dynamic>> getMessages(String cid, {int limit = 50}) async {
    final res = await _dio.get('/chats/$cid/messages', queryParameters: {'limit': limit});
    return res.data as List<dynamic>;
  }

  /// POST /chats/{cid}/messages – Send a message
  Future<Map<String, dynamic>> sendMessage(String cid, String text) async {
    final res = await _dio.post('/chats/$cid/messages', data: {'text': text});
    return res.data as Map<String, dynamic>;
  }

  /// POST /chats/{cid}/read – Mark messages in conversation as read
  Future<void> markRead(String cid) async {
    await _dio.post('/chats/$cid/read');
  }

  // ─── Photos Upload ────────────────────────────────────────────────────────

  /// Upload photo bytes/file to /listings/{id}/photos
  Future<Map<String, dynamic>> uploadListingPhotos(
    String listingId,
    List<MultipartFile> files,
  ) async {
    final formData = FormData.fromMap({
      'files': files,
    });
    final res = await _dio.post(
      '/listings/$listingId/photos',
      data: formData,
    );
    return res.data as Map<String, dynamic>;
  }

  // ─── Calls ────────────────────────────────────────────────────────────────

  /// POST /calls – get phone number + tel URI for a user, log the call
  Future<Map<String, dynamic>> triggerCall({
    required String targetUid,
    String? listingId,
    String? rateId,
  }) async {
    final body = <String, dynamic>{
      'target_uid': targetUid,
    };
    if (listingId != null) body['listing_id'] = listingId;
    if (rateId != null) body['rate_id'] = rateId;
    final res = await _dio.post('/calls', data: body);
    return res.data as Map<String, dynamic>;
  }
}

