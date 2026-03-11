import 'package:flutter/material.dart';
import '../widgets/home_header.dart';
import '../widgets/generate_outfit_card.dart';
import '../widgets/quick_actions_section.dart';
import '../widgets/saved_outfits_section.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              HomeHeader(),
              SizedBox(height: 32.0),
              GenerateOutfitCard(),
              SizedBox(height: 32.0),
              QuickActionsSection(),
              SizedBox(height: 32.0),
              SavedOutfitsSection(),
            ],
          ),
        ),
      ),
    );
  }
}
