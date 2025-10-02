# Cheese Factory Terraform

Este proyecto crea 3 servidores web con diferentes tipos de queso usando contenedores Docker y una base de datos RDS MySQL.

- 3 Instancias EC2** con contenedores Docker (Wensleydale, Cheddar, Stilton)
- Application Load Balancer** para distribuir tráfico
- VPC con subnets públicas y privadas
- Base de datos RDS MySQL** para almacenamiento
- Security Groups** configurados



1. Clonar el repositorio
```bash
git clone https://github.com/edoturb/chesse-factory-terraform.git
cd chesse-factory-terraform
```

 2. Configurar credenciales AWS
```bash
aws configure
# o
aws sso login
```

 3Configurar variables requeridas
Copia el archivo de ejemplo y configúralo:
```bash
cp terraform.tfvars.example terraform.tfvars
```

Edita `terraform.tfvars` con tus valores:
```hcl
# OBLIGATORIAS - Debes configurar estos valores
my_ip = "TU_IP_PUBLICA/32"        # Obtener con: curl ifconfig.me
key_name = "TU_AWS_KEY_PAIR"      # Tu AWS Key Pair existente
db_password = "TuContraseñaSegura123!"  # Contraseña para la base de datos

# OPCIONALES - Puedes cambiar si quieres
# aws_region = "us-west-2"
# instance_count = 3
# instance_type = "t2.small"
```

### 4. **Desplegar la infraestructura**
```bash
terraform init
terraform plan
terraform apply
```

## 📁 Estructura del Proyecto

```
cheese-factory-terraform/
│
├── main.tf                   # Recursos AWS (VPC, EC2, ALB, RDS)
├── variables.tf             # Variables de entrada
├── outputs.tf               # Salidas del proyecto
├── user-data.sh             # Configuración inicial de EC2
├── terraform.tfvars.example # Plantilla de variables
└── README.md                # Documentación
```

### Archivos principales:
- **`main.tf`** - Infraestructura completa (25 recursos)
- **`variables.tf`** - Configuración personalizable
- **`terraform.tfvars.example`** - Valores de ejemplo

## 🔧 Notas Técnicas

- **RDS:** La base de datos puede tardar 8-10 minutos en crearse
- **Aplicación:** Las instancias tardan 2-3 minutos adicionales en estar listas después del despliegue
- **Variables:** Todas las variables obligatorias deben configurarse en `terraform.tfvars`


