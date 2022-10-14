import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/dashboard_model.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/dashboard/component/category_component.dart';
import 'package:booking_system_flutter/screens/dashboard/component/customer_ratings_component.dart';
import 'package:booking_system_flutter/screens/dashboard/component/featured_service_list_component.dart';
import 'package:booking_system_flutter/screens/dashboard/component/service_list_component.dart';
import 'package:booking_system_flutter/screens/dashboard/component/slider_and_location_component.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/app_common_dialog.dart';
import '../../../component/location_service_dialog.dart';
import '../../../services/location_service.dart';
import '../../../utils/colors.dart';
import '../../../utils/common.dart';
import '../../../utils/images.dart';
import '../../../utils/permissions.dart';
import '../../notification/notification_screen.dart';
import '../../service/search_list_screen.dart';

class DashboardFragment extends StatefulWidget {
  final int? notificationReadCount;

  DashboardFragment({
    this.notificationReadCount,
  });
  @override
  _DashboardFragmentState createState() => _DashboardFragmentState();
}

class _DashboardFragmentState extends State<DashboardFragment> {
  Future<DashboardResponse>? future;

  @override
  void initState() {
    init();
    location();
    super.initState();
    setStatusBarColor(transparentColor, delayInMilliSeconds: 1000);
    LiveStream().on(LIVESTREAM_UPDATE_DASHBOARD, (p0) {
      setState(() {});
    });
  }

  void init() async {
    future = userDashboard(
        isCurrentLocation: appStore.isCurrentLocation,
        lat: getDoubleAsync(LATITUDE),
        long: getDoubleAsync(LONGITUDE));
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
    LiveStream().dispose(LIVESTREAM_UPDATE_DASHBOARD);
  }

  Decoration get commonDecoration {
    return boxDecorationDefault(
      color: context.cardColor,
      boxShadow: defaultBoxShadow(blurRadius: 0, spreadRadius: 0),
      border: Border.all(color: context.dividerColor),
      borderRadius: radius(),
    );
  }

  void location() async {
    Permissions.cameraFilesAndLocationPermissionsGranted().then((value) async {
      await setValue(PERMISSION_STATUS, value);
      appStore.setLoading(true);
      await setValue(PERMISSION_STATUS, value);
      log("loc==>" + appStore.isCurrentLocation.toString());
      await getUserLocation().then((value) async {
        await appStore.setCurrentLocation(true);
        appStore.setLoading(false);
        // init();
      }).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString(), print: true);
      });
    }).catchError((e) {
      toast(e.toString(), print: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: appStore.isDarkMode ? context.cardColor : primaryColor,
      child: SafeArea(
        child: Scaffold(
          body: RefreshIndicator(
            onRefresh: () async {
              init();
              location();
              setState(() {});
              return await 2.seconds.delay;
            },
            child: Stack(
              children: [
                FutureBuilder<DashboardResponse>(
                  future: future,
                  builder: (context, snap) {
                    if (snap.hasData) {
                      return AnimatedScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        listAnimationType: ListAnimationType.FadeIn,
                        children: [
                          // Container(
                          //   height: 20,
                          //   color: Colors.white,
                          // ),
                          Container(
                            height: 120,
                            color: appStore.isDarkMode
                                ? context.cardColor
                                : Colors.white,
                            child: Column(children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                // decoration: commonDecoration,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    commonLocationWidget(
                                      context: context,
                                      color: appStore.isCurrentLocation
                                          ? primaryColor
                                          : Colors.black,
                                      onTap: () {
                                        location();
                                      },
                                    ),
                                    8.width,
                                    Text(
                                      appStore.isCurrentLocation
                                          ? getStringAsync(CURRENT_ADDRESS)
                                          : language.lblLocationOff,
                                      style: secondaryTextStyle(
                                        size: 12
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ).expand(),
                                    if (appStore.isLoggedIn)
                                      Container(
                                        decoration: boxDecorationDefault(
                                            color: context.cardColor,
                                            shape: BoxShape.circle),
                                        height: 36,
                                        padding: EdgeInsets.all(8),
                                        width: 36,
                                        child: Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            ic_notification
                                                .iconImage(
                                                    size: 24,
                                                    color: primaryColor)
                                                .center(),
                                            Positioned(
                                              top: -20,
                                              right: -10,
                                              child: widget
                                                          .notificationReadCount
                                                          .validate() >
                                                      0
                                                  ? Container(
                                                      padding:
                                                          EdgeInsets.all(4),
                                                      child: FittedBox(
                                                        child: Text(
                                                            widget
                                                                .notificationReadCount
                                                                .toString(),
                                                            style:
                                                                primaryTextStyle(
                                                                    size: 12,
                                                                    color: Colors
                                                                        .white)),
                                                      ),
                                                      decoration:
                                                          boxDecorationDefault(
                                                              color: Colors.red,
                                                              shape: BoxShape
                                                                  .circle),
                                                    )
                                                  : Offstage(),
                                            )
                                          ],
                                        ),
                                      ).onTap(() {
                                        NotificationScreen().launch(context);
                                      })
                                  ],
                                ),
                              ).expand(),
                              Container(
                                color: appStore.isDarkMode
                                    ? context.cardColor
                                    : Colors.white,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      right: 10, left: 10, bottom: 10),
                                  child: GestureDetector(
                                      onTap: () {
                                        SearchListScreen(isFromSearch: true)
                                            .launch(context);
                                      },
                                      child: Container(
                                        height: 50,
                                        padding: EdgeInsets.all(10),
                                        decoration: commonDecoration,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Search for All Services",
                                              style: secondaryTextStyle(),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ).expand(),
                                            8.width,
                                            ic_search.iconImage(
                                                color: primaryColor),
                                          ],
                                        ),
                                      )
                                      // .expand(),
                                      //  Container(
                                      //   padding: EdgeInsets.all(16),
                                      //   decoration: commonDecoration,
                                      //   child: ic_search.iconImage(color: primaryColor),
                                      // ),
                                      ),
                                ),
                              ),
                            ]),
                          ),
                          SliderLocationComponent(
                            sliderList: snap.data!.slider.validate(),
                            notificationReadCount:
                                snap.data!.notificationUnreadCount.validate(),
                            // callback: () async {
                            //   init();
                            //   await 300.milliseconds.delay;
                            //   setState(() {});
                            // },
                          ),
                          10.height,
                          CategoryComponent(
                              categoryList: snap.data!.category.validate()),
                          24.height,
                          FeaturedServiceListComponent(
                              serviceList:
                                  snap.data!.featuredServices.validate(),
                              category: snap.data!.category.validate()),
                          // ServiceListComponent(
                          //     serviceList: snap.data!.service.validate()),
                          // 16.height,
                          CustomerRatingsComponent(
                              reviewData: snap.data!.dashboardCustomerReview
                                  .validate()),
                        ],
                      );
                    }
                    return snapWidgetHelper(snap, loadingWidget: Offstage());
                  },
                ),
                Observer(
                    builder: (context) =>
                        LoaderWidget().visible(appStore.isLoading)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
