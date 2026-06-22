/*
Võ Tấn Đào - Flutter
Đề bài: Tái hiện lại cây thư mục bằng flutter, font cách 16px và tạo thư mục ở local
*/
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class DirectoryItem {
  String name;
  List<DirectoryItem> children;

  bool get isFile => children.isEmpty && name.contains('.');

  DirectoryItem(this.name, {this.children = const []});
}

Future<String> getBasePath() async {
  final dir = await getApplicationDocumentsDirectory();
  return '${dir.path}/output';
}

Future<void> createLocalStructure(String basePath) async {
  final root = Directory(basePath);
  if (root.existsSync()) root.deleteSync(recursive: true);

  Directory('$basePath/folder_1').createSync(recursive: true);
  Directory('$basePath/folder_2/folder_3').createSync(recursive: true);
  File('$basePath/folder_2/text_1.js').createSync(recursive: true);
}

DirectoryItem buildTreeFromDisk(String path) {
  final name = path.split(Platform.pathSeparator).last;
  final type = FileSystemEntity.typeSync(path);

  if (type == FileSystemEntityType.directory) {
    final entries = Directory(path).listSync()
      ..sort((a, b) => a.path.compareTo(b.path));
    final children = entries.map((e) => buildTreeFromDisk(e.path)).toList();
    return DirectoryItem(name, children: children);
  } else {
    return DirectoryItem(name);
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DirectoryItem? _root;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final basePath = await getBasePath();
    await createLocalStructure(basePath);
    setState(() {
      _root = buildTreeFromDisk(basePath);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Directory Tree - Võ Tấn Đào')),
        body: _root == null
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: DirectoryTree(_root!),
              ),
      ),
    );
  }
}

class DirectoryTree extends StatelessWidget {
  final DirectoryItem root;

  const DirectoryTree(this.root, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [DirectoryNode(item: root, depth: 0)],
    );
  }
}

class DirectoryNode extends StatefulWidget {
  final DirectoryItem item;
  final int depth;

  const DirectoryNode({super.key, required this.item, required this.depth});

  @override
  State<DirectoryNode> createState() => _DirectoryNodeState();
}

class _DirectoryNodeState extends State<DirectoryNode> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isFolder = !item.isFile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: isFolder ? () => setState(() => _expanded = !_expanded) : null,
          child: Padding(
            padding: EdgeInsets.only(left: widget.depth * 16.0, top: 2, bottom: 2),
            child: Row(
              children: [
                if (isFolder)
                  Icon(
                    _expanded ? Icons.expand_more : Icons.chevron_right,
                    size: 18,
                    color: Colors.grey,
                  )
                else
                  const SizedBox(width: 18),
                const SizedBox(width: 2),
                Icon(
                  item.isFile
                      ? Icons.insert_drive_file_outlined
                      : (_expanded ? Icons.folder_open : Icons.folder),
                  size: 18,
                  color: item.isFile ? Colors.blueGrey : Colors.amber,
                ),
                const SizedBox(width: 6),
                Text(item.name, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
        if (isFolder && _expanded)
          ...item.children.map(
            (child) => DirectoryNode(item: child, depth: widget.depth + 1),
          ),
      ],
    );
  }
}
