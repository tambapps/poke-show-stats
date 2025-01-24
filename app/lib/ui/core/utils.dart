import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

bool isMobile(BuildContext context) => MediaQuery.sizeOf(context).width <= 600;

void openLink(String link) async {
  final Uri uri = Uri.parse(link);
  if (await canLaunchUrl(uri)) {
    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication, // Opens browser or Chrome Tabs on mobile
      webOnlyWindowName: '_blank',         // Opens a new tab on the web
    );
  } else {
    developer.log("Couldn't open link $link");
  }
}

extension Collate<T> on Iterable<T> {
  List<List<T>> collateBy(int size) {
    List<List<T>> result = [];
    for (int i = 0; i < this.length; i += size) {
      result.add(this.skip(i).take(size).toList());
    }
    return result;
  }
}