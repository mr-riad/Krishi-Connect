// ignore_for_file: constant_identifier_names
const String url = "https://dev.api.mickanic.ca/api";

final class NetworkConstants {
  NetworkConstants._();
  static const ACCEPT = "Accept";
  static const APP_KEY = "App-Key";
  static const ACCEPT_LANGUAGE = "Accept-Language";
  static const ACCEPT_LANGUAGE_VALUE = "pt";
  static const APP_KEY_VALUE = String.fromEnvironment("APP_KEY_VALUE");
  static const ACCEPT_TYPE = "application/json";
  static const AUTHORIZATION = "Authorization";
  static const CONTENT_TYPE = "content-Type";
}

final class Endpoints {
  Endpoints._();
  //backend_url
  static String signUp() => "/auth/register";
  static String logIn() => "/auth/login";
  static String otpVerify() => "/auth/verify-otp";
  static String forgotPassword() => "/auth/forget-password";
  static String forgotPasswordOtpVerify() => "/auth/verify-reset-otp";
  static String resetPassword() => "/auth/reset-password";
  static String resendOtp() => "/auth/resend-otp";
  static String getAllJob() => "/jobs";
  static String getJobDetails(String id) => "/jobs/$id";
  static String getServices() => "/service-categories";

  ///profile
  static String profile() => "/user/profile";

  // static String getShopByCategories(String slug) =>
  //     "/api/shop-categories/$slug/";

  static String example() => "/api/";

  static String products(int pageNum, int perPage) =>
      "/products?page=$pageNum&per_page=$perPage";
  static String productDetails(int id) => "/products/$id";
}
