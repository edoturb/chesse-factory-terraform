# Cheese Factory Terraform

Este proyecto despliega 3 servidores web con diferentes tipos de queso usando contenedores Docker y una base de datos RDS MySQL.

## Arquitectura

- 3 Instancias EC2 con contenedores Docker (Wensleydale, Cheddar, Stilton)
- Application Load Balancer para distribuir tráfico
- VPC con subnets públicas y privadas
- Base de datos RDS MySQL
- Security Groups configurados

## Despliegue

Para desplegar este proyecto necesitas tener configurado AWS CLI y Terraform instalado. El proceso creará automáticamente toda la infraestructura necesaria en AWS.

### 1. Configurar variables
```bash
cp terraform.tfvars.example terraform.tfvars
```
Editar `terraform.tfvars` con tus valores:
```hcl
my_ip = "TU_IP_PUBLICA/32"        # curl ifconfig.me
key_name = "TU_AWS_KEY_PAIR"      # aws ec2 describe-key-pairs
db_password = "TuContraseñaSegura123!"
```

### 2. Ejecutar despliegue
```bash
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

### 3. Obtener URL de la aplicación
```bash
terraform output alb_url
```

## Recursos Desplegados

- **VPC** con subnets públicas y privadas
- **3 EC2** t2.micro con contenedores Docker  
- **ALB** para distribución de tráfico
- **RDS MySQL** 8.0 en subnets privadas
- **Security Groups** configurados

## Limpieza

```bash
terraform destroy -var-file="terraform.tfvars"
```





