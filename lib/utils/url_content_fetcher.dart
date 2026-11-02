import 'dart:convert';

import 'package:http/http.dart' as http;

/// Fetches readable text from a web or YouTube URL for summarization.
Future<String> fetchUrlAsStudyText(String url) async {
  final String trimmed = url.trim();
  final Uri? uri = Uri.tryParse(trimmed);
  if (uri == null || !uri.hasScheme) {
    throw Exception('Enter a valid URL starting with https://');
  }

  if (_isYouTube(uri)) {
    return _fetchYouTubeStudyText(trimmed, uri);
  }

  final http.Response response = await http
      .get(uri, headers: <String, String>{'User-Agent': 'Mozilla/5.0 GradeGlow/1.0'})
      .timeout(const Duration(seconds: 15));

  if (response.statusCode != 200) {
    throw Exception('Could not load that link (${response.statusCode}). Try the Text tab instead.');
  }

  String text = _stripHtml(response.body);
  if (text.length < 80) {
    throw Exception('Not enough text on that page. Switch to Text and paste the content.');
  }

  return text;
}

bool _isYouTube(Uri uri) {
  final String host = uri.host.toLowerCase();
  return host.contains('youtube.com') || host.contains('youtu.be') || host.contains('youtube-nocookie.com');
}

String? _extractYouTubeVideoId(Uri uri) {
  if (uri.host.contains('youtu.be')) {
    return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
  }
  final String? v = uri.queryParameters['v'];
  if (v != null && v.isNotEmpty) return v;
  if (uri.pathSegments.length >= 2 && uri.pathSegments.first == 'embed') {
    return uri.pathSegments[1];
  }
  return null;
}

String? _extractYouTubeTimestamp(Uri uri) {
  final String? t = uri.queryParameters['t'] ?? uri.queryParameters['start'];
  if (t == null || t.isEmpty) return null;
  return t;
}

Future<String> _fetchYouTubeStudyText(String url, Uri uri) async {
  final String? videoId = _extractYouTubeVideoId(uri);
  final String? timestamp = _extractYouTubeTimestamp(uri);
  String title = 'YouTube lecture';
  String author = '';

  try {
    final http.Response oembed = await http
        .get(
          Uri.parse('https://www.youtube.com/oembed?url=${Uri.encodeComponent(url)}&format=json'),
          headers: <String, String>{'User-Agent': 'GradeGlow/1.0'},
        )
        .timeout(const Duration(seconds: 10));

    if (oembed.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(oembed.body) as Map<String, dynamic>;
      title = (data['title'] as String? ?? title).trim();
      author = (data['author_name'] as String? ?? '').trim();
    }
  } catch (_) {
    // oEmbed failed — still summarize from URL + id below.
  }

  final StringBuffer buffer = StringBuffer()
    ..writeln('YouTube lecture video for study set generation')
    ..writeln('URL: $url');

  if (videoId != null) buffer.writeln('Video ID: $videoId');
  buffer.writeln('Title: $title');
  if (author.isNotEmpty) buffer.writeln('Channel: $author');
  if (timestamp != null) buffer.writeln('Starts at: $timestamp');

  buffer.writeln('');
  buffer.writeln(
    'Using the video title and topic above, create accurate university-level study materials '
    '(summary, key concepts, flashcards, and quiz questions) for the subject this lecture covers. '
    'Focus on core definitions, formulas, and concepts typically taught in this topic.',
  );

  return buffer.toString();
}

String _stripHtml(String html) {
  String text = html
      .replaceAll(RegExp(r'<script[\s\S]*?</script>', caseSensitive: false), ' ')
      .replaceAll(RegExp(r'<style[\s\S]*?</style>', caseSensitive: false), ' ')
      .replaceAll(RegExp(r'<[^>]+>'), ' ')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  return text;
}
