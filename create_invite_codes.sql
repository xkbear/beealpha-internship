-- 创建invite_codes表
CREATE TABLE IF NOT EXISTS invite_codes (
    id BIGSERIAL PRIMARY KEY,
    phone_number TEXT NOT NULL CHECK (phone_number ~ '^\+?[1-9]\d{1,14}$'),  -- 符合E.164国际手机号格式
    invite_code TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    UNIQUE(phone_number, invite_code)
);

-- 创建更新时间触发器
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = TIMEZONE('utc'::text, NOW());
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_invite_codes_updated_at
    BEFORE UPDATE ON invite_codes
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 插入初始数据（示例手机号，请替换为实际手机号）
INSERT INTO invite_codes (phone_number, invite_code)
VALUES ('+8612345678901', '123456')
ON CONFLICT (phone_number, invite_code) DO NOTHING;

-- 创建RLS策略
ALTER TABLE invite_codes ENABLE ROW LEVEL SECURITY;

-- 创建只读策略（允许匿名用户查询）
CREATE POLICY "Allow anonymous select" ON invite_codes
    FOR SELECT
    TO anon
    USING (true);

-- 创建插入策略（仅允许服务角色插入）
CREATE POLICY "Allow service role insert" ON invite_codes
    FOR INSERT
    TO service_role
    WITH CHECK (true);

-- 创建更新策略（仅允许服务角色更新）
CREATE POLICY "Allow service role update" ON invite_codes
    FOR UPDATE
    TO service_role
    USING (true)
    WITH CHECK (true);

-- 创建删除策略（仅允许服务角色删除）
CREATE POLICY "Allow service role delete" ON invite_codes
    FOR DELETE
    TO service_role
    USING (true); 