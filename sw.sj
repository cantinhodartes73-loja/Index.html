const CACHE_NAME = 'cantinho-artes-cache-v1';
const urlsToCache = [
  './',
  './index.html',
  './manifest.json',
  'https://fonts.googleapis.com/css2?family=Great+Vibes&display=swap'
];

self.addEventListener('install', event => {
  event.waitUntil(caches.open(CACHE_NAME).then(cache => cache.addAll(urlsToCache)));
  self.skipWaiting();
});

self.addEventListener('activate', event => {
  event.waitUntil(caches.keys().then(keys => Promise.all(keys.filter(k => k !== CACHE_NAME).map(k => caches.delete(k)))));
});

self.addEventListener('fetch', event => {
  const url = event.request.url;
  if (event.request.destination === 'image' || url.includes('.jpg') || url.includes('.png')) {
    event.respondWith(caches.match(event.request).then(res => res || fetch(event.request).then(fRes => {
      return caches.open(CACHE_NAME).then(cache => { cache.put(event.request, fRes.clone()); return fRes; });
    })));
  } else if (url.includes('script.google.com')) {
    event.respondWith(fetch(event.request).then(fRes => {
      return caches.open(CACHE_NAME).then(cache => { cache.put(event.request, fRes.clone()); return fRes; });
    }).catch(() => caches.match(event.request)));
  } else {
    event.respondWith(caches.match(event.request).then(res => res || fetch(event.request)));
  }
});
