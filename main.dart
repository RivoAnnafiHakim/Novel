// Modified version of your app with 3 added features: Bookmark, Sort, Read Fullscreen

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

void main() => runApp(NovelApp());

class NovelApp extends StatefulWidget {
  @override
  _NovelAppState createState() => _NovelAppState();
}

class _NovelAppState extends State<NovelApp> {
  bool isDarkMode = false;

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Novel App',
      debugShowCheckedModeBanner: false,
      theme: isDarkMode ? ThemeData.dark() : ThemeData(primarySwatch: Colors.purple),
      home: LoginPage(onToggleTheme: toggleTheme),
    );
  }
}

class LoginPage extends StatefulWidget {
  final VoidCallback? onToggleTheme;
  LoginPage({this.onToggleTheme});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/novel-high-resolution-logo-transparent.png',
                height: 150,
              ),
              Text('Login', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              TextField(controller: usernameController, decoration: InputDecoration(labelText: 'Username')),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Masuk'),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => HomePage(onToggleTheme: widget.onToggleTheme)),
                  );
                },
              ),
              TextButton(
                onPressed: widget.onToggleTheme,
                child: Text('Toggle Dark Mode'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Novel {
  final String title;
  final String description;
  final String genre;
  final String content;
  bool isBookmarked;

  Novel(this.title, this.description, this.genre, this.content, {this.isBookmarked = false});
}

class HomePage extends StatefulWidget {
  final VoidCallback? onToggleTheme;

  HomePage({this.onToggleTheme});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Novel> novels = [
    Novel('Awal Petualangan', 'Sebuah petualangan dimulai.', 'Fantasi', 'Di suatu dunia penuh keajaiban, perjalanan besar pun dimulai...'),
    Novel('Cinta Tak Terduga', 'Cinta yang datang tanpa diduga.', 'Romantis', 'Di tengah kesibukan kota, dua hati bertemu secara tak sengaja...'),
  ];
  List<Novel> displayedNovels = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    displayedNovels = novels;
  }

  void searchNovel(String query) {
    final trimmed = query.trim();
    setState(() {
      displayedNovels = trimmed.isEmpty
          ? novels
          : novels.where((novel) => novel.title.toLowerCase().contains(trimmed.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage(onToggleTheme: widget.onToggleTheme)));
            },
          ),
          IconButton(icon: Icon(Icons.brightness_6), onPressed: widget.onToggleTheme),
          IconButton(
            icon: Icon(Icons.category),
            onPressed: () async {
              final selectedGenre = await Navigator.push(context, MaterialPageRoute(builder: (_) => GenrePage()));
              if (selectedGenre != null) {
                setState(() {
                  displayedNovels = novels.where((novel) => novel.genre == selectedGenre).toList();
                });
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.sort_by_alpha),
            onPressed: () {
              setState(() {
                displayedNovels.sort((a, b) => a.title.compareTo(b.title));
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.bookmark),
            onPressed: () {
              final bookmarks = novels.where((n) => n.isBookmarked).toList();
              Navigator.push(context, MaterialPageRoute(builder: (_) => BookmarkPage(bookmarkedNovels: bookmarks)));
            },
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => CreateNovelPage(
                onCreate: (novel) {
                  setState(() {
                    novels.add(novel);
                    displayedNovels = novels;
                  });
                },
              )));
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: searchNovel,
              decoration: InputDecoration(hintText: 'Search Novel', border: OutlineInputBorder()),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: displayedNovels.length,
              itemBuilder: (context, index) {
                final novel = displayedNovels[index];
                return ListTile(
                  leading: IconButton(
                    icon: Icon(novel.isBookmarked ? Icons.bookmark : Icons.bookmark_border),
                    onPressed: () {
                      setState(() {
                        novel.isBookmarked = !novel.isBookmarked;
                      });
                    },
                  ),
                  title: Text(novel.title),
                  subtitle: Text(novel.genre),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => CreateNovelPage(
                          novel: novel,
                          onCreate: (updatedNovel) {
                            setState(() {
                              novels[index] = updatedNovel;
                              displayedNovels = novels;
                            });
                          },
                        )));
                      } else if (value == 'delete') {
                        setState(() {
                          novels.removeAt(index);
                          displayedNovels = novels;
                        });
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Hapus')),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => NovelDetailPage(novel: novel)));
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class CreateNovelPage extends StatefulWidget {
  final Function(Novel) onCreate;
  final Novel? novel;

  CreateNovelPage({required this.onCreate, this.novel});

  @override
  _CreateNovelPageState createState() => _CreateNovelPageState();
}

class _CreateNovelPageState extends State<CreateNovelPage> {
  late TextEditingController titleController;
  late TextEditingController descController;
  late TextEditingController genreController;
  late TextEditingController contentController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.novel?.title ?? '');
    descController = TextEditingController(text: widget.novel?.description ?? '');
    genreController = TextEditingController(text: widget.novel?.genre ?? '');
    contentController = TextEditingController(text: widget.novel?.content ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.novel == null ? 'Buat Novel' : 'Edit Novel')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: titleController, decoration: InputDecoration(labelText: 'Judul')),
              TextField(controller: descController, decoration: InputDecoration(labelText: 'Deskripsi')),
              TextField(controller: genreController, decoration: InputDecoration(labelText: 'Genre')),
              TextField(controller: contentController, decoration: InputDecoration(labelText: 'Cerita'), maxLines: 5),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Simpan'),
                onPressed: () {
                  final novel = Novel(
                    titleController.text,
                    descController.text,
                    genreController.text,
                    contentController.text,
                    isBookmarked: widget.novel?.isBookmarked ?? false,
                  );
                  widget.onCreate(novel);
                  Navigator.pop(context);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

class GenrePage extends StatelessWidget {
  final List<String> genres = ['Fantasi', 'Romantis', 'Horor', 'Petualangan', 'Drama'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Genre')),
      body: ListView.builder(
        itemCount: genres.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(genres[index]),
          onTap: () {
            Navigator.pop(context, genres[index]);
          },
        ),
      ),
    );
  }
}

class NovelDetailPage extends StatelessWidget {
  final Novel novel;

  NovelDetailPage({required this.novel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(novel.title)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Genre: ${novel.genre}', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text(novel.description, style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Text(novel.content, style: TextStyle(fontSize: 14)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ReadNovelPage(novel: novel)));
              },
              child: Text('Baca Sekarang'),
            )
          ],
        ),
      ),
    );
  }
}

class ReadNovelPage extends StatelessWidget {
  final Novel novel;

  ReadNovelPage({required this.novel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(novel.title)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Text(novel.content, style: TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}

class BookmarkPage extends StatelessWidget {
  final List<Novel> bookmarkedNovels;

  BookmarkPage({required this.bookmarkedNovels});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bookmark')),
      body: ListView.builder(
        itemCount: bookmarkedNovels.length,
        itemBuilder: (context, index) {
          final novel = bookmarkedNovels[index];
          return ListTile(
            title: Text(novel.title),
            subtitle: Text(novel.genre),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => NovelDetailPage(novel: novel)));
            },
          );
        },
      ),
    );
  }
}
