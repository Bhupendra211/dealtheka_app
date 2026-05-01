import 'package:dealtheka/SplashScreen.dart';
import 'package:dealtheka/views/admin/AddService.dart';
import 'package:dealtheka/views/admin/dashboard.dart';
import 'package:dealtheka/views/admin/tables/serviceProviders.dart';
import 'package:dealtheka/views/admin/tables/service_table.dart';
import 'package:dealtheka/views/admin/tables/user_table.dart';
import 'package:dealtheka/views/auth/login_screen.dart';
import 'package:dealtheka/views/auth/select_user_role.dart';
import 'package:dealtheka/views/auth/uploadDocument.dart';
import 'package:dealtheka/views/common/faq.dart';
import 'package:dealtheka/views/common/history.dart';
import 'package:dealtheka/views/common/profile.dart';
import 'package:dealtheka/views/common/profile_details.dart';
import 'package:dealtheka/views/serviceProvider/Service/create_service.dart';
import 'package:dealtheka/views/serviceProvider/Service/select_category.dart';
import 'package:dealtheka/views/serviceProvider/my_services.dart';
import 'package:dealtheka/views/serviceProvider/service_provider_dashboard.dart';
import 'package:dealtheka/views/user/search_details.dart';
import 'package:dealtheka/views/user/search_page.dart';
import 'package:dealtheka/views/user/userDashboard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'views/auth/register_screen.dart';
import 'firebase_options.dart'; // generated after running the Firebase CLI

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.grey[300],  // Light gray color
    statusBarIconBrightness: Brightness.dark,  // Dark icons for better visibility
  ));
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        // home: const SplashScreen(),
        initialRoute: '/register',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),

          // Auth
          '/select-role': (context) => const RoleSelectionPage(),
          '/upload-documents': (context) => const UploadDocumentsPage(),

          // user Routes
          '/user-dashboard': (context) => const UserDashboard(),
          '/search-page':(context)=>const SearchPage(),
          // '/search-detail/:search':(context)=>const SearchDetails(),



          // Common Routes
          '/profile':(context)=>const ProfileScreen(),
          '/profile-details':(context)=>const ProfileDetails(),
          '/history':(context)=>const History_Screen(),
          '/settings':(context)=>const History_Screen(),
          '/my-service':(context)=>const MyServicesPage(),
          '/faq':(context)=>const FaqWebViewScreen(),

          // Service Provider Routes
          '/service-provider-dashboard':(context)=>const ServiceProviderDashboard(),
          '/select-category':(context)=>const SelectCategory(),


          // Admin Routes
          '/admin-dashboard': (context) => const AdminDashboard(),
          '/add-services':(context)=> const AddService(),
          '/users-table': (context) => const UserTablePage(),
          '/serviceProviders-table': (context) => const ServiceProviderTable(),
          '/services-table': (context) => const ServiceTableView(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/search-detail') {
            final query = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => SearchDetails(query: query),
            );
          }
          return null;
        }

    );
  }
}

