#!/bin/sh
set -e
#set -x

# Check if CLI_REALM environment variable is set
if [ -z "$CLI_REALM" ]; then
  echo "Error: CLI_REALM environment variable not set."
  exit 1
fi

# Check if CLI_ROLES environment variable is set
if [ -z "$CLI_ROLES" ]; then
  echo "Error: CLI_ROLES environment variable not set."
  exit 1
fi

# Check if CLI_CLIENT environment variable is set
if [ -z "$CLI_CLIENT" ]; then
  echo "Error: CLI_CLIENT environment variable not set."
  exit 1
fi

# Check if CLI_ADMIN_CLIENT environment variable is set
if [ -z "$CLI_ADMIN_CLIENT" ]; then
  echo "Error: CLI_ADMIN_CLIENT environment variable not set."
  exit 1
fi

# Check if CLI_ADMIN_CLIENT environment variable is set
if [ -z "$CLI_ACCESS_TOKEN_LIFESPAN" ]; then
  echo "Error: CLI_ACCESS_TOKEN_LIFESPAN environment variable not set."
  exit 1
fi

if [ -z "$KEYCLOAK_SERVER" ]; then
  echo "Error: KEYCLOAK_SERVER environment variable not set."
  exit 1
fi

# Function to check if a realm exists
realm_exists() {
  realm="$1"
  kcadm.sh get realms/$realm > /dev/null 2>&1
}

# Function to check if a role exists in a realm
role_exists() {
  realm="$1"
  role="$2"
  kcadm.sh get roles -r "$realm" | grep -q "\"name\" : \"$role\"" > /dev/null 2>&1
}

# Function to check if client exists
client_exists() {
  realm="$1"
  client_name="$2"
  kcadm.sh get clients -r "$realm" -q "clientId=$client_name" | jq -e '.[0]'
}

print_section() {
  cols=50
  message="$1"
  for i in $(seq 1 $cols); do printf "#"; done
  printf "\n"
  echo -e "\t\t$message"
  for i in $(seq 1 $cols); do printf "#"; done
  printf "\n"
}

# Login into keycloak instance
echo "Logging into keycloak"
kcadm.sh config credentials --server $KEYCLOAK_SERVER --realm master --user $KEYCLOAK_ADMIN --password $KEYCLOAK_ADMIN_PASSWORD

print_section "Configuring realm"

# Check if the realm already exists
echo "Checking realm"
if realm_exists "$CLI_REALM"; then
  echo "Realm $CLI_REALM already exists. Skipping realm creation."
else
  # Create Keycloak realm
  echo "Creating Keycloak realm: $CLI_REALM"
  kcadm.sh create realms -s realm="$CLI_REALM" -s enabled=true
fi

# Configure access token lifespan
echo "Configuring access token lifespan"
kcadm.sh update realms/$CLI_REALM -s accessTokenLifespan=$CLI_ACCESS_TOKEN_LIFESPAN

# Extract roles from CLI_ROLES and create each role if it doesn't exist
echo "Checking roles"
for role in $(echo $CLI_ROLES | tr ',' ' '); do
  if role_exists "$CLI_REALM" "$role"; then
    echo "Role $role already exists in realm $CLI_REALM. Skipping role creation."
  else
    echo "Creating role: $role"
    kcadm.sh create roles -r "$CLI_REALM" -s name="$role" -s description="Role for $role"
  fi
done

print_section "Configuring client"

echo "Checking client"
if client_exists "$CLI_REALM" "$CLI_CLIENT"; then
  echo "Client $CLI_CLIENT already exists. Skipping client creation."
else
  echo "Creating client: $CLI_CLIENT"
  kcadm.sh create clients -r "$CLI_REALM" -s clientId="$CLI_CLIENT" -s directAccessGrantsEnabled=true -s standardFlowEnabled=true -s clientAuthenticatorType=client-secret
fi

print_section "Configuring admin client"

echo "Checking admin client"
if client_exists "$CLI_REALM" "$CLI_ADMIN_CLIENT"; then
  echo "Client $CLI_ADMIN_CLIENT already exists. Skipping client creation."
else
  echo "Creating client: $CLI_ADMIN_CLIENT"
  kcadm.sh create clients -r "$CLI_REALM" -s clientId="$CLI_ADMIN_CLIENT" -s directAccessGrantsEnabled=true -s standardFlowEnabled=true -s clientAuthenticatorType=client-secret -s serviceAccountsEnabled=true
fi

# Retrieve client realm-management id
echo "Retrieving realm management id"
REALM_MANAGEMENT_ID=$(kcadm.sh get clients -r $CLI_REALM -q "clientId=realm-management" | jq .[0].id | tr -d '"')

# Retrieve roles for realm management
echo "Retrieving realm management roles"
REALM_MANAGEMENT_ROLES=$(kcadm.sh get clients/$REALM_MANAGEMENT_ID/roles -r $CLI_REALM)

for row in $(echo "$REALM_MANAGEMENT_ROLES" | jq -c .[]); do
  NAME=$(echo "$row" | jq -r '.name')
  echo "Adding $NAME role to service-account-$CLI_ADMIN_CLIENT"
  kcadm.sh add-roles -r $CLI_REALM --uusername "service-account-$CLI_ADMIN_CLIENT" --cclientid realm-management --rolename "$NAME"
done
echo "Keycloak configuration completed."