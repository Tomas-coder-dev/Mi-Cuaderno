# PaqueteListo (Mi Cuaderno)

**PaqueteListo** es una aplicación móvil y web intuitiva diseñada para digitalizar la libreta de gestión de cargas y envíos de paquetes. Diseñada especialmente para ser sumamente amigable, clara y fácil de usar, eliminando la confusión sobre qué paquetes están en el local y cuáles ya fueron enviados.

---

## 🚀 Funcionalidades Principales

1. **📦 Paquetes en Local (Almacén)**:
   - Registro rápido con código de paquete (ej: `FZ30`, `GUIA-102`) y persona/descripción.
   - Visualización clara del estado de los paquetes en almacén.
   - Opciones para editar o eliminar paquetes anotados.

2. **🚀 Despachar y Enviar**:
   - Selección táctil en lote mediante casillas grandes.
   - Confirmación de salida masiva en un solo toque (`Enviar paquetes ahora`).

3. **📋 Historial de Envíos**:
   - Registro de paquetes que ya salieron y fueron enviados.
   - Búsqueda por código o destinatario y filtros por fecha (Hoy, Esta semana, Este mes).
   - Opción para regresar un paquete al almacén si hubo una equivocación.

4. **🗓️ Calendario y Fechas**:
   - Calendario interactivo en la parte superior con marcadores de actividad.
   - Soporte para consultar un día específico o marcar un rango de días.
   - Filtros inmediatos para ver qué llegó y qué salió en el periodo seleccionado.
   - Badges visuales de alto contraste (`EN ALMACÉN` vs `YA SALIÓ / ENVIADO`).

---

## 🛠️ Tecnologías Utilizadas

- **Flutter 3** & **Dart** (Soporte multiplataforma: Móvil, Web y Escritorio).
- **Riverpod**: Gestión de estado reactiva y desacoplada.
- **Hive & Hive Flutter**: Base de datos local persistente y ultrarrápida.
- **Table Calendar**: Visualización y selección de fechas y rangos.
- **Google Fonts (Nunito)**: Tipografía legible y cálida para una lectura descansada.
- **Flutter Animate**: Transiciones y micro-interacciones suaves.

---

## 📦 Ejecución del Proyecto

### Prerrequisitos
- Tener instalado el SDK de Flutter (3.x o superior).

### Pasos
1. Clonar el repositorio:
   ```bash
   git clone https://github.com/Tomas-coder-dev/Mi-Cuaderno.git
   cd Mi-Cuaderno
   ```
2. Obtener dependencias:
   ```bash
   flutter pub get
   ```
3. Ejecutar en el dispositivo deseado:
   - **En Navegador Web**:
     ```bash
     flutter run -d chrome
     ```
   - **En Android**:
     ```bash
     flutter run
     ```
   - **Compilación Web de Producción**:
     ```bash
     flutter build web
     ```
