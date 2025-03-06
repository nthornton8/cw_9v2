import 'package:flutter/material.dart';
import 'database_helper.dart';

class CardsScreen extends StatefulWidget {
  final int folderId;
  CardsScreen({required this.folderId});

  @override
  _CardsScreenState createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  late DatabaseHelper _dbHelper;
  List<Map<String, dynamic>> _cards = [];

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper();
    _loadCards();
  }

  _loadCards() async {
    var cards = await _dbHelper.getCardsByFolderId(widget.folderId);
    setState(() {
      _cards = cards;
    });
  }

  _addCard() async {
    if (_cards.length < 6) {
      // Example: Add the first available card from the deck
      await _dbHelper.insertCard({
        'name': 'Ace of Hearts',
        'suit': 'Hearts',
        'image_url': 'https://example.com/images/1_Hearts.png',
        'folder_id': widget.folderId,
      });
      _loadCards();
    } else {
      // Show error dialog
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Folder Limit Exceeded'),
          content: Text('This folder can only hold 6 cards.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  _deleteCard(int cardId) async {
    await _dbHelper.deleteCard(cardId);
    _loadCards();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cards in Folder')),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemCount: _cards.length,
        itemBuilder: (context, index) {
          var card = _cards[index];
          return GestureDetector(
            onTap: () {
              // Handle card details update
            },
            child: Card(
              child: Column(
                children: [
                  Image.network(card['image_url'], width: 50, height: 50),
                  Text(card['name']),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteCard(card['id']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCard,
        child: Icon(Icons.add),
      ),
    );
  }
}
