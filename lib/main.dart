import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(TacoTruckApp());
}

class TacoTruckApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taco Truck NFT',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LandingPage(),
    );
  }
}

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 50),
              child: Image.asset('assets/images/taco_truck_logo.png', width: 300),
            ),
            Text('DISCOVER, COLLECT AND SELL NFT TACOS.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('The World\'s First NFT Taco Marketplace.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.blueGrey)),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TacoGalleryPage()),
              ),
              child: Text('EXPLORE'),
            ),
          ],
        ),
      ),
    );
  }
}

class TacoGalleryPage extends StatelessWidget {
  final List<String> categories = ["Classic Beef", "Seafood", "Vegetarian", "Spicy Chicken"];
  final List<double> prices = [0.05, 0.07, 0.06, 0.08]; // Example prices in ETH for each category

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NFT Tacos'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AccountPage()));
            },
          ),
          IconButton(icon: Icon(Icons.search), onPressed: () {}),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(child: Text('0.00 ETH', style: TextStyle(fontWeight: FontWeight.bold))),
          ),
        ],
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          String tacoImage = 'assets/images/taco_${index+1}.png'; // Assuming images are named sequentially
          return GestureDetector(
            onTap: () {},
            child: Column(
              children: [
                Expanded(
                  child: Image.asset(tacoImage, errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.error); // Display error icon if image fails to load
                  }),
                ),
                Text(categories[index]), // Display the category name
                Text('${prices[index]} ETH', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)), // Display price in ETH
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(Icons.favorite_border, color: Colors.red),
                      onPressed: () {}, // Logic to handle Like action
                    ),
                    ElevatedButton(
                      onPressed: () {}, // Logic to handle Subscribe action
                      child: Text('Subscribe'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.blue, // Text color
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateNFTPage()),
          );
        },
        tooltip: 'Create NFT',
        child: Icon(Icons.add),
      ),
    );
  }
}

class CreateNFTPage extends StatefulWidget {
  @override
  _CreateNFTPageState createState() => _CreateNFTPageState();

}

class _CreateNFTPageState extends State<CreateNFTPage> {
  String? imageUrl; // imageUrl is now nullable

  Future<void> fetchTacoImage() async {
    final apiKey = 'bYm8f68gKUfAvtmkhd8aoznIGK-p-sqz-BTC-qnSa00';
    final uri = Uri.parse('https://api.unsplash.com/photos/random?query=taco&client_id=$apiKey');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      setState(() {
        imageUrl = jsonDecode(response.body)['urls']['regular'];
      });
    } else {
      print('Failed to load images: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create NFT'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            imageUrl == null
                ? Container(
              height: 150, // Adjusted size for the placeholder
              color: Colors.grey[300],
              child: Center(child: Text('Tap below to generate image')),
            )
                : Container(
              height: 150, // Adjusted image height
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.network(imageUrl!, fit: BoxFit.contain), // Changed BoxFit to contain
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchTacoImage,
              child: Text('Generate Taco Image'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Logic to create NFT
              },
              child: Text('Create NFT'),
            ),
          ],
        ),
      ),
    );
  }
}

// Define the AccountPage class as needed based on previous instructions
class AccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Account"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage("https://via.placeholder.com/150"), // Placeholder for user image
            ),
            SizedBox(height: 10),
            Text("0xtEb5de...", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text("10", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("My NFTs"),
                  ],
                ),
                Column(
                  children: [
                    Text("100", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("Followers"),
                  ],
                ),
                Column(
                  children: [
                    Text("2", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("Following"),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: Text("Follow"),
            ),
            SizedBox(height: 20),
            DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      Tab(text: "My NFTs"),
                      Tab(text: "Collectibles"),
                    ],
                  ),
                  Container(
                    height: 300,
                    child: TabBarView(
                      children: [
                        GridView.count(
                          crossAxisCount: 2,
                          children: List.generate(4, (index) => Card(child: Image.network("https://via.placeholder.com/150"))),
                        ),
                        GridView.count(
                          crossAxisCount: 2,
                          children: List.generate(2, (index) => Card(child: Image.network("https://via.placeholder.com/150"))),
                        ),
                      ],
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