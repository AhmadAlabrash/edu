import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/cubits/sendQueryToAdminCubit.dart';
import 'package:e_demand/data/model/chat/chatUser.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  static Route<AppSettingsScreen> route(final RouteSettings routeSettings) => CupertinoPageRoute(
        builder: (final _) => BlocProvider(
          create: (context) => SendQueryToAdminCubit(),
          child: ContactUsScreen(),
        ),
      );

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  late Map<String, dynamic> contactUsDetails =
      context.read<SystemSettingCubit>().getContactUsDetails();
  late List<SocialMediaURL> socialMediaLinks =
      context.read<SystemSettingCubit>().getSocialMediaLinks() ?? [];

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _nameTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _subjectTextController = TextEditingController();
  TextEditingController _messageTextController = TextEditingController();

  FocusNode _emailFocusNode = FocusNode();
  FocusNode _subjectFocusNode = FocusNode();
  FocusNode _messageFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UiUtils.getSimpleAppBar(
        context: context,
        title: "contactUs".translate(context: context),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 10),
              child: CustomText(
                "getInTouchWithUs".translate(context: context),
                color: Theme.of(context).colorScheme.blackColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(
              height: 10,
            ),

            if (contactUsDetails.isNotEmpty) ...[
              if (contactUsDetails["email"] != "") ...[
                SizedBox(
                  height: 10,
                ),
                _buildContactInfoWidget(
                  context,
                  iconName: Icons.email_outlined,
                  subTitle: contactUsDetails["email"],
                  title: "email",
                  onTap: () async {
                    try {
                      if (await canLaunchUrl(Uri.parse("mailto:${contactUsDetails["email"]}"))) {
                        launchUrl(
                          Uri.parse("mailto:${contactUsDetails["email"]}"),
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        throw Exception();
                      }
                    } catch (e) {
                      print("error");
                      print(e.toString());
                      UiUtils.showMessage(
                          context, "unableToOpen".translate(context: context), MessageType.error);
                    }
                  },
                ),
              ],
              if (contactUsDetails["mobile"] != "") ...[
                SizedBox(
                  height: 10,
                ),
                _buildContactInfoWidget(
                  context,
                  iconName: Icons.phone_outlined,
                  subTitle: contactUsDetails["mobile"],
                  title: "phone",
                  onTap: () async {
                    try {
                      if (await canLaunchUrl(Uri.parse("tel:${contactUsDetails["mobile"]}"))) {
                        launchUrl(
                          Uri.parse("tel:${contactUsDetails["mobile"]}"),
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        throw Exception();
                      }
                    } catch (e) {
                      UiUtils.showMessage(
                          context, "unableToOpen".translate(context: context), MessageType.error);
                    }
                  },
                ),
              ],
              if (contactUsDetails["address"] != "") ...[
                SizedBox(
                  height: 10,
                ),
                _buildContactInfoWidget(context,
                    iconName: Icons.location_on_outlined,
                    subTitle: contactUsDetails["address"],
                    title: "address",
                    onTap: () {}),
              ],
              if (contactUsDetails["supportHours"] != "") ...[
                SizedBox(
                  height: 10,
                ),
                _buildContactInfoWidget(context,
                    iconName: Icons.access_time,
                    subTitle: contactUsDetails["supportHours"],
                    title: "supportHours",
                    onTap: () {}),
              ],
            ],
            _buildContactInfoWidget(context,
                iconName: Icons.support_agent_outlined,
                subTitle: "chatWithUsDescription".translate(context: context),
                title: "chatWithUs", onTap: () {
                  Navigator.pushNamed(context, chatMessages, arguments: {
                    "chatUser": ChatUser(
                      id:  "-",
                      name: "customerSupport",
                      receiverType: "0",
                      unReadChats: 0,
                      bookingId: "0",
                      senderId: context.read<UserDetailsCubit>().getUserDetails().id ?? "0",

                    ),
                  });
                }),
            if (socialMediaLinks.isNotEmpty) ...[
              SizedBox(
                height: 10,
              ),
              _buildSocialMediaLinkWidget(),
            ],
            SizedBox(
              height: 10,
            ),
            Card(
              color: Theme.of(context).colorScheme.secondaryColor,
              elevation: 0.5,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLetsTalkTitleWidget(),
                      SizedBox(
                        height: 10,
                      ),
                      _buildLetsTalkSubTitleWidget(),
                      SizedBox(
                        height: 10,
                      ),
                      _buildNameTextFieldWidget(),
                      _buildEmailTextFieldWidget(),
                      _buildSubjectTextFieldWidget(),
                      _buildMessageTextFieldWidget(),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            _buildFAQsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoWidget(BuildContext context,
      {required IconData iconName,
      VoidCallback? onTap,
      required String title,
      required String subTitle}) {
    return CustomInkWellContainer(
      onTap: () => onTap?.call(),
      child: Card(
        color: Theme.of(context).colorScheme.secondaryColor,
        elevation: 0.5,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                iconName,
                size: 30,
                color: Theme.of(context).colorScheme.accentColor,
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    title.translate(context: context),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.lightGreyColor,
                  ),
                  CustomText(
                    subTitle,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.blackColor,
                  ),
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }

  _buildSocialMediaLinkWidget() {
    return Card(
      color: Theme.of(context).colorScheme.secondaryColor,
      elevation: 0.5,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              "ourSocials".translate(context: context),
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.blackColor,
            ),
            Container(
              width: MediaQuery.sizeOf(context).width,
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.start,
                children: List.generate(
                    socialMediaLinks.length,
                    (index) => CustomInkWellContainer(
                          onTap: () async {
                            try {
                              if (await canLaunchUrl(
                                  Uri.parse(socialMediaLinks[index].url ?? ""))) {
                                launchUrl(
                                  Uri.parse(socialMediaLinks[index].url ?? ""),
                                  mode: LaunchMode.externalApplication,
                                );
                              } else {
                                throw Exception();
                              }
                            } catch (e) {
                              UiUtils.showMessage(context,
                                  "unableToOpen".translate(context: context), MessageType.error);
                            }
                          },
                          child: CustomContainer(
                            height: 50,
                            width: 50,
                            padding: EdgeInsets.all(5),
                            child: CustomCachedNetworkImage(
                              networkImageUrl: socialMediaLinks[index].imageURL ?? "",
                              width: 45,
                              height: 45,
                              fit: BoxFit.fill,
                            ),
                          ),
                        )),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFAQsSection() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 10),
      child: Text.rich(
        TextSpan(
            text: "${"youMightAlsoFindYourAnswersOn".translate(context: context)} ",
            style: TextStyle(
              color: Theme.of(context).colorScheme.blackColor,
              fontSize: 12,
            ),
            children: [
              TextSpan(
                text: "${"faqs".translate(context: context)}",
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.pushNamed(context, faqsRoute);
                  },
                style: TextStyle(
                    color: Theme.of(context).colorScheme.accentColor,
                    fontSize: 12,
                    decoration: TextDecoration.underline,
                    decorationColor: Theme.of(context).colorScheme.accentColor),
              ),
              TextSpan(
                  text:
                      " ${"ifYouHaventCheckedItAlreadyBeforeContactingUs".translate(context: context)}",
                  style: TextStyle(color: Theme.of(context).colorScheme.blackColor, fontSize: 12)),
            ]),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildLetsTalkTitleWidget() {
    return CustomText(
      "letsTalk".translate(context: context),
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.accentColor,
      fontSize: 22,
    );
  }

  Widget _buildLetsTalkSubTitleWidget() {
    return CustomText(
      "weLoveYourFeedbackSuggestionAndReviewOnHowToServeYou".translate(context: context),
      color: Theme.of(context).colorScheme.blackColor,
      fontSize: 14,
    );
  }

  Widget _buildNameTextFieldWidget() {
    return CustomTextFormField(
      controller: _nameTextController,
      labelText: "name".translate(context: context),
      hintText: "name".translate(context: context),
      nextFocus: _emailFocusNode,
      validator: (name) => isTextFieldEmpty(value: name, context: context),
    );
  }

  Widget _buildEmailTextFieldWidget() {
    return CustomTextFormField(
      controller: _emailTextController,
      labelText: "email".translate(context: context),
      hintText: "email".translate(context: context),
      currNode: _emailFocusNode,
      validator: (email) => isValidEmail(email: email ?? "", context: context),
      nextFocus: _subjectFocusNode,
    );
  }

  Widget _buildSubjectTextFieldWidget() {
    return CustomTextFormField(
      controller: _subjectTextController,
      labelText: "subject".translate(context: context),
      hintText: "subject".translate(context: context),
      currNode: _subjectFocusNode,
      validator: (subject) => isTextFieldEmpty(value: subject, context: context),
      nextFocus: _messageFocusNode,
    );
  }

  Widget _buildMessageTextFieldWidget() {
    return CustomTextFormField(
      controller: _messageTextController,
      labelText: "message".translate(context: context),
      hintText: "message".translate(context: context),
      expands: true,
      textInputType: TextInputType.multiline,
      currNode: _messageFocusNode,
      minLines: 2,
      validator: (message) => isTextFieldEmpty(value: message, context: context),
      textInputAction: TextInputAction.done,
    );
  }

  @override
  void dispose() {
    _nameTextController.dispose();
    _emailTextController.dispose();
    _messageTextController.dispose();
    _subjectTextController.dispose();

    _emailFocusNode.dispose();
    _subjectFocusNode.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  Widget _buildSubmitButton() {
    return BlocConsumer<SendQueryToAdminCubit, SendQueryToAdminState>(
      listener: (context, state) {
        UiUtils.removeFocus();
        if (state is SendQueryToAdminFailureState) {
          UiUtils.showMessage(
              context,
              "weCouldntSendYourRequestPleaseTryAgainLater".translate(context: context),
              MessageType.error);
        } else if (state is SendQueryToAdminSuccessState) {
          _nameTextController.clear();
          _emailTextController.clear();
          _subjectTextController.clear();
          _messageTextController.clear();
          UiUtils.showMessage(
              context,
              "yourRequestHasBeenSuccessfullySent".translate(context: context),
              MessageType.success);
        }
      },
      builder: (context, state) {
        bool isLoading = state is SendQueryToAdminInProgressState;
        return CustomRoundedButton(
          buttonTitle: "submit".translate(context: context),
          showBorder: false,
          widthPercentage: 1,
          backgroundColor: Theme.of(context).colorScheme.accentColor,
          child: isLoading
              ? CustomCircularProgressIndicator(
                  color: AppColors.whiteColors,
                )
              : null,
          onTap: () {
            if (state is SendQueryToAdminInProgressState) {
              return;
            }
            if (_formKey.currentState!.validate()) {
              context.read<SendQueryToAdminCubit>().sendQueryToAdmin(
                  name: _nameTextController.text.trim().toString(),
                  email: _emailTextController.text.trim().toString(),
                  subject: _subjectTextController.text.trim().toString(),
                  message: _messageTextController.text.trim().toString());
            }
          },
        );
      },
    );
  }
}

enum contactUsType { EMAIL, PHONE, ADDRESS, WORKING_HOURS }
