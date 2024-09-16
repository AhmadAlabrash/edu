import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/cubits/cart/removeCartCubit.dart';
import 'package:e_demand/utils/conetxtExtensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shader_snap/flutter_shader_snap.dart';

class CartSubDetailsContainer extends StatefulWidget {
  const CartSubDetailsContainer({final Key? key, this.providerID}) : super(key: key);
  final String? providerID;

  @override
  State<CartSubDetailsContainer> createState() => _CartSubDetailsContainerState();
}

class _CartSubDetailsContainerState extends State<CartSubDetailsContainer>
    with SingleTickerProviderStateMixin {
  //
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  );

  @override
  void initState() {
    super.initState();

    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        context.read<CartCubit>().clearCartCubit();
        _controller.reset();
      }
/*      if (status != AnimationStatus.completed || _controller.value == 0)
        _controller.animateBack(0, duration: const Duration(seconds: 1));*/
    });
  }

  @override
  Widget build(final BuildContext context) => SnapShader(
        snapShaderType: SnapShaderType.smoke,
        controller: _controller,
        child: BlocBuilder<CartCubit, CartState>(
          builder: (BuildContext context, final CartState state) {
            if (state is CartInitial) {
              return const CustomSizedBox();
            } else if (state is CartFetchSuccess) {
              if (state.cartData.cartDetails == null) {
                return const CustomSizedBox();
              }

              return state.cartData.cartDetails!.isEmpty
                  ? const CustomSizedBox()
                  : CustomInkWellContainer(
                      onTap: () {
                        if (Routes.currentRoute != providerRoute ||
                            state.cartData.providerId != widget.providerID) {
                          Navigator.pushNamed(
                            context,
                            providerRoute,
                            arguments: {"providerId": state.cartData.providerId},
                          ).then(
                            (Object? value) {
                              //we are changing the route name
                              // to use CartSubDetailsContainer widget to navigate to provider details screen
                              Routes.previousRoute = Routes.currentRoute;
                              Routes.currentRoute = navigationRoute;
                            },
                          );
                        }
                      },
                      child: CustomContainer(
                        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        padding: const EdgeInsets.fromLTRB(10, 5, 5, 5),
                        color: Theme.of(context).colorScheme.accentColor,
                        borderRadius: borderRadiusOf10,
                        height: kBottomNavigationBarHeight,
                        width: MediaQuery.sizeOf(context).width * 0.95,
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      CustomText(
                                        "${state.cartData.subTotal!.priceFormat()} | ${state.cartData.totalQuantity} ${(int.parse(state.cartData.totalQuantity ?? "0") > 1 ? "services" : "service").translate(context: context)} ",
                                        color: AppColors.whiteColors,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      CustomText(
                                        "view".translate(context: context),
                                        color: AppColors.whiteColors,
                                        showUnderline: true,
                                        underlineOrLineColor: AppColors.whiteColors,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ],
                                  ),
                                  CustomText(
                                    "${"from".translate(context: context)} ${state.cartData.companyName}",
                                    fontSize: 12,
                                    color: AppColors.whiteColors,
                                  ),
                                ],
                              ),
                            ),
                            MaterialButton(
                              onPressed: () {
                                context
                                    .read<GetPromocodeCubit>()
                                    .getPromocodes(providerId: state.cartData.providerId ?? "0");
                                //

                                Navigator.pushNamed(
                                  context,
                                  scheduleScreenRoute,
                                  arguments: {
                                    "isFrom": "cart",
                                    "providerName": state.cartData.providerName ?? "",
                                    "providerId": state.cartData.providerId ?? "0",
                                    "companyName": state.cartData.companyName ?? "",
                                    "providerAdvanceBookingDays": state.cartData.advanceBookingDays,
                                  },
                                );
                              },
                              height: double.maxFinite,
                              child: CustomText(
                                'continueText'.translate(context: context),
                                color: AppColors.whiteColors,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            BlocProvider(
                              create: (context) => RemoveCartCubit(),
                              child: BlocConsumer<RemoveCartCubit, RemoveCartState>(
                                listener: (context, removeCartState) {

                                  if (removeCartState is RemoveCartSuccess) {
                                    _controller.forward();
                                  }
                                },
                                builder: (context, removeCartState) {
                                  bool isLoading = removeCartState is RemoveCartInProgress;

                                  return CustomInkWellContainer(
                                    onTap: () {
                                      context
                                          .read<RemoveCartCubit>()
                                          .removeCart(providerId: state.cartData.providerId ?? "0");
                                    },
                                    borderRadius: BorderRadius.circular(borderRadiusOf50),
                                    child: CustomContainer(
                                        margin: EdgeInsetsDirectional.only(end: 5),
                                        height: 28,
                                        width: 28,
                                        borderRadius: borderRadiusOf50,
                                        color: AppColors.whiteColors,
                                        child: isLoading
                                            ? Center(
                                                child: CustomCircularProgressIndicator(
                                                  widthAndHeight: 20,
                                                ),
                                              )
                                            : CustomToolTip(
                                                toolTipMessage: "deleteCart",
                                                child: Icon(
                                                  Icons.delete_outline,
                                                  color: context.colorScheme.accentColor,
                                                ),
                                              )),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
            }
            return const CustomSizedBox();
          },
        ),
      );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
