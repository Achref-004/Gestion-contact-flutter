import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';
import '../models/contact.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  
  // Noms des boxes Hive
  static const String _usersBoxName = 'users';
  static const String _contactsBoxName = 'contacts';
  
  // Session utilisateur
  User? _currentUser;
  User? get currentUser => _currentUser;

  DatabaseHelper._init();

  // Initialiser Hive
  Future<void> initDB() async {
    await Hive.initFlutter();
    
    // Enregistrer les adaptateurs
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ContactAdapter());
    }
    
    // Ouvrir les boxes
    await Hive.openBox<User>(_usersBoxName);
    await Hive.openBox<Contact>(_contactsBoxName);
    
    // Insérer des données de test si les boxes sont vides
    await _insertTestDataIfNeeded();
  }

  Future<void> _insertTestDataIfNeeded() async {
    final usersBox = Hive.box<User>(_usersBoxName);
    
    if (usersBox.isEmpty) {
      // Utilisateurs de test
      final user1 = User(
        id: 1,
        nom: 'Dupont',
        prenom: 'Jean',
        email: 'jean@email.com',
        telephone: '12345678',
        password: '123456',
        createdAt: DateTime.now(),
      );
      
      final user2 = User(
        id: 2,
        nom: 'Martin',
        prenom: 'Marie',
        email: 'marie@email.com',
        telephone: '23456789',
        password: 'password',
        createdAt: DateTime.now(),
      );
      
      await usersBox.put(user1.email, user1);
      await usersBox.put(user2.email, user2);
      
      // Contacts pour user 1
      final contactsBox = Hive.box<Contact>(_contactsBoxName);
      
      final contact1 = Contact(
        id: 1,
        userId: 1,
        nom: 'Dupont',
        prenom: 'Marie',
        telephone: '12345678',
        email: 'marie@email.com',
        isFavorite: true,
        createdAt: DateTime.now(),
      );
      
      final contact2 = Contact(
        id: 2,
        userId: 1,
        nom: 'Martin',
        prenom: 'Pierre',
        telephone: '23456789',
        email: 'pierre@email.com',
        isFavorite: false,
        createdAt: DateTime.now(),
      );
      
      final contact3 = Contact(
        id: 3,
        userId: 1,
        nom: 'Bernard',
        prenom: 'Sophie',
        telephone: '34567890',
        isFavorite: true,
        createdAt: DateTime.now(),
      );
      
      await contactsBox.put('1_1', contact1);
      await contactsBox.put('1_2', contact2);
      await contactsBox.put('1_3', contact3);
    }
  }

  // ============ GESTION SESSION ============

  Future<User?> loginAsync(String email, String password) async {
    _currentUser = await getUser(email, password);
    return _currentUser;
  }

  Future<User?> registerAsync({
    required String nom,
    required String prenom,
    required String email,
    required String telephone,
    required String password,
  }) async {
    final usersBox = Hive.box<User>(_usersBoxName);
    
    // Générer un nouvel ID
    int newId = usersBox.length + 1;
    
    final user = User(
      id: newId,
      nom: nom,
      prenom: prenom,
      email: email,
      telephone: telephone,
      password: password,
      createdAt: DateTime.now(),
    );

    await usersBox.put(email, user);
    _currentUser = user;
    return _currentUser;
  }

  void logout() {
    _currentUser = null;
  }

  Future<bool> emailExistsAsync(String email) async {
    final user = await getUserByEmail(email);
    return user != null;
  }

  // ============ OPERATIONS USERS ============

  Future<User?> getUser(String email, String password) async {
    final usersBox = Hive.box<User>(_usersBoxName);
    final user = usersBox.get(email);
    
    if (user != null && user.password == password) {
      return user;
    }
    return null;
  }

  Future<User?> getUserByEmail(String email) async {
    final usersBox = Hive.box<User>(_usersBoxName);
    return usersBox.get(email);
  }

  // ============ OPERATIONS CONTACTS ============

  Future<int> createContact(Contact contact) async {
    final contactsBox = Hive.box<Contact>(_contactsBoxName);
    
    // Générer un nouvel ID
    int newId = _getNextContactId(contact.userId);
    
    final newContact = contact.copyWith(
      id: newId,
      createdAt: DateTime.now(),
    );
    
    // Clé: userId_contactId
    final key = '${contact.userId}_$newId';
    await contactsBox.put(key, newContact);
    
    return newId;
  }

  int _getNextContactId(int userId) {
    final contactsBox = Hive.box<Contact>(_contactsBoxName);
    int maxId = 0;
    
    for (var contact in contactsBox.values) {
      if (contact.userId == userId && contact.id != null && contact.id! > maxId) {
        maxId = contact.id!;
      }
    }
    
    return maxId + 1;
  }

  Future<List<Contact>> getContacts(int userId) async {
    final contactsBox = Hive.box<Contact>(_contactsBoxName);
    
    final contacts = contactsBox.values
        .where((contact) => contact.userId == userId)
        .toList();
    
    // Trier par nom
    contacts.sort((a, b) => a.nom.compareTo(b.nom));
    
    return contacts;
  }

  Future<Contact?> getContact(int id) async {
    final contactsBox = Hive.box<Contact>(_contactsBoxName);
    
    for (var contact in contactsBox.values) {
      if (contact.id == id) {
        return contact;
      }
    }
    
    return null;
  }

  Future<int> updateContact(Contact contact) async {
    final contactsBox = Hive.box<Contact>(_contactsBoxName);
    final key = '${contact.userId}_${contact.id}';
    
    await contactsBox.put(key, contact);
    return 1;
  }

  Future<int> deleteContact(int id) async {
    final contactsBox = Hive.box<Contact>(_contactsBoxName);
    
    // Trouver la clé du contact
    String? keyToDelete;
    for (var entry in contactsBox.toMap().entries) {
      if (entry.value.id == id) {
        keyToDelete = entry.key as String;
        break;
      }
    }
    
    if (keyToDelete != null) {
      await contactsBox.delete(keyToDelete);
      return 1;
    }
    
    return 0;
  }

  Future<List<Contact>> searchContacts(int userId, String query) async {
    final contactsBox = Hive.box<Contact>(_contactsBoxName);
    final lowerQuery = query.toLowerCase();
    
    final contacts = contactsBox.values
        .where((contact) =>
            contact.userId == userId &&
            (contact.nom.toLowerCase().contains(lowerQuery) ||
             contact.prenom.toLowerCase().contains(lowerQuery) ||
             contact.telephone.contains(query)))
        .toList();
    
    return contacts;
  }

  Future<bool> phoneExists(int userId, String phone, {int? excludeId}) async {
    final contactsBox = Hive.box<Contact>(_contactsBoxName);
    
    for (var contact in contactsBox.values) {
      if (contact.userId == userId &&
          contact.telephone == phone &&
          (excludeId == null || contact.id != excludeId)) {
        return true;
      }
    }
    
    return false;
  }

  Future<void> close() async {
    await Hive.close();
  }
}