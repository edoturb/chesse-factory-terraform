# Cheese Factory - AWS Infrastructure con Terraform

Despliegue automatizado de una aplicación web con imagenes de quesos usando Terraform en AWS. El proyecto crea 3 servidores EC2 con diferentes tipos de queso en contenedores Docker, distribuidos por un Application Load Balancer.

##  Arquitectura

- **3 Instancias EC2** (t2.micro) con contenedores Docker
- **Application Load Balancer** para distribución de tráfico
- **VPC** con subnets públicas y privadas calculadas automáticamente
- **Base de Datos RDS MySQL** con almacenamiento cifrado
- **Security Groups** configurados para acceso HTTP/SSH/MySQL

### Tipos de Queso Disponibles:
-  **Wensleydale** (`errm/cheese:wensleydale`) - **Instancia Primaria**
-  **Cheddar** (`errm/cheese:cheddar`)
-  **Stilton** (`errm/cheese:stilton`)

##  Conceptos de Terraform Implementados

### Variables Reutilizables
- **`aws_region`**: Región de AWS para el despliegue
- **`instance_type`**: Tipo de instancia EC2 (t2.micro por defecto)
- **`cheese_images`**: Lista de imágenes Docker de quesos
- **`vpc_cidr`**: Rango CIDR para la VPC
- **`instance_count`**: Número de instancias a crear
- **`db_password`**: Contraseña para la base de datos RDS (sensible)
- **`db_instance_class`**: Clase de instancia RDS (db.t3.micro por defecto)
- **`db_allocated_storage`**: Almacenamiento de la base de datos en GB

### Expresiones Condicionales
```hcl
# Instancias EC2 - Tag IsPrimary
tags = {
  Name      = "cheese-web-${count.index + 1}"
  IsPrimary = count.index == 0 ? "true" : "false"  # Solo la primera instancia (Wensleydale)
}

# Base de Datos RDS - Configuración condicional
backup_retention_period = length(var.cheese_images) > 2 ? 7 : 3  # 7 días si hay más de 2 quesos
Environment = var.db_allocated_storage > 20 ? "production" : "development"  # Tag según almacenamiento
```
La primera instancia (índice 0) que ejecuta Wensleydale recibe el tag `IsPrimary = "true"`. La base de datos ajusta automáticamente la retención de backups y etiquetas según la configuración.

### Funciones Nativas (Built-in Functions)

#### 1. `cidrsubnet()` - Cálculo Automático de Subnets
```hcl
# Subnets públicas para instancias EC2
cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index)

# Subnets privadas para base de datos RDS  
cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index + 10)
```
**Propósito**: Calcula automáticamente los rangos CIDR para cada subnet.
- **VPC CIDR**: `10.0.0.0/16`
- **Subnets Públicas**: `10.0.0.0/24`, `10.0.1.0/24`, `10.0.2.0/24`
- **Subnets Privadas**: `10.0.10.0/24`, `10.0.11.0/24` (para RDS)

#### 2. `element()` - Selección de Elementos de Lista
```hcl
availability_zone = element(data.aws_availability_zones.available.names, count.index)
docker_image = element(var.cheese_images, count.index)
```
**Propósito**: Selecciona elementos de listas de forma cíclica y segura.
- Distribuye instancias en diferentes zonas de disponibilidad
- Asigna imágenes Docker específicas a cada instancia

#### 3. `count.index` - Indexación Automática
**Propósito**: Crea recursos múltiples con identificadores únicos.
- Genera nombres únicos para recursos
- Asigna configuraciones específicas por instancia

## ⚡ Despliegue Rápido

### 1. Prerrequisitos
- [Terraform](https://www.terraform.io/downloads) >= 1.0
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) configurado
- Cuenta AWS con permisos para EC2, VPC, ELB

### 2. Clonación y Configuración
```bash
# Clonar repositorio
git clone https://github.com/eduturb/cheese-factory-terraform.git
cd cheese-factory-terraform

# Configurar variables
cp terraform.tfvars.example terraform.tfvars
```

### 3. Configurar `terraform.tfvars`
```hcl
# Obtener tu IP pública: curl ifconfig.me
my_ip    = "TU_IP_PUBLICA/32"    # Ejemplo: "203.0.113.1/32"
key_name = "TU_AWS_KEY_PAIR"     # Tu AWS Key Pair name
```

### 4. Desplegar Infraestructura
```bash
# Inicializar Terraform
terraform init

# Revisar plan
terraform plan

# Aplicar (confirmar con 'yes')
terraform apply
```

### 5. Acceder a la Aplicación
```bash
# Obtener URL del Load Balancer
terraform output alb_url
```

## 🌐 Acceso

### Load Balancer (Recomendado)
- **URL**: Se muestra en `terraform output alb_url`
- **Comportamiento**: Distribuye tráfico entre los 3 tipos de queso
- **Uso**: Refrescar página para ver diferentes quesos

### Acceso Directo a Instancias
```bash
# Obtener IPs individuales
terraform output instance_ips
```

## ⚙️ Variables Configurables

| Variable | Descripción | Valor por Defecto | Requerido |
|----------|-------------|-------------------|-----------|
| `my_ip` | Tu IP pública para SSH | - | **Sí** |
| `key_name` | Nombre del AWS Key Pair | - | **Sí** |
| `aws_region` | Región de AWS | `us-east-1` | No |
| `instance_count` | Número de instancias | `3` | No |
| `instance_type` | Tipo de instancia EC2 | `t2.micro` | No |
| `vpc_cidr` | CIDR de la VPC | `10.0.0.0/16` | No |
| `cheese_images` | Lista de imágenes Docker | Ver `variables.tf` | No |

## 📁 Estructura del Proyecto

```
cheese-factory-terraform/
├── main.tf                    # Configuración principal de recursos
├── variables.tf              # Definición de variables
├── outputs.tf                # Valores de salida
├── terraform.tfvars.example  # Plantilla de configuración
├── terraform.tfvars         # Configuración local (ignorado por Git)
├── .gitignore               # Archivos ignorados
├── LICENSE                  # Licencia MIT
└── README.md               # Esta documentación
```

## 🧹 Limpieza

Para destruir toda la infraestructura:
```bash
terraform destroy
```
⚠️ **Confirma con 'yes'** - Esta acción es irreversible.

## 🔧 Solución de Problemas

### Error: Credenciales AWS
```bash
aws configure
aws sts get-caller-identity
```

### Error: Key Pair no encontrado
```bash
# Ver key pairs disponibles
aws ec2 describe-key-pairs

# Crear nuevo key pair
aws ec2 create-key-pair --key-name mi-key --output text --query 'KeyMaterial' > mi-key.pem
chmod 400 mi-key.pem
```

### Error: IP cambió
```bash
# Obtener nueva IP
curl ifconfig.me

# Actualizar terraform.tfvars y aplicar
terraform apply
```

## 💰 Costos Estimados

- **Instancias t2.micro**: Incluidas en AWS Free Tier (primeros 12 meses)
- **Application Load Balancer**: ~$16-20/mes
- **Transferencia de datos**: Mínima para pruebas

> 💡 **Tip**: Ejecuta `terraform destroy` después de las pruebas para evitar costos.

## 🏷️ Tags y Etiquetado

El proyecto implementa un sistema de etiquetado consistente:
- **Name**: Identificador único para cada recurso
- **IsPrimary**: Marca la instancia principal (Wensleydale) como `true`

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para detalles.

---

**¡Disfruta tu fábrica de quesos virtual construida con Terraform!** 🧀✨

Para reportar problemas o sugerencias, abre un [issue](https://github.com/TU-USUARIO/cheese-factory-terraform/issues).
