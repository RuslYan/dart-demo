import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './planet.dart';

void main() {
  runApp(MyApp());
  explorePlanet();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];
  void toggleFavorites() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        // page = Placeholder();
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(children: [
          SafeArea(
              child: NavigationRail(
            extended: true,
            selectedIndex: selectedIndex,
            destinations: [
              NavigationRailDestination(
                  icon: Icon(Icons.home), label: Text('Home')),
              NavigationRailDestination(
                  icon: Icon(Icons.favorite), label: Text('Favorites'))
            ],
            onDestinationSelected: (value) {
              print('selected: $value');
              setState(() {
                selectedIndex = value;
              });
            },
          )),
          Expanded(
              child: Container(
            color: Theme.of(context).colorScheme.onPrimary,
            child: page,
          ))
        ]),
      );
    });
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
  Widget build(BuildContext context) {
    return Scaffold(
        body: Row(children: [
      SafeArea(
        child: NavigationRail(
          extended: true,
          selectedIndex: 0,
          destinations: [
            NavigationRailDestination(
                icon: Icon(Icons.home), label: Text('Home')),
            NavigationRailDestination(
                icon: Icon(Icons.favorite), label: Text('Favorites'))
          ],
          onDestinationSelected: (value) {
            print('selected: $value');
          },
        ),
      ),
      Expanded(
          child: Container(
              // color: Theme.of(context).colorScheme.primaryContainer,
              decoration: BoxDecoration(color: Colors.deepOrange),
              child: GeneratorPage())),
    ]));
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;
    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                  onPressed: () {
                    print('press');
                    appState.getNext();
                    explorePlanet();
                  },
                  child: Text('Next')),
              SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorites();
                },
                icon: Icon(icon),
                label: Text('Lick'),
              )
            ],
          ),
        ],
      )),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });
  final WordPair pair;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!
        .copyWith(color: theme.colorScheme.onPrimary);
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    if (appState.favorites.isEmpty) {
      return Center(child: Text('No favorites yet.'));
    }
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have ${appState.favorites.length} favorites'),
        ),
        for (var pair in appState.favorites)
          ListTile(leading: Icon(Icons.favorite), title: Text(pair.asLowerCase))
      ],
    );
  }
}
