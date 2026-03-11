import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../models/contact.dart';
import '../services/contact_service.dart';
import 'add_contact_screen.dart';
import 'edit_contact_screen.dart';
import 'contact_detail_screen.dart';

class ContactListScreen extends StatefulWidget {
  const ContactListScreen({super.key});

  @override
  State<ContactListScreen> createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  final ContactService _service = ContactService();
  late Future<List<Contact>> _contactsFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _contactsFuture = _service.getContacts();
    });
  }

  void _goToAddContact() async {
    final newContact = await Navigator.push<Contact>(
      context,
      MaterialPageRoute(builder: (context) => const AddContactScreen()),
    );

    if (newContact != null) {
      await _service.addContact(newContact);
      _refresh();
    }
  }

  void _goToEditContact(Contact contact) async {
    final updatedContact = await Navigator.push<Contact>(
      context,
      MaterialPageRoute(
        builder: (context) => EditContactScreen(contact: contact),
      ),
    );

    if (updatedContact != null) {
      await _service.updateContact(updatedContact);
      _refresh();
    }
  }

  void _deleteContact(Contact contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer'),
        content: Text('Supprimer ${contact.name} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              await _service.deleteContact(contact.id);
              Navigator.pop(context);
              _refresh();
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(Contact contact, int index) {
    final initiale = contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?';

    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: const Offset(1, 0), end: Offset.zero),
      duration: Duration(milliseconds: 300 + (index * 80)),
      curve: Curves.easeOut,
      builder: (context, offset, child) {
        return FractionalTranslation(
          translation: offset,
          child: Opacity(
            opacity: (1 - offset.dx).clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: ListTile(
          leading: Hero(
            tag: 'avatar-${contact.id}',
            child: CircleAvatar(
              backgroundColor: Colors.deepPurple,
              child: Text(
                initiale,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          title: Text(
            contact.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(contact.phone),
              if (contact.email.isNotEmpty)
                Text(
                  contact.email,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
            ],
          ),
          isThreeLine: contact.email.isNotEmpty,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ContactDetailScreen(contact: contact),
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _goToEditContact(contact),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteContact(contact),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Contacts'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: FutureBuilder<List<Contact>>(
        future: _contactsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          final contacts = snapshot.data ?? [];

          if (contacts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/animations/empty.json',
                    width: 250,
                    repeat: true,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucun contact pour le moment',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Appuyez sur + pour en ajouter un',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: contacts.length,
            itemBuilder: (context, index) =>
                _buildContactCard(contacts[index], index),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAddContact,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
