/// BINISHOP — Responsive Breakpoints
library core.constants.breakpoints;

abstract final class AppBreakpoints {
  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktop = 1280;
  static const double largeDesktop = 1600;

  static bool isMobile(double width) => width < mobile;
  static bool isTablet(double width) => width >= mobile && width < tablet;
  static bool isDesktop(double width) => width >= tablet;
  static bool isLargeDesktop(double width) => width >= largeDesktop;

  /// Max content width for desktop layouts
  static const double maxContentWidth = 1280;
  static const double maxAdminContentWidth = 1600;
}