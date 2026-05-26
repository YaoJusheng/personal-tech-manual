#!/bin/bash
mongo <<EOF
use admin;
db.createUser({ user: 'root', pwd: '123456', roles: [ { role: "userAdminAnyDatabase", db: "admin" } ] });

use new_db;
db.createCollection("collection1");
db.createCollection("collection2");
EOF

mongoimport --db new_db --collection collection1 --file "$WORKSPACE"/test1.json
mongoimport --db new_db --collection collection2 --file "$WORKSPACE"/test2.json

# 在docker-compose.yml目录下执行
# docker-compose up -d
