-- ========================================
-- REEMVERSE SUPABASE MIGRATION - PRODUCTION READY
-- Complete schema correction and RLS policies
-- ========================================

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ========== CREATE MISSING TABLES FIRST ==========

-- Ensure Profiles Table exists with correct structure
CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY,
  email text,
  full_name text,
  avatar_url text,
  created_at timestamptz DEFAULT now(),
  bio text,
  phone text,
  note text
);

-- Ensure Posts Table exists with correct structure
CREATE TABLE IF NOT EXISTS posts (
  id bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  created_at timestamptz DEFAULT now(),
  user_id uuid REFERENCES profiles(id),
  title text,
  content text,
  image_url text
);

-- Ensure Marketplace Table exists with correct structure
CREATE TABLE IF NOT EXISTS marketplace (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at timestamptz DEFAULT now(),
  user_id uuid REFERENCES profiles(id),
  title text,
  description text,
  price numeric,
  image_url text
);

-- Create Comments Table (MISSING from current schema)
CREATE TABLE IF NOT EXISTS comments (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  post_id bigint REFERENCES posts(id) ON DELETE CASCADE,
  user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  content text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create Post Likes Table (may be missing)
CREATE TABLE IF NOT EXISTS post_likes (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  post_id bigint REFERENCES posts(id) ON DELETE CASCADE,
  user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  UNIQUE(post_id, user_id)
);

-- Ensure Messages Table exists
CREATE TABLE IF NOT EXISTS messages (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  sender_id uuid REFERENCES profiles(id),
  receiver_id uuid REFERENCES profiles(id),
  content text,
  is_read boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

-- Ensure Notifications Table exists
CREATE TABLE IF NOT EXISTS notifications (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id uuid REFERENCES profiles(id),
  title text,
  body text,
  is_read boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

-- Ensure Post Details Table exists
CREATE TABLE IF NOT EXISTS post_details (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  post_id bigint REFERENCES posts(id) ON DELETE CASCADE,
  content text,
  images text[],
  created_at timestamptz DEFAULT now()
);

-- Ensure Marketplace Details Table exists
CREATE TABLE IF NOT EXISTS marketplace_details (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  product_id uuid REFERENCES marketplace(id) ON DELETE CASCADE,
  description text,
  additional_images text[],
  seller_notes text,
  created_at timestamptz DEFAULT now()
);

-- ========== DROP EXISTING POLICIES SAFELY ==========
-- Only drop policies if tables exist
DO $$
BEGIN
    -- Profiles policies
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'profiles') THEN
        DROP POLICY IF EXISTS "Allow users to update their own profile" ON profiles;
        DROP POLICY IF EXISTS "Allow users to view all profiles" ON profiles;
        DROP POLICY IF EXISTS "Allow users to insert their own profile" ON profiles;
        DROP POLICY IF EXISTS "Allow profile owner to update own profile" ON profiles;
    END IF;

    -- Posts policies
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'posts') THEN
        DROP POLICY IF EXISTS "Allow anyone to read posts" ON posts;
        DROP POLICY IF EXISTS "Allow users to insert posts" ON posts;
        DROP POLICY IF EXISTS "Allow users to update their own posts" ON posts;
        DROP POLICY IF EXISTS "Allow users to delete their own posts" ON posts;
    END IF;

    -- Marketplace policies
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'marketplace') THEN
        DROP POLICY IF EXISTS "Allow anyone to view marketplace" ON marketplace;
        DROP POLICY IF EXISTS "Allow users to insert items" ON marketplace;
        DROP POLICY IF EXISTS "Allow users to update their own items" ON marketplace;
        DROP POLICY IF EXISTS "Allow users to delete their own items" ON marketplace;
    END IF;

    -- Notifications policies
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'notifications') THEN
        DROP POLICY IF EXISTS "Users can read their notifications" ON notifications;
        DROP POLICY IF EXISTS "Users can manage their notifications" ON notifications;
    END IF;

    -- Messages policies
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'messages') THEN
        DROP POLICY IF EXISTS "Allow users to insert messages" ON messages;
        DROP POLICY IF EXISTS "Allow users to update their own sent messages" ON messages;
        DROP POLICY IF EXISTS "Allow users to delete their own sent messages" ON messages;
        DROP POLICY IF EXISTS "Allow users to view their messages" ON messages;
    END IF;

    -- Post Likes policies
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'post_likes') THEN
        DROP POLICY IF EXISTS "Allow users to view post likes" ON post_likes;
        DROP POLICY IF EXISTS "Allow users to insert post likes" ON post_likes;
        DROP POLICY IF EXISTS "Allow users to delete their own post likes" ON post_likes;
    END IF;

    -- Comments policies
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'comments') THEN
        DROP POLICY IF EXISTS "Allow users to view all comments" ON comments;
        DROP POLICY IF EXISTS "Allow users to insert comments" ON comments;
        DROP POLICY IF EXISTS "Allow users to update their own comments" ON comments;
        DROP POLICY IF EXISTS "Allow users to delete their own comments" ON comments;
    END IF;

    -- Post Details policies
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'post_details') THEN
        DROP POLICY IF EXISTS "Allow all users to view post details" ON post_details;
        DROP POLICY IF EXISTS "Allow authors manage own post details" ON post_details;
    END IF;

    -- Marketplace Details policies
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'marketplace_details') THEN
        DROP POLICY IF EXISTS "Allow all users to view marketplace details" ON marketplace_details;
        DROP POLICY IF EXISTS "Allow sellers manage own marketplace details" ON marketplace_details;
    END IF;
END $$;

-- ========== ENABLE ROW LEVEL SECURITY ==========
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE marketplace ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_details ENABLE ROW LEVEL SECURITY;
ALTER TABLE marketplace_details ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;

-- ========== PROFILES POLICIES ==========
CREATE POLICY "profiles_select_all"
  ON profiles FOR SELECT 
  USING (true);

CREATE POLICY "profiles_insert_own"
  ON profiles FOR INSERT 
  WITH CHECK (auth.uid() = id);

CREATE POLICY "profiles_update_own"
  ON profiles FOR UPDATE 
  USING (auth.uid() = id);

CREATE POLICY "profiles_delete_own"
  ON profiles FOR DELETE 
  USING (auth.uid() = id);

-- ========== POSTS POLICIES ==========
CREATE POLICY "posts_select_all"
  ON posts FOR SELECT 
  USING (true);

CREATE POLICY "posts_insert_own"
  ON posts FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "posts_update_own"
  ON posts FOR UPDATE 
  USING (auth.uid() = user_id);

CREATE POLICY "posts_delete_own"
  ON posts FOR DELETE 
  USING (auth.uid() = user_id);

-- ========== MARKETPLACE POLICIES ==========
CREATE POLICY "marketplace_select_all"
  ON marketplace FOR SELECT 
  USING (true);

CREATE POLICY "marketplace_insert_own"
  ON marketplace FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "marketplace_update_own"
  ON marketplace FOR UPDATE 
  USING (auth.uid() = user_id);

CREATE POLICY "marketplace_delete_own"
  ON marketplace FOR DELETE 
  USING (auth.uid() = user_id);

-- ========== COMMENTS POLICIES ==========
CREATE POLICY "comments_select_all"
  ON comments FOR SELECT 
  USING (true);

CREATE POLICY "comments_insert_own"
  ON comments FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "comments_update_own"
  ON comments FOR UPDATE 
  USING (auth.uid() = user_id);

CREATE POLICY "comments_delete_own"
  ON comments FOR DELETE 
  USING (auth.uid() = user_id);

-- ========== POST LIKES POLICIES ==========
CREATE POLICY "post_likes_select_all"
  ON post_likes FOR SELECT 
  USING (true);

CREATE POLICY "post_likes_insert_own"
  ON post_likes FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "post_likes_delete_own"
  ON post_likes FOR DELETE 
  USING (auth.uid() = user_id);

-- ========== MESSAGES POLICIES ==========
CREATE POLICY "messages_select_own"
  ON messages FOR SELECT 
  USING (auth.uid() = sender_id OR auth.uid() = receiver_id);

CREATE POLICY "messages_insert_own"
  ON messages FOR INSERT 
  WITH CHECK (auth.uid() = sender_id);

CREATE POLICY "messages_update_sender"
  ON messages FOR UPDATE 
  USING (auth.uid() = sender_id);

CREATE POLICY "messages_delete_sender"
  ON messages FOR DELETE 
  USING (auth.uid() = sender_id);

-- ========== NOTIFICATIONS POLICIES ==========
CREATE POLICY "notifications_select_own"
  ON notifications FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "notifications_insert_own"
  ON notifications FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "notifications_update_own"
  ON notifications FOR UPDATE 
  USING (auth.uid() = user_id);

CREATE POLICY "notifications_delete_own"
  ON notifications FOR DELETE 
  USING (auth.uid() = user_id);

-- ========== POST DETAILS POLICIES ==========
CREATE POLICY "post_details_select_all"
  ON post_details FOR SELECT 
  USING (true);

CREATE POLICY "post_details_manage_own"
  ON post_details FOR ALL 
  USING (
    post_id IN (
      SELECT id FROM posts WHERE user_id = auth.uid()
    )
  );

-- ========== MARKETPLACE DETAILS POLICIES ==========
CREATE POLICY "marketplace_details_select_all"
  ON marketplace_details FOR SELECT 
  USING (true);

CREATE POLICY "marketplace_details_manage_own"
  ON marketplace_details FOR ALL 
  USING (
    product_id IN (
      SELECT id FROM marketplace WHERE user_id = auth.uid()
    )
  );

-- ========== CREATE MISSING INDEXES FOR PERFORMANCE ==========
CREATE INDEX IF NOT EXISTS idx_posts_user_id ON posts(user_id);
CREATE INDEX IF NOT EXISTS idx_posts_created_at ON posts(created_at);
CREATE INDEX IF NOT EXISTS idx_marketplace_user_id ON marketplace(user_id);
CREATE INDEX IF NOT EXISTS idx_marketplace_created_at ON marketplace(created_at);
CREATE INDEX IF NOT EXISTS idx_comments_post_id ON comments(post_id);
CREATE INDEX IF NOT EXISTS idx_comments_user_id ON comments(user_id);
CREATE INDEX IF NOT EXISTS idx_comments_created_at ON comments(created_at);
CREATE INDEX IF NOT EXISTS idx_post_likes_post_id ON post_likes(post_id);
CREATE INDEX IF NOT EXISTS idx_post_likes_user_id ON post_likes(user_id);
CREATE INDEX IF NOT EXISTS idx_messages_sender_id ON messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_messages_receiver_id ON messages(receiver_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages(created_at);
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at);

-- ========== CREATE FOREIGN KEY CONSTRAINTS ==========
-- Add missing foreign key constraints with proper names for joins

-- Posts to Profiles foreign key
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'posts_user_id_fkey'
    ) THEN
        ALTER TABLE posts 
        ADD CONSTRAINT posts_user_id_fkey 
        FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE;
    END IF;
END $$;

-- Marketplace to Profiles foreign key
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'marketplace_user_id_fkey'
    ) THEN
        ALTER TABLE marketplace 
        ADD CONSTRAINT marketplace_user_id_fkey 
        FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE;
    END IF;
END $$;

-- Comments to Profiles foreign key
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'comments_user_id_fkey'
    ) THEN
        ALTER TABLE comments 
        ADD CONSTRAINT comments_user_id_fkey 
        FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE;
    END IF;
END $$;

-- ========== FUNCTIONS FOR TRIGGERS ==========

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Add updated_at triggers for comments
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger 
        WHERE tgname = 'update_comments_updated_at'
    ) THEN
        CREATE TRIGGER update_comments_updated_at 
        BEFORE UPDATE ON comments 
        FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    END IF;
END $$;

-- ========== VERIFY SCHEMA INTEGRITY ==========
-- This will help identify any remaining issues
DO $$
DECLARE
    missing_table text;
    missing_column text;
BEGIN
    -- Check if all required tables exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'profiles') THEN
        RAISE EXCEPTION 'Missing table: profiles';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'posts') THEN
        RAISE EXCEPTION 'Missing table: posts';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'marketplace') THEN
        RAISE EXCEPTION 'Missing table: marketplace';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'comments') THEN
        RAISE EXCEPTION 'Missing table: comments';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'post_likes') THEN
        RAISE EXCEPTION 'Missing table: post_likes';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'messages') THEN
        RAISE EXCEPTION 'Missing table: messages';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'notifications') THEN
        RAISE EXCEPTION 'Missing table: notifications';
    END IF;
    
    RAISE NOTICE 'Schema migration completed successfully! All tables and policies are ready.';
END $$;

-- ========== END MIGRATION ==========
-- Schema is now production-ready and aligned with Flutter app requirements
