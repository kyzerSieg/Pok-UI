# Pok-UI

Clonar el repositorio: 

```text

https://github.com/kyzerSieg/Pok-UI.git

```
Abrir Pokedex.xcodeproj

Seleccionar el target de la app.

Elegir un simulador iOS 15+.

Run (⌘R).


## Estructura del proyecto
```text
.
├─ Sources/
│  ├─ Models/
│  │  ├─ PokemonList.swift
│  │  ├─ PokemonDetails.swift
│  │  └─ PokemonSpecies.swift
│  ├─ Services/
│  │  ├─ PokeAPI.swift
│  │  └─ ImageCacheService.swift
│  ├─ ViewModels/
│  │  └─ PokeViewModel.swift
│  └─ Views/
│     ├─ PokemonListView.swift
│     ├─ PokemonDetailView.swift
│     └─ PokeCard.swift
└─ README.md
```

## Decisiones arquitectónicas

### Arquitectura:
	
MVVM + Services.

### Models:
	
Codable alineados a los JSON de PokéAPI (PokemonList, PokemonEntry, PokemonDetails, PokemonSpecies).

### ViewModel: 

PokeViewModel expone estado con @Published y usa async/await para orquestar red, paginación, búsqueda y errores.

### Services:

PokeAPIProtocol (y PokeAPI): capa única de acceso HTTP con URLSession.

ImageCacheServiceProtocol / ImageCacheService: cache de imágenes usando URLCache.shared (sin bibliotecas de  terceros).

UI 100% SwiftUI: PokemonListView, PokemonDetailView, PokeCard. Vistas reactivas, sin lógica de red.

La VM resuelve y cachea la URL, la vista solo la consume.

## Optimizaciones implementadas (OBLIGATORIAS)
### A) Lazy Loading de Imágenes

Las celdas piden la imagen solo al aparecer:
onAppear { await vm.ensureArtwork(for: entry) }


Cache: ImageCacheService usa URLCache.shared para evitar descargas repetidas.


### B) Paginación Eficiente

Páginas de 50.


### C) Lista Optimizada (SwiftUI)

List (lazy) con IDs estables (id: enumerated().offset).

Celdas sin logica (dummy) (PokeCard): sin cálculos de URL ni red.

@Published private(set) y diccionario artworkByID @Published para invalidaciones precisas.

## Manejo de errores

Errores de red: timeouts, 4xx/5xx -> se muestran en PokemonListView.

Errores de parsing: JSON inválido -> mensaje de error y estado consistente (lista vacía al reset).

Imágenes fallidas: AsyncImage muestra Image(systemName: "photo") como fallo.

Estados de carga:

Carga inicial: ProgressView centrado si la lista está vacía.

Carga incremental: ProgressView en la toolbar mientras se pagina.


## Búsqueda en tiempo real

searchable(text:) en PokemonListView.

Filtro local por nombre (ignorando mayúsculas).

La paginación sigue activa cuando no hay filtro (evita traer páginas innecesarias con búsqueda).

Detalles técnicos clave

URLSession puro (sin Alamofire).

JSONDecoder con convertFromSnakeCase (para convertir a camelCase) cuando aplica.

AsyncImage (iOS 15+) apoya cache del sistema automáticamente; el prefetch reduce el “pop-in” (aparición de golpe).

Combine: @Published para estado; la VM es @MainActor.


## Promps usados: 

get codable model, clean code https://pokeapi.co/api/v2/pokemon?limit=50&offset=0

get codable model, clean code https://pokeapi.co/api/v2/pokemon/22

get codable model, clean code https://pokeapi.co/api/v2/pokemon-species/22


