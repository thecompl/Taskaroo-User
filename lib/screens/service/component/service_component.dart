import 'package:booking_system_flutter/component/cached_image_widget.dart';
import 'package:booking_system_flutter/component/disabled_rating_bar_widget.dart';
import 'package:booking_system_flutter/component/image_border_component.dart';
import 'package:booking_system_flutter/component/price_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/service_data_model.dart';
import 'package:booking_system_flutter/screens/booking/provider_info_screen.dart';
import 'package:booking_system_flutter/screens/service/service_detail_screen.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../model/category_model.dart';

class ServiceComponent extends StatefulWidget {
  final ServiceData? serviceData;
  final double? width;
  final bool? isBorderEnabled;
  final VoidCallback? onUpdate;
  final List<CategoryData>? categoryList;
  final bool isFavouriteService;

  ServiceComponent(
      {this.serviceData,
      this.width,
      this.isBorderEnabled,
      this.isFavouriteService = false,
      this.onUpdate,
      this.categoryList});

  @override
  ServiceComponentState createState() => ServiceComponentState();
}

class ServiceComponentState extends State<ServiceComponent> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 3,
        ),
        child: GestureDetector(
          onTap: () {
            hideKeyboard(context);
            ServiceDetailScreen(
                    serviceId: widget.isFavouriteService
                        ? widget.serviceData!.serviceId.validate().toInt()
                        : widget.serviceData!.id.validate())
                .launch(context);
          },
          child: Container(
            decoration: boxDecorationWithRoundedCorners(
              borderRadius: radius(),
              backgroundColor: context.cardColor,
              border: widget.isBorderEnabled.validate(value: false)
                  ? appStore.isDarkMode
                      ? Border.all(color: context.dividerColor)
                      : null
                  : null,
            ),
            width: widget.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 180,
                  width: context.width(),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CachedImageWidget(
                        url: widget.isFavouriteService
                            ? widget.serviceData!.serviceAttachments
                                    .validate()
                                    .isNotEmpty
                                ? widget.serviceData!.serviceAttachments!.first
                                    .validate()
                                : ''
                            : widget.serviceData!.attachments
                                    .validate()
                                    .isNotEmpty
                                ? widget.serviceData!.attachments!.first
                                    .validate()
                                : '',
                        fit: BoxFit.cover,
                        height: 150,
                        width: context.width(),
                        circle: false,

                        ///TODO Check
                      ).cornerRadiusWithClipRRectOnly(
                          topRight: defaultRadius.toInt(),
                          topLeft: defaultRadius.toInt()),
                      // Positioned(
                      //   top: 12,
                      //   left: 12,
                      //   child: Container(
                      //     padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                      //     constraints:
                      //         BoxConstraints(maxWidth: context.width() * 0.3),
                      //     decoration: boxDecorationWithShadow(
                      //       backgroundColor: context.cardColor.withOpacity(0.9),
                      //       borderRadius: radius(24),
                      //     ),
                      //     child: Marquee(
                      //       directionMarguee: DirectionMarguee.oneDirection,
                      //       child: Text(
                      //         "${widget.serviceData!.subCategoryName.validate().isNotEmpty ? widget.serviceData!.subCategoryName.validate() : widget.serviceData!.categoryName.validate()}"
                      //             .toUpperCase(),
                      //         style: boldTextStyle(
                      //             color: appStore.isDarkMode ? white : primaryColor,
                      //             size: 12),
                      //       ).paddingSymmetric(horizontal: 8, vertical: 4),
                      //     ),
                      //   ),
                      // ),
                      if (widget.isFavouriteService)
                        Positioned(
                          top: 8,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            margin: EdgeInsets.only(right: 8),
                            decoration: boxDecorationWithShadow(
                                boxShape: BoxShape.circle,
                                backgroundColor: context.cardColor),
                            child: widget.serviceData!.isFavourite == 0
                                ? ic_fill_heart.iconImage(
                                    color: favouriteColor, size: 18)
                                : ic_heart.iconImage(
                                    color: unFavouriteColor, size: 18),
                          ).onTap(() async {
                            if (widget.serviceData!.isFavourite == 0) {
                              widget.serviceData!.isFavourite = 1;
                              setState(() {});

                              await removeToWishList(
                                      serviceId: widget.serviceData!.serviceId
                                          .validate()
                                          .toInt())
                                  .then((value) {
                                if (!value) {
                                  widget.serviceData!.isFavourite = 0;
                                  setState(() {});
                                }
                              });
                            } else {
                              widget.serviceData!.isFavourite = 0;
                              setState(() {});

                              await addToWishList(
                                      serviceId: widget.serviceData!.serviceId
                                          .validate()
                                          .toInt())
                                  .then((value) {
                                if (!value) {
                                  widget.serviceData!.isFavourite = 1;
                                  setState(() {});
                                }
                              });
                            }
                            widget.onUpdate?.call();
                          }),
                        ),
                      Positioned(
                        bottom: 15,
                        right: 8,
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: boxDecorationWithShadow(
                            backgroundColor: primaryColor,
                            borderRadius: radius(24),
                            border:
                                Border.all(color: context.cardColor, width: 2),
                          ),
                          child: PriceWidget(
                            price: widget.serviceData!.price.validate(),
                            isHourlyService:
                                widget.serviceData!.isHourlyService,
                            color: Colors.white,
                            hourlyTextColor: Colors.white,
                            size: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Marquee(
                      directionMarguee: DirectionMarguee.oneDirection,
                      child: Text(widget.serviceData!.name.validate(),
                              style: boldTextStyle())
                          .paddingSymmetric(horizontal: 16),
                    ),
                    3.height,
                    Row(
                      children: [
                        DisabledRatingBarWidget(
                            rating: widget.serviceData!.totalRating.validate(),
                            size: 14),
                        4.width,
                        Text(
                            "${widget.serviceData!.totalRating.validate().toStringAsFixed(1)}",
                            style: boldTextStyle()),
                        4.width,
                        Text(
                          "(${widget.serviceData!.totalReview.validate()})",
                        ),
                      ],
                    ).paddingSymmetric(horizontal: 10),
                    3.height,
                    Row(
                      children: [
                        ImageBorder(
                            src: widget.serviceData!.providerImage.validate(),
                            height: 30),
                        8.width,
                        if (widget.serviceData!.providerName
                            .validate()
                            .isNotEmpty)
                          Text(
                            widget.serviceData!.providerName.validate(),
                            style: secondaryTextStyle(size: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ).expand(),
                      ],
                    ).onTap(() {
                      ProviderInfoScreen(
                              providerId:
                                  widget.serviceData!.providerId.validate())
                          .launch(context);
                    }).paddingSymmetric(horizontal: 16),
                    16.height,
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
