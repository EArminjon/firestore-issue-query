import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseFirestore.instance.clearPersistence();
  FirebaseFirestore.instance.settings = Settings(persistenceEnabled: false);
  FirebaseFirestore.setLoggingEnabled(true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool loading = false;
  List<DocumentSnapshot<Map<String, dynamic>>> items = [];
  Object? lastItem;
  QuerySnapshot<Map<String, dynamic>>? response;
  bool noMoreItems = false;
  String? error;

  bool loading2 = false;
  List<DocumentSnapshot<Map<String, dynamic>>> items2 = [];
  Object? lastItem2;
  QuerySnapshot<Map<String, dynamic>>? response2;
  bool noMoreItems2 = false;
  String? error2;

  void fetchWithGameDatesFrom(Object? offset, {int limit = 1}) async {
    try {
      setState(() => loading = true);

      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection("bookings")
          .where('game.dates.from', isGreaterThan: 0);

      if (offset is DocumentSnapshot) {
        query = query.startAfterDocument(offset);
      }

      query = query.limit(limit);

      final QuerySnapshot<Map<String, dynamic>> result = await query.get(
        const GetOptions(source: Source.server),
      );
      setState(() {
        noMoreItems = result.docs.length < limit;
        items.addAll(result.docs);
        response = result;
        lastItem = result.docs.lastOrNull;
      });
    } catch (err) {
      log(err.toString());
      setState(() => error = err.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  void fetchWithUserId(Object? offset, {int limit = 1}) async {
    try {
      setState(() => loading2 = true);

      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection("bookings")
          .where('user.id', isEqualTo: "123456789");

      if (offset is DocumentSnapshot) {
        query = query.startAfterDocument(offset);
      }

      query = query.limit(limit);

      final QuerySnapshot<Map<String, dynamic>> result = await query.get(
        const GetOptions(source: Source.server),
      );
      setState(() {
        noMoreItems2 = result.docs.length < limit;
        items2.addAll(result.docs);
        response2 = result;
        lastItem2 = result.docs.lastOrNull;
      });
    } catch (err) {
      log(err.toString());
      setState(() => error2 = err.toString());
    } finally {
      setState(() => loading2 = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (loading) const CircularProgressIndicator(),
                  OutlinedButton(
                    onPressed:
                        noMoreItems
                            ? null
                            : () {
                              fetchWithGameDatesFrom(lastItem);
                            },
                    child: Text(
                      "Fetch with game.dates.from (last: ${response?.docs.lastOrNull})",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Text("Current page items : ${response?.docs.length}"),
                  Text("Total fetched items: ${items.length}"),
                  Text("No more items: $noMoreItems"),
                  Text("Error: $error"),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        noMoreItems = false;
                        response = null;
                        error = null;
                        lastItem = null;
                        items.clear();
                      });
                    },
                    child: Text("reset"),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (loading2) const CircularProgressIndicator(),
                  OutlinedButton(
                    onPressed:
                        noMoreItems2
                            ? null
                            : () {
                              fetchWithUserId(lastItem2);
                            },
                    child: Text(
                      "Fetch with user.id (last: ${response2?.docs.lastOrNull})",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Text("Current page items : ${response2?.docs.length}"),
                  Text("Total fetched items: ${items2.length}"),
                  Text("No more items: $noMoreItems2"),
                  Text("Error: $error2"),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        noMoreItems2 = false;
                        response2 = null;
                        error2 = null;
                        lastItem2 = null;
                        items2.clear();
                      });
                    },
                    child: Text("reset"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
