import 'package:dynamic_links/pages/page_one.dart';
import 'package:dynamic_links/pages/page_two.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dynamic Links',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: <String, WidgetBuilder>{
        '/': (context) => MyHomePage(title: 'Dynamic Links Home'),
        '/page_one': (_) => PageOne(),
        '/page_two': (_) => PageTwo(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _linkMessage;
  bool _isCreatingLink = false;
  String _testString = "Dê um clique longo no link para copiar";

  void initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      final Uri deepLink = dynamicLink?.link;

      _navigateWithDeepLink(deepLink);
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });

    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;

    _navigateWithDeepLink(deepLink);
  }

  void _navigateWithDeepLink(Uri deepLink) {
    if (deepLink != null) {
      if (deepLink.path == '/') {
        return;
      }
      if (deepLink.path == '/page_one/page_two') {
        Navigator.pushNamed(context, '/page_one');
        Navigator.pushNamed(context, '/page_two');
        return;
      }
      Navigator.pushNamed(context, deepLink.path);
    }
  }

  Future<void> _createDynamicLink(bool short) async {
    setState(() {
      _isCreatingLink = true;
    });

    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://bmais.page.link',
      link: Uri.parse('https://bmais.page.link/helloworld'),
      androidParameters: AndroidParameters(
        packageName: 'br.com.popcode.joaoquintino.dynamic_links',
        minimumVersion: 0,
      ),
      dynamicLinkParametersOptions: DynamicLinkParametersOptions(
        shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
      ),
      iosParameters: IosParameters(
        bundleId: 'com.google.FirebaseCppDynamicLinksTestApp.dev',
        minimumVersion: '0',
      ),
    );

    Uri url;
    if (short) {
      final ShortDynamicLink shortLink = await parameters.buildShortLink();
      url = shortLink.shortUrl;
    } else {
      url = await parameters.buildUrl();
    }

    setState(() {
      _linkMessage = url.toString();
      _isCreatingLink = false;
    });
  }

  @override
  void initState() {
    super.initState();
    initDynamicLinks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CupertinoButton(
              child: Text('Ir para a página 1'),
              onPressed: () {
                Navigator.of(context).pushNamed('/page_one');
              },
            ),
            CupertinoButton(
              child: Text('Ir para a página 2'),
              onPressed: () {
                Navigator.of(context).pushNamed('/page_two');
              },
            ),
            RaisedButton(
              onPressed:
                  !_isCreatingLink ? () => _createDynamicLink(false) : null,
              child: const Text('Get Long Link'),
            ),
            RaisedButton(
              onPressed:
                  !_isCreatingLink ? () => _createDynamicLink(true) : null,
              child: const Text('Get Short Link'),
            ),
            Builder(
              builder: (contexto) => InkWell(
                child: Text(
                  _linkMessage ?? '',
                  style: const TextStyle(color: Colors.blue),
                ),
                onTap: () {
                  if (_linkMessage != null) {
                    print(_linkMessage);
                  }
                },
                onLongPress: () {
                  Clipboard.setData(ClipboardData(text: _linkMessage));
                  Scaffold.of(contexto).showSnackBar(
                    const SnackBar(content: Text('Link Copiado!')),
                  );
                },
              ),
            ),
            Text(_linkMessage == null ? '' : _testString)
          ],
        ),
      ),
    );
  }
}
