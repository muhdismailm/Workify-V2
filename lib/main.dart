
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:login_1/src/core/services/auth_service.dart';
import 'package:login_1/src/core/services/database_service.dart';
import 'package:login_1/src/client/features/auth/viewmodels/client_auth_viewmodel.dart';
import 'package:login_1/src/client/features/home/viewmodels/client_home_viewmodel.dart';
import 'package:login_1/src/client/features/requests/viewmodels/client_requests_viewmodel.dart';
import 'package:login_1/src/client/features/profile/viewmodels/client_profile_viewmodel.dart';
import 'package:login_1/src/worker/features/auth/viewmodels/worker_auth_viewmodel.dart';
import 'package:login_1/src/worker/features/home/viewmodels/worker_home_viewmodel.dart';
import 'package:login_1/src/worker/features/requests/viewmodels/worker_requests_viewmodel.dart';
import 'package:login_1/src/worker/features/profile/viewmodels/worker_profile_viewmodel.dart';
import 'package:login_1/src/client/screens/login/c_login.dart';
import 'package:login_1/src/worker/features/screens/login/w_login.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<DatabaseService>(create: (_) => DatabaseService()),
        ChangeNotifierProxyProvider<AuthService, ClientAuthViewModel>(
          create: (context) => ClientAuthViewModel(context.read<AuthService>()),
          update: (context, auth, previous) => ClientAuthViewModel(auth),
        ),
        ChangeNotifierProxyProvider<DatabaseService, ClientHomeViewModel>(
          create: (context) => ClientHomeViewModel(context.read<DatabaseService>()),
          update: (context, db, previous) => previous ?? ClientHomeViewModel(db),
        ),
        ChangeNotifierProxyProvider<DatabaseService, ClientRequestsViewModel>(
          create: (context) => ClientRequestsViewModel(context.read<DatabaseService>()),
          update: (context, db, previous) => previous ?? ClientRequestsViewModel(db),
        ),
        ChangeNotifierProxyProvider<DatabaseService, ClientProfileViewModel>(
          create: (context) => ClientProfileViewModel(context.read<DatabaseService>()),
          update: (context, db, previous) => previous ?? ClientProfileViewModel(db),
        ),
        ChangeNotifierProxyProvider<AuthService, WorkerAuthViewModel>(
          create: (context) => WorkerAuthViewModel(context.read<AuthService>()),
          update: (context, auth, previous) => previous ?? WorkerAuthViewModel(auth),
        ),
        ChangeNotifierProxyProvider<DatabaseService, WorkerHomeViewModel>(
          create: (context) => WorkerHomeViewModel(context.read<DatabaseService>()),
          update: (context, db, previous) => previous ?? WorkerHomeViewModel(db),
        ),
        ChangeNotifierProxyProvider<DatabaseService, WorkerRequestsViewModel>(
          create: (context) => WorkerRequestsViewModel(context.read<DatabaseService>()),
          update: (context, db, previous) => previous ?? WorkerRequestsViewModel(db),
        ),
        ChangeNotifierProxyProvider<DatabaseService, WorkerProfileViewModel>(
          create: (context) => WorkerProfileViewModel(context.read<DatabaseService>()),
          update: (context, db, previous) => previous ?? WorkerProfileViewModel(db),
        ),
      ],
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "WORKIFY",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: const Icon(Icons.work_rounded),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Image.asset('assets/images/worker.png'), // Add your logo here
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome to workify!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Connecting the workers.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return const CLogin();
                  }),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Background color
                foregroundColor: Colors.white, // Text color
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: const Text('CLIENT'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return WLogin();
                  }),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber, // Background color
                foregroundColor: Colors.white, // Text color
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: const Text('WORKER'),
            ),
          ],
        ),
      ),
    );
  }
}

class AppHome extends StatelessWidget {
  const AppHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue, 
        title: const Text(
          "workify",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: const Icon(Icons.work_rounded),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20.0),
       
      ),
    );
  }
}