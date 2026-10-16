import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:oktoast/oktoast.dart';

class PictureWebUrl extends StatefulWidget {
  final String weburl;
  final String title;
  const PictureWebUrl({Key? key, required this.title, required this.weburl}) : super(key: key);

  @override
  State<PictureWebUrl> createState() => _PictureWebUrlState();
}

class _PictureWebUrlState extends State<PictureWebUrl> {
  late InAppWebViewController _webViewController;  //声明 InAppWebViewController 控制器
  late final ToastFuture toastFuture;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  void showLoading(){
    setState(() {
      toastFuture = showToastWidget(
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30.0),
            child: SizedBox(
              width: 100.0,
              height: 100.0,
              //color: Colors.grey.withOpacity(0.3),
              child: Image.asset('static/images/loading.gif',fit: BoxFit.cover,
                width: 100,),
            ),
          ),
        ),
        duration: const Duration(seconds: 10),
        onDismiss: () {
          // The method will be called on toast dismiss.
          //debugPrint('Toast has been dismissed.');
        },
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title:  Text(widget.title),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double width = constraints.maxWidth;
          double height = constraints.maxHeight;
          return SizedBox(
            width: width,
            height: height,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(10),
                child: InAppWebView(
                  initialUrlRequest: URLRequest(
                    url: WebUri(Uri.parse("${widget.weburl}").toString()),
                  ),
                  onLoadStart: (controller, url){
                    showLoading();
                  },
                  onLoadStop: (controller, url){
                    toastFuture.dismiss();
                  },
                  //onWebViewCreated 的作用就是在 WebView 创建完成后，提供一个机会让开发者执行一些初始化操作，
                  // 同时获取 WebView 的控制器，以便后续对 WebView 进行操作
                  onWebViewCreated: (controller) {
                    _webViewController = controller;  // 当 WebView 创建完成时，将控制器赋值
                    //_webViewController.getHtml();
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void didUpdateWidget(covariant PictureWebUrl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.weburl != oldWidget.weburl) {
      if (_webViewController != null) {
        _webViewController.loadUrl(
            urlRequest: URLRequest(
              url: WebUri(Uri.parse("${widget.weburl}").toString()),
            ));
      }
    }
  }
}