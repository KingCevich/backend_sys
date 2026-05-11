@echo off
echo 🚀 Ejecutando todos los tests...

python usuarios_serv/manage.py test usuarios_app.tests
python auth_serv/manage.py test auth_app.tests
python mascotas_serv/manage.py test mascotas_app.tests
python bff_serv/manage.py test bff_app.tests

echo ✅ Todos los tests ejecutados
pause
