 Cheese Factory Terraform-AWS

Este proyecto despliega 3 servidores web con diferentes tipos de queso usando contenedores Docker y una base de datos RDS MySQL.

 Arquitectura

- 3 Instancias EC2 con contenedores Docker (Wensleydale, Cheddar, Stilton)
- Application Load Balancer para distribuir tráfico
- VPC con subnets públicas y privadas
- Base de datos RDS MySQL
- Security Groups configurados

 Despliegue

Para desplegar este proyecto necesitas tener configurado AWS CLI y Terraform instalado. El proceso creará automáticamente toda la infraestructura necesaria en AWS. 

 1. Configurar variables
```bash
cp terraform.tfvars.example terraform.tfvars
```
Editar `terraform.tfvars` con tus valores:
```hcl
my_ip = "TU_IP_PUBLICA/32"        # curl ifconfig.me
key_name = "TU_AWS_KEY_PAIR"      # aws ec2 describe-key-pairs
db_password = "TuContraseñaSegura123!"
```

 2. Ejecutar despliegue
```bash
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

 3. Obtener URL de la aplicación
```bash
terraform output alb_url
```

 Recursos Desplegados

- **VPC** con subnets públicas y privadas
- **3 EC2** t2.micro con contenedores Docker  
- **ALB** para distribución de tráfico
- **RDS MySQL** 8.0 en subnets privadas
- **Security Groups** configurados

 Limpieza

```bash
terraform destroy -var-file="terraform.tfvars"
```

## Troubleshooting - Errores Comunes en Windows

### Error: CIDR block inválido
Si obtienes un error de CIDR block inválido, verifica que tu IP esté en formato correcto:
```bash
# Obtener tu IP pública
curl ifconfig.me
# O usar PowerShell en Windows
Invoke-RestMethod -Uri "https://ifconfig.me/ip"
```
Tu IP debe estar en formato: `"TU_IP/32"` (ejemplo: `"203.0.113.1/32"`)

### Error: Security Group dependency
Este error ocurre cuando hay recursos previos. Solucion:
```bash
terraform refresh
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

### Error: Target Group "cheese-tg" already exists
Esto indica un despliegue previo incompleto. Opciones:
1. **Destruir recursos previos:**
```bash
terraform destroy -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```
2. **O importar el estado existente:**
```bash
terraform refresh
terraform plan -var-file="terraform.tfvars"
```

### Configuración AWS CLI en Windows
Asegúrate de tener AWS CLI configurado:
```cmd
aws configure
aws sts get-caller-identity
```





