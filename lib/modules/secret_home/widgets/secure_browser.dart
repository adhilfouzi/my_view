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
  final TextEditingController _urlController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _urlController.text = widget.initialUrl;
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF111111))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar logic if needed
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                isLoading = true;
                _urlController.text = url;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) setState(() => isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

  @override
  void dispose() {
    _controller.clearCache();
    _controller.clearLocalStorage();
    _urlController.dispose();
    super.dispose();
  }

  void _loadUrlOrSearch(String input) {
    Uri? uri = Uri.tryParse(input);
    bool isUrl = uri != null && (uri.scheme == 'http' || uri.scheme == 'https');

    if (!isUrl) {
      // Basic heuristic: if it has a dot and no spaces, maybe treat as URL?
      // For now, simpler: if no scheme, search.
      if (input.contains('.') && !input.contains(' ')) {
        // Try adding https
        _controller.loadRequest(Uri.parse('https://$input'));
      } else {
        // Search
        _controller.loadRequest(
          Uri.parse('https://duckduckgo.com/?q=${Uri.encodeComponent(input)}'),
        );
      }
    } else {
      _controller.loadRequest(Uri.parse(input));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 18,
            color: Colors.cyanAccent,
          ),
          onPressed: () async {
            if (await _controller.canGoBack()) {
              _controller.goBack();
            }
          },
        ),
        title: Container(
          height: 40,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
          ),
          child: TextField(
            controller: _urlController,
            style: const TextStyle(
              color: Colors.cyanAccent,
              fontFamily: 'Courier',
              fontSize: 13,
            ),
            decoration: const InputDecoration(
              hintText: "Search or type URL",
              hintStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
              prefixIcon: Icon(
                Icons.lock_outline,
                color: Colors.cyanAccent,
                size: 16,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 7,
              ), // Vertically center text
            ),
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.go,
            onSubmitted: _loadUrlOrSearch,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Colors.cyanAccent,
            ),
            onPressed: () async {
              if (await _controller.canGoForward()) {
                _controller.goForward();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.cyanAccent),
            onPressed: () => _controller.reload(),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.cyanAccent),
            color: const Color(0xFF222222),
            onSelected: (value) async {
              if (value == 'clear') {
                await _controller.clearCache();
                await _controller.clearLocalStorage();
                Get.snackbar(
                  "Ghost Mode",
                  "Traces wiped.",
                  colorText: Colors.cyanAccent,
                  backgroundColor: Colors.black54,
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_forever,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text("Nuke Cache", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: isLoading
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(
                  color: Colors.cyanAccent,
                  backgroundColor: Colors.transparent,
                ),
              )
            : null,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
