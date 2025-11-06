import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView(
        children: [
          SizedBox(height: 20),
          Image.asset(
            'assets/kld.png',
            height: 100,
            width: 100,
          ),
          SizedBox(height: 20),
          Text("At Kolehiyo ng Lungsod ng Dasmarinas (KLD), we're building tools to make learning easier for nursing students. Our Augmented Reality (AR) Learning Tool was created by a team of IS students in partnership with the Nursing Department. It tackles issues like limited lab equipment, student fears about handling tools, and the need for more hands-on practice.", style: TextStyle(fontSize: 10)),
          SizedBox(height: 20),
          Text("The app uses QR codes to show 3D models of lab tools on phones-no internet required. Students can zoom in, rotate, and learn how each tool works through simple visuals and descriptions. Made with user-friendly tech, it helps students connect classroom lessons to real-world skills. Teachers and students tested the app to ensure it's helpful and easy to use.", style: TextStyle(fontSize: 10)),
          SizedBox(height: 20),
          Text("This project reflects KLD's mission to use technology for better education. We aim to prepare future nurses with confidence and practical knowledge.", style: TextStyle(fontSize: 10)),
          SizedBox(height: 20),
        ]
      )
    );
  }
}