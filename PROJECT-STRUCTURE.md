# Project Structure

This document describes the organized structure of the Cloud Native Documentation project.

## 📁 Directory Structure

```
docs-cloudnative.rs-1/
├── 📁 components/           # React components
│   ├── ui/                 # UI components (Button, Card, etc.)
│   ├── AuthWrapper.tsx     # Authentication wrapper
│   ├── counters.tsx        # Counter components
│   └── LogoutButton.tsx    # Logout functionality
│
├── 📁 config/              # Configuration files
│   ├── vercel.json         # Vercel deployment config
│   └── vercel-env.example  # Environment variables template
│
├── 📁 deployment/          # Deployment configurations
│   ├── configs/            # Docker & deployment configs
│   └── scripts/            # Deployment scripts
│
├── 📁 docs/                # Documentation
│   ├── deployment/         # Deployment guides
│   ├── setup/              # Setup instructions
│   ├── troubleshooting/    # Troubleshooting guides
│   └── DEVELOPMENT.md      # Development guide
│
├── 📁 infrastructure/      # Infrastructure as Code
│   ├── helm/               # Helm charts
│   ├── k8s/                # Kubernetes manifests
│   └── tekton/             # Tekton pipelines
│
├── 📁 pages/               # Next.js pages
│   ├── api/                # API routes
│   ├── auth/               # Authentication pages
│   ├── deployment/         # Deployment docs pages
│   ├── docs/               # Documentation pages
│   ├── get-started/        # Getting started pages
│   ├── operations/         # Operations pages
│   ├── projects/           # Projects pages
│   ├── resources/          # Resources pages
│   ├── sales/              # Sales pages
│   ├── login.tsx           # Login page
│   └── logout.tsx          # Logout page
│
├── 📁 scripts/             # Utility scripts
│   ├── route-health-check.sh
│   └── update-github-oauth.sh
│
├── 📁 tools/               # Development tools
│   ├── github-webhook-test.md
│   ├── quick-test-commands.txt
│   ├── scheduling-fix-test.txt
│   └── webhook-test-final.txt
│
├── 📁 lib/                 # Utility libraries
│   └── utils.ts
│
├── 📁 styles/              # Global styles
│   └── globals.css
│
├── 📁 public/              # Static assets
│   ├── edu-poc-cluster.png
│   └── logo.svg
│
└── 📄 Configuration Files
    ├── package.json         # Dependencies
    ├── next.config.js       # Next.js config
    ├── tailwind.config.js   # Tailwind CSS config
    ├── postcss.config.js    # PostCSS config
    ├── theme.config.tsx     # Nextra theme config
    ├── components.json      # UI components config
    ├── tsconfig.json        # TypeScript config
    ├── middleware.ts        # Next.js middleware
    ├── env.example          # Environment variables template
    ├── env.production       # Production environment
    └── README.md            # Project documentation
```

## 🗂️ Key Directories

### `/components/`
- **Purpose**: Reusable React components
- **Contains**: UI components, authentication wrappers, custom components
- **Important**: `ui/` subdirectory contains shadcn/ui components

### `/config/`
- **Purpose**: Configuration files for deployment
- **Contains**: Vercel config, environment templates
- **Note**: Moved from root for better organization

### `/deployment/`
- **Purpose**: Deployment-related files
- **Contains**: Docker configs, deployment scripts, infrastructure configs
- **Subdirs**: 
  - `configs/`: Docker Compose, Dockerfile, deployment configs
  - `scripts/`: Automated deployment scripts

### `/docs/`
- **Purpose**: All documentation files
- **Contains**: Deployment guides, setup instructions, troubleshooting
- **Subdirs**:
  - `deployment/`: All deployment-related documentation
  - `setup/`: Setup and configuration guides
  - `troubleshooting/`: Problem-solving documentation

### `/infrastructure/`
- **Purpose**: Infrastructure as Code
- **Contains**: Helm charts, Kubernetes manifests, Tekton pipelines
- **Subdirs**:
  - `helm/`: Helm charts for Kubernetes deployment
  - `k8s/`: Raw Kubernetes manifests
  - `tekton/`: CI/CD pipeline definitions

### `/pages/`
- **Purpose**: Next.js application pages
- **Contains**: All application routes and pages
- **Note**: Follows Next.js file-based routing

### `/scripts/`
- **Purpose**: Utility and maintenance scripts
- **Contains**: Health checks, OAuth updates, maintenance tasks

### `/tools/`
- **Purpose**: Development and testing tools
- **Contains**: Test commands, webhook testing, debugging tools

## 🧹 Cleanup Actions Performed

1. **Moved deployment guides** from root to `docs/deployment/`
2. **Moved config files** to `config/` directory
3. **Removed duplicate files** (`* 2.js`, `* 2.ts`)
4. **Moved standalone scripts** to `scripts/` directory
5. **Consolidated documentation** into `docs/` structure
6. **Removed temporary files** (cookies.txt, test files)
7. **Updated .gitignore** to prevent future clutter

## 🚀 Benefits of This Organization

- **Clear separation** of concerns
- **Easy navigation** through project structure
- **Reduced root directory** clutter
- **Logical grouping** of related files
- **Better maintainability** and scalability
- **Consistent structure** across similar projects

## 📝 Maintenance

- Keep configuration files in `/config/`
- Add new documentation to appropriate `/docs/` subdirectories
- Place utility scripts in `/scripts/`
- Follow the established directory structure for new additions
