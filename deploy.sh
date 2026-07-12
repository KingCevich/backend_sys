#!/bin/bash

set -e

REGION="us-east-1"
CLUSTER_NAME="sanosysalvos"
ACCOUNT_ID="053760945279"
ECR_URL="053760945279.dkr.ecr.us-east-1.amazonaws.com"

# RDS Endpoints
RDS_USUARIOS="sanos-usuarios-db.c9oo6visqpir.us-east-1.rds.amazonaws.com"
RDS_AUTH="sanos-auth-db.c9oo6visqpir.us-east-1.rds.amazonaws.com"
RDS_MASCOTAS="sanos-mascotas-db.c9oo6visqpir.us-east-1.rds.amazonaws.com"
RDS_NOTICIAS="sanos-noticias-db.c9oo6visqpir.us-east-1.rds.amazonaws.com"
RDS_NOTIFICACIONES="sanos-notificaciones-db.c9oo6visqpir.us-east-1.rds.amazonaws.com"
REDIS_URL="redis://san-re-41v4ud2cwljl.ruzbk7.0001.use1.cache.amazonaws.com:6379/0"

# DB Password
DB_PASSWORD="SanosPass123!"

# Rutas a los repositorios (ajusta si es necesario)
USUARIOS_DIR="./usuarios_serv"
AUTH_DIR="./auth_serv"
MASCOTAS_DIR="./mascotas_serv"
BFF_DIR="./bff_serv"
NOTICIAS_DIR="./noticias_serv"
NOTIFICACIONES_DIR="./notificaciones_serv"
FRONTEND_DIR="./frontend_sys"

echo "===================================================="
echo "   SanosYSalvos - Deploy a AWS EKS"
echo "===================================================="
echo "  ECR URL  : ${ECR_URL}"
echo "  Cluster  : ${CLUSTER_NAME}"
echo "  Region   : ${REGION}"
echo "===================================================="

echo ""
echo "Actualizando kubeconfig..."
aws eks update-kubeconfig \
  --region ${REGION} \
  --name ${CLUSTER_NAME}

echo ""
echo "Instalando Metrics Server..."
kubectl apply -f \
  https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

echo ""
echo "Login ECR..."
aws ecr get-login-password \
  --region ${REGION} | \
docker login \
  --username AWS \
  --password-stdin ${ECR_URL}

####################################################
# BUILD Y PUSH IMÁGENES
####################################################

echo ""
echo "Build usuarios_serv..."
docker build -t sanos-usuarios-serv ${USUARIOS_DIR}
docker tag sanos-usuarios-serv:latest ${ECR_URL}/sanos-usuarios-serv:v1
docker push ${ECR_URL}/sanos-usuarios-serv:v1

echo ""
echo "Build auth_serv..."
docker build -t sanos-auth-serv ${AUTH_DIR}
docker tag sanos-auth-serv:latest ${ECR_URL}/sanos-auth-serv:v1
docker push ${ECR_URL}/sanos-auth-serv:v1

echo ""
echo "Build mascotas_serv..."
docker build -t sanos-mascotas-serv ${MASCOTAS_DIR}
docker tag sanos-mascotas-serv:latest ${ECR_URL}/sanos-mascotas-serv:v1
docker push ${ECR_URL}/sanos-mascotas-serv:v1

echo ""
echo "Build FastAPI IA..."
docker build -t sanos-fastapi-ia -f ${MASCOTAS_DIR}/Dockerfile.ia ${MASCOTAS_DIR}
docker tag sanos-fastapi-ia:latest ${ECR_URL}/sanos-fastapi-ia:v1
docker push ${ECR_URL}/sanos-fastapi-ia:v1

echo ""
echo "Build bff_serv..."
docker build -t sanos-bff-serv ${BFF_DIR}
docker tag sanos-bff-serv:latest ${ECR_URL}/sanos-bff-serv:v1
docker push ${ECR_URL}/sanos-bff-serv:v1

echo ""
echo "Build noticias_serv..."
docker build -t sanos-noticias-serv ${NOTICIAS_DIR}
docker tag sanos-noticias-serv:latest ${ECR_URL}/sanos-noticias-serv:v1
docker push ${ECR_URL}/sanos-noticias-serv:v1

echo ""
echo "Build notificaciones_serv..."
docker build -t sanos-notificaciones-serv ${NOTIFICACIONES_DIR}
docker tag sanos-notificaciones-serv:latest ${ECR_URL}/sanos-notificaciones-serv:v1
docker push ${ECR_URL}/sanos-notificaciones-serv:v1

echo ""
echo "Build frontend..."
docker build -t sanos-frontend \
  --build-arg VITE_API_BASE_URL=http://BFF_LOAD_BALANCER_URL/api \
  --build-arg VITE_LOCATIONIQ_KEY=pk.440543f1cc8f7842051d030abe72fb31 \
  --build-arg VITE_IMGBB_API_KEY=a8b8d63944d3b3c0c4e2aff5fdcc6403 \
  ${FRONTEND_DIR}
docker tag sanos-frontend:latest ${ECR_URL}/sanos-frontend:v1
docker push ${ECR_URL}/sanos-frontend:v1

####################################################
# KUBERNETES
####################################################

echo ""
echo "Creando namespace..."
kubectl apply -f ./k8s/namespace.yaml

echo ""
echo "Creando secrets..."
kubectl apply -f ./k8s/secrets.yaml

echo ""
echo "Reemplazando ECR_URL en manifests..."
find ./k8s -type f -name "*.yaml" \
  -exec sed -i "s|{{ECR_URL}}|${ECR_URL}|g" {} \;

echo ""
echo "Desplegando microservicios..."
kubectl apply -f ./k8s/usuarios-deployment.yaml
kubectl apply -f ./k8s/auth-deployment.yaml
kubectl apply -f ./k8s/mascotas-deployment.yaml
kubectl apply -f ./k8s/fastapi-ia-deployment.yaml
kubectl apply -f ./k8s/noticias-deployment.yaml
kubectl apply -f ./k8s/notificaciones-deployment.yaml
kubectl apply -f ./k8s/bff-deployment.yaml
kubectl apply -f ./k8s/frontend-deployment.yaml
kubectl apply -f ./k8s/celery-deployment.yaml

echo ""
echo "Esperando que los pods queden Ready..."
kubectl rollout status deployment/sanos-usuarios -n sanosysalvos --timeout=300s
kubectl rollout status deployment/sanos-auth -n sanosysalvos --timeout=300s
kubectl rollout status deployment/sanos-mascotas -n sanosysalvos --timeout=300s
kubectl rollout status deployment/sanos-bff -n sanosysalvos --timeout=300s
kubectl rollout status deployment/sanos-frontend -n sanosysalvos --timeout=300s

####################################################
# LOAD BALANCER URL
####################################################

echo ""
echo "Esperando LoadBalancer del frontend..."
for i in $(seq 1 40); do
  HOSTNAME=$(kubectl get svc sanos-frontend \
    -n sanosysalvos \
    -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)

  if [ ! -z "$HOSTNAME" ]; then
    echo ""
    echo "===================================================="
    echo "  APLICACIÓN DISPONIBLE EN:"
    echo "  http://${HOSTNAME}"
    echo "===================================================="

    echo ""
    echo "IMPORTANTE: Ahora actualiza el frontend con la URL del BFF:"
    BFF_URL=$(kubectl get svc sanos-bff \
      -n sanosysalvos \
      -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
    echo "  BFF URL: http://${BFF_URL}"
    echo "  Rebuild el frontend con esa URL y vuelve a hacer push."
    exit 0
  fi

  echo "Esperando IP pública... (${i}/40)"
  sleep 15
done

echo ""
echo "Verificar manualmente con:"
echo "  kubectl get svc -n sanosysalvos"
