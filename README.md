# 🐾 SanosYSalvos

Gestión de mascotas perdidas y encontradas, construida con arquitectura de microservicios en Django REST Framework. Permite a usuarios reportar mascotas perdidas o encontradas, gestionar contactos y administrar perfiles de entidades.

---
## Repositorios vinculados

- Frontend: https://github.com/ToniC-3PO/frontend_sys.git
- Mascotas: https://github.com/KingCevich/Mascotas_SYS.git
- Usuarios: https://github.com/KingCevich/Usuarios_SYS.git
- Auth: https://github.com/KingCevich/Usuarios_SYS.git
- BFF: https://github.com/KingCevich/BFF_SYS.git

## Arquitectura

```
Frontend
    └── BFF (puerto 8003)
            ├── auth_serv     (puerto 8001) → Login y validación JWT
            ├── usuarios_serv (puerto 8000) → Usuarios, perfiles, preferencias
            └── mascotas_serv (puerto 8002) → Reportes y contactos
```

El frontend no habla directamente con los microservicios — todo pasa por el **BFF** como punto de entrada único.

---

## Microservicios

| Servicio | Puerto | Descripción |
|---|---|---|
| `usuarios_serv` | 8000 | Gestión de usuarios, perfiles de entidades y preferencias |
| `auth_serv` | 8001 | Autenticación y generación/validación de tokens JWT |
| `mascotas_serv` | 8002 | Reportes de mascotas perdidas/encontradas y contactos |
| `bff_serv` | 8003 | Punto de entrada único que proxifica al frontend |

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
cd usuarios_serv
python manage.py migrate
python manage.py runserver 8000

# Terminal 2 - Auth
cd auth_serv
python manage.py migrate
python manage.py runserver 8001

# Terminal 3 - Mascotas
cd mascotas_serv
python manage.py migrate
python manage.py runserver 8002

# Terminal 4 - BFF
cd bff_serv
python manage.py migrate
python manage.py runserver 8003
```

---

## Ejecutar tests

Desde la raíz del proyecto, con el entorno virtual activado:

```bash
# Todos los tests
cd usuarios_serv && python manage.py test
cd auth_serv && python manage.py test
cd mascotas_serv && python manage.py test
cd bff_serv && python manage.py test
```

O usando el script incluido:

```bash
runtest.bat   # Windows
```

---
