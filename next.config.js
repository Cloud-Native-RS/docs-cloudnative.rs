const withNextra = require('nextra')({
  theme: 'nextra-theme-docs',
  themeConfig: './theme.config.tsx',
})

module.exports = withNextra({
  // Add static file configuration
  async rewrites() {
    return [
      {
        source: '/images/:path*',
        destination: '/static/:path*',
      },
    ]
  },
})