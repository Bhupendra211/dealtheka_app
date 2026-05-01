import 'package:dealtheka/constant/AppStyle.dart';
import 'package:dealtheka/constant/Colors.dart';
import 'package:flutter/material.dart';

class HistoryBox extends StatelessWidget {
  final IconData icondata;
  final String serviceName;
  final String location;
  final String date;
  final String status;

  const HistoryBox({super.key, required this.icondata, required this.serviceName, required this.location, required this.date, required this.status});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: AppColor.primaryColor,
        ),
        borderRadius: BorderRadius.circular(5)
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth*0.02),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: AppColor.primaryColor
                  ),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Padding(
                  padding:  EdgeInsets.all(screenWidth*0.025),
                  child: Icon(icondata, color: AppColor.primaryColor),
                )),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(serviceName,style: AppStyle.fontMedium12),
                Text(location, style: AppStyle.font12,),
              ],
            ),

            Text(date,style: AppStyle.font12),

            Text(
              status,
              style: status.toLowerCase() == "pending"
                  ? AppStyle.fontMedium12Blue
                  : status.toLowerCase() == "cancelled"
                  ? AppStyle.fontMedium12Red
                  : AppStyle.fontMedium12Green,
            ),

          ],
        ),
      ),
    );
  }
}
