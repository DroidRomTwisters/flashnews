import 'package:flashnews2/NewsBrowser.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// TODO 2: Import packages we added to our pubspec.yaml file.
import 'package:webfeed/webfeed.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RSSReader extends StatefulWidget {
  RSSReader() : super();

  final String title = "News Flash";

  @override
  State<StatefulWidget> createState() => RSSReaderState();
}

class RSSReaderState extends State<RSSReader> {
  static const String FEED_URL = 'https://news.google.com/news/rss';
  RssFeed _feed; // RSS Feed Object
  String _title; // Place holder for appbar title.
  static const String loadingMessage = 'Loading Feed...';
  static const String feedLoadErrorMessage = 'Error Loading Feed.';
  static const String feedOpenErrorMessage = 'Error Opening Feed.';
  GlobalKey<RefreshIndicatorState> _refreshKey;

  updateTitle(title) {
    setState(() {
      _title = title;
    });
  }

  updateFeed(feed) {
    setState(() {
      _feed = feed;
    });
  }

  Future<void> openFeed(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: true,
        forceWebView: false,
      );
      return;
    }
    updateTitle(feedOpenErrorMessage);
  }

  load() async {
    updateTitle(loadingMessage);
    loadFeed().then((result) {
      if (null == result || result.toString().isEmpty) {
        // Notify user of error.
        updateTitle(feedLoadErrorMessage);
        return;
      }

      updateFeed(result);

      updateTitle("Google News");
    });
  }

  Future<RssFeed> loadFeed() async {
    try {
      final client = http.Client();
      final response = await client.get(FEED_URL);
      return RssFeed.parse(response.body);
    } catch (e) {}
    return null;
  }

  @override
  void initState() {
    super.initState();
    _refreshKey = GlobalKey<RefreshIndicatorState>();
    updateTitle(widget.title);
    load();
  }

  isFeedEmpty() {
    return null == _feed || null == _feed.items;
  }

  body() {
    return isFeedEmpty()
        ? Center(
            child: CircularProgressIndicator(),
          )
        : RefreshIndicator(
            key: _refreshKey,
            child: list(),
            onRefresh: () => load(),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //child: Scaffold(
      appBar: AppBar(
        title: Text(_title),
      ),
      body: body(),
      //),
    );
  }

  list() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // ListView that displays the RSS data.
          Expanded(
            flex: 3,
            child: Container(
              child: ListView.builder(
                padding: EdgeInsets.all(5.0),
                itemCount: _feed.items.length,
                itemBuilder: (BuildContext context, int index) {
                  final item = _feed.items[index];
                  return Container(
                    margin: EdgeInsets.only(
                      bottom: 10.0,
                    ),
                    decoration: customBoxDecoration(),
                    child: ListTile(
                      title: title(item.title),
                      subtitle: subtitle(item.pubDate),
                      trailing: rightIcon(),
                      contentPadding: EdgeInsets.all(5.0),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  WebViewContainer(item.link, item.title))),
                    ),
                  );
                },
              ),
            ),
          ),
        ]);
  }

  // Method that returns the Text Widget for the title of our RSS data.
  title(title) {
    return Text(
      title,
      style: TextStyle(
          fontSize: 18.0, fontWeight: FontWeight.w500, color: Colors.amber),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  // Method that returns the Text Widget for the subtitle of our RSS data.
  subtitle(subTitle) {
    return Text(
      subTitle,
      style: TextStyle(
          fontSize: 15.0, fontWeight: FontWeight.w300, color: Colors.amber),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  // Method that returns Icon Widget.
  rightIcon() {
    return Icon(
      Icons.keyboard_arrow_right,
      color: Colors.amberAccent,
      size: 30.0,
    );
  }

  // Custom box decoration for the Container Widgets.
  BoxDecoration customBoxDecoration() {
    return BoxDecoration(
      border: Border.all(
        color: Colors.amberAccent, // border color
        width: 1.0,
      ),
    );
  }

// ====================  End ListView Components ====================
}
