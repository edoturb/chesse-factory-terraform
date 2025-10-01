# Cheese Factory Terraform

Este proyecto crea 3 servidores web con diferentes tipos de queso usando contenedores Docker.

## Despliegue

- Instancias EC2 con Terraform
- Usar Docker en servidores de AWS
- Configurar redes (VPC y subnets)
- Variables en Terraform
- Base de datos RDS


## � Cómo Usar Este Proyecto

### Prerrequisitos
- [Terraform](https://www.terraform.io/downloads.html) instalado (v1.0+)
- Cuenta de AWS con permisos de administrador
- [AWS CLI](https://aws.amazon.com/cli/) configurado
- Par de claves EC2 creado en AWS

### Pasos para Desplegar

1. **Clonar el repositorio**
```bash
git clone https://github.com/edoturb/chesse-factory-terraform.git
cd chesse-factory-terraform
```

2. **Configurar credenciales de AWS**
```bash
aws configure
# Ingresa tu Access Key ID, Secret Access Key, región (us-east-1) y formato (json)
```

3. **Crear archivo de configuración**
```bash
cp terraform.tfvars.example terraform.tfvars
```

4. **Editar terraform.tfvars con tus valores**
```bash
# Ejemplo de configuración:
region = "us-east-1"
key_name = "tu-key-pair"  # Debe existir en AWS
db_password = "TuPassword123!"
```

5. **Inicializar y desplegar**
```bash
terraform init
terraform plan
terraform apply
```

6. **Probar la aplicación**
- Copia la URL del Load Balancer del output
- Abre en navegador para ver los diferentes quesos
- Refresca la página para ver quesos diferentes

7. **Limpiar recursos (IMPORTANTE)**
```bash
terraform destroy
```

## �📁 Estructura del Proyecto

```
cheese-factory-terraform/
├── main.tf                    # Configuración principal de recursos
├── variables.tf              # Definición de variables
├── outputs.tf                # Valores de salida
├── terraform.tfvars.example  # Plantilla de configuración
├── .gitignore               # Archivos ignorados por Git
└── README.md               # Esta documentación
```

## ⚠️ Notas Importantes

- **Costos**: Este proyecto crea recursos en AWS que generan costos
- **Región**: Configurado para us-east-1 por defecto
- **Limpieza**: Siempre ejecuta `terraform destroy` al terminar
- **Seguridad**: Nunca subas tu archivo `terraform.tfvars` a Git


