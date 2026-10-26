# ¿Auto o moto?

Prototipo académico en Flutter basado en el wireframe de Figma. La aplicación compara el costo estimado de un viaje en auto y en moto, y permite recorrer pantallas de vehículos, mantenimiento, historial y estadísticas.

## Qué incluye la demo

- Pantalla de bienvenida y acceso de demostración.
- Cálculo de costos estimados por distancia, consumo y precio del combustible.
- Comparación entre auto y moto, con opción para guardar el viaje.
- Alta de vehículos y consulta de mantenimiento.
- Historial y estadísticas con datos de ejemplo.
- Diseño adaptable a celular y computadora.

La demo no tiene autenticación real ni base de datos. Los viajes nuevos se guardan en memoria mientras la aplicación permanece abierta; al recargar, vuelven los datos iniciales.

## Ejecutar localmente

Se necesita Flutter instalado y Chrome o Edge.

```bash
flutter pub get
flutter run -d chrome
```

## Publicar con GitHub Pages

El flujo de GitHub Actions de `.github/workflows/pages.yml` compila la aplicación y la publica en GitHub Pages cuando se actualiza la rama `main`.

1. En el repositorio, abrí **Settings → Pages** y elegí **GitHub Actions** como origen.
2. En **Actions**, esperá que termine el flujo **Deploy Flutter Web**.
3. El enlace de la demo aparece en **Settings → Pages**.
