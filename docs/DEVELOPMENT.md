# Development Guide

## Quick Start

### 1. **Demo Login (Development Only)**

For development and testing, you can use the **Demo Login** button on the login page:

- **Username**: `demo`
- **Password**: Not required (just click the button)

This will log you in as a demo user and give you full access to the documentation.

### 2. **GitHub OAuth (Production)**

For production use, you'll need to set up a real GitHub OAuth App:

1. Go to [GitHub Settings > Developer settings > OAuth Apps](https://github.com/settings/developers)
2. Click "New OAuth App"
3. Fill in:
   - **Application name**: Cloud Native Docs
   - **Homepage URL**: `https://your-domain.com`
   - **Authorization callback URL**: `https://your-domain.com/api/auth/callback/github`
4. Copy the Client ID and Client Secret
5. Update your `.env.local` file:
   ```env
   GITHUB_ID=your-real-client-id
   GITHUB_SECRET=your-real-client-secret
   ```

### 3. **Environment Variables**

The `.env.local` file should contain:

```env
# NextAuth.js Configuration
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=oyN43ZzckwaCkus7HHVyj73XeMKzMD72rLzMV+hU1Io=

# GitHub OAuth (for production)
GITHUB_ID=your-github-client-id
GITHUB_SECRET=your-github-client-secret

# GitHub Organization (optional)
GITHUB_ORG=Cloud-Native-RS

# Node Environment
NODE_ENV=development
```

## Features

### ✅ **Working Features**

- **Demo Login**: Works in development mode
- **GitHub OAuth**: Ready for production setup
- **Protected Routes**: All content requires authentication
- **Responsive Design**: Works on all devices
- **Documentation**: Full MDX support with Nextra
- **Modern UI**: TailwindCSS with custom components

### 🔧 **Development Commands**

```bash
# Start development server
npm run dev

# Build for production
npm run build

# Start production server
npm start

# Run linting
npm run lint
```

## Troubleshooting

### **Authentication Issues**

1. **Demo Login Not Working**: Make sure you're in development mode (`NODE_ENV=development`)
2. **GitHub OAuth Failing**: Check that your GitHub OAuth App is configured correctly
3. **Redirect Loops**: Clear browser cookies and cache

### **Build Issues**

1. **CSS Errors**: Make sure TailwindCSS is properly configured
2. **TypeScript Errors**: Run `npm run build` to check for type errors
3. **Dependency Issues**: Run `npm install` to update dependencies

## Production Deployment

### **Vercel (Recommended)**

1. Connect your GitHub repository to Vercel
2. Set environment variables in Vercel dashboard
3. Deploy automatically on push to main branch

### **Other Platforms**

The app can be deployed to any platform that supports Next.js:
- Netlify
- AWS Amplify
- Railway
- DigitalOcean App Platform

## Security Notes

- **Demo Login**: Only available in development mode
- **Environment Variables**: Never commit `.env.local` to version control
- **GitHub OAuth**: Use real credentials in production
- **HTTPS**: Always use HTTPS in production

---

**Happy coding! 🚀**
