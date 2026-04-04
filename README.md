# Terraform AWS infraestructure

**Descripción**
Infraestructura gestionada con Terraform (IaC)

- 3 EC2's (y la tecnología correspondiente):
    - Web_server -> Docker, Git y Nginx
    - Back_server -> Docker y Git
    - Data_server -> MariaDB(Mysql)
*Las instancias poseen el mínimo privilegio mediante IAM y SG's.*



> *PD: las instancias esperarán hasta que puedan conectarse con google y empezará la instalación de paquetes.*

## 📂 Infraestructura del proyecto

````
eva1/
├── backend #futura implementación
├── frontend #futura implementación
├── infra/
│ ├── main.tf
│ ├── iam.tf
│ ├── compute.tf
│ ├── keys.tf
│ ├── network.tf
│ ├── security.tf
├──  .gitignore
└── README.md
````
**Desglose**

| Lista | Descripción |
| ------------- | ------ |
| Compute   | Conlleva la información de templates y la formación de instancias. |
| network        | Posee la información de redes en donde se situan las máquinas y su comunicación con el mundo. |
| security  | Creación de los Secutiry Groups (limitación de la comunicación de entrada y salida). |

> *Solo se implementará la estructura de infra, puesto backend y frontend no cumplen funciones en estos momentos.*

## 🛠️ Requisitos previos

- Terraform v1.1x + (`terraform --version`)
- AWS CLI (`aws --version`)
- tener la llave.pem descargada del laboratorio ya iniciado (EC2 - key-pair).

## ⚙️ Indicaciones y sugerencias para infra
Procura cambiar los siguientes archivos por la información que poseas:

- **main.tf** -> region -> La región a la que pertenescas.
- **iam.tf** -> Solo si no se posee el ya escrito.
- **Security.tf** -> ingress ssh -> cird_blocks -> tu ip de pc (Ipv4).
- **compute.tf** -> image.id -> la id de tu imagen AMI según tu región.
- **network.tf** -> "aws_subnet" -> availability_zone -> cambia esto en las subnets según tu zona de disponibilidad.
- **keys.tf** -> public_key -> La llave generada mediante el comando `ssh-keygen -y -f "mi-llave.pem"` (Requiere la creación de una llave .pem primero y la ubiación luego de la descarga de la llave).

**Mejoras en posibles cambios**

Si llegas a cambiar el código de infra, según las sugerencias, usa:
- `terraform fmt` (Estética.)
- `terraform validate` (Procura que los resources estén bien escritos.)

## 🚀 Despliege
Luego de los cambios sugeridos (y algunos obligatorios), usa:
- `terraform init`
- `terraform plan` (Es necesario configurar aws con el lab, usa: `aws configure`)
- `terraform apply`

- Para entrar al front mediante SSH:
    - ubicate en el directorio de la llave privada
    - escribe el ejemplo de front del cliente SSH
    - usa la llave privada ya descargada para entrar ("llave_deluxe.pem" o algo así)

- Para entrar al backend_server mediante SSH debes poseer la llave privada:
    - `nano llave.pem` (para crear el archivo en el **Front_server**)
    - debes pegar la llave privada dentro y guardar.
    - cambia los permisos a 400 de la llave creada con nano
    - dentro del front_server, usa la plantilla de ssh y usa la llave creada

Para el data_server, entra al backend_server y repite los pasos, luego pon la plantilla de SSH de data_server y podras entrar.

Para ver el estado de instalación en las instancias, usa: `sudo tail -f /var/log/cloud-init-output.log`
(Se puede desde cualquier punto)

Para apagar las instancias, usa:
- `terraform destroy`

### Opcional

para ver que la bdd responde desde el back, usa: `nc -zv <IP_PRIVADA_DATA_SERVER> 3306`
(deberia responder con *succeeded!*)



## 📦 Diagrama de AWS

![DiagramaAWS](image/daws2.png)

> *Futuro: AWS Fargate (serverless)*


