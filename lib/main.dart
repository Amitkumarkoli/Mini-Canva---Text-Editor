import 'package:flutter/material.dart';
import 'models/text_element.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text Canvas App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const CanvasScreen(),
    );
  }
}

class CanvasScreen extends StatefulWidget {
  const CanvasScreen({super.key});

  @override
  State<CanvasScreen> createState() => _CanvasScreenState();
}

class _CanvasScreenState extends State<CanvasScreen> {
  List<TextElement> texts = [];
  int? selectedIndex;
  final List<List<TextElement>> _undoStack = [];
  final List<List<TextElement>> _redoStack = [];

  @override
  void initState() {
    super.initState();
    // Optional: Add one sample text on start
    // _addText();
  }

  // Save current state to undo stack
  void _saveToUndo() {
    _undoStack.add(texts.map((e) => TextElement.copy(e)).toList());
    _redoStack.clear();
  }

  // Undo last action
  void _undo() {
    if (_undoStack.isEmpty) return;
    setState(() {
      _redoStack.add(texts.map((e) => TextElement.copy(e)).toList());
      texts = _undoStack.removeLast();
      selectedIndex = null;
    });
  }

  // Redo last undone action
  void _redo() {
    if (_redoStack.isEmpty) return;
    setState(() {
      _undoStack.add(texts.map((e) => TextElement.copy(e)).toList());
      texts = _redoStack.removeLast();
      selectedIndex = null;
    });
  }

  // Add new text
  void _addText() {
    _saveToUndo();
    setState(() {
      texts.add(TextElement(
        x: 50 + (texts.length * 30) % 200,
        y: 100 + (texts.length * 40) % 300,
      ));
      selectedIndex = texts.length - 1;
    });
  }

  // Select text
  void _select(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  // Deselect all
  void _deselect() {
    setState(() {
      selectedIndex = null;
    });
  }

  // Move selected text
  void _moveText(int index, DragUpdateDetails details) {
    if (index != selectedIndex) return;
    setState(() {
      final elem = texts[index];
      elem.x += details.delta.dx;
      elem.y += details.delta.dy;

      // Optional: Keep within bounds
      elem.x = elem.x.clamp(0.0, MediaQuery.of(context).size.width - 100);
      elem.y = elem.y.clamp(0.0, MediaQuery.of(context).size.height - 200);
    });
  }

  // Toggle bold
  void _toggleBold() {
    _saveToUndo();
    setState(() {
      final elem = texts[selectedIndex!];
      elem.fontWeight = elem.fontWeight == FontWeight.bold
          ? FontWeight.normal
          : FontWeight.bold;
    });
  }

  // Toggle italic
  void _toggleItalic() {
    _saveToUndo();
    setState(() {
      final elem = texts[selectedIndex!];
      elem.fontStyle = elem.fontStyle == FontStyle.italic
          ? FontStyle.normal
          : FontStyle.italic;
    });
  }

  // Delete selected text
  void _deleteSelected() {
    if (selectedIndex == null) return;
    _saveToUndo();
    setState(() {
      texts.removeAt(selectedIndex!);
      selectedIndex = null;
    });
  }

  // Editor UI for selected text
  Widget _buildEditor() {
    if (selectedIndex == null) return const SizedBox.shrink();
    final elem = texts[selectedIndex!];

    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Edit Text
          TextField(
            decoration: const InputDecoration(
              labelText: 'Edit Text',
              border: OutlineInputBorder(),
            ),
            controller: TextEditingController(text: elem.text)
              ..selection = TextSelection.fromPosition(
                  TextPosition(offset: elem.text.length)),
            onChanged: (value) {
              setState(() {
                elem.text = value;
              });
            },
          ),
          const SizedBox(height: 12),

          // Font Size Slider
          Row(
            children: [
              const Text('Size: '),
              Expanded(
                child: Slider(
                  value: elem.fontSize,
                  min: 10,
                  max: 60,
                  divisions: 50,
                  label: elem.fontSize.round().toString(),
                  onChanged: (value) {
                    setState(() {
                      elem.fontSize = value;
                    });
                  },
                  onChangeEnd: (_) => _saveToUndo(),
                ),
              ),
              Text('${elem.fontSize.round()}'),
            ],
          ),
          const SizedBox(height: 8),

          // Style Buttons
          Wrap(
            spacing: 8,
            children: [
              ElevatedButton(
                onPressed: _toggleBold,
                style: ElevatedButton.styleFrom(
                  backgroundColor: elem.fontWeight == FontWeight.bold
                      ? Colors.blue
                      : null,
                ),
                child: const Text('Bold'),
              ),
              ElevatedButton(
                onPressed: _toggleItalic,
                style: ElevatedButton.styleFrom(
                  backgroundColor: elem.fontStyle == FontStyle.italic
                      ? Colors.blue
                      : null,
                ),
                child: const Text('Italic'),
              ),
              ElevatedButton(
                onPressed: _deleteSelected,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini Canva - Text Editor'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Text',
            onPressed: _addText,
          ),
          IconButton(
            icon: const Icon(Icons.undo),
            tooltip: 'Undo',
            onPressed: _undoStack.isEmpty ? null : _undo,
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            tooltip: 'Redo',
            onPressed: _redoStack.isEmpty ? null : _redo,
          ),
        ],
      ),
      body: Column(
        children: [
          // Canvas Area
          Expanded(
            child: GestureDetector(
              onTap: _deselect,
              child: Container(
                color: Colors.grey[50],
                child: Stack(
                  children: [
                    // Background hint
                    const Center(
                      child: Text(
                        'Tap + to add text\nTap text to select\nDrag to move',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    // Render all text elements
                    ...texts.asMap().entries.map((entry) {
                      final index = entry.key;
                      final elem = entry.value;
                      final isSelected = index == selectedIndex;

                      return Positioned(
                        left: elem.x,
                        top: elem.y,
                        child: GestureDetector(
                          onTap: () => _select(index),
                          onPanUpdate: (details) => _moveText(index, details),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: isSelected
                                ? BoxDecoration(
                                    border: Border.all(
                                        color: Colors.blue, width: 2),
                                    borderRadius: BorderRadius.circular(4),
                                  )
                                : null,
                            child: Text(
                              elem.text.isEmpty ? 'Empty' : elem.text,
                              style: TextStyle(
                                fontSize: elem.fontSize,
                                fontStyle: elem.fontStyle,
                                fontWeight: elem.fontWeight,
                                color: elem.text.isEmpty
                                    ? Colors.grey
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),

          // Editor Panel
          _buildEditor(),
        ],
      ),
    );
  }
}