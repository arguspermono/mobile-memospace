import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  /// Prompts the user to pick an image (camera or gallery) and extracts text from it.
  /// Returns the recognized text or null if no text was found/user cancelled.
  static Future<String?> scanFromImage(BuildContext context, ImagePicker picker) async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return null;

    try {
      final XFile? image = await picker.pickImage(source: source);
      if (image == null) return null;

      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

      try {
        final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
        
        // Improve formatting by iterating through blocks and lines,
        // reducing arbitrary newlines inserted by ML kit.
        final StringBuffer buffer = StringBuffer();
        for (final block in recognizedText.blocks) {
          for (final line in block.lines) {
            final text = line.text.trim();
            if (text.isEmpty) continue;
            
            buffer.write(text);
            
            // If line doesn't end with punctuation, it probably continues to the next line
            if (text.endsWith('.') || text.endsWith('!') || text.endsWith('?')) {
              buffer.write('\n');
            } else {
              buffer.write(' ');
            }
          }
          buffer.write('\n\n'); // Add spacing between blocks
        }
        
        final String extractedText = buffer.toString().trim();
        
        if (extractedText.trim().isEmpty) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No text found in the image.')),
            );
          }
          return null;
        }
        return extractedText;
      } finally {
        textRecognizer.close();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to process image: $e')),
        );
      }
      return null;
    }
  }
}
