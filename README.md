Cheese Factory Terraform

Este proyecto crea 3 servidores web con diferentes tipos de queso usando contenedores Docker y una base de datos RDS MySQL.

- 3 Instancias EC2 con contenedores Docker (Wensleydale, Cheddar, Stilton)
- Application Load Balancer para distribuir tráfico
- VPC con subnets públicas y privadas
- Base de datos RDS MySQL para almacenamiento
- Security Groups configurados



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

3. Configurar variables requeridas
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



Estructura del Proyecto

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


