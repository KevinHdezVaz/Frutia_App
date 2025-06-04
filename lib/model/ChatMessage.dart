import 'package:flutter/material.dart';

class ChatMessage {
  final String text;
  final bool isUserMessage; // true si es del usuario, false si es de la IA
  final DateTime timestamp; // Fecha y hora del mensaje

  ChatMessage({
    required this.text,
    required this.isUserMessage,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  // Método para convertir el mensaje a JSON (útil para almacenamiento futuro)
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUserMessage': isUserMessage,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Método para crear un ChatMessage desde JSON
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'],
      isUserMessage: json['isUserMessage'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class Chat {
  final String id; // Identificador único del chat
  final String title; // Título del chat (ejemplo: "Chat de hoy")
  final List<ChatMessage> messages; // Lista de mensajes del chat
  final DateTime lastMessageTimestamp; // Timestamp del último mensaje
  final String preview; // Vista previa del último mensaje para el historial

  Chat({
    required this.id,
    required this.title,
    required this.messages,
    required this.lastMessageTimestamp,
    required this.preview,
  });

  // Método para convertir el chat a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'messages': messages.map((message) => message.toJson()).toList(),
      'lastMessageTimestamp': lastMessageTimestamp.toIso8601String(),
      'preview': preview,
    };
  }

  // Método para crear un Chat desde JSON
  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      title: json['title'],
      messages: (json['messages'] as List)
          .map((messageJson) => ChatMessage.fromJson(messageJson))
          .toList(),
      lastMessageTimestamp: DateTime.parse(json['lastMessageTimestamp']),
      preview: json['preview'],
    );
  }
}

// Ejemplo de datos simulados para probar el modelo
List<Chat> sampleChats = [
  Chat(
    id: 'chat_1',
    title: 'Chat de hoy',
    messages: [
      ChatMessage(
        text:
            'Hablamos sobre tu plan de comidas. ¿Quieres ajustarlo para mañana?',
        isUserMessage: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
      ChatMessage(
        text: 'Sí, quiero añadir más proteínas.',
        isUserMessage: true,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      ChatMessage(
        text:
            'Perfecto, puedo añadir pechuga de pollo a tu almuerzo. ¿Qué te parece?',
        isUserMessage: false,
        timestamp: DateTime.now(),
      ),
    ],
    lastMessageTimestamp: DateTime.now(),
    preview: 'Hablamos sobre tu plan de comidas...',
  ),
  Chat(
    id: 'chat_2',
    title: 'Ayer',
    messages: [
      ChatMessage(
        text: 'Te di consejos para mejorar tu hidratación. ¿Cómo te fue hoy?',
        isUserMessage: false,
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      ),
      ChatMessage(
        text: 'Bebí 2 litros de agua, pero me olvidé en la tarde.',
        isUserMessage: true,
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
      ),
      ChatMessage(
        text:
            '¡Eso es un buen comienzo! Te puedo enviar recordatorios si quieres.',
        isUserMessage: false,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ],
    lastMessageTimestamp: DateTime.now().subtract(const Duration(days: 1)),
    preview: 'Te di consejos para mejorar tu hidratación...',
  ),
  Chat(
    id: 'chat_3',
    title: 'Lunes',
    messages: [
      ChatMessage(
        text:
            'Revisamos tus calorías quemadas. Quemaste 500 kcal el fin de semana.',
        isUserMessage: false,
        timestamp: DateTime.now().subtract(const Duration(days: 3, hours: 2)),
      ),
      ChatMessage(
        text: '¡Genial! ¿Qué ejercicios hice?',
        isUserMessage: true,
        timestamp: DateTime.now().subtract(const Duration(days: 3, hours: 1)),
      ),
      ChatMessage(
        text: 'Hiciste 30 minutos de cardio y una sesión de pesas.',
        isUserMessage: false,
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ],
    lastMessageTimestamp: DateTime.now().subtract(const Duration(days: 3)),
    preview: 'Revisamos tus calorías quemadas...',
  ),
];
