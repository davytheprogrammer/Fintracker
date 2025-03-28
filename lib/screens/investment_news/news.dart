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

class InvestmentsPage extends StatefulWidget {
  @override
  _InvestmentsPageState createState() => _InvestmentsPageState();
}

class _InvestmentsPageState extends State<InvestmentsPage> {
  final List<String> globalRssFeeds = [
    'https://www.cnbc.com/id/10001147/device/rss/rss.html',
    'https://www.investing.com/rss/news.rss',
    'https://www.bloomberg.com/feed/podcast/bloomberg-businessweek.xml'
  ];

  List<Article> articles = [];
  bool isLoading = true;
  String? currentCountry;

  @override
  void initState() {
    super.initState();
    _initializeLocationAndNews();
  }

  Future<void> _initializeLocationAndNews() async {
    try {
      // Request location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );

      // Get country from coordinates
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      setState(() {
        currentCountry = placemarks.first.country;
      });

      // Fetch news based on location
      await fetchNews();
    } catch (e) {
      print('Location Error: $e');
      // Fallback to global news if location fails
      await fetchNews();
    }
  }

  Future<void> fetchNews() async {
    List<Article> fetchedArticles = [];
    for (String url in globalRssFeeds) {
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final document = xml.XmlDocument.parse(response.body);
          final items = document.findAllElements('item');

          fetchedArticles.addAll(items.map((element) {
            String? extractImageUrl() {
              // Multiple methods to extract image URL
              final mediaContent = element.findElements('media:content');
              if (mediaContent.isNotEmpty) {
                return mediaContent.first.getAttribute('url');
              }

              final enclosure = element.findElements('enclosure');
              if (enclosure.isNotEmpty) {
                return enclosure.first.getAttribute('url');
              }

              final description =
                  element.findElements('description').first.text;
              final imageRegex = RegExp(r'<img[^>]+src="([^">]+)"');
              final match = imageRegex.firstMatch(description);
              if (match != null) {
                return match.group(1);
              }

              final image = element.findElements('image');
              if (image.isNotEmpty) {
                final imageUrl = image.first.findElements('url');
                if (imageUrl.isNotEmpty) {
                  return imageUrl.first.text;
                }
              }

              return null;
            }

            String? imageUrl = extractImageUrl();

            return Article(
                title: element.findElements('title').first.text,
                link: element.findElements('link').first.text,
                pubDate: element.findElements('pubDate').isNotEmpty
                    ? element.findElements('pubDate').first.text
                    : DateTime.now().toString(),
                imageUrl: imageUrl ?? '',
                description: element.findElements('description').isNotEmpty
                    ? element.findElements('description').first.text
                    : '',
                country: currentCountry ?? 'Global');
          }));
        }
      } catch (e) {
        print('RSS Feed Error: $e');
      }
    }

    setState(() {
      // Filter articles based on country or description
      articles = fetchedArticles
          .where((article) =>
              (article.country == currentCountry ||
                  article.description
                      .toLowerCase()
                      .contains(currentCountry?.toLowerCase() ?? '')) &&
              article.imageUrl.isNotEmpty)
          .toList();

      // If no local articles with images, use global articles with images
      if (articles.isEmpty) {
        articles = fetchedArticles
            .where((article) => article.imageUrl.isNotEmpty)
            .toList();
      }

      isLoading = false;
    });
  }

  void _openArticle(String url) async {
    try {
      await launch(url, customTabsOption: CustomTabsOption());
    } catch (e) {
      print('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Investment Insights',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? _buildShimmerLoader()
          : RefreshIndicator(
              onRefresh: fetchNews,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  return _buildArticleCard(articles[index]);
                },
              ),
            ),
    );
  }

  Widget _buildShimmerLoader() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Shimmer.fromColors(
            baseColor: Colors.pink[100]!,
            highlightColor: Colors.pink[50]!,
            child: Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildArticleCard(Article article) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Card(
        elevation: 8,
        shadowColor: Colors.pink.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: Color(0xFFFFF0F5),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _openArticle(article.link),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image with advanced error handling
                  ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                    child: CachedNetworkImage(
                      imageUrl: article.imageUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.pink[100]!,
                        highlightColor: Colors.pink[50]!,
                        child: Container(
                          height: 200,
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 200,
                        color: Colors.pink[50],
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.pink[300],
                            size: 50,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.title,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),
                        Text(
                          _formatDate(article.pubDate),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.pink[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(String pubDate) {
    try {
      return DateFormat('EEE, MMM d, yyyy').format(
          DateFormat('EEE, dd MMM yyyy HH:mm:ss Z')
              .parse(pubDate, true)
              .toLocal());
    } catch (e) {
      return 'Recent News';
    }
  }
}

class Article {
  final String title;
  final String link;
  final String pubDate;
  final String imageUrl;
  final String description;
  final String? country;

  Article({
    required this.title,
    required this.link,
    required this.pubDate,
    required this.imageUrl,
    required this.description,
    this.country,
  });
}
