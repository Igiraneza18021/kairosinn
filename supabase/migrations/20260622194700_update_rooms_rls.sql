-- Ensure the bucket room-images exists in Supabase storage
INSERT INTO storage.buckets (id, name, public)
VALUES ('room-images', 'room-images', true)
ON CONFLICT (id) DO NOTHING;

-- Drop old policy that only allowed manager
DROP POLICY IF EXISTS "Managers manage rooms" ON public.rooms;

-- Create new policy that allows both owner and manager to manage rooms
CREATE POLICY "Managers and owners manage rooms" ON public.rooms 
  FOR ALL 
  USING (public.is_owner_or_manager(auth.uid()));

-- Create policies for storage.objects for the room-images bucket to allow owner/manager uploads
-- Drop them first if they exist to prevent conflicts during migration
DROP POLICY IF EXISTS "Allow public read of room images" ON storage.objects;
DROP POLICY IF EXISTS "Allow managers and owners to insert room images" ON storage.objects;
DROP POLICY IF EXISTS "Allow managers and owners to update room images" ON storage.objects;
DROP POLICY IF EXISTS "Allow managers and owners to delete room images" ON storage.objects;

CREATE POLICY "Allow public read of room images" 
  ON storage.objects FOR SELECT 
  USING (bucket_id = 'room-images');

CREATE POLICY "Allow managers and owners to insert room images" 
  ON storage.objects FOR INSERT 
  WITH CHECK (bucket_id = 'room-images' AND public.is_owner_or_manager(auth.uid()));

CREATE POLICY "Allow managers and owners to update room images" 
  ON storage.objects FOR UPDATE 
  USING (bucket_id = 'room-images' AND public.is_owner_or_manager(auth.uid()));

CREATE POLICY "Allow managers and owners to delete room images" 
  ON storage.objects FOR DELETE 
  USING (bucket_id = 'room-images' AND public.is_owner_or_manager(auth.uid()));
