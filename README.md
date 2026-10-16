# Anomalys Trading — edición privada y consulta pública

La web está preparada para GitHub Pages, con:
- buscador por nombre y filtro por categoría;
- categorías Cuchillo, Asesino, Cabaña y Otro;
- imagen principal original incorporada sin modificar;
- imágenes opcionales por URL para cada objeto;
- historial de cambios;
- acceso de administración por correo y contraseña;
- base de datos con permisos de solo lectura para visitantes.

**Importante:** la interfaz sola no crea una base de datos ni un usuario administrador. Seguí los pasos de abajo. No publiques nunca una `service_role key`, una contraseña ni tokens privados.

## A. Crear el proyecto de base de datos (Supabase, gratis para empezar)

1. Desde Chrome en Android, abre https://supabase.com/ y crea un proyecto.
2. Guarda la contraseña de base de datos en un lugar privado; no la pongas en GitHub.
3. En el proyecto, abre **SQL Editor → New query**.
4. Abre el archivo `supabase-setup.sql` de este paquete, copia todo el SQL y ejecútalo.
5. Ve a **Project Settings → API** (o **Connect**) y copia la **Project URL** y la clave pública **publishable** (en proyectos antiguos puede llamarse `anon/public`). La clave `service_role` NO se usa en la web.

## B. Crear tu cuenta de administrador

1. En Supabase, abre **Authentication → Users → Add user**.
2. Crea un usuario con tu propio correo y una contraseña fuerte. No compartas la contraseña.
3. Copia el UUID/ID de ese usuario desde la lista de Users.
4. En SQL Editor, ejecuta esta consulta sustituyendo el UUID:
   `insert into public.admins (user_id) values ('UUID-DE-TU-USUARIO');`
5. No habilites el registro público de usuarios si no lo necesitás. La página solo usa el inicio de sesión de la cuenta que creaste.

## C. Conectar la web a Supabase

1. En GitHub, abre el repositorio `Anomalys` y el archivo `index.html`.
2. Toca el lápiz **Edit this file**.
3. Busca estas dos líneas cerca del final:
   `const SUPABASE_URL = "PEGAR_URL_DEL_PROYECTO";`
   `const SUPABASE_ANON_KEY = "PEGAR_CLAVE_PUBLISHABLE";`
4. Reemplaza los textos entre comillas por tu Project URL y tu clave pública publishable/anon.
5. Guarda con **Commit changes**.
6. Espera la publicación de GitHub Pages y abre `https://anomalystrading.github.io/Anomalys/`.

La URL y la clave publishable/anon se usan en aplicaciones de navegador y no son contraseñas. La seguridad depende de las políticas RLS incluidas en el SQL. Nunca pegues una `service_role` key en `index.html`.

## D. Añadir y editar objetos

1. Abre la web publicada.
2. En “Administración privada”, inicia sesión con el correo y la contraseña que creaste en Supabase.
3. Completa nombre, categoría, valor, rareza y descripción. Para la imagen del objeto, pega una URL pública que empiece por `https://`.
4. Guarda. Los visitantes verán los datos compartidos al actualizar la página.
5. El historial registra altas, cambios de nombre/valor/categoría y eliminaciones.

La imagen principal de Anomalys se conserva tal como fue compartida. Cambiar imágenes de objetos mediante URL no modifica la imagen original del encabezado.

## E. GitHub Pages

En el repositorio, ve a **Settings → Pages**:
- Source: Deploy from a branch
- Branch: `main`
- Folder: `/(root)`

La dirección prevista es `https://anomalystrading.github.io/Anomalys/` (si el usuario de GitHub es exactamente `AnomalysTrading` y el repositorio se llama `Anomalys`).

## F. Google

1. Publica primero el sitio y comprueba que abra.
2. Entra a https://search.google.com/search-console/
3. Añade la propiedad de tipo **Prefijo de URL** con `https://anomalystrading.github.io/Anomalys/`.
4. Completa el método de verificación que Google te ofrezca.
5. En **Inspección de URL**, solicita indexación. Si Google lo acepta, puede tardar días o semanas; no se garantiza la indexación ni una posición concreta.

## Notas de seguridad y límites

- Los visitantes pueden consultar valores y el historial; las políticas de base de datos bloquean sus escrituras.
- Solo el usuario cuyo UUID esté en `public.admins` puede crear, editar o eliminar objetos.
- No uses una contraseña compartida para administrar. No pegues claves privadas en el chat.
- Esta web usa servicios externos (Supabase y el CDN de la biblioteca). La disponibilidad y límites dependen de esos servicios.
- Los valores son comunitarios y no oficiales; el sitio no está afiliado a Roblox.
