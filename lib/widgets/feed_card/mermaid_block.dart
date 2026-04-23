import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Renders a Mermaid diagram inside a WebView.
/// Accepts raw mermaid source code and renders it via the mermaid.js CDN.
class MermaidBlock extends StatefulWidget {
  final String code;
  final bool isDark;

  const MermaidBlock({
    super.key,
    required this.code,
    this.isDark = true,
  });

  @override
  State<MermaidBlock> createState() => _MermaidBlockState();
}

class _MermaidBlockState extends State<MermaidBlock> {
  late final WebViewController _controller;
  double _height = 200;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        'FlutterHeight',
        onMessageReceived: (message) {
          final h = double.tryParse(message.message);
          if (h != null && mounted) {
            setState(() => _height = h + 32); // extra padding
          }
        },
      )
      ..loadHtmlString(_buildHtml());
  }

  String _buildHtml() {
    final bgColor = widget.isDark ? '#0A0A0A' : '#FAFAFA';
    final textColor = widget.isDark ? '#E8E8E8' : '#1A1A1A';
    final theme = widget.isDark ? 'dark' : 'default';
    final escapedCode = _escapeHtml(widget.code.trim());

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      background: $bgColor;
      color: $textColor;
      display: flex;
      justify-content: center;
      align-items: center;
      padding: 16px;
      overflow: hidden;
    }
    .mermaid {
      width: 100%;
      display: flex;
      justify-content: center;
    }
    .mermaid svg {
      max-width: 100% !important;
      height: auto !important;
    }
  </style>
</head>
<body>
  <pre class="mermaid">
$escapedCode
  </pre>
  <script type="module">
    import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs';
    mermaid.initialize({
      startOnLoad: true,
      theme: '$theme',
      securityLevel: 'loose',
    });
    // Report height back to Flutter after render
    setTimeout(() => {
      const el = document.querySelector('.mermaid');
      if (el) {
        FlutterHeight.postMessage(String(el.scrollHeight));
      }
    }, 1500);
  </script>
</body>
</html>
''';
  }

  String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
    // intentionally NOT escaping < and > as mermaid needs them
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _height,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: WebViewWidget(controller: _controller),
    );
  }
}
