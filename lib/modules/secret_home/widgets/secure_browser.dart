import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../../../services/encryption_service.dart';

class SecureBrowser extends StatefulWidget {
  final String initialUrl;
  const SecureBrowser({super.key, this.initialUrl = 'https://google.com'});

  @override
  State<SecureBrowser> createState() => _SecureBrowserState();
}

class _SecureBrowserState extends State<SecureBrowser> {
  late final WebViewController _controller;
  final TextEditingController _urlController = TextEditingController();
  bool isLoading = true;
  bool _isPromptOpen = false; // Lock for dialog
  bool _isAdBlockEnabled = true;

  void _injectAdBlocker() {
    if (!_isAdBlockEnabled) return;

    // 1. Massive CSS List
    const css = """
      /* Generic ad containers */
      div[id*='google_ads'], div[id*='div-gpt-ad'], div[class*='ad-'], div[class*='ads-'],
      .ad-banner, .adsbygoogle, .ad_container, .ad-slot, .ad-wrapper, .adBox, .advertisement,
      [id^='ad_'], [class^='ad_'], [id^='ads_'], [class^='ads_'],
      
      /* Iframes often used for ads */
      iframe[id*='google_ads'], iframe[id*='ads-iframe'], iframe[src*='doubleclick'],
      
      /* Specific networks */
      .taboola, .outbrain, .zergnet, .revcontent,
      
      /* Sticky footers / headers often used for ads */
      .sticky-ad, .bottom-ad-bar
      
      { display:none !important; height:0px !important; width:0px !important; 
        opacity:0 !important; visibility:hidden !important; pointer-events:none !important; }
    """;

    // 2. JavaScript Nuke Logic
    const js =
        """
      (function() {
        // A. Inject CSS
        try {
          var styleId = 'ghost-net-shield';
          if (!document.getElementById(styleId)) {
            var style = document.createElement('style');
            style.id = styleId;
            style.textContent = `$css`;
            document.head.appendChild(style);
            console.log('Ghost Net Shield: CSS Active');
          }
        } catch(e) {}

        // B. Active DOM Removal
        function nukeAds() {
          var selectors = [
            "iframe[id*='google_ads']", "iframe[src*='doubleclick']", 
            ".adsbygoogle", ".ad-banner", "div[id*='div-gpt-ad']",
            "a[href*='googleads']", "a[href*='doubleclick']"
          ];
          
          selectors.forEach(sel => {
            document.querySelectorAll(sel).forEach(el => el.remove());
          });
          
          // Heuristic: remove small iframes that might be tracking pixels
          // document.querySelectorAll('iframe').forEach(el => {
          //   if(el.offsetWidth < 10 && el.offsetHeight < 10) el.remove();
          // });
        }

        // C. Observers for dynamic content
        var observer = new MutationObserver(function(mutations) {
          nukeAds();
        });
        observer.observe(document.body, { childList: true, subtree: true });
        
        // D. Initial Nuke & Interval Backup
        nukeAds();
        setInterval(nukeAds, 3000); 

        console.log('Ghost Net Shield: JS Active');
      })();
    """;

    _controller.runJavaScript(js);
  }

  @override
  void initState() {
    super.initState();
    _urlController.text = widget.initialUrl;

    // Javascript to detect long press on images and videos
    final String jsCode = """
      document.body.addEventListener('contextmenu', function(e) {
        var target = e.target;
        if (target.tagName === 'IMG') {
          e.preventDefault();
          SaveMediaChannel.postMessage(e.target.src);
        } else if (target.tagName === 'VIDEO') {
          e.preventDefault();
          SaveMediaChannel.postMessage(target.currentSrc || target.src);
        }
      });
    """;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF111111))
      ..addJavaScriptChannel(
        'SaveMediaChannel',
        onMessageReceived: (JavaScriptMessage message) {
          _promptToSaveMedia(message.message);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                isLoading = true;
                _urlController.text = url;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() => isLoading = false);
              _controller.runJavaScript(jsCode);
              _injectAdBlocker();
            }
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

  Future<void> _promptToSaveMedia(String url) async {
    // 1. Lock: Prevent multiple identical dialogs
    if (_isPromptOpen) return;
    _isPromptOpen = true;

    // 2. Safety: Close any rogue dialogs from previous interactions
    if (Get.isDialogOpen == true) {
      Get.back();
    }

    String dispUrl = url;
    if (dispUrl.length > 50) dispUrl = "${dispUrl.substring(0, 47)}...";

    // 3. Open Dialog
    final result = await Get.dialog<bool>(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E).withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.cyanAccent.withOpacity(0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.cyanAccent.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.cyanAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.phonelink_lock,
                  size: 40,
                  color: Colors.cyanAccent,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "SECURE SAVE",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Courier',
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Encrypt and store this media?",
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  dispUrl,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontFamily: 'Courier',
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () => Get.back(result: false),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        shadowColor: Colors.cyanAccent.withOpacity(0.4),
                      ),
                      onPressed: () => Get.back(result: true),
                      child: const Text(
                        "Save",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierColor: Colors.black.withOpacity(0.9),
      transitionDuration: const Duration(milliseconds: 300),
      transitionCurve: Curves.easeOutBack,
    );

    // 4. Release Lock
    _isPromptOpen = false;

    // 5. Process Result
    if (result == true) {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 200));
      _downloadAndEncrypt(url);
    }
  }

  Future<void> _downloadAndEncrypt(String url) async {
    try {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: Colors.cyanAccent),
        ),
        barrierDismissible: false,
      );

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        },
      );

      Get.back(); // close loading

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final encryptedBytes = EncryptionService.to.encryptData(bytes);

        final dir = await getApplicationDocumentsDirectory();
        final lockerDir = Directory('${dir.path}/secret_files');
        if (!await lockerDir.exists()) {
          await lockerDir.create(recursive: true);
        }

        final timestamp = DateTime.now().millisecondsSinceEpoch;

        // Smart extension guessing
        String ext = p.extension(url).split('?').first.toLowerCase();

        // If extension is missing or weird, check headers
        if (ext.isEmpty || ext.length > 5) {
          final contentType = response.headers['content-type'];
          if (contentType != null) {
            if (contentType.contains('video/mp4'))
              ext = '.mp4';
            else if (contentType.contains('video/webm'))
              ext = '.webm';
            else if (contentType.contains('image/png'))
              ext = '.png';
            else if (contentType.contains('image/jpeg'))
              ext = '.jpg';
            else if (contentType.contains('image/gif'))
              ext = '.gif';
            else
              ext = '.bin'; // storage blob
          } else {
            ext = '.jpg'; // Fallback
          }
        }

        final filename = "secure_$timestamp$ext.enc";

        final file = File('${lockerDir.path}/$filename');
        await file.writeAsBytes(encryptedBytes);

        Get.snackbar(
          "ENCRYPTED",
          "Media secured in vault.",
          colorText: Colors.black,
          backgroundColor: Colors.cyanAccent,
          icon: const Icon(Icons.check_circle, color: Colors.black),
          duration: const Duration(seconds: 2),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      } else {
        throw Exception("Server returned ${response.statusCode}");
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar(
        "ERROR",
        "Failed to secure media: $e",
        colorText: Colors.white,
        backgroundColor: Colors.redAccent.withOpacity(0.8),
      );
    }
  }

  void _loadUrlOrSearch(String input) {
    Uri? uri = Uri.tryParse(input);
    bool isUrl = uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
    if (!isUrl) {
      if (input.contains('.') && !input.contains(' ')) {
        _controller.loadRequest(Uri.parse('https://$input'));
      } else {
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
            if (await _controller.canGoBack()) _controller.goBack();
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
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
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
              if (await _controller.canGoForward()) _controller.goForward();
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
              } else if (value == 'adblock') {
                setState(() {
                  _isAdBlockEnabled = !_isAdBlockEnabled;
                });
                _controller.reload();
                Get.snackbar(
                  "Shield",
                  _isAdBlockEnabled ? "AdBlock ENABLED" : "AdBlock DISABLED",
                  colorText: _isAdBlockEnabled
                      ? Colors.greenAccent
                      : Colors.redAccent,
                  backgroundColor: Colors.black54,
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'adblock',
                child: Row(
                  children: [
                    Icon(
                      _isAdBlockEnabled ? Icons.gpp_good : Icons.gpp_bad,
                      color: _isAdBlockEnabled
                          ? Colors.greenAccent
                          : Colors.redAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isAdBlockEnabled ? "AdBlock On" : "AdBlock Off",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
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
