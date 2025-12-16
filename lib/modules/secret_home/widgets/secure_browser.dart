import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SecureBrowser extends StatefulWidget {
  final String initialUrl;
  const SecureBrowser({super.key, this.initialUrl = 'https://duckduckgo.com'});

  @override
  State<SecureBrowser> createState() => _SecureBrowserState();
}

class _SecureBrowserState extends State<SecureBrowser> {
  late final WebViewController _controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {
            if (mounted) setState(() => isLoading = true);
          },
          onPageFinished: (String url) {
            if (mounted) setState(() => isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            // Block downloads or specific schemes if needed
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

  @override
  void dispose() {
    // Clear cache on exit for privacy
    _controller.clearCache();
    _controller.clearLocalStorage();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        title: const Text(
          "GHOST_NET",
          style: TextStyle(fontFamily: 'Courier', color: Colors.cyanAccent),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        bottom: isLoading
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(
                  color: Colors.cyanAccent,
                  backgroundColor: Colors.black,
                ),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.cyanAccent),
            onPressed: () => _controller.reload(),
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
            onPressed: () async {
              await _controller.clearCache();
              Get.snackbar(
                "Trace Cleared",
                "Browser cache and storage wiped.",
                colorText: Colors.white,
                backgroundColor: Colors.red.withValues(alpha: 0.3),
              );
            },
          ),
        ],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
