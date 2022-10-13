import 'dart:convert';

import 'package:booking_system_flutter/component/view_all_label_component.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/category_model.dart';
import 'package:booking_system_flutter/model/service_data_model.dart';
import 'package:booking_system_flutter/screens/service/component/service_component.dart';
import 'package:booking_system_flutter/screens/service/search_list_screen.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class FeaturedServiceListComponent extends StatelessWidget {
  final List<ServiceData> serviceList;
  final List<CategoryData>? category;

  FeaturedServiceListComponent({required this.serviceList, this.category});

  @override
  Widget build(BuildContext context) {
    if (serviceList.isEmpty) return Offstage();
    return Container(
      padding: EdgeInsets.only(bottom: 16),
      width: context.width(),
      decoration: BoxDecoration(
        color: appStore.isDarkMode
            ? context.cardColor
            : context.primaryColor.withOpacity(0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          16.height,
          // ViewAllLabel(
          //   label: language.lblFeatured,
          //   list: serviceList,
          //   onTap: () {
          //     SearchListScreen(isFeatured: "1").launch(context);
          //   },
          // ).paddingSymmetric(horizontal: 16),
          if (serviceList.isNotEmpty)
            ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: category?.length,
                itemBuilder: (BuildContext context, int indexs) => (Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: serviceList.length,
                            itemBuilder: (BuildContext context, int indexss) {
                              if (category![indexs].name ==
                                  serviceList[indexss].categoryName) {
                                return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ViewAllLabel(
                                        label:
                                            '${category![indexs].name.validate()}',
                                        list: category![indexs].name ==
                                                serviceList[indexss]
                                                    .categoryName
                                            ? serviceList
                                            : null,
                                        onTap: () {
                                          SearchListScreen(
                                                  categoryId: category![indexs]
                                                      .id
                                                      .validate(),
                                                  categoryName:
                                                      category![indexs].name)
                                              .launch(context);
                                        },
                                      ).paddingSymmetric(horizontal: 16),
                                      HorizontalList(
                                        itemCount: serviceList.length,
                                        //  spacing: 16,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 0, vertical: 5),
                                        itemBuilder: (context, index) {
                                          if (category![indexs].name ==
                                              serviceList[index].categoryName) {
                                            return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  ServiceComponent(
                                                      serviceData:
                                                          serviceList[index],
                                                      width: 280,
                                                      isBorderEnabled: true),
                                                ]);
                                          } else {
                                            return Container();
                                          }
                                        },
                                      ),
                                    ]);
                              } else {
                                return Container();
                              }
                            })
                      ],
                    )))
          else
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
              child: Column(
                children: [
                  Image.asset(notDataFoundImg, height: 126),
                  32.height,
                  Text(language.lblNoServicesFound, style: boldTextStyle()),
                ],
              ),
            ).center(),
        ],
      ),
    );
  }
}
