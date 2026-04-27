import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../models/image_item.dart';
import '../services/database_helper.dart';

class ImageRepository {
  final Cau6DatabaseHelper _dbHelper = Cau6DatabaseHelper();

  Future<List<ImageItem>> getAllImages() async {
    final db = await _dbHelper.database;
    final maps = await db.query('images', orderBy: 'createdAt DESC');
    return maps.map((map) => ImageItem.fromMap(map)).toList();
  }

  Future<int> insertImage(ImageItem image) async {
    final db = await _dbHelper.database;
    return await db.insert('images', image.toMap());
  }

  Future<int> deleteImage(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('images', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      final path = maps.first['path'] as String;
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }
    return await db.delete('images', where: 'id = ?', whereArgs: [id]);
  }

  Future<ImageItem> saveGeneratedImage(String title) async {
    final directory = await getApplicationDocumentsDirectory();
    final imageDir = Directory('${directory.path}/gallery_images');
    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }

    final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.png';
    final filePath = '${imageDir.path}/$fileName';

    final imageBytes = _generateRandomImage();
    final file = File(filePath);
    await file.writeAsBytes(imageBytes);

    final imageItem = ImageItem(
      path: filePath,
      title: title,
      createdAt: DateTime.now(),
    );

    final id = await insertImage(imageItem);
    return imageItem.copyWith(id: id);
  }

  List<int> _generateRandomImage() {
    final random = Random();
    final width = 200;
    final height = 200;

    final image = img.Image(width: width, height: height);

    final baseColor = img.ColorRgba8(
      random.nextInt(200) + 50,
      random.nextInt(200) + 50,
      random.nextInt(200) + 50,
      255,
    );

    img.fill(image, color: baseColor);

    for (int i = 0; i < 20; i++) {
      final x = random.nextInt(width);
      final y = random.nextInt(height);
      final w = random.nextInt(80) + 20;
      final h = random.nextInt(80) + 20;
      final color = img.ColorRgba8(
        random.nextInt(255),
        random.nextInt(255),
        random.nextInt(255),
        180,
      );
      img.fillRect(
        image,
        x1: x,
        y1: y,
        x2: (x + w).clamp(0, width),
        y2: (y + h).clamp(0, height),
        color: color,
      );
    }

    for (int i = 0; i < 5; i++) {
      final x1 = random.nextInt(width);
      final y1 = random.nextInt(height);
      final x2 = random.nextInt(width);
      final y2 = random.nextInt(height);
      final color = img.ColorRgba8(
        random.nextInt(255),
        random.nextInt(255),
        random.nextInt(255),
        200,
      );
      img.drawLine(image, x1: x1, y1: y1, x2: x2, y2: y2, color: color, thickness: 3);
    }

    return img.encodePng(image);
  }
}
