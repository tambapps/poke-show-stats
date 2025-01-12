

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart';
import '../../ui/core/themes/dimens.dart';

class PokemonImageService {

  PokemonImageService({this.mappings = const {}});

  final Map<dynamic, dynamic> mappings;

  Widget getSprite(String pokemon) {
    Uri? uri = getSpriteUri(pokemon);
    if (uri == null) return _getDefaultSprite();
    return _getImageWidget(uri, width: Dimens.pokemonLogoSize, height: Dimens.pokemonLogoSize);
  }

  Widget getArtwork(String pokemon, {double? width, double? height}) {
    Uri? uri = getArtworkUri(pokemon);
    if (uri == null) return _getDefaultSprite();
    return _getImageWidget(uri, width: width, height: height);
  }

  Widget _getImageWidget(Uri uri, {double? width, double? height}) {
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
      errorWidget: (context, url, error) => _getDefaultSprite(),
    );
  }

  Widget _getDefaultSprite() => Icon(Icons.catching_pokemon, size: Dimens.pokemonLogoSize);

  Uri? getSpriteUri(String pokemon) => _getKey(pokemon, 'sprite');
  Uri? getArtworkUri(String pokemon) => _getKey(pokemon, 'artwork');

  Uri? _getKey(String pokemon, String key)  {
    Map<dynamic, dynamic>? pokemonUrls = mappings[pokemon.replaceAll(' ', '-')];
    if (pokemonUrls == null) return null;
    String uri = pokemonUrls[key];
    return Uri.parse(uri);
  }
}

