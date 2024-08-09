import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DonationWidget extends StatelessWidget {
  final String koFiUrl = 'https://ko-fi.com/elchipaxd';
  final String paypalUrl = 'https://paypal.me/ElChipaXD'; // URL de PayPal

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 28, 213, 255), // Color azul más claro
            Color.fromARGB(255, 2, 167, 254), // Color azul más oscuro
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 2),
            blurRadius: 6.0,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Support me on Ko-fi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          Image.network(
            'https://storage.ko-fi.com/cdn/cup-border.png',
            height: 50,
          ),
          SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () {
              _launchURL(koFiUrl);
            },
            icon: Icon(Icons.favorite, color: Colors.redAccent),
            label: Text('Buy me a coffee ☕'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Support me on PayPal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () {
              _launchURL(paypalUrl);
            },
            icon: Icon(Icons.paypal, color: Colors.blueAccent),
            label: Text('Donate with PayPal 💰'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
