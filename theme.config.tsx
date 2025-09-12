import type { DocsThemeConfig } from 'nextra-theme-docs'

const config: DocsThemeConfig = {
  logo: (
    <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
      <svg
        viewBox="0 0 144 144"
        fill="currentColor"
        stroke="currentColor"
        xmlns="http://www.w3.org/2000/svg"
        strokeWidth="4"
        style={{ width: '24px', height: '24px' }}
        className="dark:fill-white dark:stroke-white"
        aria-label="Cloud Native Logo"
        role="img"
      >
        <title>Cloud Native Logo</title>
        <path d="M108.411 31.0308L104.919 34.523C86.9284 52.5134 57.7601 52.5134 39.7697 34.523L36.2775 31.0308C34.8287 29.582 32.4797 29.582 31.0309 31.0308C29.5821 32.4796 29.5821 34.8286 31.0309 36.2773L34.5231 39.7695C52.5135 57.76 52.5135 86.9283 34.5231 104.919L31.0309 108.411C29.5821 109.86 29.5821 112.209 31.0309 113.657C32.4797 115.106 34.8287 115.106 36.2775 113.657L39.7697 110.165C57.7601 92.1748 86.9284 92.1748 104.919 110.165L108.411 113.657C109.86 115.106 112.209 115.106 113.658 113.657C115.106 112.209 115.106 109.86 113.658 108.411L110.165 104.919C92.1749 86.9283 92.1749 57.76 110.165 39.7695L113.658 36.2773C115.106 34.8286 115.106 32.4796 113.658 31.0308C112.209 29.582 109.86 29.582 108.411 31.0308Z" />
      </svg>
      <span>Cloud Native Docs</span>
    </div>
  ),
  project: {
    link: 'https://github.com/Cloud-Native-RS/docs-cloudnative.rs',
  },

  docsRepositoryBase: 'https://github.com/Cloud-Native-RS/docs-cloudnative.rs',
  footer: {
    text: 'Cloud Native Internal Documentation',
  },
  useNextSeoProps() {
    return {
      titleTemplate: '%s – Cloud Native Docs'
    }
  },
  head: (
    <>
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      <meta name="description" content="Cloud Native Internal Documentation" />
      <style>{`
        .dark .nextra-nav-container svg {
          fill: white !important;
          stroke: white !important;
        }
        .nextra-nav-container svg {
          fill: currentColor;
          stroke: currentColor;
        }
        
        /* Default collapsed state for navigation items except Get Started */
        .nextra-sidebar-container li[data-menu-item]:not([data-menu-item*="get-started"]) > div[style*="height"] {
          height: 0 !important;
        }
        
        .nextra-sidebar-container li[data-menu-item]:not([data-menu-item*="get-started"]) > div > div {
          opacity: 0 !important;
        }
        
        /* Keep Get Started expanded */
        .nextra-sidebar-container li[data-menu-item*="get-started"] > div[style*="height"] {
          height: auto !important;
        }
        
        .nextra-sidebar-container li[data-menu-item*="get-started"] > div > div {
          opacity: 1 !important;
        }
      `}</style>
      <script dangerouslySetInnerHTML={{
        __html: `
          // Expand Get Started section by default and add logout button
          document.addEventListener('DOMContentLoaded', function() {
            function expandGetStarted() {
              // Find the Get Started navigation item
              const getStartedItem = Array.from(document.querySelectorAll('a[href="/get-started"]')).find(a => 
                a.textContent.includes('Get Started')
              );
              
              if (getStartedItem && getStartedItem.parentElement) {
                const parentLi = getStartedItem.parentElement;
                const collapseDiv = parentLi.querySelector('div[style*="height"]');
                const opacityDiv = parentLi.querySelector('div > div');
                
                if (collapseDiv && opacityDiv) {
                  // Force expand
                  collapseDiv.style.height = 'auto';
                  opacityDiv.style.opacity = '1';
                  
                  // Add expanded class if Nextra uses it
                  parentLi.classList.add('expanded');
                }
              }
              
              // Collapse other sections
              const menuItems = ['deployment', 'operations', 'resources', 'projects', 'sales'];
              menuItems.forEach(item => {
                const itemLink = document.querySelector('a[href="/' + item + '"]');
                if (itemLink && itemLink.parentElement) {
                  const parentLi = itemLink.parentElement;
                  const collapseDiv = parentLi.querySelector('div[style*="height"]');
                  const opacityDiv = parentLi.querySelector('div > div');
                  
                  if (collapseDiv && opacityDiv) {
                    collapseDiv.style.height = '0px';
                    opacityDiv.style.opacity = '0';
                    parentLi.classList.remove('expanded');
                  }
                }
              });
            }
            
            function addLogoutButton() {
              // Find the GitHub link in the navbar
              const githubLink = document.querySelector('a[href*="github.com"]');
              if (githubLink && !document.querySelector('.logout-button-container')) {
                // Create logout button container
                const logoutContainer = document.createElement('div');
                logoutContainer.className = 'logout-button-container';
                logoutContainer.style.cssText = \`
                  display: flex;
                  align-items: center;
                  gap: 12px;
                  margin-left: 16px;
                \`;
                
                // Create logout button
                const logoutButton = document.createElement('button');
                logoutButton.innerHTML = \`
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/>
                    <polyline points="16,17 21,12 16,7"/>
                    <line x1="21" y1="12" x2="9" y2="12"/>
                  </svg>
                \`;
                logoutButton.style.cssText = \`
                  display: flex;
                  align-items: center;
                  justify-content: center;
                  width: 32px;
                  height: 32px;
                  border: 1px solid #d1d5db;
                  border-radius: 50%;
                  background: white;
                  color: #374151;
                  cursor: pointer;
                  transition: all 0.2s ease;
                  padding: 0;
                \`;
                
                // Add tooltip
                logoutButton.setAttribute('title', 'Sign out');
                
                logoutButton.addEventListener('mouseenter', function() {
                  this.style.borderColor = '#000';
                  this.style.backgroundColor = '#f9fafb';
                });
                
                logoutButton.addEventListener('mouseleave', function() {
                  this.style.borderColor = '#d1d5db';
                  this.style.backgroundColor = 'white';
                });
                
                logoutButton.addEventListener('click', function() {
                  console.log('Logout button clicked, redirecting to logout page...');
                  // Redirect to logout page which handles the logout process
                  window.location.href = '/logout';
                });
                
                logoutContainer.appendChild(logoutButton);
                
                // Insert after GitHub link
                githubLink.parentNode.insertBefore(logoutContainer, githubLink.nextSibling);
              }
            }
            
            // Try to expand immediately
            expandGetStarted();
            addLogoutButton();
            
            // Also try after a short delay in case of async loading
            setTimeout(() => {
              expandGetStarted();
              addLogoutButton();
            }, 100);
            setTimeout(() => {
              expandGetStarted();
              addLogoutButton();
            }, 500);
          });
        `
      }} />
    </>
  ),
  primaryHue: 210,
  primarySaturation: 100,
  sidebar: {
    defaultMenuCollapseLevel: 1,
    autoCollapse: false,
    toggleButton: true,
  },

}

export default config
