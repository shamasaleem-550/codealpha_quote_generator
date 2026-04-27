import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'quote_data.dart';

void main() => runApp(const ProQuoteApp());

class ProQuoteApp extends StatelessWidget {
  const ProQuoteApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Georgia',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
      ),
      home: const WelcomeScreen(),
    );
  }
}

// --- 1. WELCOME SCREEN ---
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/welcome_bg.png', fit: BoxFit.cover)),
          Container(color: Colors.white.withOpacity(0.4)),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("CODEALPHA SHOWCASE", style: TextStyle(letterSpacing: 6, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                const Text("MINIMAL\nWISDOM", textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 65, fontWeight: FontWeight.w100, height: 0.9)),
                const SizedBox(height: 50),
                OutlinedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MainDashboard())),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black, width: 1),
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 22),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                  child: const Text("EXPLORE NOW", style: TextStyle(color: Colors.black, letterSpacing: 2)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- 2. MAIN DASHBOARD ---
class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});
  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  String selectedCategory = 'Philosophy';
  late Map<String, String> currentQuote;
  int _selectedIndex = 0;

  final Map<String, String> categoryImages = {
    'Philosophy': 'assets/main_bg.png',
    'Romance': 'assets/welcome_bg.png',
    'Success': 'assets/main_bg.png',
  };

  @override
  void initState() {
    super.initState();
    _getNewQuote();
  }

  void _getNewQuote() {
    setState(() {
      final list = QuoteLibrary.categories[selectedCategory]!;
      currentQuote = list[Random().nextInt(list.length)];
    });
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: "${currentQuote['text']} — ${currentQuote['author']}"));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Quote copied to clipboard"),
        behavior: SnackBarBehavior.floating,
        width: 250,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // SIDEBAR WITH COPY ACTION ONLY (NO SHARE)
          NavigationRail(
            backgroundColor: Colors.white.withOpacity(0.9),
            selectedIndex: _selectedIndex,
            labelType: NavigationRailLabelType.all,
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 25.0),
                  child: IconButton(
                    icon: const Icon(Icons.content_copy_rounded, color: Colors.black54),
                    onPressed: _copyToClipboard,
                    tooltip: "Copy Current Quote",
                  ),
                ),
              ),
            ),
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
                selectedCategory = QuoteLibrary.categories.keys.elementAt(index);
                _getNewQuote();
              });
            },
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.psychology_outlined), label: Text('Logic')),
              NavigationRailDestination(icon: Icon(Icons.favorite_border), label: Text('Romance')),
              NavigationRailDestination(icon: Icon(Icons.auto_graph_outlined), label: Text('Success')),
            ],
          ),

          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 800),
                    child: Image.asset(categoryImages[selectedCategory]!, key: ValueKey(selectedCategory), fit: BoxFit.cover),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // CLEAN QUOTE CARD
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: Container(
                          key: ValueKey(currentQuote['text']),
                          width: 480,
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 80),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 40)],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(currentQuote['text']!.toUpperCase(), textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 20, letterSpacing: 2.0, height: 1.6, fontWeight: FontWeight.w300)),
                              const SizedBox(height: 35),
                              Text("— ${currentQuote['author']}", style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.blueGrey, fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 60),
                      TextButton(
                        onPressed: _getNewQuote,
                        child: const Text("NEXT INSIGHT", style: TextStyle(color: Colors.black87, letterSpacing: 3, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}