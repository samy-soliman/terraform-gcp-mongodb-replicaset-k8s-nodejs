# High Available NodeJs App Connected to MongoDB on Google Kubernetes Engine (GKE)

![Architecture](/Images/Architecture.png)

In this project I will deploy a simple Node.js web application **(stateless)** that interacts with a highly available MongoDB **(stateful)** replicated across **3 zones** and consisting of 1 primary and 2 secondaries.

Notes:
- Only the **Management VM (private)** will have access to internet through the **NAT**.
- The **GKE cluster (private)** will NOT have access to the internet.
- The **Management VM** will be used to manage the **GKE cluster** and **build/push** images to the **Artifact Registry**.
- All deployed images must be stored in Artifact Registry.
