import '../models/chat_message.dart';
import 'mock_people.dart';

final DateTime _now = DateTime.now();

final List<ChatMessage> mockMessages = [
  ChatMessage(
    id: 'c1',
    senderId: sophiaId,
    type: MessageType.text,
    text: 'Good morning love ❤️',
    sentAt: _now.subtract(const Duration(hours: 5, minutes: 10)),
  ),
  ChatMessage(
    id: 'c2',
    senderId: alexId,
    type: MessageType.text,
    text: 'Morning! Slept so well, missed you though',
    sentAt: _now.subtract(const Duration(hours: 5, minutes: 5)),
  ),
  ChatMessage(
    id: 'c3',
    senderId: sophiaId,
    type: MessageType.song,
    songId: 's1',
    text: 'I heard this and immediately thought of you ❤️',
    sentAt: _now.subtract(const Duration(hours: 3, minutes: 40)),
    reactions: ['❤️'],
  ),
  ChatMessage(
    id: 'c4',
    senderId: alexId,
    type: MessageType.text,
    text: 'This is beautiful 😍',
    sentAt: _now.subtract(const Duration(hours: 3, minutes: 35)),
  ),
  ChatMessage(
    id: 'c5',
    senderId: sophiaId,
    type: MessageType.photo,
    photoSeed: 4,
    text: null,
    sentAt: _now.subtract(const Duration(hours: 2, minutes: 50)),
  ),
  ChatMessage(
    id: 'c6',
    senderId: alexId,
    type: MessageType.text,
    text: 'That sunset though 😍 wish I was there',
    sentAt: _now.subtract(const Duration(hours: 2, minutes: 48)),
  ),
  ChatMessage(
    id: 'c7',
    senderId: sophiaId,
    type: MessageType.memory,
    memoryId: 'm2',
    text: 'Remember this?',
    sentAt: _now.subtract(const Duration(hours: 1, minutes: 20)),
  ),
  ChatMessage(
    id: 'c8',
    senderId: alexId,
    type: MessageType.text,
    text: 'Of course, best trip ever',
    sentAt: _now.subtract(const Duration(hours: 1, minutes: 15)),
  ),
  ChatMessage(
    id: 'c9',
    senderId: sophiaId,
    type: MessageType.voice,
    voiceDuration: const Duration(seconds: 18),
    sentAt: _now.subtract(const Duration(minutes: 40)),
  ),
  ChatMessage(
    id: 'c10',
    senderId: sophiaId,
    type: MessageType.text,
    text: 'Can\'t wait to see you tonight',
    sentAt: _now.subtract(const Duration(minutes: 38)),
  ),
];
