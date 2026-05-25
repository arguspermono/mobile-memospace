import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';

void main() {
  quill.QuillController c = quill.QuillController.basic();
  
  Widget toolbar = quill.QuillSimpleToolbar(
    controller: c,
    config: quill.QuillSimpleToolbarConfig(
      embedButtons: FlutterQuillEmbeds.toolbarButtons(),
    ),
  );

  Widget editor = quill.QuillEditor.basic(
    controller: c,
    config: quill.QuillEditorConfig(
      embedBuilders: FlutterQuillEmbeds.editorBuilders(),
    ),
  );
}
