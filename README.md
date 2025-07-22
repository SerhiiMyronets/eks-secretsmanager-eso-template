# aws-secretsmanager-eso-template
Production-ready Terraform + Kubernetes integration with Secrets Manager, ESO, and RDS.


kubectl exec -n default -it deploy/mysql-client -- bash
mysql -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD"

kubectl logs deployments/secret-test 