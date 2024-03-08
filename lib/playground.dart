import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:untitled17/screens/playdet.dart';

class Playground extends StatefulWidget {
  const Playground({Key? key});

  @override
  State<Playground> createState() => _PlaygroundState();
}

class _PlaygroundState extends State<Playground> {
  String selectedCity = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text('Playground'),
      ),
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(8),
            child: Column(
              children: <Widget>[
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                          hintText: "Search",
                          hintStyle: TextStyle(color: Colors.grey),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey,
                          ),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final selectedCityResult = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DistrictList(),
                          ),
                        );

                        if (selectedCityResult != null) {
                          setState(() {
                            selectedCity = selectedCityResult;
                          });
                        }
                      },
                      child: Text('Districts'),
                    ),
                  ],
                ),
                const Divider(
                  thickness: 1,
                  color: Colors.grey,
                ),
                Category(),
                const Divider(
                  height: 8,
                  thickness: 0.5,
                  color: Colors.grey,
                ),
                SizedBox(height: 18,),

                FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  future: (selectedCity.isEmpty)
                      ? FirebaseFirestore.instance.collection('playgrounds').get()
                      : FirebaseFirestore.instance
                      .collection('playgrounds')
                      .where('city', isEqualTo: selectedCity)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                      return Text('No data available');
                    } else {
                      List<DocumentSnapshot> playgrounds = snapshot.data!.docs;

                      return Column(
                        children: playgrounds.map((playground) {
                          return Column(
                            children: [
                              SizedBox(height: 18,),
                              PlaygroundCard(data: playground.data() as Map<String, dynamic>),
                            ],
                          );
                        }).toList(),
                      );
                    }
                  },
                ),
                SizedBox(height: 18,),

                Text(
                  'Selected City: $selectedCity',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PlaygroundCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const PlaygroundCard({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaygroundDetailsPage(playgroundData: data),
          ),
        );
      },
      child: Stack(
        children: [
          NewWidget(imge: data['imageUrl']),
          Positioned(
            child: Container(
              margin: EdgeInsets.only(left: 20, bottom: 10),
              child: Nagma(),
            ),
            bottom: 1,
          ),
          Positioned(
            top: 20,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${data['name']}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Nagma extends StatefulWidget {
  const Nagma({
    super.key,
  });

  @override
  State<Nagma> createState() => _NagmaState();
}

class Nagmas extends StatefulWidget {
  const Nagmas({
    Key? key,
  }) : super(key: key);

  @override
  State<Nagma> createState() => _NagmaState();
}

class _NagmaState extends State<Nagma> {
  double rating = 0;

  @override
  Widget build(BuildContext context) {
    return RatingBar.builder(
      initialRating: rating,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
      itemSize: 20,
      itemBuilder: (context, _) => Icon(
        Icons.star,
        color: Colors.amber,
      ),
      onRatingUpdate: (newRating) {
        setState(() {
          rating = newRating;
        });
      },
    );
  }
}

class NewWidget extends StatelessWidget {
  final String imge;

  const NewWidget({Key? key, required this.imge}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      child: Builder(
        builder: (BuildContext context) {
          return Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.symmetric(horizontal: 5.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
            ),
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(imge),
                  fit: BoxFit.fill,
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Container(
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                        right: 180,
                        left: 8,
                        top: 88,
                      ),
                      width: 209,
                      height: 72,
                      child: Text(
                        '',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class SearchBar extends StatelessWidget {
  const SearchBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: TextFormField(
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: "Search",
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}

class Category extends StatelessWidget {
  const Category({Key? key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          child: Column(
            children: [
              SizedBox(
                height: 100,
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: Row(
                      children: [
                        categoryIcon("Paddle", "images/paddel.jpeg"),
                        const SizedBox(width: 12),
                        categoryIcon("Football", "images/football.jpeg"),
                        const SizedBox(width: 12),
                        categoryIcon("Basketball", "images/basketball.jpeg"),
                        const SizedBox(width: 12),
                        categoryIcon("Volleyball", "images/volleyball.jpeg"),
                        const SizedBox(width: 12),
                        categoryIcon("Tennis", "images/tennis.jpeg"),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        )
      ],
    );
  }

  Widget categoryIcon(String text, String image) {
    return SizedBox(
      width: 65,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            child: CircleAvatar(
              backgroundImage: AssetImage(image),
              radius: 34,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            child: Text(
              text,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DistrictList extends StatefulWidget {
  @override
  _DistrictListState createState() => _DistrictListState();
}

class _DistrictListState extends State<DistrictList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Districts'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Al-Mokattam'),
            onTap: () {
              Navigator.pop(context, 'Al-Mokattam');
            },
          ),
          ListTile(
            title: Text('Madinaty'),
            onTap: () {
              Navigator.pop(context, 'Madinaty');
            },
          ),
          ListTile(
            title: Text('Al-Shorouk'),
            onTap: () {
              Navigator.pop(context, 'Al-Shorouk');
            },
          ),
        ],
      ),
    );
  }
}