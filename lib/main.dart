import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(//ESTE ES EL Widget
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 211, 148, 224)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

//TIENE EL ESTADO. ESTA SIENDO OBSERVADO, LO VAN OBSERVAR LOS DEMAS
//EL ESTADO ES LA GENERACION DE PALABRAS
class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  //VA A GENERAR UNA SIGUIENTE PALABRA
  void getNext() {
    current = WordPair.random();
    notifyListeners(); //ASI NOTIFICA EL CAMBIO A TODOS LOS QUE ESTAN OBSERVANDO
  }

  //FUNCION DE FAVORITO
  var favorites = <WordPair>[];
  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState(); //LE CREA ESTE ESTADO, CUANDO HICIMOS EL CAMBIO A UN WIDGET CON ESTADO
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0; 

  @override
  Widget build(BuildContext context) {

    Widget page; 
switch (selectedIndex) { //SEGUN EL SELECTEDINDEX
  case 0:
    page = GeneratorPage();
    break;
  case 1:
    page = FavoritesPage();
    break;
     case 2:
        page = RotatedFavoritesPage();
        break;
  default:
    throw UnimplementedError('no widget for $selectedIndex');
}
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth>=600, //QUE TENGA EN CUENTA LOS CONSTRAINTS, SI HAY MAS DE 600 LOS MUESTRA
                  destinations: [
                    //TIENE DOS DESTINOS, UNO PARA IR AL HOME Y OTRO A LOS FAVORITOS
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favorites'),
                    ),
                     NavigationRailDestination(
                      icon: Icon(Icons.rotate_right),
                      label: Text('Rotated Favorites'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                  //print('selected: $value'); LO MOSTRABA EN LA CONSOLA Y AHORA LLAMO AL SETSTATE PARA REDIBUJAR LA PRESENTACION Y CAMBIAR DE PANTALLA:
                   setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();//WATCH QUIERE DECIR QUE ESTA OBERSANDO LA CLASE MYAPPSTORE
    var pair = appState.current;

    IconData icon; //ICONO DE FAVORITO
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),//ACA MUESTRO LAS PALABRAS RANDOM EN UN WIDGET A PARTE
          SizedBox(height: 10),

           //BOTON de siguiente
          Row(
            mainAxisSize: MainAxisSize.min,//QUE TOME EL MINIMO ESPACIO
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();//LLAMA A LA FUNCION DE MARCAR Y DESMARCAR
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  //print('button pressed!'); 
                    //AHORA NO IMPRIME, LLAMA AL GETNEXT:
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}

//NUEVA CLASE PARA AGREGAR LA PANTALLA DE FAVORITOS ROTADA
class RotatedFavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: 3,
      child: FavoritesPage(),
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
  final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
         child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
      ),
      ),
    );
  }
}