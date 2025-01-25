import 'dart:collection';
import 'dart:developer' as developer;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';
import '../../ui/core/themes/dimens.dart';

class PokemonResourceService extends ChangeNotifier {

  PokemonResourceService() {
    _loadAsync();
  }

  Map<dynamic, dynamic> _pokemonMappings = {};
  Map<dynamic, dynamic> _itemMappings = {};
  List<String> _itemNames = [];
  List<String> get itemNames => _itemNames;
  List<String> _pokemonNames = [];
  List<String> get pokemonNames => _pokemonNames;
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
  List<String> _abilities = [];
  List<String> get abilities => _abilities;


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
    return Tooltip(
      message: itemName,
      child: _getImageWidget(uri, width: width, height: height, tooltip: itemName),
    );
  }

  // if the guy doesn't respond just use the ones here https://www.pokepedia.fr/Cat%C3%A9gorie:Image_de_type_de_Pok%C3%A9mon_%C3%89carlate_et_Violet
  Widget getTeraTypeSprite(String type, {double? width, double? height}) {
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
        return _getDefaultSprite(tooltip: tooltip);
      },
    );
  }

  Widget _getDefaultSprite({String? tooltip}) {
    final widget = Icon(Icons.catching_pokemon, size: Dimens.pokemonLogoSize);
    return tooltip != null ? Tooltip(message: tooltip, child: widget,) : widget;
  }

  Uri? _getPokemonSpriteUri(String pokemon) => _getKey(pokemon, 'sprite', _pokemonMappings);
  Uri? _getPokemonArtworkUri(String pokemon) => _getKey(pokemon, 'artwork', _pokemonMappings);

  Uri? _getKey(String key, String uriKey, Map<dynamic, dynamic> mappings)  {
    Map<dynamic, dynamic>? pokemonUrls = mappings[key.replaceAll(' ', '-')];
    if (pokemonUrls == null) return null;
    String uri = pokemonUrls[uriKey];
    return Uri.parse(uri);
  }

  void _loadAsync() async {
    Map<dynamic, dynamic> pokemonMappings = loadYaml(await rootBundle.loadString('assets/mappings/pokemon-sprite-urls.yaml'));
    Map<dynamic, dynamic> itemMappings = loadYaml(await rootBundle.loadString('assets/mappings/items-mapping.yaml'));
    List<dynamic> abilities = loadYaml(await rootBundle.loadString('assets/mappings/abilities.yaml'));
    _abilities = abilities.map((o) => o.toString()).toList();
    _abilities.sort();
    _abilities = UnmodifiableListView(_abilities);

    _pokemonMappings = pokemonMappings;
    _itemMappings = itemMappings;
    _pokemonNames = _extractKeys(pokemonMappings);
    _itemNames = _extractKeys(itemMappings);
    notifyListeners();
  }

  List<String> _extractKeys(Map<dynamic, dynamic> map) {
    List<String> list = map.keys.map((k) => k.toString()).toList();
    list.sort();
    return UnmodifiableListView(list);
  }
}

