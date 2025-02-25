'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"icons/Icon-maskable-512.png": "5ad58cd5f5db1b25752ef248f81c74ef",
"icons/Icon-512.png": "c996621caaad4b4a98601a116d6a3453",
"icons/Icon-maskable-192.png": "ded96ec534fcdd55f4af08d529271ccf",
"icons/Icon-192.png": "5a6f90589c1a5273f11bbd2ea797c33a",
"flutter_bootstrap.js": "935ccee61460888ef77d69bc0b482b1f",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c",
"canvaskit/skwasm.wasm": "828c26a0b1cc8eb1adacbdd0c5e8bcfa",
"canvaskit/chromium/canvaskit.wasm": "ea5ab288728f7200f398f60089048b48",
"canvaskit/chromium/canvaskit.js.symbols": "e115ddcfad5f5b98a90e389433606502",
"canvaskit/chromium/canvaskit.js": "b7ba6d908089f706772b2007c37e6da4",
"canvaskit/skwasm.js": "ac0f73826b925320a1e9b0d3fd7da61c",
"canvaskit/canvaskit.wasm": "e7602c687313cfac5f495c5eac2fb324",
"canvaskit/skwasm.js.symbols": "96263e00e3c9bd9cd878ead867c04f3c",
"canvaskit/canvaskit.js.symbols": "efc2cd87d1ff6c586b7d4c7083063a40",
"canvaskit/canvaskit.js": "26eef3024dbc64886b7f48e1b6fb05cf",
"main.dart.js": "d2a7fb030763e985d389d2ba5e934d5b",
"version.json": "52fb0106db3233b3b003a825765a4a3a",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/packages/fluttertoast/assets/toastify.js": "56e2c9cedd97f10e7e5f1cebd85d53e3",
"assets/packages/fluttertoast/assets/toastify.css": "a85675050054f179444bc5ad70ffc635",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.json": "ccd5a1da229611c39e47319bb2663126",
"assets/assets/samples/delpHOx.json": "7eb1b9b8713661afa6c93a9fc0501263",
"assets/assets/samples/electrizer.json": "8b507cbbc1f9731cdba90737dd0f8b64",
"assets/assets/mappings/abilities.yaml": "fa55b7b9686c9d079b5007d4e8171eae",
"assets/assets/mappings/pokemon-sprite-urls.yaml": "5a1bda088543e8a5049769d870d18499",
"assets/assets/mappings/items-mapping.yaml": "a206e65186bef04f9ce006be238b5b1a",
"assets/assets/mappings/moves.yaml": "8d75647af60269c318f6e3908bb94bae",
"assets/assets/images/moves/ghost.png": "4723494697986fb2ebe91eea196c5ac5",
"assets/assets/images/moves/dragon.png": "3fb6e634a3f5bfcbd756e88250d8971e",
"assets/assets/images/moves/electric.png": "be6261f5110af374d9a21c0326b48561",
"assets/assets/images/moves/special.png": "7bc61e83eb02c82d1246d91cd813ac5d",
"assets/assets/images/moves/fire.png": "dbd74a4151ffe7bb2ce449dccf3e6565",
"assets/assets/images/moves/normal.png": "5f343adcc8f01ae2aa4045d5ff272326",
"assets/assets/images/moves/steel.png": "21b17b2f765e3ecd7197bdf29092c374",
"assets/assets/images/moves/bug.png": "192dea4d1e24967676342953f0748f51",
"assets/assets/images/moves/rock.png": "fa9cdd637d86de1d57ac4f53dd4faed7",
"assets/assets/images/moves/status.png": "adc0c19ea60f62d577a41373fd615d58",
"assets/assets/images/moves/physical.png": "bd21ba8e0599ed3c23b00d0f448cfbca",
"assets/assets/images/moves/ice.png": "8fc6142fd26f56ecebe80b306157d044",
"assets/assets/images/moves/dark.png": "1e813aa4a768ab80a146eaec4b05a708",
"assets/assets/images/moves/fairy.png": "795a85116eaf3787679cf3462f9c72d6",
"assets/assets/images/moves/fighting.png": "979595111ec29b9804a65acf5d8fd925",
"assets/assets/images/moves/flying.png": "c288ed2ca4ededf1714f5f935153c9dc",
"assets/assets/images/moves/grass.png": "db8658f112d5f7f4698ff6685678addb",
"assets/assets/images/moves/poison.png": "b629944191823a827af15099656ec926",
"assets/assets/images/moves/ground.png": "c6f288424a62f0c7adf7f04e5165c197",
"assets/assets/images/moves/water.png": "6d69d1294bed067767a062d49ae118e7",
"assets/assets/images/moves/psychic.png": "4f538d04e9082fd2593c3d79dcfc1867",
"assets/assets/images/tera-types/ghost.png": "600dfa2925cb73351b806b8ddc67dfb4",
"assets/assets/images/tera-types/dragon.png": "1b24c77278374f9b49f83c06b3d3fa3d",
"assets/assets/images/tera-types/electric.png": "6f07e4e82f99c7fece7c0faf1dde0494",
"assets/assets/images/tera-types/fire.png": "131f78fbf9f0014ff5d570dd26eedc9c",
"assets/assets/images/tera-types/normal.png": "4fd7ce615eeffa67859c0045d67a3ab0",
"assets/assets/images/tera-types/stellar.png": "ba680731473705901ed9b374084d063f",
"assets/assets/images/tera-types/steel.png": "03972bf13730d010ca1478fb43eb9b41",
"assets/assets/images/tera-types/bug.png": "c4114892a8afd7b307b1dd2e0bf84618",
"assets/assets/images/tera-types/rock.png": "e654f1258b6b6e09a423831379e8d3d0",
"assets/assets/images/tera-types/ice.png": "5a46f43e21444f72e362a33bc328b56a",
"assets/assets/images/tera-types/dark.png": "8740c80e0237009bb20285b4cc37156d",
"assets/assets/images/tera-types/fairy.png": "56bd3f73f0c165b2d59abc6af3c39dd6",
"assets/assets/images/tera-types/fighting.png": "2de444e5f4e7dbd33311656b3248841f",
"assets/assets/images/tera-types/flying.png": "f2e77bcd8ded6263dfa3097cedbcc1da",
"assets/assets/images/tera-types/grass.png": "9cf54b3393a0a37e40baed97006dd982",
"assets/assets/images/tera-types/poison.png": "a7f6c49606b7edf1238e8d1b070d825e",
"assets/assets/images/tera-types/ground.png": "bb73e434f0626cd6174a455a2491e648",
"assets/assets/images/tera-types/water.png": "3aec0226dbb751d70617226749ce189b",
"assets/assets/images/tera-types/psychic.png": "9cf5c3b5d82d02d2895bade247d01e32",
"assets/NOTICES": "40ad85ac5337d025e488cbbb7c9074d7",
"assets/AssetManifest.bin": "81c5631930b390d9c1cd4bd95caf1cfb",
"assets/fonts/MaterialIcons-Regular.otf": "aa12bbf72749dc0eba2f696510c88e62",
"assets/AssetManifest.bin.json": "f3445aca4bb782b9ca7b4929fa4cc583",
"favicon.png": "df4f04beee348ddade0c5dfbf71539c0",
"index.html": "83445b3f0848a8d87b75ebadeb7269c3",
"/": "83445b3f0848a8d87b75ebadeb7269c3",
"manifest.json": "6b9773aa3c77d839209523195a2097e8",
"flutter.js": "4b2350e14c6650ba82871f60906437ea"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
