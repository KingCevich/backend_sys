# FULLSTACK 3
<img width="320" height="190" alt="logo" src="https://github.com/user-attachments/assets/1430ebc1-eb10-4000-9bb7-2ce440c52011" />
<img width="320" height="190" alt="logo-bw" src="https://github.com/user-attachments/assets/e80c6d28-82bf-4a66-bf6f-449c7aff98dc" />

# 🐾 SanosYSalvos - Backend

Gestión de mascotas perdidas y encontradas, construida con arquitectura de microservicios en Django REST Framework. Permite a usuarios reportar mascotas perdidas o encontradas, gestionar contactos y administrar perfiles de entidades.

---
## Repositorios vinculados

- Frontend: https://github.com/ToniC-3PO/frontend_sys.git
- Mascotas: https://github.com/KingCevich/Mascotas_SYS.git
- Usuarios: https://github.com/KingCevich/Usuarios_SYS.git
- Auth: https://github.com/KingCevich/Auth_SYS
- Noticias: [https://github.com/KingCevich/BFF_SYS.git](https://github.com/KingCevich/Noticias_SYS)
- Notificaciones: [https://github.com/KingCevich/BFF_SYS.git](https://github.com/KingCevich/Notifiaciones_SYS)
- BFF: https://github.com/KingCevich/BFF_SYS.git

## Arquitectura

```
Frontend
    └── BFF (puerto 8003)
            ├── auth_sys     (puerto 8001) → Login y validación JWT
            ├── usuarios_sys (puerto 8000) → Usuarios, perfiles, preferencias
            ├── mascotas_sys (puerto 8002) → Reportes y contactos
            ├── noticias_sys (puerto 8004) → Noticias de usuarios y entidades
            └── notificaciones_sys (puerto 8005) → Notificaciones de coincidencias e otros
```

El frontend no habla directamente con los microservicios — todo pasa por el **BFF** como punto de entrada 

---

## Microservicios

| Servicio | Puerto | Descripción |
|---|---|---|
| `usuarios_sys` | 8000 | Gestión de usuarios, perfiles de entidades y preferencias |
| `auth_sys` | 8001 | Autenticación y generación/validación de tokens JWT |
| `mascotas_sys` | 8002 | Reportes de mascotas perdidas/encontradas y contactos |
| `bff_sys` | 8003 | Punto de entrada único que proxifica al frontend |
| `noticias_sys` | 8004 | Publicacion de Noticias |
| `notificaciones_sys` | 8005 | Alertas / Notificaciones |

---

## Tecnologías

- **Backend:** Django 6.0.4 + Django REST Framework 3.17.1
- **Autenticación:** JWT con `djangorestframework-simplejwt`
- **CORS:** `django-cors-headers`
- **Base de datos:** PostgreSQL (producción) / SQLite (desarrollo)
- **Testing:** pytest + pytest-django
- **Comunicación entre servicios:** `requests` (HTTP)

---

## Instalación y configuración

### 1. Clonar el repositorio

```bash
git clone <url-del-repo>
cd SanosYSalvos
```

### 2. Crear y activar entorno virtual

```bash
python -m venv sys_venv
# Windows
sys_venv\Scripts\activate.bat
# Linux/Mac
source sys_venv/bin/activate
```
**Nota:** Si hay problemas con venv y permisos, dar temporalmente:
(Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned) ; (& c:\RAM_UBICACION\venv\Scripts\Activate.ps1)

### 3. Instalar dependencias

```bash
pip install -r requirements.txt
```

### 4. Levantar cada microservicio

Cada microservicio se levanta de forma independiente en su propio puerto:

```bash
# Terminal 1 - Usuarios
cd usuarios_sys
python manage.py migrate
python manage.py runserver 8000

# Terminal 2 - Auth
cd auth_sys
python manage.py migrate
python manage.py runserver 8001

# Terminal 3 - Mascotas
cd mascotas_sys
python manage.py migrate
python manage.py runserver 8002

# Terminal 4 - BFF
cd bff_sys
python manage.py migrate
python manage.py runserver 8003

# Terminal 5 - Noticias
cd noticias_sys
python manage.py migrate
python manage.py runserver 8003

# Terminal 6 - Notificaciones
cd notificaciones_sys
python manage.py migrate
python manage.py runserver 8003
```

---

## Ejecutar tests

Desde la raíz del proyecto, con el entorno virtual activado:

```bash
# Todos los tests
cd usuarios_sys && python manage.py test
cd auth_sys && python manage.py test
cd mascotas_sys && python manage.py test
cd bff_sys && python manage.py test
cd noticias_sys && python manage.py test
cd notificaciones_sys python manage.py test
```

O usando el script incluido:

```bash
runtest.bat   # Windows
```

---
