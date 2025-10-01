# Cheese Factory Terraform

Este proyecto crea 3 servidores web con diferentes tipos de queso usando contenedores Docker.

## Despliegue

- Instancias EC2 con Terraform
- Usar Docker en servidores de AWS
- Configurar redes (VPC y subnets)
- Variables en Terraform
- Base de datos RDS

## Instrucciones para el Profesor

1. **Clonar el repositorio**
```bash
git clone https://github.com/edoturb/chesse-factory-terraform.git
cd chesse-factory-terraform
```

2. **El proyecto está listo para revisar**
   - Código Terraform completo y funcional
   - Configuración ejemplo disponible
   - Documentación técnica en los comentarios del código

## 📁 Estructura del Proyecto

```
cheese-factory-terraform/
├── main.tf                    # Configuración principal de recursos
├── variables.tf              # Definición de variables
├── outputs.tf                # Valores de salida
├── terraform.tfvars.example  # Plantilla de configuración
├── .gitignore               # Archivos ignorados por Git
└── README.md               # Esta documentación
```
