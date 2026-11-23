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

  // Crop Calendar & Intercropping
  static String fullCalendar() => "/calendar";
  static String seasonCalendar(String seasonId) => "/calendar/season/$seasonId";
  static String monthCalendar(int month) => "/calendar/month/$month";
  static String intercropGuide() => "/intercrop";
  static String intercropBySeason(String seasonId) => "/intercrop/season/$seasonId";
  static String intercropByCrop(String cropId) => "/intercrop/crop/$cropId";
  static String intercropCompanions(String cropId) => "/intercrop/companions/$cropId";

  // Disease Diagnosis & Agricultural Tips
  static String diseases() => "/diseases";
  static String diseaseDetails(String id) => "/diseases/$id";
  static String diseaseCrops() => "/diseases/crops";
  static String diagnoseDisease() => "/diseases/diagnose";

  static String tips() => "/tips";
  static String tipDetails(String id) => "/tips/$id";

  static String diseaseReports() => "/disease-reports";
  static String diseaseReportDetails(String id) => "/disease-reports/$id";
  static String diseaseReportPhotos(String id) => "/disease-reports/$id/photos";
  static String diseaseReportStats() => "/disease-reports/stats/summary";

  // Machinery Directory
  static String machinery() => "/machinery";
  static String machineryDetail(String id) => "/machinery/$id";

  // Agricultural News
  static String news() => "/news";
  static String newsDetail(String id) => "/news/$id";
  static String newsCategories() => "/news/categories";

  // Community Forum
  static String forumPosts() => "/forum/posts";
  static String forumPostDetail(String id) => "/forum/posts/$id";
  static String forumPostLike(String id) => "/forum/posts/$id/like";
  static String forumPostComments(String id) => "/forum/posts/$id/comments";
  static String forumComment(String id) => "/forum/comments/$id";
  static String forumPostReport(String id) => "/forum/posts/$id/report";
}
