import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter_sms_listener/flutter_sms_listener.dart';
import 'package:intl/intl.dart';

import 'card_list.dart';
import 'package:http/http.dart' as http;


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const String LISTEN_MSG = 'Hi, Listening to sms...';
  static const String NEW_MSG = 'Captured new message!';
  String _status = LISTEN_MSG;

  FlutterSmsListener _smsListener = FlutterSmsListener();
  List<SmsMessage> _messagesCaptured = <SmsMessage>[];
  List<SmsMessage> _spamMssages = <SmsMessage>[];

  final _dateFormat = DateFormat('E, ').add_jm();

  @override
  void initState() {
    super.initState();

    if (!Platform.isAndroid) {
      return;
    }

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      _beginListening();
    });
  }

  void _beginListening() {
    _smsListener.onSmsReceived!.listen((message) async {

      final response = await fetchResponse();

      if(response){
        _messagesCaptured.add(message);
        print(message.body);
      }else{
        _spamMssages.add(message);
        print(message.body);
      }
      _messagesCaptured.forEach((element) {print(element.body);});
      setState(() {
        _status = NEW_MSG;
      });

      Future.delayed(Duration(seconds: 5)).then((_) {
        setState(() {
          _status = LISTEN_MSG;
        });
      });
    });
  }

  Future<bool> fetchResponse() async {

    // var url = Uri.https('www.googleapis.com', '/books/v1/vo', {'q': '{http}'});
    //ToDo : Place your API here
    var url = Uri.https('reqres.in','/api/users/1');

    // Await the http get response
    var response = await http.get(url);

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      return true;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw Exception('Failed to load');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Sms Listener'),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CardList()),
                  );
                },
                icon: Icon(Icons.featured_play_list_outlined))
          ],
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 12,
              ),
              Text(_status),
              _messagesCaptured.isEmpty
                  ? Center(
                child: Text('No message found!'),
              )
                  : ListView.separated(
                itemCount: _messagesCaptured.length,
                itemBuilder: (context, index) => ListTile(
                  contentPadding: EdgeInsets.all(4),
                  title: Text(
                    _messagesCaptured[index].address ?? '',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  subtitle: Text(
                    _messagesCaptured[index].body ?? '',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(_dateFormat.format(
                      _messagesCaptured[index].date ?? DateTime.now())),
                ),
                shrinkWrap: true,
                separatorBuilder: (context, _) => SizedBox(
                  height: 8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
