#!/bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo "Starting user-data script at $(date)"

# Actualizar sistema
yum update -y

# Instalar Docker Community Edition (método recomendado para Amazon Linux 2023)
yum install -y docker

# Para Amazon Linux 2023, también instalar containerd
yum install -y containerd

# Instalar cliente MySQL y AWS CLI para conectarse a RDS
yum install -y mysql awscli

# Iniciar y habilitar Docker
systemctl start docker
systemctl enable docker

# Agregar usuario al grupo docker
usermod -a -G docker ec2-user

# Esperar a que Docker esté completamente iniciado
echo "Waiting for Docker to be ready..."
sleep 30

# Verificar versión de Docker instalada
docker --version

# Verificar que Docker esté funcionando
echo "Checking Docker status..."
docker info

# Descargar y ejecutar la imagen específica de queso
echo "Starting cheese container: ${docker_image}"
echo "Pulling Docker image..."
docker pull ${docker_image}

if [ $? -eq 0 ]; then
    echo "Docker image pulled successfully"
else
    echo "ERROR: Failed to pull Docker image ${docker_image}"
    exit 1
fi

# Parar cualquier contenedor previo
docker stop cheese-app 2>/dev/null || true
docker rm cheese-app 2>/dev/null || true

# Iniciar el nuevo contenedor
echo "Starting Docker container..."
docker run -d --restart=always --name=cheese-app -p 80:80 ${docker_image}

if [ $? -eq 0 ]; then
    echo "Container started successfully"
else
    echo "ERROR: Failed to start container"
    exit 1
fi

# Esperar un momento para que el contenedor se inicialice
sleep 10

# Verificar que el contenedor esté ejecutándose
echo "Container status:"
docker ps
docker logs cheese-app

# Verificar que el servicio responda
echo "Testing service response..."
curl -s http://localhost:80 || echo "Service not responding yet"

echo "User-data script completed at $(date)"
