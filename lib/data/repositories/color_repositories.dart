import 'package:fashion_app/data/models/colors_model.dart';
import 'package:fashion_app/data/sources/color_source.dart';

class ColorRepositories {
  final ColorSource _remoteSource = ColorSource();

  Future<ColorsModel> addColor(ColorsModel color) =>
      _remoteSource.addColor(color);

  Future<List<ColorsModel>> getAllColors() => _remoteSource.getAllColors();
}
