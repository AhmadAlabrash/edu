import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    final Key? key,
    this.phoneNumberWithCountryCode,
    this.phoneNumberWithOutCountryCode,
    this.countryCode,
    this.source,
  }) : super(key: key);
  final String? phoneNumberWithCountryCode;
  final String? phoneNumberWithOutCountryCode;
  final String? countryCode;
  final String? source;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();

  static Route route(final RouteSettings routeSettings) => CupertinoPageRoute(
        builder: (final BuildContext context) {
          Map arguments = {};
          if (routeSettings.arguments != null) {
            arguments = routeSettings.arguments as Map;
          }

          return EditProfileScreen(
            phoneNumberWithOutCountryCode: arguments['phoneNumberWithOutCountryCode'] ?? '',
            phoneNumberWithCountryCode: arguments['phoneNumberWithCountryCode'] ?? '',
            countryCode: arguments['countryCode'] ?? '',
            source: arguments['source'] ?? '',
          );
        },
      );
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  //
  final TextEditingController usernameController =
      TextEditingController(text: HiveRepository.getUsername);

  //
  final TextEditingController phoneNumberController = TextEditingController(
    text: "${HiveRepository.getUserMobileCountryCode} ${HiveRepository.getUserMobileNumber}",
  );

  //
  final TextEditingController emailController = TextEditingController();

  UserDetailsModel? userDetails;
  File? selectedImage;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    phoneNumberController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (widget.phoneNumberWithCountryCode != '' &&
        widget.phoneNumberWithCountryCode != null &&
        widget.phoneNumberWithCountryCode != 'null') {
      phoneNumberController.text = widget.phoneNumberWithCountryCode!;

      Future.delayed(
        Duration.zero,
        () {
          userDetails = context.read<UserDetailsCubit>().getUserDetails();
        },
      );
    }

    if (HiveRepository.getUserEmailId != '' && HiveRepository.getUserEmailId != null) {
      emailController.text = HiveRepository.getUserEmailId.toString();
    }
  }

  Future<void> _getFromGallery() async {
    final XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );

    final croppedFile = await _croppedImage(pickedFile!.path);

    setState(() {
      selectedImage = File(croppedFile!.path);
    });
  }

  Future<CroppedFile?> _croppedImage(String pickedFilePath) async {
    return ImageCropper().cropImage(
      sourcePath: pickedFilePath,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
      ],
      cropStyle: CropStyle.circle,
      compressFormat: ImageCompressFormat.png,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: "cropImage".translate(context: context),
          toolbarColor: Theme.of(context).colorScheme.accentColor,
          toolbarWidgetColor: AppColors.whiteColors,
          initAspectRatio: CropAspectRatioPreset.square,
          hideBottomControls: true,
          activeControlsWidgetColor: Theme.of(context).colorScheme.primaryColor,
        ),
        IOSUiSettings(
          title: "cropImage".translate(context: context),
        ),
      ],
    );
  }

  @override
  Widget build(final BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: UiUtils.getSystemUiOverlayStyle(context: context),
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.primaryColor,
          appBar: UiUtils.getSimpleAppBar(
            context: context,
            title: 'editProfile'.translate(context: context),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: BlocConsumer<UpdateUserCubit, UpdateUserState>(
                listener: (context, UpdateUserState updateUserState) {
                  if (updateUserState is UpdateUserSuccess) {
                    final existingUserDetails =
                        (context.read<UserDetailsCubit>().state as UserDetails).userDetailsModel;

                    final newUserDetails =
                        existingUserDetails.fromMapCopyWith(updateUserState.updatedDetails.toMap());

                    context.read<UserDetailsCubit>().changeUserDetails(newUserDetails);
                  }
                },
                builder: (final context, UpdateUserState updateUserState) => Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: AlignmentDirectional.center,
                        child: Stack(
                          children: [
                            CustomInkWellContainer(
                              onTap: () {
                                _getFromGallery();
                              },
                              child: CustomContainer(
                                width: 100,
                                height: 100,
                                borderRadius: borderRadiusOf50,
                                border: Border.all(color: Theme.of(context).colorScheme.blackColor),
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: ClipRRect(
                                    //
                                    borderRadius: BorderRadius.circular(borderRadiusOf50),
                                    //
                                    child: selectedImage != null
                                        ? Image.file(
                                            File(selectedImage?.path ?? ""),
                                          )
                                        : (HiveRepository.getUserProfilePictureURL == null ||
                                                HiveRepository.getUserProfilePictureURL == '')
                                            ? CustomSvgPicture(
                                                svgImage: "dr_profile",
                                                color: Theme.of(context).colorScheme.blackColor,
                                              )
                                            : CustomCachedNetworkImage(
                                                height: 100,
                                                width: 100,
                                                networkImageUrl:
                                                    HiveRepository.getUserProfilePictureURL ?? '',
                                              ),
                                  ),
                                ),
                              ),
                            ),
                            PositionedDirectional(
                              end: 0,
                              bottom: 5,
                              child: CustomContainer(
                                height: 25,
                                width: 25,
                                color: Theme.of(context).colorScheme.secondaryColor,
                                borderRadius: borderRadiusOf5,
                                padding: const EdgeInsets.all(3),
                                child: Icon(
                                  Icons.camera_alt_outlined,
                                  color: Theme.of(context).colorScheme.accentColor,
                                  size: 20,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      const CustomSizedBox(
                        height: 15,
                      ),
                      const CustomDivider(
                        thickness: 0.4,
                      ),
                      const CustomSizedBox(
                        height: 15,
                      ),
                      CustomTextFormField(
                        labelText: "username".translate(context: context),
                        hintText: "enterUsername".translate(context: context),
                        controller: usernameController,
                        textInputType: TextInputType.name,
                        validator: (username) =>
                            isTextFieldEmpty(context: context, value: username),
                      ),
                      const CustomSizedBox(
                        height: 20,
                      ),
                      CustomTextFormField(
                        labelText: "phoneNumber".translate(context: context),
                        hintText: "enterPhoneNumber".translate(context: context),
                        controller: phoneNumberController,
                        isReadOnly: true,
                        textInputType: TextInputType.number,
                        validator: (p0) {
                          return null;
                        },
                      ),
                      const CustomSizedBox(
                        height: 20,
                      ),
                      CustomTextFormField(
                        labelText: "email".translate(context: context),
                        hintText: "enterYourEmailAddress".translate(context: context),
                        controller: emailController,
                        textInputType: TextInputType.emailAddress,
                        validator: (email) => isValidEmail(email: email ?? "", context: context),
                      ),
                      const CustomSizedBox(
                        height: 50,
                      ),
                      BlocConsumer<UpdateUserCubit, UpdateUserState>(
                        listener: (final context, final state) {
                          if (state is UpdateUserSuccess) {
                            UiUtils.showMessage(
                              context,
                              "profileUpdateSuccess".translate(context: context),
                              MessageType.success,
                            );

                            if (Routes.previousRoute != otpVerificationRoute) {
                              //user is editing their profile details
                              Navigator.pop(context);
                            }
                          } else if (state is UpdateUserFail) {
                            UiUtils.showMessage(
                              context,
                              state.error.translate(context: context),
                              MessageType.error,
                            );
                          }
                        },
                        builder: (final BuildContext context, UpdateUserState state) {
                          Widget? child;
                          if (state is UpdateUserInProgress) {
                            child = CustomCircularProgressIndicator(color: AppColors.whiteColors);
                          } else if (state is UpdateUserSuccess || state is UpdateUserFail) {
                            child = null;
                          }
                          return CustomSizedBox(
                            width: MediaQuery.sizeOf(context).width,
                            height: 48,
                            child: CustomRoundedButton(
                              onTap: () async {
                                if (!formKey.currentState!.validate()) {
                                  return;
                                }

                                UiUtils.removeFocus();
                                if (state is UpdateUserInProgress) {
                                  return;
                                }

                                //if user is registering their profile first time
                                if (Routes.previousRoute == otpVerificationRoute) {
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
                                    countryCode: widget.countryCode!,
                                    mobileNumber: widget.phoneNumberWithOutCountryCode!,
                                    latitude: latitude.toString(),
                                    longitude: longitude.toString(),
                                  ).then(
                                    (final UserDetailsModel value) async {
                                      //
                                      context.read<UserDetailsCubit>().setUserDetails(value);
                                      //
                                      final UpdateUserDetails updateUserDetails = UpdateUserDetails(
                                        email: emailController.value.text,
                                        phone: HiveRepository.getUserMobileNumber,
                                        countryCode: HiveRepository.getUserMobileCountryCode,
                                        username: usernameController.value.text,
                                        image: selectedImage ?? "",
                                      );
                                      //
                                      await context
                                          .read<UpdateUserCubit>()
                                          .updateUserDetails(updateUserDetails);

                                      //update user authenticated status
                                      HiveRepository.setUserFirstTimeInApp = false;
                                      HiveRepository.setUserLoggedIn = true;
                                      // HiveRepository.putAllValue(
                                      //     boxName: HiveRepository.authStatusBoxKey,
                                      //     values: {
                                      //       HiveRepository.isUserFirstTimeKey: false,
                                      //       HiveRepository.isAuthenticatedKey: true
                                      //     });

                                      if (mounted) {
                                        context.read<AuthenticationCubit>().checkStatus();
                                      }
                                      //update fcm id
                                      /*try {
                                        await FirebaseMessaging.instance
                                            .getToken()
                                            .then((value) async {
                                          await UserRepository().updateFCM(
                                            fcmId: value ?? "",
                                            platform: Platform.isAndroid ? "android" : "ios",
                                          );
                                        });
                                      } catch (_) {}*/
                                      //
                                      Future.delayed(
                                        Duration.zero,
                                        () {
                                          if (widget.source == "dialog") {
                                            try {
                                              context
                                                  .read<CartCubit>()
                                                  .getCartDetails(isReorderCart: false);
                                              context
                                                  .read<BookmarkCubit>()
                                                  .fetchBookmark(type: 'list');
                                              context.read<UserDetailsCubit>().loadUserDetails();
                                            } catch (_) {}
                                            //
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                          } else {
                                            bottomNavigationBarGlobalKey.currentState
                                                ?.selectedIndexOfBottomNavigationBar.value = 0;
                                            Navigator.pop(context);

                                            Navigator.pushReplacementNamed(
                                                context, navigationRoute);
                                          }
                                        },
                                      );
                                    },
                                  );
                                } else {
                                  //if user is editing their profile then directly update their data
                                  final UpdateUserDetails updateUserDetails = UpdateUserDetails(
                                    email: emailController.value.text,
                                    phone: HiveRepository.getUserMobileNumber,
                                    countryCode: HiveRepository.getUserMobileCountryCode,
                                    username: usernameController.value.text,
                                    image: selectedImage ?? "",
                                  );
                                  //  UserRepository().updateUserDetails(updateUserDetails);

                                  context
                                      .read<UpdateUserCubit>()
                                      .updateUserDetails(updateUserDetails);
                                }
                              },
                              buttonTitle: "saveChanges".translate(context: context),
                              backgroundColor: Theme.of(context).colorScheme.accentColor,
                              showBorder: false,
                              widthPercentage: 0.9,
                              child: child,
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
