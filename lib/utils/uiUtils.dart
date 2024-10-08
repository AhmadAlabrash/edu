// ignore_for_file: prefer_final_locals

import 'dart:ui';

import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vibration/vibration.dart';

class UiUtils {
  //key for globle navigation
  static GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

  static Locale getLocaleFromLanguageCode(final String languageCode) {
    final result = languageCode.split("-");
    return result.length == 1 ? Locale(result.first) : Locale(result.first, result.last);
  }

  static Future<void> showMessage(
      final BuildContext context, final String text, final MessageType type) async {
    OverlayState? overlayState = Overlay.of(context);
    OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (final context) => Positioned(
        left: 5,
        right: 5,
        bottom: 15,
        child: MessageContainer(
          context: context,
          text: text,
          type: type,
        ),
      ),
    );
    overlayState.insert(overlayEntry);
    await Future.delayed(const Duration(milliseconds: messageDisplayDuration));

    overlayEntry.remove();
  }

// Only numbers can be entered
  static List<TextInputFormatter> allowOnlyDigits() =>
      <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly];

  //
  static Future<dynamic> showBottomSheet({
    required final BuildContext context,
    required final Widget child,
    final Color? backgroundColor,
    final bool? enableDrag,
    final bool? isScrollControlled,
    final bool? useSafeArea,
  }) async {
    final result = await showModalBottomSheet(
      enableDrag: enableDrag ?? false,
      isScrollControlled: isScrollControlled ?? true,
      useSafeArea: useSafeArea ?? false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadiusOf20),
          topRight: Radius.circular(borderRadiusOf20),
        ),
      ),
      context: context,
      builder: (final _) {
        //using backdropFilter to blur the background screen
        //while bottomSheet is open
        return BackdropFilter(filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1), child: child);
      },
    );

    return result;
  }


  static Widget getBackArrow(BuildContext context, {VoidCallback? onTap}) {
    return CustomInkWellContainer(
      onTap: () {
        if (onTap != null) {
          onTap.call();
        } else {
          Navigator.pop(context);
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Center(
          child: CustomSvgPicture(
            svgImage: context.watch<AppThemeCubit>().state.appTheme == AppTheme.dark
                ? Directionality.of(context)
                        .toString()
                        .contains(TextDirection.RTL.value.toLowerCase())
                    ? "back_arrow_dark_ltr"
                    : "back_arrow_dark"
                : Directionality.of(context)
                        .toString()
                        .contains(TextDirection.RTL.value.toLowerCase())
                    ? "back_arrow_light_ltr"
                    : "back_arrow_light",
          ),
        ),
      ),
    );
  }

  static AppBar getSimpleAppBar({
    required final BuildContext context,
    required final String title,
    final Color? backgroundColor,
    final bool? centerTitle,
    final bool? isLeadingIconEnable,
    final double? elevation,
    final List<Widget>? actions,
  }) =>
      AppBar(
        surfaceTintColor: Theme.of(context).colorScheme.secondaryColor,
        systemOverlayStyle: UiUtils.getSystemUiOverlayStyle(context: context),
        leading: isLeadingIconEnable ?? true ? getBackArrow(context) : const CustomSizedBox(),
        title: CustomText(title, color: Theme.of(context).colorScheme.blackColor),
        centerTitle: centerTitle ?? false,
        elevation: elevation ?? 0.0,
        backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.secondaryColor,
        actions: actions ?? [],
      );

  static SystemUiOverlayStyle getSystemUiOverlayStyle({required final BuildContext context}) =>
      SystemUiOverlayStyle(
        statusBarColor: Theme.of(context).colorScheme.secondaryColor,
        systemNavigationBarColor: Theme.of(context).colorScheme.secondaryColor,
        systemNavigationBarIconBrightness:
            context.watch<AppThemeCubit>().state.appTheme == AppTheme.dark
                ? Brightness.light
                : Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
        statusBarIconBrightness: context.watch<AppThemeCubit>().state.appTheme == AppTheme.dark
            ? Brightness.light
            : Brightness.dark,
      );

  static void removeFocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  static Future<bool> clearUserData() async {
    try {
      final String? latitude = HiveRepository.getLatitude;
      final String? longitude = HiveRepository.getLongitude;
      final String? currentLocationName = HiveRepository.getLocationName;

      //
      await FirebaseAuth.instance.signOut();

      HiveRepository.setUserLoggedIn = false;

      await HiveRepository.clearBoxValues(boxName: HiveRepository.userDetailBoxKey);

      //we will store latitude,longitude and location name to fetch data based on latitude and longitude

      HiveRepository.setLongitude = longitude;
      HiveRepository.setLatitude = latitude;
      HiveRepository.setLocationName = currentLocationName;

      NotificationService.disposeListeners();
      //
      return true;
    } catch (e) {
      return false;
    }
  }

  static Color getStatusColor(
      {required final BuildContext context, required final String statusVal}) {
    Color stColor;
    switch (statusVal) {
      case "awaiting":
        stColor = Colors.grey.shade500;
        break;
      case "confirmed":
        stColor = Colors.green.shade500;
        break;
      case "started":
        stColor = const Color(0xff0096FF);
        break;
      case "rescheduled": //Rescheduled
        stColor = Colors.grey.shade500;
        break;
      case "cancelled": //Cancelled
        stColor = Colors.red;
        break;
      case "completed":
        stColor = Colors.green;
        break;
      default:
        stColor = Colors.green;
        break;
    }
    return stColor;
  }

  static Map<String, dynamic> getStatusColorAndImage(
      {required final BuildContext context, required final String statusVal}) {
    Color stColor;
    String imageName;
    switch (statusVal) {
      case "awaiting":
        stColor = const Color(0xff9E9E9E);
        imageName = "Awaiting";
        break;
      case "confirmed":
        stColor = const Color(0xffD6A90A);
        imageName = "Confirmed";
        break;
      case "started":
        stColor = const Color(0xff23AEFE);
        imageName = "Started";
        break;
      case "rescheduled": //Rescheduled
        stColor = const Color(0xff2560FC);
        imageName = "Rescheduled";
        break;
      case "cancelled": //Cancelled
        stColor = const Color(0xffFF0D09);
        imageName = "Cancelled";
        break;
      case "completed":
        stColor = const Color(0xff0AC836);
        imageName = "Completed";
        break;
      default:
        stColor = const Color(0xff0AC836);
        imageName = "Completed";
        break;
    }
    return {"color": stColor, "imageName": imageName};
  }

  static Future<void> getVibrationEffect() async {
    if (await Vibration.hasVibrator() ?? false) {
      await Vibration.vibrate(duration: 100);
    }
  }

  static Future<void> showAnimatedDialog(
      {required BuildContext context, required Widget child}) async {
    await showGeneralDialog(
      context: context,
      pageBuilder: (final context, final animation, final secondaryAnimation) =>
          const CustomSizedBox(),
      transitionBuilder: (final context, final animation, final secondaryAnimation, Widget _) =>
          Transform.scale(
        scale: Curves.easeInOut.transform(animation.value),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
          child: Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadiusOf10)),
            child: child,
          ),
        ),
      ),
    );
  }

  static String formatTimeWithDateTime(
    DateTime dateTime,
  ) {
    if (dateAndTimeSetting["use24HourFormat"]) {
      return DateFormat("kk:mm").format(dateTime);
    } else {
      return DateFormat("hh:mm a").format(dateTime);
    }
  }

  static Future<void> downloadOrShareFile({
    required String url,
    String? customFileName,
    required bool isDownload,
  }) async {
    try {
      String downloadFilePath = isDownload
          ? (await getApplicationDocumentsDirectory()).path
          : (await getTemporaryDirectory()).path;

      downloadFilePath =
          "$downloadFilePath/${customFileName != null ? customFileName : DateTime.now().toIso8601String()}";

      if (await File(downloadFilePath).exists()) {
        if (isDownload) {
          OpenFilex.open(downloadFilePath);
        } else {
          Share.shareXFiles([XFile(downloadFilePath)]);
        }
        return;
      }

      var httpClient = new HttpClient();
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);

      await File(downloadFilePath).writeAsBytes(
        bytes,
        flush: !isDownload,
      );
      if (isDownload) {
        OpenFilex.open(downloadFilePath);
      } else {
        Share.shareXFiles([XFile(downloadFilePath)]);
      }
    } catch (_) {

    }
  }
}
