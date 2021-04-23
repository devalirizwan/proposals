CREATE USER $POSTGRES_USER WITH ENCRYPTED PASSWORD '$POSTGRES_PASSWORD';
CREATE DATABASE proposals_test OWNER=$POSTGRES_USER ENCODING 'UTF8' LC_COLLATE='en_US.utf8' LC_CTYPE='en_US.utf8';
CREATE DATABASE proposals_development OWNER=$POSTGRES_USER ENCODING 'UTF8' LC_COLLATE='en_US.utf8' LC_CTYPE='en_US.utf8';
CREATE DATABASE proposals_production OWNER=$POSTGRES_USER ENCODING 'UTF8' LC_COLLATE='en_US.utf8' LC_CTYPE='en_US.utf8';
GRANT ALL PRIVILEGES ON DATABASE proposals_test to $POSTGRES_USER;
GRANT ALL PRIVILEGES ON DATABASE proposals_development to $POSTGRES_USER;
GRANT ALL PRIVILEGES ON DATABASE proposals_production to $POSTGRES_USER;
