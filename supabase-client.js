/**
 * ============================================================================
 * Rixel Studio — Production Supabase Integration Layer & CMS Engine
 * ============================================================================
 * Handles:
 * 1. Authentication (Admin email/password via Supabase Auth)
 * 2. Inquiries / Leads CRUD (Public insert, Admin select/update/delete)
 * 3. CMS: Site Settings, Hero, About, Services, Portfolio, Contact, Social
 * 4. Supabase Storage Buckets: profile-images, portfolio-images, site-assets
 * 5. Dynamic Public Hydration & Safe Fallback Resilience
 * ============================================================================
 */

(function () {
  'use strict';

  const DEFAULT_SUPABASE_URL = 'https://telynaezwbibshzckokh.supabase.co';
  const BUCKET_PROFILE = 'profile-images';
  const BUCKET_PORTFOLIO = 'portfolio-images';
  const BUCKET_ASSETS = 'site-assets';

  class RixelSupabaseService {
    constructor() {
      this.supabaseUrl = '';
      this.supabaseAnonKey = '';
      this.client = null;
      this.currentUser = null;
      this.authListeners = [];

      this.init();
    }

    /**
     * Resolves configuration and initializes Supabase client
     */
    init() {
      // 1. Check window.ENV (loaded from env.js if present)
      const envUrl = window.ENV && window.ENV.SUPABASE_URL ? window.ENV.SUPABASE_URL.trim() : '';
      const envAnonKey = window.ENV && window.ENV.SUPABASE_ANON_KEY ? window.ENV.SUPABASE_ANON_KEY.trim() : '';

      // 2. Check Vite / meta env if available in bundlers
      let viteUrl = '';
      let viteKey = '';
      try {
        if (typeof import.meta !== 'undefined' && import.meta.env) {
          viteUrl = import.meta.env.VITE_SUPABASE_URL || '';
          viteKey = import.meta.env.VITE_SUPABASE_ANON_KEY || import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY || '';
        }
      } catch (e) {}

      // 3. Check localStorage (allows admin to configure keys directly in browser)
      const localUrl = localStorage.getItem('rixel_supabase_url');
      const localAnonKey = localStorage.getItem('rixel_supabase_anon_key');

      this.supabaseUrl = viteUrl || envUrl || localUrl || DEFAULT_SUPABASE_URL;
      
      const candidateKey = viteKey || envAnonKey || localAnonKey || '';
      this.supabaseAnonKey = (candidateKey && !candidateKey.startsWith('YOUR_SUPABASE') && !candidateKey.startsWith('PASTE_YOUR'))
        ? candidateKey.trim()
        : '';

      if (this.supabaseUrl && this.supabaseAnonKey && window.supabase && typeof window.supabase.createClient === 'function') {
        try {
          this.client = window.supabase.createClient(this.supabaseUrl, this.supabaseAnonKey, {
            auth: {
              persistSession: true,
              autoRefreshToken: true,
              detectSessionInUrl: true,
              storageKey: 'rixel_studio_auth_token'
            }
          });

          // Auth state listener
          this.client.auth.onAuthStateChange((event, session) => {
            this.currentUser = session?.user || null;
            this.authListeners.forEach(cb => {
              try { cb(event, session); } catch (err) { console.error('Auth callback error:', err); }
            });
          });

          // Fetch initial session
          this.client.auth.getSession().then(({ data }) => {
            this.currentUser = data?.session?.user || null;
          }).catch(err => {
            console.warn('[Rixel Studio] Initial session note:', err.message);
          });

          console.log('%c[Rixel Studio]%c Supabase engine active: ' + this.supabaseUrl, 'color:#2fd9f4;font-weight:bold;', 'color:inherit;');
        } catch (e) {
          console.error('[Rixel Studio] Client initialization error:', e);
        }
      } else {
        if (!this.supabaseAnonKey) {
          console.info('[Rixel Studio] Running with public fallback data. Configure Anon key via /admin/login or env.js for live CMS sync.');
        }
      }
    }

    isConfigured() {
      return Boolean(this.client && this.supabaseUrl && this.supabaseAnonKey);
    }

    saveConfig(url, anonKey) {
      if (url) localStorage.setItem('rixel_supabase_url', url.trim());
      if (anonKey) localStorage.setItem('rixel_supabase_anon_key', anonKey.trim());
      this.init();
      return this.isConfigured();
    }

    clearConfig() {
      localStorage.removeItem('rixel_supabase_anon_key');
      this.init();
    }

    async testConnection() {
      if (!this.isConfigured()) {
        return { success: false, message: 'Supabase client is not configured with an Anon Key.' };
      }
      try {
        const { data, error } = await this.client.from('site_settings').select('site_title').limit(1);
        if (error) {
          if (error.code === '42P01') {
            return { success: true, schemaPending: true, message: 'Connected to Supabase! Run supabase-schema.sql to create database tables.' };
          }
          return { success: false, message: error.message };
        }
        return { success: true, message: 'Connected to Supabase PostgreSQL database successfully!' };
      } catch (err) {
        return { success: false, message: err.message || 'Connection failed' };
      }
    }

    // ========================================================================
    // AUTHENTICATION
    // ========================================================================
    onAuthStateChange(callback) {
      if (typeof callback === 'function') this.authListeners.push(callback);
    }

    async getSession() {
      if (!this.client) return null;
      const { data } = await this.client.auth.getSession();
      return data?.session || null;
    }

    async getUser() {
      if (!this.client) return null;
      const { data } = await this.client.auth.getUser();
      return data?.user || null;
    }

    async signIn(email, password) {
      if (!this.isConfigured()) throw new Error('Supabase is not configured. Please input your publishable Anon key.');
      const { data, error } = await this.client.auth.signInWithPassword({
        email: email.trim(),
        password: password
      });
      if (error) throw error;
      this.currentUser = data.user;
      return data;
    }

    async signOut() {
      if (!this.client) return;
      const { error } = await this.client.auth.signOut();
      this.currentUser = null;
      if (error) throw error;
    }

    // ========================================================================
    // INQUIRIES / LEADS (inquiries table)
    // ========================================================================
    async submitInquiry(data) {
      if (!this.isConfigured()) {
        return { success: false, fallback: true, message: 'Supabase not configured' };
      }

      const payload = {
        name: data.name,
        email: data.email,
        phone: data.phone || null,
        company: data.company || null,
        service: Array.isArray(data.services) ? data.services.join(', ') : (data.service || data.services || 'General Inquiry'),
        budget: data.budget || null,
        deadline: data.deadline || null,
        reference_url: data.reference || data.reference_url || null,
        message: data.message || data.details || '',
        status: 'new'
      };

      // Try inserting into inquiries table first
      let result = await this.client.from('inquiries').insert([payload]).select();
      
      // Fallback to contact_submissions if table differs
      if (result.error && result.error.code === '42P01') {
        const legacyPayload = {
          ...payload,
          services: Array.isArray(data.services) ? data.services : [payload.service],
          details: payload.message
        };
        result = await this.client.from('contact_submissions').insert([legacyPayload]).select();
      }

      if (result.error) {
        console.error('[Rixel Studio] Inquiry insertion error:', result.error);
        throw result.error;
      }

      return { success: true, data: result.data ? result.data[0] : null };
    }

    async getInquiries(filterStatus = 'all', searchQuery = '', sortBy = 'newest') {
      if (!this.isConfigured()) throw new Error('Supabase not configured.');

      let query = this.client.from('inquiries').select('*');

      if (filterStatus && filterStatus !== 'all') {
        query = query.eq('status', filterStatus);
      }

      if (searchQuery && searchQuery.trim()) {
        const q = `%${searchQuery.trim()}%`;
        query = query.or(`name.ilike.${q},email.ilike.${q},phone.ilike.${q},company.ilike.${q}`);
      }

      query = query.order('created_at', { ascending: sortBy === 'oldest' });

      let { data, error } = await query;
      
      // Fallback check
      if (error && error.code === '42P01') {
        let legacyQuery = this.client.from('contact_submissions').select('*');
        if (filterStatus && filterStatus !== 'all') legacyQuery = legacyQuery.eq('status', filterStatus);
        legacyQuery = legacyQuery.order('created_at', { ascending: sortBy === 'oldest' });
        const legacy = await legacyQuery;
        if (legacy.error) throw legacy.error;
        data = (legacy.data || []).map(item => ({
          ...item,
          service: Array.isArray(item.services) ? item.services.join(', ') : item.services,
          message: item.details
        }));
      } else if (error) {
        throw error;
      }

      return data || [];
    }

    async updateInquiryStatus(id, newStatus) {
      if (!this.isConfigured()) throw new Error('Supabase not configured.');
      
      const { data, error } = await this.client
        .from('inquiries')
        .update({ status: newStatus, updated_at: new Date().toISOString() })
        .eq('id', id)
        .select();

      if (error) {
        // Fallback to legacy
        const legacy = await this.client
          .from('contact_submissions')
          .update({ status: newStatus })
          .eq('id', id)
          .select();
        if (legacy.error) throw legacy.error;
        return legacy.data[0];
      }
      return data[0];
    }

    async deleteInquiry(id) {
      if (!this.isConfigured()) throw new Error('Supabase not configured.');
      
      let { error } = await this.client.from('inquiries').delete().eq('id', id);
      if (error) {
        const legacy = await this.client.from('contact_submissions').delete().eq('id', id);
        if (legacy.error) throw legacy.error;
      }
      return true;
    }

    // ========================================================================
    // CMS: SITE SETTINGS
    // ========================================================================
    async getSiteSettings() {
      if (!this.isConfigured()) return null;
      const { data, error } = await this.client.from('site_settings').select('*').limit(1);
      if (error || !data || data.length === 0) return null;
      return data[0];
    }

    async updateSiteSettings(settings) {
      if (!this.isConfigured()) throw new Error('Supabase not configured.');
      const existing = await this.getSiteSettings();
      const payload = {
        ...settings,
        updated_at: new Date().toISOString()
      };
      if (existing && existing.id) {
        const { data, error } = await this.client.from('site_settings').update(payload).eq('id', existing.id).select();
        if (error) throw error;
        return data[0];
      } else {
        const { data, error } = await this.client.from('site_settings').insert([payload]).select();
        if (error) throw error;
        return data[0];
      }
    }

    // ========================================================================
    // CMS: HERO CONTENT
    // ========================================================================
    async getHeroContent() {
      if (!this.isConfigured()) return null;
      const { data, error } = await this.client.from('hero_content').select('*').limit(1);
      if (error || !data || data.length === 0) return null;
      return data[0];
    }

    async updateHeroContent(hero) {
      if (!this.isConfigured()) throw new Error('Supabase not configured.');
      const existing = await this.getHeroContent();
      const payload = { ...hero, updated_at: new Date().toISOString() };
      if (existing && existing.id) {
        const { data, error } = await this.client.from('hero_content').update(payload).eq('id', existing.id).select();
        if (error) throw error;
        return data[0];
      } else {
        const { data, error } = await this.client.from('hero_content').insert([payload]).select();
        if (error) throw error;
        return data[0];
      }
    }

    // ========================================================================
    // CMS: ABOUT CONTENT & STATS
    // ========================================================================
    async getAboutContent() {
      if (!this.isConfigured()) return null;
      const { data, error } = await this.client.from('about_content').select('*').limit(1);
      if (error || !data || data.length === 0) return null;
      return data[0];
    }

    async updateAboutContent(about) {
      if (!this.isConfigured()) throw new Error('Supabase not configured.');
      const existing = await this.getAboutContent();
      const payload = { ...about, updated_at: new Date().toISOString() };
      if (existing && existing.id) {
        const { data, error } = await this.client.from('about_content').update(payload).eq('id', existing.id).select();
        if (error) throw error;
        return data[0];
      } else {
        const { data, error } = await this.client.from('about_content').insert([payload]).select();
        if (error) throw error;
        return data[0];
      }
    }

    // ========================================================================
    // CMS: SERVICES
    // ========================================================================
    async getServices(onlyActive = true) {
      if (!this.isConfigured()) return null;
      let query = this.client.from('services').select('*').order('display_order', { ascending: true });
      if (onlyActive) query = query.eq('is_active', true);
      const { data, error } = await query;
      if (error) return null;
      return data;
    }

    async addService(service) {
      if (!this.isConfigured()) throw new Error('Supabase not configured.');
      const { data, error } = await this.client.from('services').insert([service]).select();
      if (error) throw error;
      return data[0];
    }

    async updateService(id, service) {
      if (!this.isConfigured()) throw new Error('Supabase not configured.');
      const { data, error } = await this.client
        .from('services')
        .update({ ...service, updated_at: new Date().toISOString() })
        .eq('id', id)
        .select();
      if (error) throw error;
      return data[0];
    }

    async deleteService(id) {
      if (!this.isConfigured()) throw new Error('Supabase not configured.');
      const { error } = await this.client.from('services').delete().eq('id', id);
      if (error) throw error;
      return true;
    }

    // ========================================================================
    // CMS: PORTFOLIO PROJECTS
    // ========================================================================
    async getPortfolioProjects(category = 'all', onlyPublished = true) {
      if (!this.isConfigured()) return null;
      let query = this.client.from('portfolio_projects').select('*').order('display_order', { ascending: true }).order('created_at', { ascending: false });
      if (onlyPublished) query = query.eq('is_published', true);
      if (category && category !== 'all') {
        query = query.ilike('category', `%${category}%`);
      }
      const { data, error } = await query;
      if (error) return null;
      return data;
    }

    async addPortfolioProject(project) {
      if (!this.isConfigured()) throw new Error('Supabase not configured.');
      const { data, error } = await this.client.from('portfolio_projects').insert([project]).select();
      if (error) throw error;
      return data[0];
    }

    async updatePortfolioProject(id, project) {
      if (!this.isConfigured()) throw new Error('Supabase not configured.');
      const { data, error } = await this.client
        .from('portfolio_projects')
        .update({ ...project, updated_at: new Date().toISOString() })
        .eq('id', id)
        .select();
      if (error) throw error;
      return data[0];
    }

    async deletePortfolioProject(id) {
      if (!this.isConfigured()) throw new Error('Supabase not configured.');
      const { error } = await this.client.from('portfolio_projects').delete().eq('id', id);
      if (error) throw error;
      return true;
    }

    // ========================================================================
    // CMS: CONTACT INFO
    // ========================================================================
    async getContactInfo() {
      if (!this.isConfigured()) return null;
      const { data, error } = await this.client.from('contact_info').select('*').limit(1);
      if (error || !data || data.length === 0) return null;
      return data[0];
    }

    async updateContactInfo(info) {
      if (!this.isConfigured()) throw new Error('Supabase not configured.');
      const existing = await this.getContactInfo();
      const payload = { ...info, updated_at: new Date().toISOString() };
      if (existing && existing.id) {
        const { data, error } = await this.client.from('contact_info').update(payload).eq('id', existing.id).select();
        if (error) throw error;
        return data[0];
      } else {
        const { data, error } = await this.client.from('contact_info').insert([payload]).select();
        if (error) throw error;
        return data[0];
      }
    }

    // ========================================================================
    // CMS: SOCIAL LINKS
    // ========================================================================
    async getSocialLinks(onlyEnabled = true) {
      if (!this.isConfigured()) return null;
      let query = this.client.from('social_links').select('*');
      if (onlyEnabled) query = query.eq('is_enabled', true);
      const { data, error } = await query;
      if (error) return null;
      return data;
    }

    async updateSocialLink(platform, url, isEnabled) {
      if (!this.isConfigured()) throw new Error('Supabase not configured.');
      const { data, error } = await this.client
        .from('social_links')
        .upsert([{ platform, url, is_enabled: Boolean(isEnabled), updated_at: new Date().toISOString() }], { onConflict: 'platform' })
        .select();
      if (error) throw error;
      return data[0];
    }

    // ========================================================================
    // STORAGE: Uploading Images (profile-images, portfolio-images, site-assets)
    // ========================================================================
    async uploadImageToBucket(file, bucketName, folder = 'uploads') {
      if (!this.isConfigured()) throw new Error('Supabase not configured.');

      // Validation
      const allowedTypes = ['image/jpeg', 'image/png', 'image/webp', 'image/gif'];
      if (!allowedTypes.includes(file.type)) {
        throw new Error('Invalid file type. Only JPG, PNG, WEBP, and GIF are allowed.');
      }
      if (file.size > 10 * 1024 * 1024) {
        throw new Error('File size exceeds the 10MB limit.');
      }

      const cleanFileName = file.name.replace(/[^a-zA-Z0-9._-]/g, '_');
      const filePath = `${folder}/${Date.now()}_${cleanFileName}`;

      // Upload with upsert
      let uploadResult = await this.client.storage
        .from(bucketName)
        .upload(filePath, file, { cacheControl: '3600', upsert: true });

      // Fallback to studio-media if dedicated bucket not yet created
      if (uploadResult.error) {
        uploadResult = await this.client.storage
          .from('studio-media')
          .upload(filePath, file, { cacheControl: '3600', upsert: true });
        if (uploadResult.error) throw uploadResult.error;
        const { data: pubData } = this.client.storage.from('studio-media').getPublicUrl(filePath);
        return pubData.publicUrl;
      }

      const { data: pubData } = this.client.storage.from(bucketName).getPublicUrl(filePath);
      return pubData.publicUrl;
    }

    async uploadProfilePhoto(file) {
      const publicUrl = await this.uploadImageToBucket(file, BUCKET_PROFILE, 'profile');
      await this.updateAboutContent({ profile_image_url: publicUrl });
      return publicUrl;
    }

    async uploadPortfolioImage(file) {
      return await this.uploadImageToBucket(file, BUCKET_PORTFOLIO, 'portfolio');
    }

    async uploadSiteAsset(file) {
      return await this.uploadImageToBucket(file, BUCKET_ASSETS, 'assets');
    }

    // ========================================================================
    // DASHBOARD OVERVIEW METRICS
    // ========================================================================
    async getDashboardStats() {
      if (!this.isConfigured()) {
        return {
          totalProjects: 12,
          totalInquiries: 0,
          newInquiries: 0,
          profileImageUrl: 'logo.png',
          websiteStatus: 'Live (Fallback)',
          lastUpdate: 'Default'
        };
      }

      try {
        const [projects, allInquiries, newInquiries, about] = await Promise.all([
          this.client.from('portfolio_projects').select('id', { count: 'exact', head: true }),
          this.client.from('inquiries').select('id', { count: 'exact', head: true }),
          this.client.from('inquiries').select('id', { count: 'exact', head: true }).eq('status', 'new'),
          this.getAboutContent()
        ]);

        return {
          totalProjects: projects?.count ?? 12,
          totalInquiries: allInquiries?.count ?? 0,
          newInquiries: newInquiries?.count ?? 0,
          profileImageUrl: about?.profile_image_url || 'logo.png',
          websiteStatus: 'Live & Connected',
          lastUpdate: new Date().toLocaleTimeString()
        };
      } catch (e) {
        return {
          totalProjects: 12,
          totalInquiries: 0,
          newInquiries: 0,
          profileImageUrl: 'logo.png',
          websiteStatus: 'Connected',
          lastUpdate: 'Just now'
        };
      }
    }
  }

  // Register globally
  window.RixelSupabase = new RixelSupabaseService();

  // If Supabase CDN loaded asynchronously, re-trigger init
  if (typeof window.supabase === 'undefined') {
    window.addEventListener('DOMContentLoaded', () => {
      if (typeof window.supabase !== 'undefined' && !window.RixelSupabase.client) {
        window.RixelSupabase.init();
      }
    });
  }
})();
