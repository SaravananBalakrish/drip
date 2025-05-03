// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart' show JavaScriptMode, WebViewController, WebViewWidget;
//
// import 'dart:html' as html if (dart.library.io) 'dart:io'; // Conditional import
// import 'dart:ui_web' as ui if (dart.library.io) 'dart:io'; // Conditional import
//
// class WeatherScreenExternal extends StatelessWidget {
// final int userid;
// final int controllerid;
//
// const WeatherScreenExternal({
// super.key,
// required this.userid,
// required this.controllerid,
// });
//
// @override
// Widget build(BuildContext context) {
// // Construct URL with userid and controllerid (modify as needed)
// final url = 'https://www.weatherandradar.in/?user=$userid&controller=$controllerid';
//
// return Scaffold(
// appBar: AppBar(title: const Text('External Weather')),
// body: Center(
// child: kIsWeb
// ? Iframe(urlstr: url) // Web: Use iframe
//     : MobileWebView(url: url), // Mobile: Use WebView
// ),
// );
// }
// }
//
// // Web-specific iframe widget
// class Iframe extends StatefulWidget {
// final String urlstr;
//
// const Iframe({required this.urlstr, super.key});
//
// @override
// _IframeState createState() => _IframeState();
// }
//
// class _IframeState extends State<Iframe> {
// late String iframeViewType;
//
// @override
// void initState() {
// super.initState();
// if (kIsWeb) {
// iframeViewType = 'iframe-${DateTime.now().millisecondsSinceEpoch}';
// ui.platformViewRegistry ;
// ui.platformViewRegistry.registerViewFactory(iframeViewType, (int viewId) {
// var iframe = html.IFrameElement()
// ..src = widget.urlstr
// ..style.border = 'none';
// return iframe;
// });
// }
// }
//
// @override
// void dispose() {
// if (kIsWeb) {
// final iframe = html.document.querySelector('iframe');
// if (iframe != null) {
// iframe.style.display = 'none';
// }
// }
// super.dispose();
// }
//
// @override
// Widget build(BuildContext context) {
// return HtmlElementView(viewType: iframeViewType);
// }
// }
//
// // Mobile-specific WebView widget
// class MobileWebView extends StatelessWidget {
// final String url;
//
// const MobileWebView({required this.url, super.key});
//
// @override
// Widget build(BuildContext context) {
// return WebViewWidget(
// controller: WebViewController()
// ..setJavaScriptMode(JavaScriptMode.unrestricted)
// ..loadRequest(Uri.parse(url)),
// );
// }
// }