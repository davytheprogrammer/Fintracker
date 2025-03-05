import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xml/xml.dart' as xml;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

// Location Models
class LocationNewsConfig {
  final Position position;
  final String? countryCode;
  final String? city;
  final String? region;

  LocationNewsConfig({
    required this.position,
    this.countryCode,
    this.city,
    this.region,
  });
}

// RSS Feed Models
class RssFeed {
  final List<RssItem>? items;

  RssFeed({this.items});

  factory RssFeed.parse(String xmlString) {
    try {
      final document = xml.XmlDocument.parse(xmlString);
      final items = document.findAllElements('item').map((node) {
        return RssItem(
          title: node.findElements('title').firstOrNull?.innerText,
          description: node.findElements('description').firstOrNull?.innerText,
          link: node.findElements('link').firstOrNull?.innerText,
          pubDate: _parseDate(
              node.findElements('pubDate').firstOrNull?.innerText ?? ''),
          content: node.findElements('content:encoded').firstOrNull?.innerText ??
              node.findElements('content').firstOrNull?.innerText,
          enclosure: node.findElements('enclosure').firstOrNull != null
              ? RssEnclosure(
            url: node
                .findElements('enclosure')
                .firstOrNull
                ?.getAttribute('url'),
            type: node
                .findElements('enclosure')
                .firstOrNull
                ?.getAttribute('type'),
            length: int.tryParse(node
                .findElements('enclosure')
                .firstOrNull
                ?.getAttribute('length') ??
                '0'),
          )
              : null,
        );
      }).toList();

      return RssFeed(items: items);
    } catch (e) {
      debugPrint('RSS Parse Error: $e');
      return RssFeed(items: []);
    }
  }

  static DateTime? _parseDate(String dateString) {
    if (dateString.isEmpty) return null;

    try {
      return DateFormat('EEE, dd MMM yyyy HH:mm:ss Z').parse(dateString);
    } catch (_) {
      try {
        return DateTime.parse(dateString);
      } catch (_) {
        return null;
      }
    }
  }
}

class RssItem {
  final String? title;
  final String? description;
  final String? link;
  final DateTime? pubDate;
  final String? content;
  final RssEnclosure? enclosure;

  RssItem({
    this.title,
    this.description,
    this.link,
    this.pubDate,
    this.content,
    this.enclosure,
  });
}

class RssEnclosure {
  final String? url;
  final String? type;
  final int? length;

  RssEnclosure({
    this.url,
    this.type,
    this.length,
  });
}

class NewsArticle {
  final String title;
  final String description;
  final String link;
  final DateTime pubDate;
  final String? imageUrl;
  final String? location;

  NewsArticle({
    required this.title,
    required this.description,
    required this.link,
    required this.pubDate,
    this.imageUrl,
    this.location,
  });

  factory NewsArticle.fromRssItem(RssItem item, {String? location}) {
    String? imageUrl;

    if (item.enclosure?.url != null) {
      imageUrl = item.enclosure?.url;
    }

    if (imageUrl == null && item.content != null) {
      final RegExp imgRegExp = RegExp(r'<img[^>]+src=\"([^\">]+)\"');
      final match = imgRegExp.firstMatch(item.content!);
      if (match != null) {
        imageUrl = match.group(1);
      }
    }

    if (imageUrl == null && item.description != null) {
      final RegExp imgRegExp = RegExp(r'<img[^>]+src=\"([^\">]+)\"');
      final match = imgRegExp.firstMatch(item.description!);
      if (match != null) {
        imageUrl = match.group(1);
      }
    }

    return NewsArticle(
      title: item.title ?? 'No Title',
      description: item.description?.replaceAll(RegExp(r'<[^>]*>'), '') ??
          'No Description',
      link: item.link ?? '',
      pubDate: item.pubDate ?? DateTime.now(),
      imageUrl: imageUrl,
      location: location,
    );
  }
}

class InvestmentsPage extends StatefulWidget {
  const InvestmentsPage({Key? key}) : super(key: key);

  @override
  State<InvestmentsPage> createState() => _InvestmentsPageState();
}

class _InvestmentsPageState extends State<InvestmentsPage> {
  List<NewsArticle> _articles = [];
  bool _isLoading = false;
  String _error = '';
  LocationNewsConfig? _locationConfig;

  // Base RSS Feed sources
  final List<String> _baseRssSources = [
    'https://feeds.finance.yahoo.com/rss/2.0/headline?s=fb,aapl,amzn',
    'https://www.investing.com/rss/news.rss',
    'https://www.cnbc.com/id/10000664/device/rss/rss.html',
  ];

  @override
  void initState() {
    super.initState();
    _initializeLocationAndNews();
  }

  Future<void> _initializeLocationAndNews() async {
    await _getCurrentLocation();
    await _fetchNews();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _error = 'Location services are disabled.';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _error = 'Location permissions are denied.';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _error = 'Location permissions are permanently denied.';
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          _locationConfig = LocationNewsConfig(
            position: position,
            countryCode: place.isoCountryCode,
            city: place.locality,
            region: place.administrativeArea,
          );
        });
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      setState(() {
        _error = 'Failed to get location: $e';
      });
    }
  }

  List<String> _getLocationBasedFeeds() {
    List<String> feeds = List.from(_baseRssSources);

    if (_locationConfig != null) {
      // Add location-based RSS feeds based on the user's location
      final country = _locationConfig!.countryCode?.toLowerCase() ?? '';
      final city = _locationConfig!.city?.toLowerCase() ?? '';
      final region = _locationConfig!.region?.toLowerCase() ?? '';

      // Add location-specific RSS feeds here
      feeds.addAll([
        'https://news.google.com/news/rss/headlines/section/geo/$city',
        'https://news.google.com/news/rss/headlines/section/geo/$region',
        'https://news.google.com/news/rss/headlines/section/geo/$country',
      ]);
    }

    return feeds;
  }

  Future<void> _fetchNews() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final List<NewsArticle> articles = [];
      final client = http.Client();
      final feeds = _getLocationBasedFeeds();

      for (final source in feeds) {
        try {
          final response = await client.get(
            Uri.parse(source),
            headers: {
              'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
            },
          );

          if (response.statusCode == 200) {
            final feed = RssFeed.parse(response.body);
            articles.addAll(
              feed.items?.map((item) => NewsArticle.fromRssItem(
                item,
                location: _locationConfig?.city,
              )) ??
                  [],
            );
          } else {
            debugPrint('Failed to fetch from $source: ${response.statusCode}');
          }
        } catch (e) {
          debugPrint('Error fetching from $source: $e');
          continue;
        }
      }

      articles.sort((a, b) => b.pubDate.compareTo(a.pubDate));

      setState(() {
        _articles = articles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to fetch news: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Financial News',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: 24,
            ),
          ),
          if (_locationConfig?.city != null)
            Text(
              'Location: ${_locationConfig!.city}',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.location_on, color: Colors.black87),
          onPressed: _getCurrentLocation,
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.black87),
          onPressed: _fetchNews,
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildShimmerList();
    }

    if (_error.isNotEmpty) {
      return _buildErrorView();
    }

    if (_articles.isEmpty) {
      return _buildEmptyView();
    }

    return RefreshIndicator(
      onRefresh: _fetchNews,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _articles.length,
        itemBuilder: (context, index) {
          return NewsCard(article: _articles[index]);
        },
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.newspaper,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No news articles available',
            style: GoogleFonts.poppins(
              color: Colors.grey[700],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _fetchNews,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => const NewsShimmerCard(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            _error,
            style: GoogleFonts.poppins(
              color: Colors.grey[700],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _initializeLocationAndNews,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NewsCard extends StatelessWidget {
  final NewsArticle article;

  const NewsCard({Key? key, required this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: () => _launchUrl(context, article.link),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            _buildContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (article.imageUrl == null) return const SizedBox.shrink();

    return ClipRRect(
        borderRadius: const BorderRadius.vertical(
        top: Radius.circular(20),
    ),
    child: CachedNetworkImage(
    imageUrl: article.imageUrl!,
    height: 220,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => ShimmerBox(height: 220),
      errorWidget: (context, url, error) => Container(
        height: 220,
        color: Colors.grey[200],
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 40,
          color: Colors.grey[400],
        ),
      ),
    ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            article.title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            article.description,
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
              fontSize: 14,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                DateFormat('MMM dd, yyyy • HH:mm').format(article.pubDate),
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              if (article.location != null) ...[
                const SizedBox(width: 16),
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 6),
                Text(
                  article.location!,
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    try {
      await launch(
        url,
        customTabsOption: CustomTabsOption(
          toolbarColor: Theme.of(context).primaryColor,
          enableDefaultShare: true,
          enableUrlBarHiding: true,
          showPageTitle: true,
          animation: CustomTabsSystemAnimation.slideIn(),
        ),
        safariVCOption: SafariViewControllerOption(
          preferredBarTintColor: Theme.of(context).primaryColor,
          preferredControlTintColor: Colors.white,
          barCollapsingEnabled: true,
          entersReaderIfAvailable: false,
          dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
        ),
      );
    } catch (e) {
      debugPrint('Could not launch $url: $e');
    }
  }
}

class ShimmerBox extends StatelessWidget {
  final double height;

  const ShimmerBox({Key? key, required this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        color: Colors.white,
      ),
    );
  }
}

class NewsShimmerCard extends StatelessWidget {
  const NewsShimmerCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.only(bottom: 20),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 220,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 120,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
