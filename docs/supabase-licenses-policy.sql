-- =============================================================================
-- xolve ライセンス: RLS ポリシー（アプリ src/main/licenseHandlers.ts のクエリに合わせる）
-- =============================================================================
-- アプリが送る UPDATE の形:
--
-- 【check-license・新規端末登録】
--   UPDATE ... SET machine_id = <端末ID>, user_email = ?
--   WHERE license_key = ? AND status = 'active' AND machine_id IS NULL
--   または
--   WHERE license_key = ? AND status = 'active' AND machine_id = ''
--
-- 【release-license・解放】
--   UPDATE ... SET machine_id = ''   （NOT NULL 列向けに先に試す）
--   WHERE license_key = ?
--   失敗時
--   UPDATE ... SET machine_id = null
--   WHERE license_key = ?
--
-- SELECT は .eq('license_key', key) のみ。SELECT 用ポリシーが無いと照会できないため、
-- 下に anon 用 SELECT 例を含めています（既に同等ポリシーがある場合は重複作成しないこと）。
-- =============================================================================

-- 1. 既存の制限付き更新ポリシーを削除（名前は環境に合わせて調整）
DROP POLICY IF EXISTS "Allow machine_id registration" ON public.licenses;
DROP POLICY IF EXISTS "Allow license registration and release" ON public.licenses;

-- 2. UPDATE: 既存行が「有効なライセンス」なら更新を許可（登録元は null/空、解放元は端末ID入りの行）
--    アプリ側は license_key で行を特定する。WITH CHECK で更新後も status が有効なままであることを要求。
CREATE POLICY "licenses_anon_update_registration_and_release" ON public.licenses
  FOR UPDATE
  USING (
    lower(trim(coalesce(status::text, ''))) IN ('active', 'valid', 'enabled')
  )
  WITH CHECK (
    lower(trim(coalesce(status::text, ''))) IN ('active', 'valid', 'enabled')
  );

-- 3. SELECT: 照会が RLS で弾かれる場合のみ必要（未作成なら有効化）
--    注意: USING (true) は「行の読み取り」を anon に開く。運用上は license_key 秘匿でリスク低減。
DROP POLICY IF EXISTS "licenses_anon_select_for_app" ON public.licenses;
CREATE POLICY "licenses_anon_select_for_app" ON public.licenses
  FOR SELECT
  USING (true);

-- 4. updated_at 自動更新（列 licenses.updated_at がある前提）
CREATE OR REPLACE FUNCTION public.update_licenses_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS update_licenses_updated_at ON public.licenses;

CREATE TRIGGER update_licenses_updated_at
  BEFORE UPDATE ON public.licenses
  FOR EACH ROW
  EXECUTE FUNCTION public.update_licenses_updated_at();

-- PostgreSQL 11〜13 で EXECUTE FUNCTION が使えない場合は次の1行に置き換え:
-- EXECUTE PROCEDURE public.update_licenses_updated_at();
