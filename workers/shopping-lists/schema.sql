-- D1 Schema for shared shopping lists
-- This runs on Cloudflare's edge SQLite (D1)

-- Shopping lists
CREATE TABLE IF NOT EXISTS shopping_lists (
    id TEXT PRIMARY KEY,
    owner_id TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    is_shared INTEGER DEFAULT 0,
    share_code TEXT UNIQUE,
    created_at TEXT DEFAULT (datetime('now')),
    updated_at TEXT DEFAULT (datetime('now'))
);

-- List members (for shared lists)
CREATE TABLE IF NOT EXISTS list_members (
    id TEXT PRIMARY KEY,
    list_id TEXT NOT NULL REFERENCES shopping_lists(id) ON DELETE CASCADE,
    user_id TEXT NOT NULL,
    role TEXT DEFAULT 'viewer', -- 'owner', 'editor', 'viewer'
    joined_at TEXT DEFAULT (datetime('now')),
    UNIQUE(list_id, user_id)
);

-- Shopping list items
CREATE TABLE IF NOT EXISTS list_items (
    id TEXT PRIMARY KEY,
    list_id TEXT NOT NULL REFERENCES shopping_lists(id) ON DELETE CASCADE,
    product_id TEXT, -- Reference to product in main DB
    custom_name TEXT, -- For items not in product catalog
    quantity REAL DEFAULT 1,
    unit TEXT,
    checked INTEGER DEFAULT 0,
    checked_by TEXT,
    checked_at TEXT,
    added_by TEXT NOT NULL,
    notes TEXT,
    position INTEGER DEFAULT 0,
    created_at TEXT DEFAULT (datetime('now')),
    updated_at TEXT DEFAULT (datetime('now'))
);

-- Product substitutes (user-defined)
CREATE TABLE IF NOT EXISTS substitutes (
    id TEXT PRIMARY KEY,
    list_item_id TEXT NOT NULL REFERENCES list_items(id) ON DELETE CASCADE,
    product_id TEXT NOT NULL,
    preference INTEGER DEFAULT 0, -- Higher = more preferred
    created_at TEXT DEFAULT (datetime('now'))
);

-- List history for sync
CREATE TABLE IF NOT EXISTS list_changes (
    id TEXT PRIMARY KEY,
    list_id TEXT NOT NULL REFERENCES shopping_lists(id) ON DELETE CASCADE,
    user_id TEXT NOT NULL,
    change_type TEXT NOT NULL, -- 'add', 'remove', 'check', 'uncheck', 'update'
    item_id TEXT,
    old_value TEXT,
    new_value TEXT,
    created_at TEXT DEFAULT (datetime('now'))
);

-- Indexes for common queries
CREATE INDEX IF NOT EXISTS idx_list_items_list ON list_items(list_id);
CREATE INDEX IF NOT EXISTS idx_list_items_checked ON list_items(list_id, checked);
CREATE INDEX IF NOT EXISTS idx_list_members_user ON list_members(user_id);
CREATE INDEX IF NOT EXISTS idx_list_changes_list ON list_changes(list_id, created_at);
CREATE INDEX IF NOT EXISTS idx_shopping_lists_owner ON shopping_lists(owner_id);
CREATE INDEX IF NOT EXISTS idx_shopping_lists_share ON shopping_lists(share_code);
