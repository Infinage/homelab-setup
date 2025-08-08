## Building a Budget-Friendly Portfolio Homelab

This guide will show you how to set up an affordable, self-hosted environment on AWS Lightsail, connect it to a custom domain from Namecheap, and deploy multiple personal or hobby projects under one roof.

---

### 1. Build Your App

- Prepare your app to run inside a container (Podman or Docker) and note the internal port it listens on.
- Make sure the container image is available on Docker Hub and set to public so it can be pulled without restrictions (Docker Hub offers unlimited public repositories).

---

### 2. Purchase a Domain from Namecheap

1. Go to [Namecheap](https://www.namecheap.com).
2. Use **Beast Mode** to search with prefixes, keywords, and price filters to find a good, budget-friendly domain.
3. Complete the purchase:
   * Enter your card details.
   * You may want to **disable auto-renew**.
   * Optionally **uncheck “Save card details”** for security.

---

### 3. Rent an AWS Lightsail Instance

1. Visit [AWS Lightsail](https://lightsail.aws.amazon.com/ls/webapp/home/instances).

2. Click **Create Instance**:
   * **Platform:** Linux
   * **Blueprint:** Operating System (OS) only
   * **OS Choice:** Ubuntu or Amazon Linux 2 are good defaults

3. **SSH Keys:**
   * Use the default AWS key,
   * Or generate one locally with `ssh-keygen`.

4. **Networking:**
   * Prefer **Dual Stack** over IPv6-only (IPv6-only is cheaper but requires extra setup).

5. **Instance Size:**
   * For hobby projects: 1 GB RAM is safe.
   * Minimal experiments: 512 MB is possible if you know the constraints.

6. Name your instance and launch it.

---

### 4. Set Up the Lightsail Instance for Your App

1. **Update packages:**
   ```bash
   sudo apt update && sudo apt upgrade
   ```
2. **Install dependencies:**
   * Install **Podman** and **Nginx** 
    *(Amazon Linux package managers do not ship Podman by default, use docker instead)*.

3. **Run your app container:**
   ```bash
   podman run --rm -d -p <external-port>:<internal-port> <image>
   ```

4. **Configure Nginx reverse proxy:**
   Create a config file at `/etc/nginx/conf.d/<app>.conf`:
   ```nginx
   # Named backend
   upstream <backend-name> {
       server localhost:<external-port>;
   }

   # Virtual host
   server {
       listen 80;
       server_name <subdomain>.<domain-name>;

       location / {
           proxy_pass http://<backend-name>;
           proxy_http_version 1.1;
           proxy_set_header Host $host;
       }
   }
   ```

5. **Apply changes:**
   ```bash
   sudo service nginx reload
   ```
---

### 5. Configure Namecheap DNS

1. Log in to Namecheap and open your **Domain List**.
2. Go to **Advanced DNS**.
3. Add an **A Record**:
   * **Host:** Your subdomain (e.g., `app`)
   * **Value:** Public IP of your Lightsail instance
4. Save changes — traffic to `subdomain.domain` will now route to your app.

