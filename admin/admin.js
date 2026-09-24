/**
 * ============================================================================
 * Rixel Studio — Central Admin Controller
 * ============================================================================
 * Powers:
 * - /admin/login
 * - /admin/dashboard
 * - /admin/inquiries
 * Features:
 * - Supabase Auth check & Route Guards
 * - Inquiries Lead Management (Search, Filter, Sort, Detail Modal, WhatsApp/Email)
 * - Profile Image Uploader (profile-images bucket)
 * - Hero & About CMS Editors
 * - Services CRUD
 * - Portfolio Projects CRUD with Image Uploader (portfolio-images bucket)
 * - Contact Information & Social Links Editors
 * - Site Settings & Supabase Diagnostics
 * ============================================================================
 */

(function () {
  'use strict';

  // Toast notification helper
  function showToast(message, type = 'success') {
    let container = document.getElementById('admin-toast-container');
    if (!container) {
      container = document.createElement('div');
      container.id = 'admin-toast-container';
      container.className = 'fixed bottom-5 right-5 z-[200] flex flex-col gap-2 pointer-events-none';
      document.body.appendChild(container);
    }

    const toast = document.createElement('div');
    const isSuccess = type === 'success';
    const isError = type === 'error';
    
    toast.className = `pointer-events-auto flex items-center gap-3 px-5 py-3.5 rounded-2xl shadow-2xl border text-sm font-inter transition-all duration-300 transform translate-y-4 opacity-0 ${
      isSuccess
        ? 'bg-surface-container-high border-tertiary/40 text-white'
        : isError
        ? 'bg-surface-container-high border-error/50 text-white'
        : 'bg-surface-container-high border-white/20 text-white'
    }`;

    toast.innerHTML = `
      <span class="material-symbols-outlined text-[20px] ${isSuccess ? 'text-tertiary' : isError ? 'text-error' : 'text-primary'}">
        ${isSuccess ? 'check_circle' : isError ? 'error' : 'info'}
      </span>
      <span>${message}</span>
    `;

    container.appendChild(toast);
    requestAnimationFrame(() => {
      toast.classList.remove('translate-y-4', 'opacity-0');
    });

    setTimeout(() => {
      toast.classList.add('translate-y-4', 'opacity-0');
      setTimeout(() => toast.remove(), 300);
    }, 4000);
  }

  window.showToast = showToast;

  // Universal path helper for Vercel, GitHub Pages, and local file://
  function getAdminPath(page) {
    if (window.location.protocol === 'file:') {
      if (page === 'login') return '../login/index.html';
      if (page === 'dashboard') return '../dashboard/index.html';
      if (page === 'inquiries') return '../inquiries/index.html';
      return '../index.html';
    }
    const adminIdx = window.location.pathname.indexOf('/admin');
    const prefix = adminIdx > 0 ? window.location.pathname.substring(0, adminIdx) : '';
    return `${prefix}/admin/${page}`;
  }

  // Route Guards
  async function checkAuth(required = true) {
    if (!window.RixelSupabase) return;
    
    // Wait for client initialization if needed
    let retries = 0;
    while (!window.RixelSupabase.client && retries < 15) {
      await new Promise(r => setTimeout(r, 100));
      retries++;
    }

    const session = await window.RixelSupabase.getSession();
    const user = session?.user || null;

    const isLoginPage = window.location.pathname.includes('/login');

    if (required && !user && !isLoginPage) {
      console.warn('[Admin] Unauthenticated access. Redirecting to login');
      window.location.href = getAdminPath('login');
    } else if (!required && user && isLoginPage) {
      console.log('[Admin] Already authenticated. Redirecting to dashboard');
      window.location.href = getAdminPath('dashboard');
    }

    return user;
  }

  // Adjust in-page links dynamically based on environment
  function fixRelativeLinks() {
    if (window.location.protocol === 'file:') {
      document.querySelectorAll('a[href^="/admin/"]').forEach(a => {
        const target = a.getAttribute('href').replace('/admin/', '');
        const parts = target.split('#');
        const page = parts[0];
        const hash = parts[1] ? '#' + parts[1] : '';
        if (page === 'dashboard') a.href = '../dashboard/index.html' + hash;
        else if (page === 'inquiries') a.href = '../inquiries/index.html' + hash;
        else if (page === 'login') a.href = '../login/index.html' + hash;
      });
      document.querySelectorAll('a[href="/"]').forEach(a => {
        a.href = '../../index.html';
      });
    } else {
      const adminIdx = window.location.pathname.indexOf('/admin');
      if (adminIdx > 0) {
        const prefix = window.location.pathname.substring(0, adminIdx);
        document.querySelectorAll('a[href^="/admin/"]').forEach(a => {
          a.href = prefix + a.getAttribute('href');
        });
        document.querySelectorAll('a[href="/"]').forEach(a => {
          a.href = prefix + '/';
        });
      }
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', fixRelativeLinks);
  } else {
    fixRelativeLinks();
  }

  window.RixelAdmin = {
    checkAuth,
    showToast,
    getAdminPath,

    // Sign out helper
    async logout() {
      try {
        if (window.RixelSupabase) {
          await window.RixelSupabase.signOut();
        }
      } catch (e) {
        console.warn('Sign out warning:', e);
      }
      showToast('Logged out successfully.');
      setTimeout(() => {
        window.location.href = getAdminPath('login');
      }, 500);
    }
  };
})();
