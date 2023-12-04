# rest-recs

live endpoints: 
find an Italian restaurant that is vegetarian and delivers:
https://rest-rec-service-6mffkvlocq-ue.a.run.app/getRestaurant?style=Italian&vegetarian=yes&doesDeliveries=yes
find any open Korean restaurant:
https://rest-rec-service-6mffkvlocq-ue.a.run.app/getRestaurant?style=Korean
find an open restaurant that offers vegetarian options (regardless of style or delivery option):
https://rest-rec-service-6mffkvlocq-ue.a.run.app/getRestaurant?vegetarian=yes

Requirements:
Cloud-Native: Fully hosted and operational in the cloud (GCP - no personal azure sub).
Minimal Maintenance: Serverless architecture minimizes the need for ongoing maintenance.
IaC: Terraform scripts for full infrastructure setup.
Backend Storage: Cloud Storage bucket for log retention.
Security: Leveraging GCP's secure environment, with no authentication required for hitting endpoints (public access).
Automatic CI/CD: Application updates and infrastructure changes are handled through GitHub Actions.

Deployment Instructions: 
Clone the repository.
Set up required GH service account in GCP & grant permissions.
Configure GitHub repository secrets (GCP service account key, Docker hub credentials, Terraform Cloud API Key).
Push changes to trigger CI/CD pipelines for deployment.