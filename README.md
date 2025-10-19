# PNG-Provisioner

# Conectarse a la Vm
ssh -i "TEF-INGSIS_key2.pem" tef@20.200.120.244


# Levantar todos los servicios
docker compose up -d

# Levantar servicios específicos
docker compose up -d formatter-api snippet-service-api

# Ver logs
docker compose logs -f

# Ver estado
docker compose ps

# Detener todo
docker compose down

# Detener y eliminar volúmenes
docker compose down -v

# Levantar Todos Los Container
chmod +x start-docker.sh
./start-docker.sh

# Actualizar todos los servicios
chmod +x update.sh
./update.sh
