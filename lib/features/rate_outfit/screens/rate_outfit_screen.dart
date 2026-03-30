import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../cubit/rate_outfit_cubit.dart';
import '../cubit/rate_outfit_state.dart';
import '../widgets/rate_button.dart';
import '../widgets/rating_result_card.dart';
import '../widgets/suggestion_list.dart';
import '../widgets/upload_section.dart';

class RateOutfitScreen extends StatelessWidget {
  const RateOutfitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RateOutfitCubit(),
      child: const RateOutfitView(),
    );
  }
}

class RateOutfitView extends StatefulWidget {
  const RateOutfitView({super.key});

  @override
  State<RateOutfitView> createState() => _RateOutfitViewState();
}

class _RateOutfitViewState extends State<RateOutfitView> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Modern dark UI
      appBar: AppBar(
        title: const Text('Rate My Outfit', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocConsumer<RateOutfitCubit, RateOutfitState>(
          listener: (context, state) {
            if (state is RateOutfitSuccess) {
              _animationController.forward(from: 0.0);
            } else if (state is RateOutfitInitial || state is RateOutfitImageSelected) {
              _animationController.reset();
            } else if (state is RateOutfitError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.redAccent),
              );
            }
          },
          builder: (context, state) {
            final showResult = state is RateOutfitSuccess;
            final image = (state is RateOutfitImageSelected)
                ? state.image
                : (state is RateOutfitLoading)
                ? state.image
                : (state is RateOutfitSuccess)
                ? state.image
                : (state is RateOutfitError)
                ? state.image
                : null;
                
            bool isLoading = state is RateOutfitLoading;
        
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UploadSection(
                    image: image,
                    onCameraTap: () => context.read<RateOutfitCubit>().pickImage(ImageSource.camera),
                    onGalleryTap: () => context.read<RateOutfitCubit>().pickImage(ImageSource.gallery),
                    onClear: () => context.read<RateOutfitCubit>().clearImage(),
                  ),
                  const SizedBox(height: 32),
                  
                  if (!showResult) ...[
                    RateButton(
                      isLoading: isLoading,
                      onPressed: image != null
                          ? () => context.read<RateOutfitCubit>().rateOutfit()
                          : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please upload an outfit image first.'),
                                  backgroundColor: Colors.orangeAccent,
                                ),
                              );
                            },
                    ),
                  ],
        
                  if (showResult) ...[
                     FadeTransition(
                       opacity: _fadeAnimation,
                       child: SlideTransition(
                         position: _slideAnimation,
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             RatingResultCard(
                               rating: state.result.rating,
                               feedback: state.result.feedback,
                             ),
                             const SizedBox(height: 32),
                             SuggestionList(
                               suggestions: state.result.suggestions,
                             ),
                             const SizedBox(height: 40),
                             RateButton(
                               label: 'Rate Another Outfit',
                               onPressed: () => context.read<RateOutfitCubit>().clearImage(),
                             ), 
                             const SizedBox(height: 24),
                           ],
                         ),
                       ),
                     ),
                  ]
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
