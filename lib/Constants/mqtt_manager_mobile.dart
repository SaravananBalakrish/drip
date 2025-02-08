import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:uuid/uuid.dart';

import '../utils/environment.dart';

class MqttManager {
  static MqttManager? _instance;
  dynamic _client;

  factory MqttManager() {
    _instance ??= MqttManager._internal();
    return _instance!;
  }

  MqttManager._internal();

  bool get isConnected => _client?.connectionStatus?.state == MqttConnectionState.connected;
  String? currentSubscribedTopic;

  void initializeMQTTClient() {

    String uniqueId = const Uuid().v4();

    int port = Environment.mqttPort;
    String baseURL = Environment.mqttMobileUrl;

    if (_client == null) {
      _client = MqttServerClient(baseURL, uniqueId);
      _client!.port = port;
      _client!.keepAlivePeriod = 60;
      _client!.onDisconnected = onDisconnected;
      _client!.logging(on: false);
      _client!.websocketProtocols = MqttClientConstants.protocolsSingleDefault;
      _client!.onConnected = onConnected;
      _client!.onSubscribed = onSubscribed;
      final MqttConnectMessage connMess = MqttConnectMessage()
          .withClientIdentifier(uniqueId)
          .withWillTopic('will-topic')
          .withWillMessage('My Will message')
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);
      print('Mosquitto client connecting....');
      _client!.connectionMessage = connMess;
    }
  }

  void connect() async {
    assert(_client != null);
    if (!isConnected) {
      try {
        print('Mosquitto start client connecting....');
        await Future.delayed(Duration.zero);
        await _client!.connect();
        _client?.updates!.listen(_onMessageReceived);
        // if(providerState!.subscribeTopic.isNotEmpty){
        //   subscribeToTopic(providerState!.subscribeTopic);
        //   print('subscribeTopic : ${providerState!.subscribeTopic}');
        // }
        // if(providerState!.publishTopic.isNotEmpty){
        //   publish(providerState!.publishMessage, providerState!.publishTopic);
        // }
        // print('subscribe => ${providerState!.subscribeTopic}');
      } on Exception catch (e, stackTrace) {
        print('Client exception - $e');
        print('StackTrace: $stackTrace');
        disconnect();
      }
    }
  }

  void disconnect() {
    print('Disconnected');
    _client!.disconnect();
  }

  void _onMessageReceived(List<MqttReceivedMessage<MqttMessage?>>? c) async {
    final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;
    final String pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    // print('Received message: $pt');
    // providerState?.updateReceivedPayload(pt,false);
  }

  Future<void> subscribeToTopic(String topic) async {
    if (isConnected) {
      if (currentSubscribedTopic != null && currentSubscribedTopic != topic) {
        _client?.unsubscribe(currentSubscribedTopic!);
        print("Unsubscribed from topic: $currentSubscribedTopic");
      }
      _client?.subscribe(topic, MqttQos.atLeastOnce);
      currentSubscribedTopic = topic;
      print("Subscribed to topic: $topic");
    } else {
      Future.delayed(Duration(seconds: 1), () {
        subscribeToTopic(topic);
      });
    }
  }

  // Future<void> subscribeToTopic(String topic) async {
  //   if (isConnected) {
  //     _client?.subscribe(topic, MqttQos.atLeastOnce);
  //     print("topic Subscribe :::: ${topic}");
  //   } else {
  //     Future.delayed(Duration(seconds: 1), () {
  //       subscribeToTopic(topic);
  //     });
  //   }
  // }

  // void subscribeToTopic(String topic) async{
  //   print('trying to subscribe ${topic}');
  //   print('isConnected : ${isConnected}');
  //   if(isConnected){
  //     _client!.subscribe(topic, MqttQos.atLeastOnce);
  //     _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) async{
  //       final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;
  //       final String pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
  //       providerState?.updateReceivedPayload(pt,false);
  //     });
  //   }else{
  //     Future.delayed(Duration(seconds: 1),(){
  //       subscribeToTopic(topic);
  //     });
  //   }
  // }
  //
  // void unSubscribe({
  //   required String unSubscribeTopic,
  // }){
  //   if(isConnected){
  //     _client!.unsubscribe(unSubscribeTopic);
  //     print('unSubscribeTopic => $unSubscribeTopic');
  //   }else{
  //     Future.delayed(Duration(seconds: 1),(){
  //       unSubscribe(
  //         unSubscribeTopic: unSubscribeTopic,
  //       );
  //     });
  //   }
  // }
  void unSubscribe({
    required String unSubscribeTopic,
    required String subscribeTopic,
    required String publishTopic,
    required String publishMessage
  }){
    if(isConnected){
      // providerState!.editSubscribeTopic(subscribeTopic);
      // providerState!.editPublishTopic(publishTopic);
      // providerState!.editPublishMessage(publishMessage);
      _client!.unsubscribe(currentSubscribedTopic!);
      print("Unsubscribed from topic: $currentSubscribedTopic");
      currentSubscribedTopic = null;
      subscribeToTopic(subscribeTopic);
      // _client!.unsubscribe(unSubscribeTopic);
      print('topic unSubscribe ::::  $unSubscribeTopic');
    }else{
      Future.delayed(Duration(seconds: 1),(){
        unSubscribe(
            unSubscribeTopic: unSubscribeTopic,
            subscribeTopic: subscribeTopic,
            publishTopic: publishTopic,
            publishMessage: publishMessage
        );
      });
    }
  }

  Future<void> publish(String message, String topic) async{
    print('publish topic : $topic');
    print('publish message : $message');
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client!.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
  }

  /// The subscribed callback
  void onSubscribed(String topic) {
    // if(providerState!.publishTopic.isNotEmpty){
    //   print('publish in subscribe function');
    //   publish(providerState!.publishMessage, providerState!.publishTopic);
    // }
    print('Subscription confirmed for topic $topic');
  }

  /// The unsolicited disconnect callback
  void onDisconnected() async{
    await Future.delayed(Duration(seconds: 5,));
    try{
      print('OnDisconnected client callback - Client disconnection');
      if (_client!.connectionStatus!.returnCode == MqttConnectReturnCode.noneSpecified) {
        print('OnDisconnected callback is solicited, this is correct');
      }
      await Future.delayed(Duration.zero);
      connect();
    }catch(e){
      print('Mqtt connectivity issue => ${e.toString()}');
    }

    // Attempt reconnection after a delay
    /*Future.delayed(const Duration(seconds: 03), () {
      //_client!.disconnect();
      //connect();
    });*/
  }

  void onConnected() async{
    assert(isConnected);
    await Future.delayed(Duration.zero);
    print('Mosquitto client connected....');
  }
  Future<void> unsubscribeFromTopic(String topic) async{
    if (topic == null) {
      _client!.unsubscribe(topic);
      print('Unsubscribed from topic: $topic');
    } else {
      print('Not subscribed to topic: $topic');
    }
  }
}
