import 'dart:collection';
import 'dart:developer' as developer;

import 'package:pokemon_core/pokemon_core.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
//import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';
import '../../ui/core/themes/dimens.dart';

class PokemonResourceService extends ChangeNotifier {

  PokemonResourceService() {
    _loadAsync();
  }

  Map<dynamic, dynamic> _pokemonMappings = {};
  Map<dynamic, dynamic> get pokemonMappings => _pokemonMappings;
  Map<dynamic, dynamic> _itemMappings = {};
  Map<dynamic, dynamic> get itemMappings => _itemMappings;
  Map<dynamic, dynamic> _pokemonMoves = {};
  Map<dynamic, dynamic> get pokemonMoves => _pokemonMoves;
  Map<dynamic, dynamic> _abilities = {};
  Map<dynamic, dynamic> get abilities => _abilities;

  final List<String> teraTypes = UnmodifiableListView([
    'Bug',
    'Dark',
    'Dragon',
    'Electric',
    'Fairy',
    'Fighting',
    'Fire',
    'Flying',
    'Ghost',
    'Grass',
    'Ground',
    'Ice',
    'Normal',
    'Poison',
    'Rock',
    'Steel',
    'Stellar',
    'Water'
  ]);

  Widget getPokemonSprite(String pokemon, {double width = Dimens.pokemonLogoSize, double height = Dimens.pokemonLogoSize}) {
    Uri? uri = _getPokemonSpriteUri(pokemon);
    if (uri == null) {
      if (_pokemonMappings.isNotEmpty) developer.log("Sprite URL for $pokemon was not found on mapping file");
      return _getDefaultSprite(tooltip: pokemon);
    }
    return Tooltip(
      message: pokemon,
      child: _getImageWidget(uri, width: width, height: height, tooltip: pokemon),
    );
  }

  Widget getItemSprite(String itemName, {double? width, double? height}) {
    Uri? uri = _getKey(itemName, 'spriteUrl', _itemMappings);
    if (uri == null) {
      if (_itemMappings.isNotEmpty) developer.log("Sprite URL for item $itemName was not found on mapping file");
      return _getDefaultSprite(tooltip: itemName);
    }
    return getItemSpriteFromUri(itemName, uri, width: width, height: height);
  }

  Widget getItemSpriteFromUri(String itemName, Uri uri, {double? width, double? height}) {
    return Tooltip(
      message: itemName,
      child: _getImageWidget(uri, width: width, height: height, tooltip: itemName),
    );
  }

  // if the guy doesn't respond just use the ones here https://www.pokepedia.fr/Cat%C3%A9gorie:Image_de_type_de_Pok%C3%A9mon_%C3%89carlate_et_Violet
  Widget getTeraTypeSprite(String type, {double? width, double? height}) {
    if (type == 'None') {
      return Container();
    }
    return Tooltip(
      message: "Tera $type",
      child: Image(image: AssetImage('assets/images/tera-types/${type.toLowerCase()}.png'), width: width, height: height,),
    );
  }

  Widget getTypeSprite(String type, {double? width, double? height}) {
    return Tooltip(
      message: type,
      child: Image(image: AssetImage('assets/images/moves/${type.toLowerCase()}.png'), width: width, height: height,),
    );
  }

  Widget getCategorySprite(String moveType, {double? width, double? height}) {
    return Tooltip(
      message: moveType,
      child: Image(image: AssetImage('assets/images/moves/${moveType.toLowerCase()}.png'), width: width, height: height,),
    );
  }

  Widget getPokemonArtwork(String pokemon, {double? width, double? height}) {
    Uri? uri = _getPokemonArtworkUri(pokemon);
    if (uri == null) return _getDefaultSprite(tooltip: pokemon);
    return Tooltip(
      message: pokemon,
      child: _getImageWidget(uri, width: width, height: height, tooltip: pokemon),
    );
  }

  double _getSize({double? width, double? height}) {
    if (width != null && height != null) {
      return width >= height ? width : height;
    } else if (width == null && height == null) {
      return Dimens.pokemonLogoSize;
    }
    return width ?? height!;
  }

  Widget _getImageWidget(Uri uri, {double? width, double? height, String? tooltip}) {
    // use the flag flutter run "--web-renderer html" to make this work.
    // don't forget to use it also when building the release app
    return CachedNetworkImage(
      imageUrl: uri.toString(),
      // needed in order for image loading to work even with CORS
      // tried using imageRenderMethodForWeb: ImageRenderMethodForWeb.HttpGet, but it doesn't work. So  I use the --web-renderer html flag
      width: width,
      height: height,
      fit: BoxFit.contain,
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) {
        developer.log('Image load failed: $url, Error: $error', error: error);
        return _getDefaultSprite(tooltip: tooltip, size: _getSize(width: width, height: height));
      },
    );
  }

  Widget _getDefaultSprite({String? tooltip, double size = Dimens.pokemonLogoSize}) {
    final widget = Icon(Icons.catching_pokemon, size: size);
    return tooltip != null ? Tooltip(message: tooltip, child: widget,) : widget;
  }

  Uri? _getPokemonSpriteUri(String pokemon) => _getKey(pokemon, 'sprite', _pokemonMappings);
  Uri? _getPokemonArtworkUri(String pokemon) => _getKey(pokemon, 'artwork', _pokemonMappings);

  Uri? _getKey(String key, String uriKey, Map<dynamic, dynamic> mappings)  {
    Map<dynamic, dynamic>? pokemonUrls = mappings[Pokemon.normalize(key)];
    if (pokemonUrls == null) return null;
    String uri = pokemonUrls[uriKey];
    return Uri.parse(uri);
  }

  dynamic getPokemonMove(String move) {
    return _pokemonMoves[Pokemon.normalize(move)];
  }

  void _loadAsync() async {
    _pokemonMappings = loadYaml(await rootBundle.loadString('assets/mappings/pokemon-sprite-urls.yaml'));
    _itemMappings = loadYaml(await rootBundle.loadString('assets/mappings/items-mapping.yaml'));
    _abilities = loadYaml(await rootBundle.loadString('assets/mappings/abilities.yaml'));
    _pokemonMoves = loadYaml(await rootBundle.loadString('assets/mappings/moves.yaml'));

    notifyListeners();
  }
}
