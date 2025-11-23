import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../services/database_helper.dart';
import 'add_contact_page.dart';
import 'contact_detail_page.dart';

class ContactsListPage extends StatefulWidget {
  const ContactsListPage({super.key});

  @override
  State<ContactsListPage> createState() => _ContactsListPageState();
}

class _ContactsListPageState extends State<ContactsListPage> {
  final TextEditingController _searchController = TextEditingController();
  final _dbService = DatabaseHelper.instance;

  List<Contact> _allContacts = [];
  List<Contact> _filteredContacts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _searchController.addListener(_filterContacts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  //  Charger les contacts de l'utilisateur connecté 
  Future<void> _loadContacts() async {
    if (_dbService.currentUser == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final contacts = await _dbService.getContacts(_dbService.currentUser!.id!);
      setState(() {
        _allContacts = contacts;
        _filteredContacts = List.from(_allContacts);
        _sortContacts();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors du chargement des contacts'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Trier les contacts par ordre alphabétique
  void _sortContacts() {
    _filteredContacts.sort((a, b) => a.nom.compareTo(b.nom));
  }

  // Filtrer les contacts en fonction de la recherche
  void _filterContacts() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredContacts = List.from(_allContacts);
      } else {
        _filteredContacts = _allContacts.where((contact) {
          return contact.fullName.toLowerCase().contains(query) ||
              contact.telephone.contains(query);
        }).toList();
      }
      _sortContacts();
    });
  }

  // Rafraîchir la liste (Pull-to-refresh)
  Future<void> _refreshContacts() async {
    await _loadContacts();
  }

  //  Basculer le statut favori (avec await)
  Future<void> _toggleFavorite(Contact contact) async {
    final updated = contact.copyWith(isFavorite: !contact.isFavorite);
    await _dbService.updateContact(updated);
    
    setState(() {
      final index = _allContacts.indexWhere((c) => c.id == contact.id);
      if (index != -1) {
        _allContacts[index] = updated;
      }
      _filterContacts();
    });
  }

  //  Déconnexion avec méthode existante
  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              _dbService.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }

  // Navigation vers AddContactPage
  Future<void> _addContact() async {
    if (_dbService.currentUser == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddContactPage(userId: _dbService.currentUser!.id!),
      ),
    );

    if (result == true) {
      _loadContacts();
    }
  }

  //  Navigation vers ContactDetailPage
  Future<void> _openContactDetail(Contact contact) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactDetailPage(contact: contact),
      ),
    );

    if (result != null) {
      _loadContacts();
    }
  }

  // Grouper les contacts par lettre
  Map<String, List<Contact>> _groupContactsByLetter() {
    Map<String, List<Contact>> grouped = {};
    for (var contact in _filteredContacts) {
      String letter = contact.firstLetter;
      if (!grouped.containsKey(letter)) {
        grouped[letter] = [];
      }
      grouped[letter]!.add(contact);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final groupedContacts = _groupContactsByLetter();
    final sortedLetters = groupedContacts.keys.toList()..sort();
    final currentUser = _dbService.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // En-tête avec titre et bouton d'ajout
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Titre "Contacts"
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Contacts',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (currentUser != null)
                        Text(
                          'Bonjour ${currentUser.prenom} !',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  // Bouton déconnexion
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.grey),
                    onPressed: _logout,
                    tooltip: 'Déconnexion',
                  ),
                  // Bouton ajouter avec navigation
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C6FDC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: _addContact,
                    ),
                  ),
                ],
              ),
            ),

            // Barre de recherche
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F2FF),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Rechercher un contact...',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 15,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF7C6FDC),
                      size: 22,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: Colors.grey.shade600,
                              size: 20,
                            ),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Liste des contacts
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredContacts.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _refreshContacts,
                          color: const Color(0xFF7C6FDC),
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: sortedLetters.length,
                            itemBuilder: (context, index) {
                              String letter = sortedLetters[index];
                              List<Contact> contactsForLetter =
                                  groupedContacts[letter]!;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Séparateur alphabétique
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                    ),
                                    child: Text(
                                      letter,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF7C6FDC),
                                      ),
                                    ),
                                  ),
                                  // Liste des contacts pour cette lettre
                                  ...contactsForLetter.map((contact) {
                                    return _buildContactCard(contact);
                                  }),
                                ],
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour afficher un contact
  Widget _buildContactCard(Contact contact) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _openContactDetail(contact), 
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Avatar avec initiales
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF7C6FDC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    contact.initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Nom et prénom
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      contact.telephone,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // Badge favori (étoile)
              IconButton(
                icon: Icon(
                  contact.isFavorite ? Icons.star : Icons.star_border,
                  color: contact.isFavorite
                      ? Colors.amber
                      : Colors.grey.shade400,
                  size: 24,
                ),
                onPressed: () => _toggleFavorite(contact),
              ),

              // Icône flèche
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget pour l'état vide (aucun contact)
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.contacts_outlined, size: 120, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          Text(
            'Aucun contact',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isEmpty
                ? 'Ajoutez votre premier contact'
                : 'Aucun résultat trouvé',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 30),
          if (_searchController.text.isEmpty)
            ElevatedButton.icon(
              onPressed: _addContact, // CORRECTION
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un contact'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C6FDC),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}