-- ============================================================================
-- RIXEL STUDIO — PRODUCTION SUPABASE DATABASE SCHEMA (V2 ULTRA-RESILIENT)
-- Project ID: telynaezwbibshzckokh (Region: ap-northeast-1)
-- ============================================================================
-- Designed for 100% error-free execution in Supabase SQL Editor.
-- Idempotent: can be run repeatedly without errors or duplicate data.
-- ============================================================================

-- Safe extension check (built-in in modern PostgreSQL)
DO $$
BEGIN
    CREATE EXTENSION IF NOT EXISTS "pgcrypto";
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- ============================================================================
-- 1. INQUIRIES (Lead Management & Contact Form Submissions)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.inquiries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    name TEXT NOT NULL DEFAULT '',
    email TEXT NOT NULL DEFAULT '',
    phone TEXT DEFAULT '',
    company TEXT DEFAULT '',
    service TEXT DEFAULT '',
    budget TEXT DEFAULT '',
    deadline TEXT DEFAULT '',
    reference_url TEXT DEFAULT '',
    message TEXT NOT NULL DEFAULT '',
    status TEXT NOT NULL DEFAULT 'new'
);

-- Ensure all columns exist even if table was previously created with fewer columns
ALTER TABLE public.inquiries ADD COLUMN IF NOT EXISTS phone TEXT DEFAULT '';
ALTER TABLE public.inquiries ADD COLUMN IF NOT EXISTS company TEXT DEFAULT '';
ALTER TABLE public.inquiries ADD COLUMN IF NOT EXISTS service TEXT DEFAULT '';
ALTER TABLE public.inquiries ADD COLUMN IF NOT EXISTS budget TEXT DEFAULT '';
ALTER TABLE public.inquiries ADD COLUMN IF NOT EXISTS deadline TEXT DEFAULT '';
ALTER TABLE public.inquiries ADD COLUMN IF NOT EXISTS reference_url TEXT DEFAULT '';
ALTER TABLE public.inquiries ADD COLUMN IF NOT EXISTS message TEXT DEFAULT '';
ALTER TABLE public.inquiries ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'new';
ALTER TABLE public.inquiries ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now());

-- Safe status constraint
ALTER TABLE public.inquiries DROP CONSTRAINT IF EXISTS inquiries_status_check;
ALTER TABLE public.inquiries ADD CONSTRAINT inquiries_status_check 
    CHECK (status IN ('new', 'contacted', 'in_progress', 'completed', 'cancelled', 'in_review', 'archived'));

-- Backward compatibility table: contact_submissions
CREATE TABLE IF NOT EXISTS public.contact_submissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    name TEXT NOT NULL DEFAULT '',
    email TEXT NOT NULL DEFAULT '',
    phone TEXT DEFAULT '',
    company TEXT DEFAULT '',
    services TEXT[] DEFAULT ARRAY[]::TEXT[],
    budget TEXT DEFAULT '',
    deadline TEXT DEFAULT '',
    reference_url TEXT DEFAULT '',
    details TEXT NOT NULL DEFAULT '',
    status TEXT NOT NULL DEFAULT 'new',
    admin_notes TEXT DEFAULT ''
);

ALTER TABLE public.contact_submissions ADD COLUMN IF NOT EXISTS services TEXT[] DEFAULT ARRAY[]::TEXT[];
ALTER TABLE public.contact_submissions ADD COLUMN IF NOT EXISTS budget TEXT DEFAULT '';
ALTER TABLE public.contact_submissions ADD COLUMN IF NOT EXISTS deadline TEXT DEFAULT '';
ALTER TABLE public.contact_submissions ADD COLUMN IF NOT EXISTS reference_url TEXT DEFAULT '';
ALTER TABLE public.contact_submissions ADD COLUMN IF NOT EXISTS details TEXT DEFAULT '';
ALTER TABLE public.contact_submissions ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'new';
ALTER TABLE public.contact_submissions ADD COLUMN IF NOT EXISTS admin_notes TEXT DEFAULT '';

-- ============================================================================
-- 2. SITE SETTINGS
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.site_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    site_title TEXT NOT NULL DEFAULT 'Rixel Studio — Brand Identity, Motion Graphics & Creative Direction',
    meta_description TEXT NOT NULL DEFAULT 'Official portfolio of Rixel Studio. Specializing in memorable brand identities, cinematic motion graphics, and high-impact visual design.',
    footer_copyright TEXT NOT NULL DEFAULT '© 2025 Rixel Studio. All rights reserved. Crafted for digital immersion.',
    email TEXT NOT NULL DEFAULT 'ourrixelstudio@gmail.com',
    phone TEXT NOT NULL DEFAULT '+880 1849-697850',
    whatsapp TEXT NOT NULL DEFAULT '+880 1849-697850',
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.site_settings ADD COLUMN IF NOT EXISTS site_title TEXT DEFAULT 'Rixel Studio — Brand Identity, Motion Graphics & Creative Direction';
ALTER TABLE public.site_settings ADD COLUMN IF NOT EXISTS meta_description TEXT DEFAULT 'Official portfolio of Rixel Studio.';
ALTER TABLE public.site_settings ADD COLUMN IF NOT EXISTS footer_copyright TEXT DEFAULT '© 2025 Rixel Studio. All rights reserved.';
ALTER TABLE public.site_settings ADD COLUMN IF NOT EXISTS email TEXT DEFAULT 'ourrixelstudio@gmail.com';
ALTER TABLE public.site_settings ADD COLUMN IF NOT EXISTS phone TEXT DEFAULT '+880 1849-697850';
ALTER TABLE public.site_settings ADD COLUMN IF NOT EXISTS whatsapp TEXT DEFAULT '+880 1849-697850';

-- ============================================================================
-- 3. HERO CONTENT
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.hero_content (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    badge TEXT NOT NULL DEFAULT 'Graphic Design & Video Editing Studio',
    heading TEXT NOT NULL DEFAULT 'Brand Identities That',
    heading_highlight TEXT NOT NULL DEFAULT 'Get Remembered.',
    heading_suffix TEXT NOT NULL DEFAULT 'Motion That Converts.',
    subheading TEXT NOT NULL DEFAULT 'Graphic Design & Video Editing Studio',
    short_description TEXT NOT NULL DEFAULT 'Freelance Graphic Designer & Video Editor with 4+ years crafting visual identities, high-impact social creatives, and cinematic motion for forward-thinking startups, corporate leaders, and global institutions.',
    primary_btn_text TEXT NOT NULL DEFAULT 'Hire Me — Start a Project',
    primary_btn_url TEXT NOT NULL DEFAULT '#hire',
    secondary_btn_text TEXT NOT NULL DEFAULT 'View Portfolio',
    secondary_btn_url TEXT NOT NULL DEFAULT '#portfolio',
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.hero_content ADD COLUMN IF NOT EXISTS badge TEXT DEFAULT 'Graphic Design & Video Editing Studio';
ALTER TABLE public.hero_content ADD COLUMN IF NOT EXISTS heading TEXT DEFAULT 'Brand Identities That';
ALTER TABLE public.hero_content ADD COLUMN IF NOT EXISTS heading_highlight TEXT DEFAULT 'Get Remembered.';
ALTER TABLE public.hero_content ADD COLUMN IF NOT EXISTS heading_suffix TEXT DEFAULT 'Motion That Converts.';
ALTER TABLE public.hero_content ADD COLUMN IF NOT EXISTS subheading TEXT DEFAULT 'Graphic Design & Video Editing Studio';
ALTER TABLE public.hero_content ADD COLUMN IF NOT EXISTS short_description TEXT DEFAULT '';
ALTER TABLE public.hero_content ADD COLUMN IF NOT EXISTS primary_btn_text TEXT DEFAULT 'Hire Me — Start a Project';
ALTER TABLE public.hero_content ADD COLUMN IF NOT EXISTS primary_btn_url TEXT DEFAULT '#hire';
ALTER TABLE public.hero_content ADD COLUMN IF NOT EXISTS secondary_btn_text TEXT DEFAULT 'View Portfolio';
ALTER TABLE public.hero_content ADD COLUMN IF NOT EXISTS secondary_btn_url TEXT DEFAULT '#portfolio';

-- ============================================================================
-- 4. ABOUT CONTENT & STATS
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.about_content (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    badge TEXT NOT NULL DEFAULT 'MEET THE STUDIO',
    heading TEXT NOT NULL DEFAULT 'Bridging Regional Nuance with Global Design Standards',
    short_intro TEXT NOT NULL DEFAULT 'Available for New Projects • 4+ Years Practice',
    description TEXT NOT NULL DEFAULT 'Based in Dhaka and operating across international time zones, I lead Rixel Studio as an agile creative partner. Over four intense years, I have navigated brand launches, corporate communications revamps, and fast-moving social video campaigns.',
    description_p2 TEXT NOT NULL DEFAULT 'My core philosophy revolves around functional restraint: design must solve a commercial obstacle before it impresses visually. By combining deep contextual market knowledge with world-class digital aesthetics, I ensure your brand commands respect and attention.',
    experience_years TEXT NOT NULL DEFAULT '4+',
    completed_works TEXT NOT NULL DEFAULT '120+',
    corporate_clients TEXT NOT NULL DEFAULT '45+',
    ontime_delivery TEXT NOT NULL DEFAULT '99%',
    profile_image_url TEXT NOT NULL DEFAULT 'https://lh3.googleusercontent.com/aida-public/AB6AXuDZI-bkAJSgig4RUTgExitxh5DIuwkYDHWV1m7y9UjXbs8yiBh0AuyUEGOrSr2B8rLHogm7DhtSzeah2rN3RbzE3GxOewUCzCiq6rkt-V-QbMvmy764gFQkcn6lAbRgesSR7Ql7pETYOWO4VfpY1T11m12myzfS3UraWEnNgdw_9DyIHO1BKbLbVyYyhy6AgVX7rk01CW6x9mu2g710RKxHpeR26N6HPu-HIm_oWzwqhJ89ZplssBijInKjK21koHsdENnq6lNN5N51qtI',
    btn_text TEXT NOT NULL DEFAULT 'Start Collaboration',
    btn_url TEXT NOT NULL DEFAULT '#hire',
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.about_content ADD COLUMN IF NOT EXISTS badge TEXT DEFAULT 'MEET THE STUDIO';
ALTER TABLE public.about_content ADD COLUMN IF NOT EXISTS heading TEXT DEFAULT '';
ALTER TABLE public.about_content ADD COLUMN IF NOT EXISTS short_intro TEXT DEFAULT '';
ALTER TABLE public.about_content ADD COLUMN IF NOT EXISTS description TEXT DEFAULT '';
ALTER TABLE public.about_content ADD COLUMN IF NOT EXISTS description_p2 TEXT DEFAULT '';
ALTER TABLE public.about_content ADD COLUMN IF NOT EXISTS experience_years TEXT DEFAULT '4+';
ALTER TABLE public.about_content ADD COLUMN IF NOT EXISTS completed_works TEXT DEFAULT '120+';
ALTER TABLE public.about_content ADD COLUMN IF NOT EXISTS corporate_clients TEXT DEFAULT '45+';
ALTER TABLE public.about_content ADD COLUMN IF NOT EXISTS ontime_delivery TEXT DEFAULT '99%';
ALTER TABLE public.about_content ADD COLUMN IF NOT EXISTS profile_image_url TEXT DEFAULT '';
ALTER TABLE public.about_content ADD COLUMN IF NOT EXISTS btn_text TEXT DEFAULT 'Start Collaboration';
ALTER TABLE public.about_content ADD COLUMN IF NOT EXISTS btn_url TEXT DEFAULT '#hire';

-- ============================================================================
-- 5. SERVICES CMS
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.services (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    icon TEXT DEFAULT 'auto_awesome',
    display_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.services ADD COLUMN IF NOT EXISTS icon TEXT DEFAULT 'auto_awesome';
ALTER TABLE public.services ADD COLUMN IF NOT EXISTS display_order INTEGER DEFAULT 0;
ALTER TABLE public.services ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;

-- ============================================================================
-- 6. PORTFOLIO PROJECTS CMS
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.portfolio_projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    category TEXT NOT NULL,
    description TEXT,
    image_url TEXT NOT NULL,
    project_url TEXT DEFAULT '',
    display_order INTEGER NOT NULL DEFAULT 0,
    is_published BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.portfolio_projects ADD COLUMN IF NOT EXISTS project_url TEXT DEFAULT '';
ALTER TABLE public.portfolio_projects ADD COLUMN IF NOT EXISTS display_order INTEGER DEFAULT 0;
ALTER TABLE public.portfolio_projects ADD COLUMN IF NOT EXISTS is_published BOOLEAN DEFAULT true;

-- ============================================================================
-- 7. CONTACT INFORMATION
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.contact_info (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL DEFAULT 'Rixel Studio',
    email TEXT NOT NULL DEFAULT 'ourrixelstudio@gmail.com',
    phone TEXT NOT NULL DEFAULT '+880 1849-697850',
    whatsapp_number TEXT NOT NULL DEFAULT '+8801849697850',
    location TEXT NOT NULL DEFAULT 'Dhaka, Bangladesh • Serving Worldwide',
    availability_text TEXT NOT NULL DEFAULT 'Available for New Projects',
    contact_btn_text TEXT NOT NULL DEFAULT 'Chat on WhatsApp (+880 1849-697850)',
    contact_btn_url TEXT NOT NULL DEFAULT 'https://wa.me/8801849697850',
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.contact_info ADD COLUMN IF NOT EXISTS name TEXT DEFAULT 'Rixel Studio';
ALTER TABLE public.contact_info ADD COLUMN IF NOT EXISTS email TEXT DEFAULT 'ourrixelstudio@gmail.com';
ALTER TABLE public.contact_info ADD COLUMN IF NOT EXISTS phone TEXT DEFAULT '+880 1849-697850';
ALTER TABLE public.contact_info ADD COLUMN IF NOT EXISTS whatsapp_number TEXT DEFAULT '+8801849697850';
ALTER TABLE public.contact_info ADD COLUMN IF NOT EXISTS location TEXT DEFAULT 'Dhaka, Bangladesh • Serving Worldwide';
ALTER TABLE public.contact_info ADD COLUMN IF NOT EXISTS availability_text TEXT DEFAULT 'Available for New Projects';
ALTER TABLE public.contact_info ADD COLUMN IF NOT EXISTS contact_btn_text TEXT DEFAULT 'Chat on WhatsApp (+880 1849-697850)';
ALTER TABLE public.contact_info ADD COLUMN IF NOT EXISTS contact_btn_url TEXT DEFAULT 'https://wa.me/8801849697850';

-- ============================================================================
-- 8. SOCIAL LINKS
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.social_links (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    platform TEXT NOT NULL UNIQUE,
    label TEXT NOT NULL,
    url TEXT DEFAULT '',
    icon TEXT DEFAULT '',
    is_enabled BOOLEAN NOT NULL DEFAULT true,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.social_links ADD COLUMN IF NOT EXISTS is_enabled BOOLEAN DEFAULT true;

-- Backward compatibility table: site_content
CREATE TABLE IF NOT EXISTS public.site_content (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- ============================================================================
-- 9. ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================

ALTER TABLE public.inquiries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contact_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.site_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.hero_content ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.about_content ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.portfolio_projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contact_info ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.social_links ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.site_content ENABLE ROW LEVEL SECURITY;

-- 1. Inquiries RLS
DROP POLICY IF EXISTS "Public can submit inquiries" ON public.inquiries;
DROP POLICY IF EXISTS "Admins can view inquiries" ON public.inquiries;
DROP POLICY IF EXISTS "Admins can update inquiries" ON public.inquiries;
DROP POLICY IF EXISTS "Admins can delete inquiries" ON public.inquiries;

-- Public can ONLY insert new inquiries
CREATE POLICY "Public can submit inquiries"
ON public.inquiries FOR INSERT
TO public
WITH CHECK (true);

-- Authenticated Admin can view, update, and delete
CREATE POLICY "Admins can view inquiries"
ON public.inquiries FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Admins can update inquiries"
ON public.inquiries FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

CREATE POLICY "Admins can delete inquiries"
ON public.inquiries FOR DELETE
TO authenticated
USING (true);

-- Legacy contact_submissions RLS
DROP POLICY IF EXISTS "Public can submit contact inquiries" ON public.contact_submissions;
DROP POLICY IF EXISTS "Admins can view contact submissions" ON public.contact_submissions;
DROP POLICY IF EXISTS "Admins can update contact submissions" ON public.contact_submissions;
DROP POLICY IF EXISTS "Admins can delete contact submissions" ON public.contact_submissions;

CREATE POLICY "Public can submit contact inquiries" ON public.contact_submissions FOR INSERT TO public WITH CHECK (true);
CREATE POLICY "Admins can view contact submissions" ON public.contact_submissions FOR SELECT TO authenticated USING (true);
CREATE POLICY "Admins can update contact submissions" ON public.contact_submissions FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Admins can delete contact submissions" ON public.contact_submissions FOR DELETE TO authenticated USING (true);

-- 2. CMS Tables: Public READ, Authenticated Admin ALL
-- site_settings
DROP POLICY IF EXISTS "Public can read site settings" ON public.site_settings;
DROP POLICY IF EXISTS "Admins can modify site settings" ON public.site_settings;
CREATE POLICY "Public can read site settings" ON public.site_settings FOR SELECT TO public USING (true);
CREATE POLICY "Admins can modify site settings" ON public.site_settings FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- hero_content
DROP POLICY IF EXISTS "Public can read hero content" ON public.hero_content;
DROP POLICY IF EXISTS "Admins can modify hero content" ON public.hero_content;
CREATE POLICY "Public can read hero content" ON public.hero_content FOR SELECT TO public USING (true);
CREATE POLICY "Admins can modify hero content" ON public.hero_content FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- about_content
DROP POLICY IF EXISTS "Public can read about content" ON public.about_content;
DROP POLICY IF EXISTS "Admins can modify about content" ON public.about_content;
CREATE POLICY "Public can read about content" ON public.about_content FOR SELECT TO public USING (true);
CREATE POLICY "Admins can modify about content" ON public.about_content FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- services (Public sees active; Admin manages all)
DROP POLICY IF EXISTS "Public can read services" ON public.services;
DROP POLICY IF EXISTS "Admins can modify services" ON public.services;
CREATE POLICY "Public can read services" ON public.services FOR SELECT TO anon USING (is_active = true);
CREATE POLICY "Admins can modify services" ON public.services FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- portfolio_projects (Public sees published; Admin manages all)
DROP POLICY IF EXISTS "Public can read portfolio projects" ON public.portfolio_projects;
DROP POLICY IF EXISTS "Admins can modify portfolio projects" ON public.portfolio_projects;
CREATE POLICY "Public can read portfolio projects" ON public.portfolio_projects FOR SELECT TO anon USING (is_published = true);
CREATE POLICY "Admins can modify portfolio projects" ON public.portfolio_projects FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- contact_info
DROP POLICY IF EXISTS "Public can read contact info" ON public.contact_info;
DROP POLICY IF EXISTS "Admins can modify contact info" ON public.contact_info;
CREATE POLICY "Public can read contact info" ON public.contact_info FOR SELECT TO public USING (true);
CREATE POLICY "Admins can modify contact info" ON public.contact_info FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- social_links (Public sees enabled; Admin manages all)
DROP POLICY IF EXISTS "Public can read social links" ON public.social_links;
DROP POLICY IF EXISTS "Admins can modify social links" ON public.social_links;
CREATE POLICY "Public can read social links" ON public.social_links FOR SELECT TO anon USING (is_enabled = true);
CREATE POLICY "Admins can modify social links" ON public.social_links FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- site_content
DROP POLICY IF EXISTS "Public can read site content" ON public.site_content;
DROP POLICY IF EXISTS "Admins can modify site content" ON public.site_content;
CREATE POLICY "Public can read site content" ON public.site_content FOR SELECT TO public USING (true);
CREATE POLICY "Admins can modify site content" ON public.site_content FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- ============================================================================
-- 10. STORAGE BUCKETS & POLICIES (Safe Execution Block)
-- ============================================================================
DO $$
BEGIN
    -- Create public buckets if storage is available
    INSERT INTO storage.buckets (id, name, public)
    VALUES 
        ('profile-images', 'profile-images', true),
        ('portfolio-images', 'portfolio-images', true),
        ('site-assets', 'site-assets', true),
        ('studio-media', 'studio-media', true)
    ON CONFLICT (id) DO UPDATE SET public = true;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Notice: Storage buckets setup skipped in SQL. Buckets can be created via Supabase Dashboard -> Storage.';
END $$;

DO $$
BEGIN
    -- Storage RLS: Public read access
    BEGIN
        DROP POLICY IF EXISTS "Public can view studio assets" ON storage.objects;
        CREATE POLICY "Public can view studio assets"
        ON storage.objects FOR SELECT
        TO public
        USING (bucket_id IN ('profile-images', 'portfolio-images', 'site-assets', 'studio-media'));
    EXCEPTION WHEN OTHERS THEN NULL;
    END;

    -- Storage RLS: Authenticated admin write access
    BEGIN
        DROP POLICY IF EXISTS "Admin can manage studio assets" ON storage.objects;
        CREATE POLICY "Admin can manage studio assets"
        ON storage.objects FOR ALL
        TO authenticated
        USING (bucket_id IN ('profile-images', 'portfolio-images', 'site-assets', 'studio-media'))
        WITH CHECK (bucket_id IN ('profile-images', 'portfolio-images', 'site-assets', 'studio-media'));
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
END $$;

-- ============================================================================
-- 11. CONTENT MIGRATION & SEED DATA (Preserving All Existing Text & Assets)
-- ============================================================================

-- Clean extra singleton rows and ensure predictable single-row records
DELETE FROM public.site_settings WHERE id != '00000000-0000-0000-0000-000000000001';
INSERT INTO public.site_settings (id, site_title, meta_description, footer_copyright, email, phone, whatsapp)
VALUES (
    '00000000-0000-0000-0000-000000000001',
    'Rixel Studio — Brand Identity, Motion Graphics & Creative Direction',
    'Official portfolio of Rixel Studio. Specializing in memorable brand identities, cinematic motion graphics, and high-impact visual design for startups, corporate brands, and global institutions.',
    '© 2025 Rixel Studio. All rights reserved. Crafted for digital immersion.',
    'ourrixelstudio@gmail.com',
    '+880 1849-697850',
    '+880 1849-697850'
)
ON CONFLICT (id) DO UPDATE SET
    site_title = EXCLUDED.site_title,
    meta_description = EXCLUDED.meta_description,
    footer_copyright = EXCLUDED.footer_copyright,
    email = EXCLUDED.email,
    phone = EXCLUDED.phone,
    whatsapp = EXCLUDED.whatsapp;

DELETE FROM public.hero_content WHERE id != '00000000-0000-0000-0000-000000000002';
INSERT INTO public.hero_content (id, badge, heading, heading_highlight, heading_suffix, subheading, short_description, primary_btn_text, primary_btn_url, secondary_btn_text, secondary_btn_url)
VALUES (
    '00000000-0000-0000-0000-000000000002',
    'Graphic Design & Video Editing Studio',
    'Brand Identities That ',
    'Get Remembered.',
    ' Motion That Converts.',
    'Graphic Design & Video Editing Studio',
    'Freelance Graphic Designer & Video Editor with 4+ years crafting visual identities, high-impact social creatives, and cinematic motion for forward-thinking startups, corporate leaders, and global institutions.',
    'Hire Me — Start a Project',
    '#hire',
    'View Portfolio',
    '#portfolio'
)
ON CONFLICT (id) DO UPDATE SET
    badge = EXCLUDED.badge,
    heading = EXCLUDED.heading,
    heading_highlight = EXCLUDED.heading_highlight,
    heading_suffix = EXCLUDED.heading_suffix,
    subheading = EXCLUDED.subheading,
    short_description = EXCLUDED.short_description;

DELETE FROM public.about_content WHERE id != '00000000-0000-0000-0000-000000000003';
INSERT INTO public.about_content (id, badge, heading, short_intro, description, description_p2, experience_years, completed_works, corporate_clients, ontime_delivery, profile_image_url)
VALUES (
    '00000000-0000-0000-0000-000000000003',
    'MEET THE STUDIO',
    'Bridging Regional Nuance with Global Design Standards',
    'Available for New Projects • 4+ Years Practice',
    'Based in Dhaka and operating across international time zones, I lead Rixel Studio as an agile creative partner. Over four intense years, I have navigated brand launches, corporate communications revamps, and fast-moving social video campaigns.',
    'My core philosophy revolves around functional restraint: design must solve a commercial obstacle before it impresses visually. By combining deep contextual market knowledge with world-class digital aesthetics, I ensure your brand commands respect and attention.',
    '4+',
    '120+',
    '45+',
    '99%',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuDZI-bkAJSgig4RUTgExitxh5DIuwkYDHWV1m7y9UjXbs8yiBh0AuyUEGOrSr2B8rLHogm7DhtSzeah2rN3RbzE3GxOewUCzCiq6rkt-V-QbMvmy764gFQkcn6lAbRgesSR7Ql7pETYOWO4VfpY1T11m12myzfS3UraWEnNgdw_9DyIHO1BKbLbVyYyhy6AgVX7rk01CW6x9mu2g710RKxHpeR26N6HPu-HIm_oWzwqhJ89ZplssBijInKjK21koHsdENnq6lNN5N51qtI'
)
ON CONFLICT (id) DO UPDATE SET
    heading = EXCLUDED.heading,
    description = EXCLUDED.description,
    description_p2 = EXCLUDED.description_p2,
    experience_years = EXCLUDED.experience_years,
    completed_works = EXCLUDED.completed_works,
    corporate_clients = EXCLUDED.corporate_clients,
    ontime_delivery = EXCLUDED.ontime_delivery,
    profile_image_url = EXCLUDED.profile_image_url;

DELETE FROM public.contact_info WHERE id != '00000000-0000-0000-0000-000000000004';
INSERT INTO public.contact_info (id, name, email, phone, whatsapp_number, location, availability_text, contact_btn_text, contact_btn_url)
VALUES (
    '00000000-0000-0000-0000-000000000004',
    'Rixel Studio',
    'ourrixelstudio@gmail.com',
    '+880 1849-697850',
    '+8801849697850',
    'Dhaka, Bangladesh • Serving Worldwide',
    'Available for New Projects',
    'Chat on WhatsApp (+880 1849-697850)',
    'https://wa.me/8801849697850'
)
ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    phone = EXCLUDED.phone,
    whatsapp_number = EXCLUDED.whatsapp_number,
    location = EXCLUDED.location;

-- Services Seed (idempotent, prevents duplicates)
INSERT INTO public.services (title, description, icon, display_order, is_active)
SELECT 'Brand Identity Design', 'Full-spectrum visual systems built to outlast trends and command industry authority from day one. Logo suite, colors, typography, guidelines.', 'auto_awesome', 1, true
WHERE NOT EXISTS (SELECT 1 FROM public.services WHERE title = 'Brand Identity Design');

INSERT INTO public.services (title, description, icon, display_order, is_active)
SELECT 'Social Media Creative', 'Scroll-stopping graphic assets and multi-slide carousels engineered for engagement, reach, and performance ad conversion ROAS.', 'campaign', 2, true
WHERE NOT EXISTS (SELECT 1 FROM public.services WHERE title = 'Social Media Creative');

INSERT INTO public.services (title, description, icon, display_order, is_active)
SELECT 'Corporate Print Design', 'Flawless publication-grade print materials: corporate brochures, annual reports, rollups, business stationary, and event booths.', 'menu_book', 3, true
WHERE NOT EXISTS (SELECT 1 FROM public.services WHERE title = 'Corporate Print Design');

INSERT INTO public.services (title, description, icon, display_order, is_active)
SELECT 'Motion Graphics & 3D', 'Cinematic motion graphics, kinetic typography, 3D product animations, and visual effects that bring digital brands to life.', 'play_circle', 4, true
WHERE NOT EXISTS (SELECT 1 FROM public.services WHERE title = 'Motion Graphics & 3D');

INSERT INTO public.services (title, description, icon, display_order, is_active)
SELECT 'Video Editing & Commercials', 'High-paced promotional videos, YouTube long-form cuts, TikTok/Reels short-form edits, and commercial ad post-production.', 'movie', 5, true
WHERE NOT EXISTS (SELECT 1 FROM public.services WHERE title = 'Video Editing & Commercials');

-- Portfolio Projects Seed (12 projects, idempotent, prevents duplicates)
INSERT INTO public.portfolio_projects (title, category, description, image_url, project_url, display_order, is_published)
SELECT 'Apex Fintech — Brand System', 'Brand Identity', 'Complete visual identity system including dynamic geometric typography, modern cyan-blue color palettes, and stationary mockups for an algorithmic finance startup.', 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=1200', '', 1, true
WHERE NOT EXISTS (SELECT 1 FROM public.portfolio_projects WHERE title = 'Apex Fintech — Brand System');

INSERT INTO public.portfolio_projects (title, category, description, image_url, project_url, display_order, is_published)
SELECT 'Nova Energy Drinks', 'Social Media', 'High-energy launch campaign assets, Instagram reels covers, 3D beverage poster mockups, and bold typographic ads.', 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?q=80&w=1200', '', 2, true
WHERE NOT EXISTS (SELECT 1 FROM public.portfolio_projects WHERE title = 'Nova Energy Drinks');

INSERT INTO public.portfolio_projects (title, category, description, image_url, project_url, display_order, is_published)
SELECT 'EduCorp Annual Summit', 'Print Design', 'Print-ready annual report brochure, roll-up banners, badges, and keynote presentation guides in CMYK.', 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?q=80&w=1200', '', 3, true
WHERE NOT EXISTS (SELECT 1 FROM public.portfolio_projects WHERE title = 'EduCorp Annual Summit');

INSERT INTO public.portfolio_projects (title, category, description, image_url, project_url, display_order, is_published)
SELECT 'Pulse Fitness App', 'Motion Graphics', '3D motion teaser video for mobile app launch. Kinetic typography, 60fps UI transitions, and immersive sound design.', 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?q=80&w=1200', '', 4, true
WHERE NOT EXISTS (SELECT 1 FROM public.portfolio_projects WHERE title = 'Pulse Fitness App');

INSERT INTO public.portfolio_projects (title, category, description, image_url, project_url, display_order, is_published)
SELECT 'Zenith SaaS Launch', 'Brand Identity', 'Full corporate brand design: vector icon marks, design tokens, UI style manual, and digital investor pitch decks.', 'https://images.unsplash.com/photo-1507238691740-187a5b1d37b8?q=80&w=1200', '', 5, true
WHERE NOT EXISTS (SELECT 1 FROM public.portfolio_projects WHERE title = 'Zenith SaaS Launch');

INSERT INTO public.portfolio_projects (title, category, description, image_url, project_url, display_order, is_published)
SELECT 'Aura Cosmetic Line', 'Social Media', 'Minimalist, luxury beauty social content pack: carousel templates, packaging renders, and TikTok teaser story cuts.', 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?q=80&w=1200', '', 6, true
WHERE NOT EXISTS (SELECT 1 FROM public.portfolio_projects WHERE title = 'Aura Cosmetic Line');

INSERT INTO public.portfolio_projects (title, category, description, image_url, project_url, display_order, is_published)
SELECT 'TechSphere Expo Dhaka', 'Print Design', 'OOH billboards, booth wall wraps, VIP invitation cards, and glossy souvenir program book.', 'https://images.unsplash.com/photo-1505373877841-8d25f7d46678?q=80&w=1200', '', 7, true
WHERE NOT EXISTS (SELECT 1 FROM public.portfolio_projects WHERE title = 'TechSphere Expo Dhaka');

INSERT INTO public.portfolio_projects (title, category, description, image_url, project_url, display_order, is_published)
SELECT 'CryptoStream Token Teaser', 'Video Editing', 'High-velocity crypto teaser featuring glitch transitions, 3D coin rendering composites, and fast-paced sound design.', 'https://images.unsplash.com/photo-1639762681485-074b7f938ba0?q=80&w=1200', '', 8, true
WHERE NOT EXISTS (SELECT 1 FROM public.portfolio_projects WHERE title = 'CryptoStream Token Teaser');

INSERT INTO public.portfolio_projects (title, category, description, image_url, project_url, display_order, is_published)
SELECT 'Vertex Gaming Studio', 'Brand Identity', 'Edgy cyberpunk esports logo suite, twitch stream overlay packages, jersey print vectors, and brand guide.', 'https://images.unsplash.com/photo-1542751371-adc38448a05e?q=80&w=1200', '', 9, true
WHERE NOT EXISTS (SELECT 1 FROM public.portfolio_projects WHERE title = 'Vertex Gaming Studio');

INSERT INTO public.portfolio_projects (title, category, description, image_url, project_url, display_order, is_published)
SELECT 'Kalyan Organic Foods', 'Social Media', 'Clean, health-oriented social media assets, recipe story graphics, discount vouchers, and Meta performance ads.', 'https://images.unsplash.com/photo-1498837167922-ddd27525d352?q=80&w=1200', '', 10, true
WHERE NOT EXISTS (SELECT 1 FROM public.portfolio_projects WHERE title = 'Kalyan Organic Foods');

INSERT INTO public.portfolio_projects (title, category, description, image_url, project_url, display_order, is_published)
SELECT 'Radiant Architecture Monograph', 'Print Design', 'Hardcover coffee table architectural portfolio monograph with grid-aligned typographic layouts and foil stamping mockups.', 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?q=80&w=1200', '', 11, true
WHERE NOT EXISTS (SELECT 1 FROM public.portfolio_projects WHERE title = 'Radiant Architecture Monograph');

INSERT INTO public.portfolio_projects (title, category, description, image_url, project_url, display_order, is_published)
SELECT 'Solaris Electric Vehicles', 'Motion Graphics', 'Cinematic 3D commercial reveal for electric hypercar. Volumetric lighting, camera sweeps, and CGI particle trails.', 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?q=80&w=1200', '', 12, true
WHERE NOT EXISTS (SELECT 1 FROM public.portfolio_projects WHERE title = 'Solaris Electric Vehicles');

-- Social Links Seed (idempotent ON CONFLICT platform)
INSERT INTO public.social_links (platform, label, url, icon, is_enabled)
VALUES
('whatsapp', 'WhatsApp', 'https://wa.me/8801849697850', 'chat', true),
('email', 'Email', 'mailto:ourrixelstudio@gmail.com', 'mail', true),
('phone', 'Phone', 'tel:+8801849697850', 'call', true),
('facebook', 'Facebook', '', 'public', false),
('instagram', 'Instagram', '', 'photo_camera', false),
('linkedin', 'LinkedIn', '', 'work', false),
('behance', 'Behance', '', 'palette', false),
('dribbble', 'Dribbble', '', 'sports_basketball', false),
('github', 'GitHub', '', 'code', false),
('twitter', 'X / Twitter', '', 'alternate_email', false),
('youtube', 'YouTube', '', 'smart_display', false)
ON CONFLICT (platform) DO UPDATE SET
    url = EXCLUDED.url,
    is_enabled = EXCLUDED.is_enabled;
