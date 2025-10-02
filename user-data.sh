#!/bin/bash
# Actualizar sistema e instalar Docker
yum update -y
yum install -y docker

# Iniciar Docker
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

# Descargar y ejecutar contenedor de queso
docker pull ${docker_image}
docker run -d --restart=always --name=cheese-app -p 80:80 ${docker_image}
