import 'package:flutter/material.dart';
import 'database_helper.dart';

class FoldersScreen extends StatefulWidget {
  @override
  _FoldersScreenState createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {
  late DatabaseHelper _dbHelper;
  List<Map<String, dynamic>> _folders = [];

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper();
    _loadFolders();
  }

  _loadFolders() async {
    var folders = await _dbHelper.getFolders();
    setState(() {
      _folders = folders;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Card Folders')),
      body: ListView.builder(
        itemCount: _folders.length,
        itemBuilder: (context, index) {
          var folder = _folders[index];
          return ListTile(
            title: Text(folder['name']),
            subtitle: FutureBuilder<List<Map<String, dynamic>>>(
              future: _dbHelper.getCardsByFolderId(folder['id']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  var firstCard = snapshot.data![0];
                  return Row(
                    children: [
                      Image.network(firstCard['image_url'], width: 50, height: 50),
                      SizedBox(width: 10),
                      Text('${snapshot.data!.length} cards'),
                    ],
                  );
                }
                return Text('No cards');
              },
            ),
            onTap: () {
              // Navigate to cards screen for this folder
            },
          );
        },
      ),
    );
  }
}
