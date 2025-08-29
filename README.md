# Cloud Native Documentation 📚

Comprehensive documentation for Cloud Native technologies, deployment strategies, operations, and sales resources. Built with [Nextra](https://nextra.site) framework and Next.js.

## 🌟 Content

### 📖 Documentation
- **Get Started** - Introduction to Cloud Native concepts and getting started guide
- **Deployment** - Deployment strategies, architecture, and best practices
- **Operations** - Cluster management, monitoring, and security
- **Resources** - Tools, scripts, documentation, and best practices

### 🚀 Projects & Sales
- **Project EDU/POC** - Educational and Proof of Concept projects
- **Sales** - Business resources, services, and pricing models

### 🔗 Useful Links
- [Contact](https://cloud-native.rs/contact) - Contact information
- [GitHub](https://github.com/cloud-native-serbia) - Our GitHub repository
- [Kubernetes Docs](https://kubernetes.io/docs/) - Official Kubernetes documentation
- [OpenShift Docs](https://docs.openshift.com/) - Official OpenShift documentation

## 🛠 Technologies

- **Framework:** [Nextra](https://nextra.site) (Next.js-based documentation framework)
- **Styling:** CSS Modules + Nextra Theme
- **Deployment:** Vercel / Static hosting
- **Content:** MDX (Markdown + React components)

## 🚀 Local Development

### Prerequisites
- Node.js 18+ 
- pnpm (recommended) or npm

### Installation

```bash
# Clone the repository
git clone https://github.com/darioristic/cn-docs.git
cd cn-docs

# Install dependencies
pnpm install
# or
npm install
```

### Running the development server

```bash
# Start development server
pnpm dev
# or
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) in your browser to see the site.

### Production build

```bash
# Create production build
pnpm build
# or
npm run build

# Serve production build locally
pnpm start
# or
npm start
```

## 📁 Project Structure

```
cn-docs/
├── pages/                  # MDX pages and routing
│   ├── _meta.json         # Main navigation configuration
│   ├── index.mdx          # Home page
│   ├── deployment/        # Deployment documentation
│   ├── operations/        # Operations documentation
│   ├── resources/         # Resources and tools
│   ├── projects/          # Projects (EDU/POC)
│   └── sales/            # Sales materials
├── components/            # React components
├── public/               # Static files (images, icons)
├── theme.config.tsx      # Nextra theme configuration
├── next.config.js        # Next.js configuration
└── package.json          # Dependencies and scripts
```

## 📝 Adding New Content

### Creating a new page

1. Create a new `.mdx` file in the appropriate directory under `pages/`
2. Update the `_meta.json` file in that directory to add the new page to navigation

### Example _meta.json structure

```json
{
  "index": "Overview",
  "new-page": "New Page",
  "subfolder": "Subfolder Name"
}
```

### Adding separators to navigation

```json
{
  "---section": {
    "type": "separator", 
    "title": "Section Title"
  }
}
```

### Adding external links

```json
{
  "external-link": {
    "title": "External Link ↗",
    "href": "https://example.com",
    "newWindow": true
  }
}
```

## 🎨 Customization

- **Theme:** Modify `theme.config.tsx` to change logo, title, footer, etc.
- **Styles:** Add custom CSS in the `components/` directory
- **Components:** Create reusable React components in the `components/` directory

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-feature`)
3. Commit your changes (`git commit -am 'Add new feature'`)
4. Push to the branch (`git push origin feature/new-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## 📞 Contact

- **Website:** [cloud-native.rs](https://cloud-native.rs)
- **GitHub:** [cloud-native-serbia](https://github.com/cloud-native-serbia)
- **Email:** Contact via [contact page](https://cloud-native.rs/contact)

---

Built with ❤️ for the Cloud Native community in Serbia.