import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:developer';

class SocketService {
  late io.Socket socket;

  void connect() {
    socket = io.io(
      'http://10.0.2.2:3000',
      {
        'transports': ['websocket'],
        'autoConnect': true,
      },
    );

    socket.onConnect((_) {
      log('Connected to Backend');
    });

    socket.on('notification', (data) {
      log('Notification Received: $data');
    });
  }
}