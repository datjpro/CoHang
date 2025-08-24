// App Constants
class AppConstants {
  // App Information
  static const String appName = 'Quản lý dạy thêm';
  static const String appVersion = '1.0.0';
  
  // Database
  static const String databaseName = 'tutoring_manager.db';
  static const int databaseVersion = 1;
  
  // API
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 15);
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;
  
  static const double defaultBorderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;
  static const double extraLargeBorderRadius = 24.0;
  
  static const double defaultElevation = 2.0;
  static const double smallElevation = 1.0;
  static const double largeElevation = 4.0;
  static const double extraLargeElevation = 8.0;
  
  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 150);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Layout breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1200;
  
  // Table settings
  static const double minColumnWidth = 80.0;
  static const double maxColumnWidth = 200.0;
  static const double defaultRowHeight = 56.0;
  static const double compactRowHeight = 48.0;
  
  // Form validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
  static const int maxEmailLength = 100;
  static const int maxPhoneLength = 15;
  static const int maxAddressLength = 200;
  static const int maxNoteLength = 500;
  
  // Date formats
  static const String displayDateFormat = 'dd/MM/yyyy';
  static const String displayTimeFormat = 'HH:mm';
  static const String displayDateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String apiDateFormat = 'yyyy-MM-dd';
  static const String apiDateTimeFormat = 'yyyy-MM-ddTHH:mm:ss';
  
  // Storage keys
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String userPreferencesKey = 'user_preferences';
  
  // Error messages
  static const String genericErrorMessage = 'Có lỗi xảy ra. Vui lòng thử lại.';
  static const String networkErrorMessage = 'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối internet.';
  static const String timeoutErrorMessage = 'Yêu cầu quá thời gian. Vui lòng thử lại.';
  static const String validationErrorMessage = 'Dữ liệu không hợp lệ. Vui lòng kiểm tra lại.';
  
  // Success messages
  static const String saveSuccessMessage = 'Lưu thành công!';
  static const String updateSuccessMessage = 'Cập nhật thành công!';
  static const String deleteSuccessMessage = 'Xóa thành công!';
  static const String loginSuccessMessage = 'Đăng nhập thành công!';
  static const String logoutSuccessMessage = 'Đăng xuất thành công!';
}

// Route names
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String classroom = '/classroom';
  static const String student = '/student';
  static const String debug = '/debug';
}

// Asset paths
class AppAssets {
  static const String iconsPath = 'assets/icons/';
  static const String imagesPath = 'assets/images/';
  static const String lottiePath = 'assets/lottie/';
  
  // Icons
  static const String appIcon = '${iconsPath}app_icon.png';
  static const String noDataIcon = '${iconsPath}no_data.svg';
  static const String errorIcon = '${iconsPath}error.svg';
  
  // Images
  static const String logoImage = '${imagesPath}logo.png';
  static const String backgroundImage = '${imagesPath}background.png';
  
  // Lottie animations
  static const String loadingAnimation = '${lottiePath}loading.json';
  static const String successAnimation = '${lottiePath}success.json';
  static const String errorAnimation = '${lottiePath}error.json';
}

// Regular expressions
class AppRegex {
  static final RegExp email = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  
  static final RegExp phone = RegExp(
    r'^[0-9]{10,11}$',
  );
  
  static final RegExp vietnamesePhone = RegExp(
    r'^(84|0[3|5|7|8|9])+([0-9]{8,9})$',
  );
  
  static final RegExp url = RegExp(
    r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
  );
  
  static final RegExp password = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$',
  );
  
  static final RegExp vietnameseName = RegExp(
    r'^[a-zA-ZÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚÝàáâãèéêìíòóôõùúýĂăĐđĨĩŨũƠơƯưÂâÊêÔôĂăĐđ\s]+$',
  );
}
