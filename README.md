# 🧀 Cheese Factory - AWS Infrastructure con Terraform

[![Terraform](https://img.shields.io/badge/Terraform-v1.13+-623CE4?style=flat&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-EC2%20%7C%20RDS%20%7C%20VPC-FF9900?style=flat&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)

Infraestructura como código usando Terraform para desplegar 3 instancias EC2 con contenedores Docker de quesos, Application Load Balancer y base de datos MySQL RDS en AWS.

## 🏗️ Componentes

- **3 Instancias EC2** (t2.micro) → Wensleydale, Cheddar, Stilton
- **Application Load Balancer** → Distribución de tráfico
- **RDS MySQL** → Base de datos en subnets privadas
- **VPC + Subnets** → Calculadas automáticamente con `cidrsubnet()`

## 🚀 Despliegue Rápido

### 1. Prerrequisitos
```bash
# Instalar Terraform >= 1.0
# Configurar AWS CLI
aws configure

# Verificar credenciales
aws sts get-caller-identity
```

### 2. Configuración
```bash
# Clonar y configurar
git clone https://github.com/edoturb/chesse-factory-terraform.git
cd chesse-factory-terraform
cp terraform.tfvars.example terraform.tfvars

# Editar terraform.tfvars con tus valores
my_ip    = "$(curl -s ifconfig.me)/32"  # Tu IP pública
key_name = "tu-aws-key-pair"            # Key Pair existente
db_password = "TuPassword123!"          # Contraseña de la BD
```

### 3. Desplegar
```bash
terraform init
terraform plan
terraform apply  # Confirma con 'yes'
```

### 4. Acceder
```bash
# Ver todos los outputs
terraform output

# URL del Load Balancer
terraform output alb_url

# IPs individuales de instancias
terraform output instance_ips
```

## 🧹 Limpiar Recursos
```bash
terraform destroy  # Confirma con 'yes'
```

## 🔧 Troubleshooting

| Error | Solución |
|-------|----------|
| Credenciales AWS | `aws configure` |
| Key Pair no encontrado | `aws ec2 describe-key-pairs` |
| IP cambió | Actualizar `terraform.tfvars` |

## 📄 Variables Principales

```hcl
# terraform.tfvars (requeridas)
my_ip = "TU_IP/32"
key_name = "tu-key-pair"
db_password = "password123"
```

---

**Proyecto de infraestructura como código usando Terraform con funciones nativas y expresiones condicionales**

## 📊 Outputs

El proyecto proporciona varios outputs útiles:

| Output | Descripción | Ejemplo |
|--------|-------------|---------|
| `alb_url` | URL del Application Load Balancer | `http://cheese-alb-123456789.us-east-1.elb.amazonaws.com` |
| `instance_ips` | IPs públicas de las 3 instancias | `["3.92.198.198", "34.204.40.24", "54.234.110.218"]` |
| `instance_ids` | IDs de las instancias EC2 | `["i-0d08d15a7bdd92945", ...]` |
| `db_endpoint` | Endpoint de la base de datos RDS | `cheese-factory-db.xyz.rds.amazonaws.com` |
| `db_port` | Puerto de la base de datos | `3306` |
| `vpc_id` | ID de la VPC creada | `vpc-07cb77b26876235a9` |

```bash
# Ver todos los outputs
terraform output

# Ver un output específico
terraform output alb_url
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

## � Demo

Una vez desplegado, puedes acceder a cada tipo de queso:

### 🧀 Wensleydale (Instancia Primaria)
```bash
curl http://3.92.198.198
# Muestra la página del queso Wensleydale
```

### 🧀 Cheddar
```bash
curl http://34.204.40.24  
# Muestra la página del queso Cheddar
```

### 🧀 Stilton
```bash
curl http://54.234.110.218
# Muestra la página del queso Stilton
```

> **Nota**: Las IPs específicas pueden variar en tu despliegue. Usa `terraform output instance_ips` para obtener las tuyas.

## �🏷️ Tags y Etiquetado

El proyecto implementa un sistema de etiquetado consistente:
- **Name**: Identificador único para cada recurso
- **IsPrimary**: Marca la instancia principal (Wensleydale) como `true`
- **Environment**: Se asigna automáticamente basado en el tamaño de almacenamiento RDS

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para detalles.

## 🤝 Contribuir

Las contribuciones son bienvenidas. Para cambios importantes:

1. Abre un issue para discutir el cambio
2. Fork el repositorio
3. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
4. Commit tus cambios (`git commit -m 'Add: Amazing Feature'`)
5. Push a la rama (`git push origin feature/AmazingFeature`)
6. Abre un Pull Request

## ⭐ ¿Te Gustó el Proyecto?

Si este proyecto te resultó útil, considera:
- ⭐ Darle una estrella al repositorio
- 🍴 Fork para crear tu propia versión
- 📢 Compartirlo con otros

---

<div align="center">

**🧀 ¡Disfruta tu fábrica de quesos virtual construida con Terraform! ✨**

[![Made with ❤️](https://img.shields.io/badge/Made%20with-❤️-red.svg)]()
[![Terraform](https://img.shields.io/badge/Infrastructure-Terraform-623CE4?logo=terraform)]()
[![AWS](https://img.shields.io/badge/Cloud-AWS-FF9900?logo=amazon-aws)]()

[🐛 Reportar Bug](https://github.com/TU-USUARIO/chesse-factory-terraform/issues) • [💡 Solicitar Feature](https://github.com/TU-USUARIO/chesse-factory-terraform/issues) • [📖 Documentación](https://github.com/TU-USUARIO/chesse-factory-terraform/blob/main/README.md)

</div>
