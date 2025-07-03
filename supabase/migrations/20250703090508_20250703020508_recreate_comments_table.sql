-- Drop the incorrectly structured comment table and recreate with proper structure

-- Drop the wrong comment table
DROP TABLE IF EXISTS comment CASCADE;

-- Also drop the comments table if it exists with wrong structure
DROP TABLE IF EXISTS comments CASCADE;

-- Create the correct comments table
CREATE TABLE comments (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  post_id bigint NOT NULL,
  user_id uuid NOT NULL,
  content text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Add foreign key constraints
ALTER TABLE comments 
ADD CONSTRAINT comments_post_id_fkey 
FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE;

ALTER TABLE comments 
ADD CONSTRAINT comments_user_id_fkey 
FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE;

-- Enable RLS
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;

-- Create policies for comments
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

-- Add indexes
CREATE INDEX idx_comments_post_id ON comments(post_id);
CREATE INDEX idx_comments_user_id ON comments(user_id);
CREATE INDEX idx_comments_created_at ON comments(created_at);

-- Add trigger for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_comments_updated_at 
BEFORE UPDATE ON comments 
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
