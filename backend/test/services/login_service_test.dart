import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Import delle classi reali
import 'package:backend/services/login_service.dart';
import 'package:backend/repositories/user_repository.dart';
import 'package:backend/services/jwt_service.dart';

// Import per la generazione dei Mock [cite: 56]
@GenerateNiceMocks([
  MockSpec<UserRepository>(),
  MockSpec<JWTService>(),
])
import 'login_service_test.mocks.dart';

void main() {
  late LoginService loginService;
  late MockUserRepository mockUserRepository;
  late MockJWTService mockJWTService;

  // Funzione helper per simulare l'hash della password (come nel service reale)
  String mockHashPassword(String password) {
    const secret = 'fallback_secret_dev'; // Usiamo il fallback del service
    final bytes = utf8.encode(password + secret);
    return sha256.convert(bytes).toString();
  }

  // Setup Iniziale del Test (Fase 2 della guida) [cite: 65, 78]
  setUp(() {
    mockUserRepository = MockUserRepository();
    mockJWTService = MockJWTService();

    // Iniezione delle dipendenze mockate nel service
    loginService = LoginService(
      userRepository: mockUserRepository,
      jwtService: mockJWTService,
    );
  });

  group('LoginService - Metodo login', () {

    // SCENARIO 1: Login con Email e Password corretta (Utente Verificato)
    test('Deve restituire user e token quando le credenziali sono corrette', () async {
      // 1. ARRANGE [cite: 23]
      const email = 'test@example.com';
      const password = 'passwordCorretta123';
      final passwordHash = mockHashPassword(password);

      // Dati utente simulati dal DB
      final mockUserData = {
        'id': 6,
        'email': email,
        'nome': 'Mario',
        'cognome': 'Rossi',
        'passwordHash': passwordHash,
        'attivo': true,      // Utente verificato
        'isVerified': true,
        'ruolo': 'utente'
      };

      // Stubbing: Quando cerco l'email, restituisci l'utente trovato [cite: 109]
      when(mockUserRepository.findUserByEmail(email))
          .thenAnswer((_) async => mockUserData);

      // Stubbing: Generazione token
      when(mockJWTService.generateToken(any, any))
          .thenReturn('mock_token_jwt');

      // 2. ACT [cite: 24]
      final result = await loginService.login(email: email, password: password);

      // 3. ASSERT [cite: 25]
      expect(result, isNotNull);
      expect(result!['token'], 'mock_token_jwt');
      expect(result['user'].email, email); // Verifica deserializzazione

      // Verifica interazione col Mock [cite: 149]
      verify(mockUserRepository.findUserByEmail(email)).called(1);
      verify(mockJWTService.generateToken(6, 'Utente')).called(1);
    });

    // SCENARIO 2: Password Errata
    test('Deve restituire null se la password è errata', () async {
      // 1. ARRANGE
      const email = 'test@example.com';
      final storedHash = mockHashPassword('password_giusta');

      final mockUserData = {
        'id': 3,
        'email': email,
        'passwordHash': storedHash, // Hash diverso da quello che invieremo
        'attivo': true,
      };

      when(mockUserRepository.findUserByEmail(email))
          .thenAnswer((_) async => mockUserData);

      // 2. ACT
      // Proviamo a loggarci con una password diversa
      final result = await loginService.login(email: email, password: 'password_sbagliata');

      // 3. ASSERT
      expect(result, isNull); // Il service restituisce null se l'hash non matcha
      verifyNever(mockJWTService.generateToken(any, any)); // Token non deve essere generato
    });

    // SCENARIO 3: Utente non verificato (Gestione Errori)
    test('Deve lanciare eccezione USER_NOT_VERIFIED se utente non attivo', () async {
      // 1. ARRANGE
      const email = 'inactive@example.com';
      const password = 'passwordCorretta123';
      final passwordHash = mockHashPassword(password);

      final mockUserData = {
        'id': 2,
        'email': email,
        'passwordHash': passwordHash,
        'attivo': false,      // NON ATTIVO
        'isVerified': false,  // NON VERIFICATO
      };

      when(mockUserRepository.findUserByEmail(email))
          .thenAnswer((_) async => mockUserData);

      // 2. ACT & 3. ASSERT
      // Verifica che venga lanciata l'eccezione specifica [cite: 152]
      expect(
            () async => await loginService.login(email: email, password: password),
        throwsA(predicate((e) => e.toString().contains('USER_NOT_VERIFIED'))),
      );
    });

    // SCENARIO 4: Utente inesistente
    test('Deve restituire null se l\'utente non esiste', () async {
      // 1. ARRANGE
      const email = 'ghost@example.com';

      // Il repository restituisce null
      when(mockUserRepository.findUserByEmail(email))
          .thenAnswer((_) async => null);

      // Fallback sul telefono (simuliamo che fallisca anche quello)
      when(mockUserRepository.findUserByPhone(any))
          .thenAnswer((_) async => null);

      // 2. ACT
      final result = await loginService.login(email: email, password: 'any');

      // 3. ASSERT
      expect(result, isNull);
    });

    // SCENARIO 5: Input Mancante
    test('Deve lanciare ArgumentError se email e telefono sono nulli', () async {
      // 2. ACT & 3. ASSERT
      expect(
            () async => await loginService.login(password: 'password'),
        throwsArgumentError,
      );
    });

    // SCENARIO 6: Password Vuota
    test('Deve restituire null se la password fornita è una stringa vuota', () async {
      // 1. ARRANGE
      const email = 'test@example.com';
      // Nel DB c'è una password valida salvata
      final storedHash = mockHashPassword('password_segreta_vera');

      final mockUserData = {
        'id': 1,
        'email': email,
        'passwordHash': storedHash,
        'attivo': true,
        'isVerified': true,
      };

      when(mockUserRepository.findUserByEmail(email))
          .thenAnswer((_) async => mockUserData);

      // 2. ACT
      // Proviamo a fare login passando una stringa vuota
      final result = await loginService.login(email: email, password: '');

      // 3. ASSERT
      // Ci aspettiamo che il login fallisca (ritorni null) perché
      // l'hash della stringa vuota non corrisponderà mai all'hash della password vera.
      expect(result, isNull);

      // Verifica di sicurezza: Il token NON deve essere mai stato generato
      verifyNever(mockJWTService.generateToken(any, any));
    });
  });
}