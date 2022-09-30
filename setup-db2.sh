#!/bin/bash
docker pull hftm/oracle-db2
docker run -d --name oradb2 -p 1521:1521 hftm/oracle-db2
