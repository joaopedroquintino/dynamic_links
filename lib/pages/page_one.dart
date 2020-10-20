import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PageOne extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Você está na página 1'),
            CupertinoButton(
              child: Text('Ir para a página 2'),
              onPressed: () {
                Navigator.of(context).pushNamed('/page_two');
              },
            ),
          ],
        ),
      ),
    );
  }
}
