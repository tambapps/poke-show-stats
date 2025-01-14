

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart';
import '../../ui/core/themes/dimens.dart';

class PokemonImageService {

  PokemonImageService({Map<dynamic, dynamic> pokemon_mappings = const {}, Map<dynamic, dynamic> item_mappings = const {}})
      : _pokemon_mappings = pokemon_mappings, _item_mappings = item_mappings;

  final Map<dynamic, dynamic> _pokemon_mappings;
  final Map<dynamic, dynamic> _item_mappings;

  Widget getPokemonSprite(String pokemon) {
    Uri? uri = _getPokemonSpriteUri(pokemon);
    if (uri == null) return _getDefaultSprite(tooltip: pokemon);
    return Tooltip(
      message: pokemon,
      child: _getImageWidget(uri, width: Dimens.pokemonLogoSize, height: Dimens.pokemonLogoSize, tooltip: pokemon),
    );
  }

  Widget getItemSprite(String itemName, {double? width, double? height}) {
    Uri? uri = _getKey(itemName, 'spriteUrl', _item_mappings);
    if (uri == null) return _getDefaultSprite(tooltip: itemName);
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
    // TODO doesn't work now but should work once this https://github.com/flutter/flutter/issues/160127
    //  will be included in the latest stable release and I upgrade.
    //    for now use the flag flutter run -d chrome --web-renderer html
    return CachedNetworkImage(
      imageUrl: uri.toString(),
      // needed in order for image loading to work even with CORS
      //imageRenderMethodForWeb: ImageRenderMethodForWeb.HttpGet,
      width: width,
      height: height,
      fit: BoxFit.contain,
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => _getDefaultSprite(tooltip: tooltip),
    );
  }

  Widget _getDefaultSprite({String? tooltip}) {
    final widget = Icon(Icons.catching_pokemon, size: Dimens.pokemonLogoSize);
    return tooltip != null ? Tooltip(message: "foo", child: widget,) : widget;
  }

  Uri? _getPokemonSpriteUri(String pokemon) => _getKey(pokemon, 'sprite', _pokemon_mappings);
  Uri? _getPokemonArtworkUri(String pokemon) => _getKey(pokemon, 'artwork', _pokemon_mappings);

  Uri? _getKey(String key, String uriKey, Map<dynamic, dynamic> mappings)  {
    Map<dynamic, dynamic>? pokemonUrls = mappings[key.replaceAll(' ', '-')];
    if (pokemonUrls == null) return null;
    String uri = pokemonUrls[uriKey];
    return Uri.parse(uri);
  }
}

