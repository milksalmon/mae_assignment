import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboard();
}

class _AdminDashboard extends State<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset('assets/logo.png', height: 50),
          onPressed: () {
            Navigator.pushNamed(context, '/adminDashboard');
          },
        ),
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              // PUSH REPLACEMENT NAMED = DONT ALLOW USER TO GO BACK TO PREVIOUS SCREEN
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      // BELOW IS THE CODE FOR UI IN THE BODY OF THE PHONE
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // BUTTON ONE
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(255, 227, 227, 1.0),
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 50),
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/organiserRegister');
              },
              child: Text(
                'Event Organizer Registration',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            // TO INSERT SECOND BUTTON
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(255, 227, 227, 1.0),
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 50),
              ),
              onPressed: () {
                print('Button 2 Pressed');
              },
              child: Text(
                'Organizer Account Management',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            // INSERTING BUTTON 3
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(255, 227, 227, 1.0),
                //foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 50),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/manageFeedback');
              },
              child: Text(
                'Manage Feedback',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//         child: Column(
//           mainAxisSize: MainAxisSize.spaceEvenly,
//           children: [
//             SizedBox(
//               width: double.infinity,
//               height: 50,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.pink,
//                   shape: BeveledRectangleBorder(
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                 ),
//                 onPressed: () {
//                   print('Button Pressed');
//                 },
//                 child: Text(
//                   'Event Organizer Registration',
//                   style: GoogleFonts.montserrat(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
