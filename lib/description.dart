import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_generative_language_api/google_generative_language_api.dart';

class DescriptionPage extends StatefulWidget {
  final String species;
  final File file;
  const DescriptionPage({super.key, required this.species, required this.file});

  @override
  State<DescriptionPage> createState() => _DescriptionPageState();
}

class _DescriptionPageState extends State<DescriptionPage> {
  String description = '';

  generateDescription() async {
    String apiKey = '';
    String textModel = 'models/text-bison-001';
    String promptString = 'Define butterfly ${widget.species} in details';
    GenerateTextRequest textRequest = GenerateTextRequest(
      prompt: TextPrompt(text: promptString),
      temperature: 0.7, // Control the randomness of text generation
      candidateCount: 1, // Number of generated text candidates
      topK: 40, // Consider the top K probable tokens
      topP: 0.95, // Nucleus sampling parameter
      maxOutputTokens: 1024, // Maximum number of output tokens
      stopSequences: [], // Sequences at which to stop generation
      safetySettings: const [
        // Define safety settings to filter out harmful content
        SafetySetting(
            category: HarmCategory.derogatory,
            threshold: HarmBlockThreshold.lowAndAbove),
        SafetySetting(
            category: HarmCategory.toxicity,
            threshold: HarmBlockThreshold.lowAndAbove),
        SafetySetting(
            category: HarmCategory.violence,
            threshold: HarmBlockThreshold.mediumAndAbove),
        SafetySetting(
            category: HarmCategory.sexual,
            threshold: HarmBlockThreshold.mediumAndAbove),
        SafetySetting(
            category: HarmCategory.medical,
            threshold: HarmBlockThreshold.mediumAndAbove),
        SafetySetting(
            category: HarmCategory.dangerous,
            threshold: HarmBlockThreshold.mediumAndAbove),
      ],
    );

    // Call the PaLM API to generate text
    final GeneratedText response = await GenerativeLanguageAPI.generateText(
      modelName: textModel,
      request: textRequest,
      apiKey: apiKey,
    );

    // Extract and return the generated text
    if (response.candidates.isNotEmpty) {
      TextCompletion candidate = response.candidates.first;
      setState(() {
        description = candidate.output;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    generateDescription();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.species),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: Container(
        color: Colors.black87,
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: Image.file(
                File(widget.file.path),
                width: 224,
                height: 224,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 25,
                      color: Colors.white,
                    ),
                  ),
                  const Divider(
                    color: Colors.white,
                    thickness: 2,
                  ),
                  Text(
                    description,
                    textAlign: TextAlign.justify,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
