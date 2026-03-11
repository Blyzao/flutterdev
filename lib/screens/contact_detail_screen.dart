import 'package:flutter/material.dart';
import '../models/contact.dart';

class ContactDetailScreen extends StatelessWidget {
  final Contact contact;

  const ContactDetailScreen({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    final initiale = contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?';

    return Scaffold(
      appBar: AppBar(
        title: Text(contact.name),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          Center(
            child: Hero(
              tag: 'avatar-${contact.id}',
              child: CircleAvatar(
                backgroundColor: Colors.deepPurple,
                radius: 60,
                child: Text(
                  initiale,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.deepPurple),
            title: const Text('Nom'),
            subtitle: Text(contact.name),
          ),
          ListTile(
            leading: const Icon(Icons.phone, color: Colors.deepPurple),
            title: const Text('Téléphone'),
            subtitle: Text(contact.phone),
          ),
          if (contact.email.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.email, color: Colors.deepPurple),
              title: const Text('Email'),
              subtitle: Text(contact.email),
            ),
        ],
      ),
    );
  }
}
