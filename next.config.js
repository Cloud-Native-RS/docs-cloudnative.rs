const withNextra = require('nextra')({
  theme: 'nextra-theme-docs',
  themeConfig: './theme.config.tsx',
})

module.exports = withNextra({
  // Configure for production domain
  assetPrefix: process.env.ASSET_PREFIX || '',
  basePath: '',
  trailingSlash: false,
  
  // Add static file configuration
  async rewrites() {
    return [
      {
        source: '/images/:path*',
        destination: '/static/:path*',
      },
    ]
  },
  
  // Enable experimental features for Next.js 15
  experimental: {
    // Turbopack configuration
  },
})