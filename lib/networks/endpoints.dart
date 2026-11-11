// ignore_for_file: constant_identifier_names
const String url = "https://krishi-connect-backend.onrender.com";

final class NetworkConstants {
  NetworkConstants._();
  static const ACCEPT = "Accept";
  static const ACCEPT_LANGUAGE = "Accept-Language";
  static const ACCEPT_LANGUAGE_VALUE = "bn";
  static const ACCEPT_TYPE = "application/json";
  static const AUTHORIZATION = "Authorization";
  static const CONTENT_TYPE = "content-Type";
}

final class Endpoints {
  Endpoints._();

  // Base
  static const String baseUrl = "https://krishi-connect-backend.onrender.com";

  // Users
  static String me() => "/users/me";

  // Listings (Farmer crops)
  static String listings() => "/listings";
  static String myListings() => "/listings/mine";
  static String listingDetails(String id) => "/listings/$id";
  static String listingPhotos(String id) => "/listings/$id/photos";
  static String matchingRates(String id) => "/listings/$id/matching-rates";

  // Rates (Buyer rate board)
  static String rates() => "/rates";
  static String myRates() => "/rates/mine";
  static String rateDetails(String id) => "/rates/$id";
  static String matchingListings(String id) => "/rates/$id/matching-listings";

  // Calls & Chat
  static String triggerCall() => "/calls";
  static String chats() => "/chats";
  static String chatMessages(String cid) => "/chats/$cid/messages";
  static String chatRead(String cid) => "/chats/$cid/read";
}
