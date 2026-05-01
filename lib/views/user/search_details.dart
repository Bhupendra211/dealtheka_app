import 'package:dealtheka/widgets/userPacks/search_result.dart';
import 'package:flutter/material.dart';

import '../../constant/AppStyle.dart';

class SearchDetails extends StatefulWidget {
  final String query;

  const SearchDetails({super.key,required this.query});

  @override
  State<SearchDetails> createState() => _SearchDetailsState();
}

class _SearchDetailsState extends State<SearchDetails> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query); // Set initial value
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose when done
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    final screenWidth= MediaQuery.of(context).size.width;
    final screenHeight= MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth*0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.01),
              Text("Search", style: AppStyle.fontMedium),
              SizedBox(height: screenHeight * 0.02),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(width: 1),
                ),
                child: TextField(
                  controller: _controller,
                  onSubmitted: (value) {
                    Navigator.pushNamed(context, '/search-detail');
                  },
                  decoration: InputDecoration(
                    icon: Icon(Icons.search),
                    border: InputBorder.none,
                    hintText: "Search for our services....",
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.025),

              SearchResult(query: _controller.text,)
            ],
          ),
        ),
      )),
    );
  }
}
