# Rixel Studio — Portfolio CMS & Lead Management System

Official, production-grade portfolio and dynamic CMS backend for **Rixel Studio** (Brand Identity, Motion Graphics & Creative Direction). Powered by vanilla HTML5, Tailwind CSS, Three.js 3D interactive spatial mesh, and **Supabase Cloud Backend** (`ap-northeast-1` Tokyo).

![Rixel Studio Logo](logo.png)

---

## 🌟 Overview & Key Capabilities

- **Zero-Redesign Guarantee:** 100% preservation of the original *Obsidian Luminescence* visual identity, dark luxury aesthetics, typography (Sora, Space Grotesk, Inter), responsive layouts, and interactive Three.js 3D spatial scene.
- **Dedicated Admin Portal:**
  - `/admin/login` — Clean, secured login page powered by **Supabase Auth** with session persistence, password reveal, error alerts, and route guards.
  - `/admin/dashboard` — Complete CMS control center for:
    - **Dashboard Overview Metrics:** Total Portfolio Projects, Total Leads, New Inquiries, Site Operational Status.
    - **Founder Profile Photo:** Live upload to Supabase `profile-images` storage bucket with immediate public sync.
    - **Hero Section Content:** Main headline, gradient highlight, suffix, and value proposition statement.
    - **About & Statistics:** Founder bio and live counters (Years Experience, Projects Completed, Corporate Clients, On-Time Delivery).
    - **Services Matrix:** Manage all 6 creative offerings with descriptions and highlight tags.
    - **Portfolio Showcase CRUD:** Create, edit, delete, and toggle status of all projects, with direct file uploads to `portfolio-images` bucket.
    - **Contact Information & Social Links:** Live update WhatsApp number, email, studio location, and social media handles.
    - **Site Settings & Meta:** SEO meta title, description, maintenance mode toggle.
  - `/admin/inquiries` — Dedicated Lead Management CRM:
    - Real-time search across Name, Email, Phone, and Company.
    - Multi-filter by Status (`new`, `in_review`, `contacted`, `converted`, `archived`) and Requested Service.
    - Sorting by Newest or Oldest submission.
    - In-depth detail modal with client requirements, budget tiers, deadlines, and project links.
    - Quick actions: One-click **WhatsApp** chat launch, **Mailto** compose, and clipboard copy.
    - Status lifecycle management and lead deletion with confirmation.
- **Database-Backed Lead Generation Form:**
  - Submits client requests directly to Supabase `inquiries` table.
  - Dual anti-spam protection: hidden bot honeypot field + minimum submission duration check.
  - Strict input validation with email regex and required field checks.
  - Smooth loading feedback, success confirmation, and automatic form reset.
- **Fail-Safe Resilience:**
  - If Supabase is unconfigured or temporarily unreachable, the public portfolio seamlessly falls back to static default HTML content without breaking or displaying blank sections.

---

## 🔐 Security & Architecture Rules

1. **Client Anon Key Only:** The public frontend and admin dashboard only require the Supabase publishable `anon` key.
2. **Never Expose Service Role Key:** The `service_role` secret key and database master passwords are never included in frontend code, committed to Git, or exposed in public bundles.
3. **Strict Row-Level Security (RLS) Enforced:**
   - **`inquiries` table:** Public visitors can only `INSERT` new leads. Only authenticated admin users can `SELECT`, `UPDATE`, or `DELETE`.
   - **CMS tables (`site_settings`, `hero_content`, `about_content`, `services`, `portfolio_projects`, `contact_info`, `social_links`):** Public visitors can only `SELECT` published records. Only authenticated admin users have full write access (`INSERT`, `UPDATE`, `DELETE`).
   - **Storage buckets (`profile-images`, `portfolio-images`, `site-assets`):** Public can view/download images. Only authenticated admin users can upload or delete.
4. **Environment Variables:** Credentials are kept in `.env` / `env.js` (excluded by `.gitignore`).

---

## ⚡ Supabase Setup Guide (Step-by-Step)

### Step 1: Execute Database Schema in Supabase
1. Log into your Supabase Dashboard:  
   👉 [https://supabase.com/dashboard/project/telynaezwbibshzckokh](https://supabase.com/dashboard/project/telynaezwbibshzckokh)
2. From the left sidebar, click on **SQL Editor**.
3. Click **New query**.
4. Copy the entire contents of **`supabase-schema.sql`** from this project, paste it into the editor, and click **Run**.
5. This script automatically:
   - Creates all tables: `inquiries`, `site_settings`, `hero_content`, `about_content`, `services`, `portfolio_projects`, `contact_info`, `social_links`.
   - Creates public Storage buckets: `profile-images`, `portfolio-images`, `site-assets`.
   - Configures all Row-Level Security (RLS) policies.
   - Populates initial seed data matching 100% of your existing portfolio content and projects.

---

### Step 2: Create Your First Admin User
1. In the Supabase Dashboard, click on **Authentication** (User icon in left sidebar).
2. Go to the **Users** tab.
3. Click the **Add user** button -> **Create user**.
4. Enter your admin email (e.g. `merahman279@gmail.com`) and choose a strong password.
5. Set **Auto Confirm User?** to **ON** (checked).
6. Click **Create user**. You can now log into `/admin/login` using these credentials.

---

### Step 3: Configure Supabase Credentials

Your Supabase Project URL is:  
`https://telynaezwbibshzckokh.supabase.co`

To get your Anon Key:
1. In Supabase Dashboard, go to **Project Settings** (gear icon) -> **API**.
2. Under **Project API keys**, copy the **`anon` `public`** key.

You can configure the key in either of two ways:
- **Option A (In-Browser Admin Setup):**  
  Open `/admin/login` in your browser. Click **Supabase Connection Settings** at the bottom of the card, paste your `anon` key, and click **Save Settings**.
- **Option B (`env.js` for Local Development):**  
  Duplicate `env.example.js` as `env.js` in the project root:
  ```javascript
  window.__ENV__ = {
    SUPABASE_URL: "https://telynaezwbibshzckokh.supabase.co",
    SUPABASE_ANON_KEY: "your-actual-anon-key-here"
  };
  ```

---

## 🚀 Deployment Guide

### Vercel Deployment (Recommended)

1. Push your repository to **GitHub**.
2. Log into [vercel.com](https://vercel.com) and click **Add New...** -> **Project**.
3. Import your `rixel-studio` repository.
4. In **Project Settings** -> **Environment Variables**, add:
   - `VITE_SUPABASE_URL` = `https://telynaezwbibshzckokh.supabase.co`
   - `VITE_SUPABASE_ANON_KEY` = `your-actual-anon-key-here`
5. Click **Deploy**.
6. The included `vercel.json` automatically handles:
   - Clean URLs (no `.html` extension needed)
   - Route rewrites for `/admin/login`, `/admin/dashboard`, `/admin/inquiries`
   - Security headers (`X-Content-Type-Options`, `X-Frame-Options`, `X-XSS-Protection`)

---

### Accessing the Admin System

- **Direct URL:** Visit `https://your-domain.vercel.app/admin/login`
- **Footer Link:** Click the **Studio Admin** lock icon in the website footer.
- **Keyboard Shortcut:** Press `Ctrl + Shift + A` (or `Cmd + Shift + A` on Mac) anywhere on the public site to quickly open the admin login.

---

## 📧 Server-Side Email Notifications (Recommended Setup)

To receive real-time email notifications whenever a client submits a new lead, **do not call email APIs from the frontend** (to prevent leaking API keys).

Use a **Supabase Database Webhook** or **Supabase Edge Function** with Resend:
1. Go to Supabase Dashboard -> **Database** -> **Webhooks**.
2. Create a webhook triggered on `INSERT` on the `inquiries` table.
3. Forward the webhook payload to a serverless function or services like **Resend** or **Zapier** / **Make** to send an instant notification to your inbox.

---

## 📁 Project Structure

```text
├── index.html                   # Main public portfolio (3D spatial scene, portfolio, intake form)
├── supabase-client.js           # Supabase SDK integration (Auth, Inquiries, CMS, Storage)
├── supabase-schema.sql          # Complete SQL schema, RLS policies, storage buckets & seed data
├── vercel.json                  # Vercel routing rewrites, cleanUrls, and security headers
├── admin/
│   ├── index.html               # Admin route dispatcher (checks session -> dashboard or login)
│   ├── admin.js                 # Admin utilities, route guards, toast notifications, path resolver
│   ├── login/
│   │   └── index.html           # Dedicated Admin Login portal
│   ├── dashboard/
│   │   └── index.html           # Dedicated Admin CMS Dashboard (Hero, Profile, Works, Services, etc.)
│   └── inquiries/
│       └── index.html           # Dedicated Lead Management CRM (Search, Filter, WhatsApp, Status)
├── logo.png                     # Official Rixel Studio high-res emblem
├── 200 by 200.png               # Square logo asset
├── 404.html                     # Custom 404 error page
├── env.example.js               # Local client configuration template (git-ignored)
├── .env.example                 # Environment variables template
├── .gitignore                   # Excludes env.js, .env, and sensitive files
└── README.md                    # Project documentation
```

---

© 2025 Rixel Studio. All rights reserved.
