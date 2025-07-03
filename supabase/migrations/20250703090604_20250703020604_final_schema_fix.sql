-- ========================================
-- REEMVERSE FINAL SCHEMA FIX - PRODUCTION READY
-- ========================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ========== DROP PROBLEMATIC TABLES ==========
DROP TABLE IF EXISTS comment CASCADE;
DROP TABLE IF EXISTS "PostDetailsScreen" CASCADE;

-- ========== CREATE/FIX ALL REQUIRED TABLES ==========

-- 1. Comments Table (correctly structured)
CREATE TABLE IF NOT EXISTS comments (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  post_id bigint NOT NULL,
  user_id uuid NOT NULL,
  content text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- 2. Post Likes Table
CREATE TABLE IF NOT EXISTS post_likes (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  post_id bigint NOT NULL,
  user_id uuid NOT NULL,
  created_at timestamptz DEFAULT now(),
  UNIQUE(post_id, user_id)
);

-- ========== ADD FOREIGN KEY CONSTRAINTS ==========

-- Comments foreign keys
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'comments_post_id_fkey'
    ) THEN
        ALTER TABLE comments 
        ADD CONSTRAINT comments_post_id_fkey 
        FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE;
    END IF;
END $$;

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

-- Post likes foreign keys
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'post_likes_post_id_fkey'
    ) THEN
        ALTER TABLE post_likes 
        ADD CONSTRAINT post_likes_post_id_fkey 
        FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE;
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'post_likes_user_id_fkey'
    ) THEN
        ALTER TABLE post_likes 
        ADD CONSTRAINT post_likes_user_id_fkey 
        FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE;
    END IF;
END $$;

-- ========== ENABLE ROW LEVEL SECURITY ==========
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_likes ENABLE ROW LEVEL SECURITY;

-- ========== DROP EXISTING POLICIES SAFELY ==========
DROP POLICY IF EXISTS "comments_select_all" ON comments;
DROP POLICY IF EXISTS "comments_insert_own" ON comments;
DROP POLICY IF EXISTS "comments_update_own" ON comments;
DROP POLICY IF EXISTS "comments_delete_own" ON comments;

DROP POLICY IF EXISTS "post_likes_select_all" ON post_likes;
DROP POLICY IF EXISTS "post_likes_insert_own" ON post_likes;
DROP POLICY IF EXISTS "post_likes_delete_own" ON post_likes;

-- ========== CREATE POLICIES ==========

-- Comments policies
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

-- Post likes policies
CREATE POLICY "post_likes_select_all"
  ON post_likes FOR SELECT 
  USING (true);

CREATE POLICY "post_likes_insert_own"
  ON post_likes FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "post_likes_delete_own"
  ON post_likes FOR DELETE 
  USING (auth.uid() = user_id);

-- ========== CREATE INDEXES ==========
CREATE INDEX IF NOT EXISTS idx_comments_post_id ON comments(post_id);
CREATE INDEX IF NOT EXISTS idx_comments_user_id ON comments(user_id);
CREATE INDEX IF NOT EXISTS idx_comments_created_at ON comments(created_at);
CREATE INDEX IF NOT EXISTS idx_post_likes_post_id ON post_likes(post_id);
CREATE INDEX IF NOT EXISTS idx_post_likes_user_id ON post_likes(user_id);

-- ========== CREATE TRIGGERS ==========
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS update_comments_updated_at ON comments;
CREATE TRIGGER update_comments_updated_at 
BEFORE UPDATE ON comments 
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ========== VERIFY FINAL SCHEMA ==========
DO $$
BEGIN
    -- Verify critical tables exist
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
    
    RAISE NOTICE 'FINAL SCHEMA VERIFICATION SUCCESSFUL! All required tables and policies are in place.';
END $$;
