A modern, containerized Software Industrialization infrastructure built with Docker, designed for local development but structured for seamless production deployment.

## 📋 Overview

This project implements a complete Software Factory with version control, CI/CD automation, code quality analysis, and artifact management - all running in isolated Docker containers with proper networking, security, and resource management.

---

## 🔄 Architecture Evolution: From Original Demonstration to Production-Ready

The original software industrialization document provided a foundational approach designed for demonstration and lab environments. This project presents an alternative, production-ready architecture that builds upon those core concepts using modern containerization and orchestration practices.

> 📄 **Reference:** For the original context and demonstration setup, please refer to the [Original Software Industrialization Document](https://www.slideshare.net/slideshow/software-industrialization/237380850) *(please update this path to match your actual file location)*.

### Approach Comparison

| Aspect | Original Demonstration Approach | Production-Ready Approach (This Project) |
|--------|--------------------------------|------------------------------------------|
| **Virtualization** | VirtualBox + CentOS VMs | Docker + Docker Compose (lightweight, fast, portable) |
| **Networking** | Manual port forwarding | Shared bridge network (`sw_infra_net`) with internal DNS resolution |
| **Service Deployment** | Monolithic or tightly coupled | Service separation principle (independent lifecycles per tool) |
| **File Permissions** | Host directory bind mounts | Docker Named Volumes (secure, no host-level permission changes) |
| **Configuration** | Hardcoded values in scripts | Centralized `.env` with environment variable injection |
| **Lifecycle Management** | Manual start/stop commands | Root `Makefile` with deterministic dependency ordering |
| **Reverse Proxy** | None or manual configuration | Traefik with automatic service discovery and routing |
| **Resource Management** | Static VM allocation | Strict `mem_limit` on all containers to protect the host |
| **Database** | Separate instances per service | Shared PostgreSQL with logical database/user separation |

---

## 🏗️ Architecture

### Core Principles

1. **Service Separation**: Each tool operates in its own directory with its own `compose.yml`
2. **Shared Networking**: All services attach to `sw_infra_net` for internal DNS communication
3. **Edge Routing**: Traefik handles all HTTP/HTTPS traffic based on domain names
4. **Resource Guardrails**: Memory limits prevent host resource exhaustion
5. **Statelessness & Persistence**: Environment variables for config, Named Volumes for data
6. **Task Automation**: Single `Makefile` entry point for all operations

### Current Stack

| Service | Domain | Port | Memory Limit | Purpose |
|---------|--------|------|--------------|---------|
| **Traefik** | `traefik.localhost` | 80 | 128 MB | Reverse Proxy & Dashboard |
| **PostgreSQL** | Internal only | - | 512 MB | Shared Database (Gitea + SonarQube) |
| **pgAdmin** | `pgadmin.localhost` | - | 512 MB | Database Admin UI |
| **Gitea** | `gitea.localhost` | 2222 (SSH) | 512 MB | Git Server |
| **Jenkins** | `jenkins.localhost` | - | 1.5 GB | CI/CD Controller |
| **SonarQube** | `sonar.localhost` | - | 1.5 GB | Code Quality Analysis |
| **Nexus** | `nexus.localhost` | - | 1.2 GB | Artifact Repository |

**Total Minimum Host RAM Required**: ~6 GB (recommend 8 GB+)

---

## 📦 Implementation Phases

### ✅ Phase 0: Environment & Architecture (Complete)
- Defined core architecture principles
- Established directory structure
- Set resource allocation guidelines
- Documented security and secrets management

### ✅ Phase 1: Network & Reverse Proxy (Complete)
- Local DNS configuration (hosts file)
- Shared Docker network (`sw_infra_net`)
- Traefik reverse proxy deployment
- Initial Makefile with network/proxy targets

### ✅ Phase 2: Database & Gitea (Complete)
- Shared PostgreSQL 18 deployment
- Automated database/user initialization
- pgAdmin web UI deployment
- Gitea Git server with Traefik routing
- SSH port mapping (2222) to avoid host conflicts
- Makefile extension for database/Gitea targets

### ✅ Phase 3: CI/CD Tools (Complete)
- SonarQube deployment (code quality)
- Nexus deployment (artifact repository)
- Jenkins deployment (CI/CD controller)
- Custom Jenkins Dockerfile with Docker CLI
- Makefile extension for all CI/CD tools

### ✅ Phase 4: CI/CD Pipeline Validation (Complete)
- Todo application with TanStack Query (frontend) + Express (backend)
- Jenkins pipeline configuration
- SonarQube integration with quality gates
- Nexus artifact publishing
- End-to-end CI workflow validation

### 🚧 Phase 5: Backend Application (In Progress)
- Controller/Service/DTO pattern implementation
- PostgreSQL integration
- Unit and integration tests
- API documentation

---

## 🚀 Quick Start

### Prerequisites

- Docker & Docker Compose (v2.x)
- Make (usually pre-installed on Linux/macOS, available via Chocolatey on Windows)
- Minimum 8 GB RAM available

### 1. Clone and Setup

```bash
git clone <repository-url>
cd software-factory
```

### 2. Configure Environment

```bash
# Copy the example environment file
cp .env.example .env

# Edit .env and set secure passwords
# Generate passwords with: openssl rand -hex 16
nano .env
```

**Important**: Passwords must not contain `$`, `#`, spaces, or quotes (Makefile compatibility).

### 3. Configure Local DNS

Add to your hosts file:

**Linux/macOS** (`/etc/hosts`):
```bash
echo "127.0.0.1 traefik.localhost gitea.localhost jenkins.localhost nexus.localhost sonar.localhost pgadmin.localhost" | sudo tee -a /etc/hosts
```

**Windows** (PowerShell as Administrator):
```powershell
Add-Content -Path "$env:SystemRoot\System32\drivers\etc\hosts" -Value "127.0.0.1 traefik.localhost gitea.localhost jenkins.localhost nexus.localhost sonar.localhost pgadmin.localhost"
```

### 4. Start the Stack

```bash
# Start everything in the correct order
make up

# Check status
make status
```

### 5. Access Services

| Service | URL | First-Time Setup |
|---------|-----|------------------|
| Traefik Dashboard | http://traefik.localhost | None |
| Gitea | http://gitea.localhost | Create admin user or run `make gitea-admin-create` |
| pgAdmin | http://pgadmin.localhost | Login with `PGADMIN_DEFAULT_EMAIL`, enter Postgres admin password |
| SonarQube | http://sonar.localhost | Login `admin`/`admin`, change to `SONAR_ADMIN_PASSWORD` |
| Nexus | http://nexus.localhost | Login `admin`, get initial password from `make nexus-logs` |
| Jenkins | http://jenkins.localhost | Get initial password from `make jenkins-logs` |

---

## 🛠️ Common Operations

### Stack Lifecycle

```bash
make up                  # Start everything
make down                # Stop everything and remove network
make status              # Show running containers
```

### Individual Services

```bash
# Start/stop specific services
make proxy-up
make postgres-up
make gitea-up
make jenkins-up
make sonar-up
make nexus-up

# View logs
make proxy-logs
make postgres-logs
make jenkins-logs

# Restart services
make gitea-restart
make jenkins-restart
```

### Database Operations

```bash
# Verify database connections
make postgres-check

# Reset database (DESTRUCTIVE - asks for confirmation)
make postgres-reset
```

### Network Operations

```bash
make network-create      # Create shared network
make network-status      # Show network and attached containers
make network-remove      # Remove network (fails if containers attached)
```

---

## 📁 Directory Structure

```
software-factory/
├── .env                      # Global configuration (passwords, domains)
├── Makefile                  # Single entry point for all operations
├── README.md                 # This file
│
├── network/                  # Shared network scripts
│   ├── create-network.sh
│   └── remove-network.sh
│
├── proxy/                    # Traefik reverse proxy
│   └── compose.yml
│
├── postgres/                 # Shared PostgreSQL database
│   ├── compose.yml
│   └── init-scripts/
│       └── 01-create-app-databases.sql
│
├── pgadmin/                  # Database admin UI
│   ├── compose.yml
│   └── servers.json
│
├── gitea/                    # Git server
│   └── compose.yml
│
├── jenkins/                  # CI/CD controller
│   ├── compose.yml
│   └── Dockerfile
│
├── sonarqube/                # Code quality analysis
│   └── compose.yml
│
└── nexus/                    # Artifact repository
    └── compose.yml
```

---

## 🔒 Security Considerations

### Current Implementation (Local Development)

- ✅ Centralized secrets in `.env` (not committed to Git)
- ✅ No hardcoded passwords in compose files
- ✅ Docker Named Volumes (no host permission changes needed)
- ✅ Network isolation (only proxy and Gitea SSH exposed)
- ✅ Memory limits prevent resource exhaustion

### Production Hardening (Future Phases)

- [ ] TLS/HTTPS with Let's Encrypt
- [ ] Traefik middleware for authentication
- [ ] IP allow-listing for admin UIs (pgAdmin, Jenkins)
- [ ] Regular security updates
- [ ] Automated backups
- [ ] Monitoring and alerting

---

## 🐛 Troubleshooting

### Port Already in Use

If you see "port already in use" errors:
```bash
# Check what's using port 80
sudo lsof -i :80

# Stop conflicting services (e.g., Apache, Nginx)
sudo systemctl stop apache2
```

### Services Won't Start

```bash
# Check logs for specific service
make jenkins-logs

# Verify all containers are healthy
make status

# Restart problematic service
make jenkins-restart
```

### Database Connection Issues

```bash
# Verify PostgreSQL is healthy
make postgres-ps

# Test database connections
make postgres-check

# If init scripts didn't run, reset volume
make postgres-reset
make postgres-up
```

### Network Issues

```bash
# Verify network exists
make network-status

# Recreate network (stops all services first)
make down
make up
```

---

## 📚 Documentation

- **Phase 0**: [Environment & Architecture Spec](./00-environment-spec.md)
- **Phase 1**: [Network & Proxy Spec](./01-network-proxy-spec.md)
- **Phase 2**: [Database & Gitea Spec](./02-database-gitea-spec.md)
- **Phase 3**: [CI/CD Tools Spec](./03-sonarqube-nexus-jenkins-spec.md)
- **Phase 4**: [Pipeline Validation](./04-pipeline-validation-spec.md)

---

## 🤝 Contributing

This is a learning project demonstrating production-ready infrastructure patterns. Contributions welcome!

---

## 📄 License

MIT License - feel free to use this as a template for your own Software Factory.

---

## 🙏 Acknowledgments

This project evolved from an original software industrialization demonstration document. The production-ready architecture presented here is an alternative approach that applies modern containerization and orchestration best practices to the same foundational concepts.

---

## 📞 Support

For issues or questions:
1. Check the troubleshooting section above
2. Review the phase-specific documentation
3. Check container logs: `make <service>-logs`

---

**Built with ❤️ using Docker, Traefik, PostgreSQL, Gitea, Jenkins, SonarQube, and Nexus**