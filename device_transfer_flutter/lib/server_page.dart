import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class ServerPage extends StatefulWidget {
  const ServerPage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<ServerPage> createState() => _ServerPageState();
}

class _ServerPageState extends State<ServerPage> {
  Future<void> start() async {
    final server = await ServerSocket.bind(InternetAddress.anyIPv4, 4567);

    // listen for clent connections to the server
    server.listen((client) {
      handleConnection(client);
    });
  }

  Future printIps() async {
    for (var interface in await NetworkInterface.list()) {
      print('== Interface: ${interface.name} ==');
      for (var addr in interface.addresses) {
        print(
            '${addr.address} ${addr.host} ${addr.isLoopback} ${addr.rawAddress} ${addr.type.name}');
      }
    }
  }

  void handleConnection(Socket client) {
    print('Connection from'
        ' ${client.remoteAddress.address}:${client.remotePort}');

    client.listen(
      (Uint8List data) async {
        await Future.delayed(Duration(seconds: 1));
        final message = String.fromCharCodes(data);
        if (message == 'Knock, knock.') {
          client.write('Who is there?');
        } else if (message.length < 10) {
          client.write('$message who?');
        } else {
          client.write('reciver $message');
        }
        print('reciver $message');
      },

      // handle errors
      onError: (error) {
        print(error);
        client.close();
      },

      // handle the client closing the connection
      onDone: () {
        print('Client left');
        client.close();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
                child: const Text('Open'),
                onPressed: () {
                  printIps();
                  start();
                })
          ],
        ),
      ),
    );
  }
}
