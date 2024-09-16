import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // ignore_for_file: use_build_context_synchronously
import 'package:pinput/pinput.dart';

import "../../utils/timer.dart";

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({
    required this.countryCode,
    required this.phoneNumberWithCountryCode,
    required this.phoneNumberWithOutCountryCode,
    required this.source,
    final Key? key,
  }) : super(key: key);

  final String phoneNumberWithCountryCode;
  final String phoneNumberWithOutCountryCode;
  final String countryCode;
  final String source;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();

  static Route route(final RouteSettings routeSettings) {
    final Map parameters = routeSettings.arguments as Map;
    return CupertinoPageRoute(
      builder: (final _) => OtpVerificationScreen(
        countryCode: parameters['countryCode'],
        phoneNumberWithOutCountryCode: parameters['phoneNumberWithOutCountryCode'],
        phoneNumberWithCountryCode: parameters["phoneNumberWithCountryCode"],
        source: parameters["source"],
      ),
    );
  }
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  bool isCountdownFinished = false;
  bool isOtpSent = false;
  TextEditingController otpController = TextEditingController();
  bool shouldShowOtpResendSuccessMessage = false;
  FocusNode otpFiledFocusNode = FocusNode();
  CountDownTimer countDownTimer = CountDownTimer();

  ValueNotifier<bool> isCountDownCompleted = ValueNotifier(false);

  //
/*
  @override
  void codeUpdated() {
    //otpController.text = code!;
    setState(() {});
  }
*/

  @override
  void dispose() {
    otpFiledFocusNode.dispose();
    otpController.dispose();
/*    unregisterListener();
    cancel();
    SmsAutoFill().unregisterListener();*/
    countDownTimer.timerController.close();
    isCountDownCompleted.dispose();
    super.dispose();
  }

  @override
  void initState() {
/*    SmsAutoFill().getAppSignature.then((final signature) {});
    SmsAutoFill().listenForCode();*/
    countDownTimer.start(_onCountdownComplete);
    if (widget.phoneNumberWithOutCountryCode == "9876543210") {
      otpController.text = '123456';
      Future.delayed(
        Duration.zero,
        () {
          context.read<VerifyOtpCubit>().verifyOtp("123456");
        },
      );
    }
    super.initState();
  }

  void _onCountdownComplete() {
    isCountDownCompleted.value = true;
  }

  //
  void _onResendOtpClick() {
    if (isCountDownCompleted.value) {
      context.read<ResendOtpCubit>().resendOtp(
        widget.phoneNumberWithCountryCode,
        onOtpSent: () {
          // context.read<CountDownCubit>().reset();
          otpController.clear();
          isCountdownFinished = false;
          SchedulerBinding.instance.addPostFrameCallback((final _) {
            if (mounted) setState(() {});
          });
        },
      );
    }
  }

  Widget _responseMessages(final ResendOtpState resendOtpState) => CustomSizedBox(
        height: 30,
        child: Builder(
          builder: (final BuildContext context) {
            if (resendOtpState is ResendOtpSuccess) {
              Future.delayed(const Duration(seconds: 3)).then((final value) {
                context.read<ResendOtpCubit>().setDefaultOtpState();
              });
            }

            if (resendOtpState is ResendOtpInProcess) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CupertinoActivityIndicator(radius: 8),
                  const CustomSizedBox(
                    width: 5,
                  ),
                  CustomText(
                    'sending_otp'.translate(context: context),
                    color: Theme.of(context).colorScheme.blackColor,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: 14,
                    textAlign: TextAlign.center,
                  )
                ],
              );
            }

            if (resendOtpState is ResendOtpFail) {
              UiUtils.showMessage(
                  context,
                  resendOtpState.error.message.toString().translate(context: context),
                  MessageType.error);
            }

            return Visibility(
              visible: resendOtpState is ResendOtpSuccess,
              child: CustomText('otp_sent'.translate(context: context),
                  color: Theme.of(context).colorScheme.blackColor),
            );
          },
        ),
      );

  Widget _buildHeader() => Align(
        alignment: AlignmentDirectional.topStart,
        child: CustomText(
          'otp_verification'.translate(context: context),
          fontSize: 35,
          fontWeight: FontWeight.bold,
        ),
      );

  Widget _buildSubHeading() => Align(
        alignment: AlignmentDirectional.topStart,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 25),
          child: CustomText(
            "${"enter_verification_code".translate(context: context)}\n${widget.phoneNumberWithCountryCode}",
            color: Theme.of(context).colorScheme.blackColor,
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.normal,
            fontSize: 16,
            textAlign: TextAlign.left,
          ),
        ),
      );

  Widget _buildResendButton(final BuildContext context, final resendOtpState) =>
      BlocConsumer<VerifyPhoneNumberFromAPICubit, VerifyPhoneNumberFromAPIState>(
        listener: (final BuildContext context, final VerifyPhoneNumberFromAPIState state) async {
          if (state is VerifyPhoneNumberFromAPIFailure) {
            UiUtils.showMessage(
              context,
              state.errorMessage.toString().translate(context: context),
              MessageType.error,
            );
          }
          if (state is VerifyPhoneNumberFromAPISuccess) {
            // 101:- Mobile number already registered and Active
            // 102:- Mobile number is not registered
            // 103:- Mobile number is De active
            if (state.statusCode == '103') {
              UiUtils.showMessage(
                context,
                'yourAccountIsDeActive'.translate(context: context),
                MessageType.warning,
              );
              Navigator.pop(context);
              return;
            } else if (state.statusCode == '101') {
              //update fcm id
              //
              final latitude = HiveRepository.getLatitude ?? "0.0";
              final longitude = HiveRepository.getLongitude ?? "0.0";

              //
              String? fcmId;
              try {
                await FirebaseMessaging.instance.getToken().then((value) async {
                  fcmId = value;
                });
              } catch (_) {}
              await AuthenticationRepository.loginUser(
                fcmId: fcmId,
                countryCode: widget.countryCode,
                mobileNumber: widget.phoneNumberWithOutCountryCode,
                latitude: latitude.toString(),
                longitude: longitude.toString(),
              ).then((final UserDetailsModel value) {
                // HiveRepository.putAllValue(boxName: HiveRepository.authStatusBoxKey, values: {
                //   HiveRepository.isUserFirstTimeKey :false,
                //   HiveRepository.isAuthenticatedKey :true
                // });
                HiveRepository.setUserFirstTimeInApp = false;
                HiveRepository.setUserLoggedIn = true;
                // Hive.box(authStatusBoxKey)
                //   ..put(isUserFirstTime, false)..put(isAuthenticated, true);

                context.read<AuthenticationCubit>().checkStatus();
                //
                Future.delayed(Duration.zero, () {
                  try {
                    context.read<BookingCubit>().fetchBookingDetails(status: '');
                    context.read<HomeScreenCubit>().fetchHomeScreenData();
                    context.read<CartCubit>().getCartDetails(isReorderCart: false);
                    context.read<BookmarkCubit>().fetchBookmark(type: "list");

                    context.read<UserDetailsCubit>().loadUserDetails();
                  } catch (_) {}

                  if (widget.source == 'dialog') {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  } else {
                    //
                    bottomNavigationBarGlobalKey
                        .currentState?.selectedIndexOfBottomNavigationBar.value = 0;
                    //
                    try {
                      NotificationService.disposeListeners();
                    } catch (_) {}

                    LocalAwesomeNotification.init(context);

                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(navigationRoute, (Route<dynamic> route) => false);
                  }
                });
              });

              //
            } else {
              await Navigator.pushReplacementNamed(
                context,
                editProfileRoute,
                arguments: {
                  'phoneNumberWithCountryCode': widget.phoneNumberWithCountryCode,
                  'phoneNumberWithOutCountryCode': widget.phoneNumberWithOutCountryCode,
                  'countryCode': widget.countryCode,
                  'source': widget.source
                },
              );
            }
          }
          //
        },
        builder: (context, VerifyPhoneNumberFromAPIState state) {
          if (state is VerifyPhoneNumberFromAPIInProgress) {
            return CustomCircularProgressIndicator(
              color: Theme.of(context).colorScheme.accentColor,
            );
          }
          return BlocConsumer<VerifyOtpCubit, VerifyOtpState>(
            listener: (final context, verifyOtpState) {
              if (verifyOtpState is VerifyOtpSuccess) {
                countDownTimer.close();
                UiUtils.showMessage(
                  context,
                  'verified'.translate(context: context),
                  MessageType.success,
                );

                context.read<VerifyPhoneNumberFromAPICubit>().verifyPhoneNumberFromAPI(
                      mobileNumber: widget.phoneNumberWithOutCountryCode,
                      countryCode: widget.countryCode,
                    );
                //
              } else if (verifyOtpState is VerifyOtpFail) {
                Future.delayed(const Duration(seconds: 1), () {
                  context.read<VerifyOtpCubit>().setInitialState();
                });
                //
                String errorMessage = '';
                errorMessage = findFirebaseError(context, verifyOtpState.error.code);
                //
                Future.delayed(Duration.zero, () {
                  otpController.clear();
                });
                //
                UiUtils.showMessage(context, errorMessage.toString().translate(context: context),
                    MessageType.error);
              }
            },
            builder: (final context, final verifyOtpState) => ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 42, minWidth: 130),
              child: OutlinedButton(
                onPressed: _onResendOtpClick,
                style: _resendButtonStyle(),
                child: ValueListenableBuilder(
                  valueListenable: isCountDownCompleted,
                  builder: (final context, final value, final child) => isCountDownCompleted.value
                      ? CustomText(
                          'resend_otp'.translate(context: context),
                          color: Theme.of(context).colorScheme.blackColor,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                          fontSize: 18,
                          textAlign: TextAlign.center,
                        )
                      : _resendCountDownButton(),
                ),
              ),
            ),
          );
        },
      );

  Widget _resendCountDownButton() => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomText(
            'resend_otp_in'.translate(context: context),
            color: Theme.of(context).colorScheme.lightGreyColor,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.normal,
            fontSize: 18,
            textAlign: TextAlign.center,
          ),
          const CustomSizedBox(
            width: 3,
          ),
          countDownTimer.listenText(color: Theme.of(context).colorScheme.lightGreyColor)
        ],
      );

  ButtonStyle _resendButtonStyle() => ButtonStyle(
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadiusOf10)),
        ),
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        foregroundColor: MaterialStateProperty.resolveWith((final Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            return Theme.of(context).colorScheme.lightGreyColor;
          }
          return Theme.of(context).colorScheme.blackColor;
        }),
        side: MaterialStateProperty.resolveWith((final Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            return BorderSide(color: Theme.of(context).colorScheme.lightGreyColor);
          } else {
            return BorderSide(color: Theme.of(context).colorScheme.blackColor);
          }
        }),
      );

  Widget _buildOtpField(final BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: CustomSizedBox(
          width: MediaQuery.sizeOf(context).width,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Pinput(
              controller: otpController,
              keyboardType: TextInputType.number,
              closeKeyboardWhenCompleted: true,
              focusNode: otpFiledFocusNode,
              pinAnimationType: PinAnimationType.scale,
              focusedPinTheme: PinTheme(
                height: 50,
                textStyle: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.blackColor),
                decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).colorScheme.accentColor),
                    borderRadius: BorderRadius.circular(borderRadiusOf5)),
              ),
              hapticFeedbackType: HapticFeedbackType.lightImpact,
              isCursorAnimationEnabled: true,
              defaultPinTheme: PinTheme(
                height: 50,
                textStyle: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.blackColor),
                decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).colorScheme.lightGreyColor),
                    borderRadius: BorderRadius.circular(borderRadiusOf10)),
              ),
              // fieldWidth: 45,
              /*   currentCode: widget.phoneNumberWithOutCountryCode == "9876543210" ? '123456' : '',
              */
              //    fieldStyle: FieldStyle.box,

              /*     inputFormatter: [
                FilteringTextInputFormatter.allow(RegExp('[0-9]')),
              ],*/
              readOnly: context.watch<VerifyOtpCubit>().state is VerifyOtpInProcess ||
                  context.watch<VerifyPhoneNumberFromAPICubit>().state
                      is VerifyPhoneNumberFromAPIInProgress,
              onCompleted: (final otpValue) {
                if (otpValue.length == 6) {
                  context.read<VerifyOtpCubit>().verifyOtp(otpValue);
                  //otpFiledFocusNode.unfocus();
                  UiUtils.removeFocus();
                }
              },
              // focusNode: otpFiledFocusNode,
              /* otpFieldStyle: OtpFieldStyle(
                focusBorderColor: Theme.of(context).colorScheme.accentColor,
                backgroundColor: Theme.of(context).colorScheme.secondaryColor,
                borderColor: Theme.of(context).colorScheme.lightGreyColor,
                errorBorderColor: Theme.of(context).colorScheme.error,
              ),*/
              /* style: TextStyle(color: Theme.of(context).colorScheme.blackColor),
              spaceBetween: 10,
              textFieldAlignment: MainAxisAlignment.start,*/
              length: 6,
              /*    decoration: BoxLooseDecoration(
                gapSpace: 10,
                hintText: otpHintText,
                textStyle:
                hintTextStyle: TextStyle(color: Theme
                    .of(context)
                    .colorScheme
                    .lightGreyColor),
                strokeColorBuilder: PinListenColorBuilder(
                  Theme
                      .of(context)
                      .colorScheme
                      .accentColor,
                  Theme
                      .of(context)
                      .colorScheme
                      .lightGreyColor,
                ),
              ),*/
            ),
          ),
        ),
      );

  @override
  Widget build(final BuildContext context) => Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primaryColor,
        appBar: UiUtils.getSimpleAppBar(
          context: context,
          title: "",
          backgroundColor: Theme.of(context).colorScheme.primaryColor,
        ),
        body: BlocListener<VerifyPhoneNumberCubit, VerifyPhoneNumberState>(
          listener: (final BuildContext context,
              final VerifyPhoneNumberState verifyPhoneNumberstate) async {
            /* if (verifyPhoneNumberstate is PhoneNumberVerificationSuccess) {
              Hive.box(authStatusBoxKey)
                ..put(isUserFirstTime, false)
                ..put(isAuthenticated, true);

              //it will emit state
              //
              final credential = context.read<VerifyOtpCubit>().state as VerifyOtpSuccess;

              if (credential.signinCredential.additionalUserInfo!.isNewUser) {
                await Hive.box(userDetailBoxKey).deleteAll(
                  [userNameKey, phoneNumberKey, emailIdKey, profileImageKey, phoneNumberKey],
                );
                Future.delayed(Duration.zero, () {
                  Navigator.pushReplacementNamed(
                    context,
                    editProfileRoute,
                    arguments: {
                      'phoneNumberWithCountryCode': widget.phoneNumberWithCountryCode,
                      'phoneNumberWithOutCountryCode': widget.phoneNumberWithOutCountryCode,
                      'countryCode': widget.countryCode,
                      'source': widget.source
                    },
                  );
                });
              } else {
                //update fcm id
                try {
                  final String? value = await FirebaseMessaging.instance.getToken();
                  await UserRepository().updateFCM(value!);
                } catch (_) {} //
                context.read<AuthenticationCubit>().checkStatus();
                //
                if (widget.source == 'dialog') {
                  //
                  try {
                    context.read<CartCubit>().getCartDetails();
                    context.read<BookmarkCubit>().fetchBookmark(type: "list");
                  } catch (_) {}
                  //
                  Navigator.pop(context);
                  Navigator.pop(context);
                } else {
                  Future.delayed(Duration.zero, () {
                    bottomNavigationBarGlobalKey
                        .currentState?.selectedIndexOfBottomNavigationBar.value = 0;
                    Navigator.pushReplacementNamed(context, navigationRoute);
                  });
                }
              }
            }*/
          },
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 30, 20, 20),
            child: BlocConsumer<ResendOtpCubit, ResendOtpState>(
              listener: (final BuildContext c, final ResendOtpState state) {
                if (state is ResendOtpSuccess) {
                  isCountDownCompleted.value = false;
                  //
                  countDownTimer.start(_onCountdownComplete);
                  //
                  context.read<ResendOtpCubit>().setDefaultOtpState();
                }
              },
              builder: (final context, final ResendOtpState resendOtpState) => CustomSizedBox(
                width: MediaQuery.sizeOf(context).width,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeader(),
                      _buildSubHeading(),
                      _buildOtpField(context),
                      if (context.watch<VerifyOtpCubit>().state is VerifyOtpInProcess) ...[
                        _buildOTPverificationStatus(context)
                      ] else ...[
                        _responseMessages(resendOtpState),
                      ],
                      _buildResendButton(context, resendOtpState),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  Widget _buildOTPverificationStatus(final BuildContext context) => CustomSizedBox(
        height: 30,
        child: Builder(
          builder: (context) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CupertinoActivityIndicator(radius: 8),
              const CustomSizedBox(
                width: 5,
              ),
              CustomText("otpVerifying".translate(context: context))
            ],
          ),
        ),
      );
}
