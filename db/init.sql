-- ============================================
-- QA TMS — Test Management System
-- Database Schema
-- ============================================

-- Расширение для UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- 1. WORKSPACES (Компании / Рабочие пространства)
-- ============================================
CREATE TABLE workspaces (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    description TEXT DEFAULT '',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 2. USERS (Пользователи)
-- ============================================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) DEFAULT '',
    avatar_url VARCHAR(500) DEFAULT '',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 3. WORKSPACE MEMBERS (Связь юзеров и воркспейсов)
-- ============================================
CREATE TABLE workspace_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(20) NOT NULL DEFAULT 'member' CHECK (role IN ('owner', 'admin', 'member', 'viewer')),
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(workspace_id, user_id)
);

-- ============================================
-- 4. PROJECTS (Проекты внутри воркспейса)
-- ============================================
CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT DEFAULT '',
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 5. SUITES (Папки / Сьюты для тест-кейсов)
-- ============================================
CREATE TABLE suites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    parent_id UUID REFERENCES suites(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT DEFAULT '',
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 6. TEST CASES (Тест-кейсы)
-- ============================================
CREATE TABLE test_cases (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    suite_id UUID REFERENCES suites(id) ON DELETE SET NULL,
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
    
    title VARCHAR(500) NOT NULL,
    description TEXT DEFAULT '',
    preconditions TEXT DEFAULT '',
    steps JSONB DEFAULT '[]',
    expected_result TEXT DEFAULT '',
    test_data JSONB DEFAULT '{}',
    
    priority VARCHAR(20) DEFAULT 'medium' CHECK (priority IN ('critical', 'high', 'medium', 'low')),
    type VARCHAR(30) DEFAULT 'functional' CHECK (type IN ('functional', 'smoke', 'regression', 'ui', 'api', 'performance', 'security')),
    automation_status VARCHAR(20) DEFAULT 'manual' CHECK (automation_status IN ('manual', 'automated', 'to_automate')),
    
    tags TEXT[] DEFAULT '{}',
    
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 7. TEST RUNS (Тест-раны / Прогоны)
-- ============================================
CREATE TABLE test_runs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    
    name VARCHAR(255) NOT NULL,
    description TEXT DEFAULT '',
    run_type VARCHAR(30) DEFAULT 'manual' CHECK (run_type IN ('smoke', 'regression', 'manual', 'scheduled', 'release')),
    
    status VARCHAR(20) DEFAULT 'in_progress' CHECK (status IN ('planned', 'in_progress', 'completed', 'cancelled')),
    
    started_at TIMESTAMP WITH TIME ZONE,
    finished_at TIMESTAMP WITH TIME ZONE,
    
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 8. TEST RESULTS (Результаты тестов в прогоне)
-- ============================================
CREATE TABLE test_results (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    test_run_id UUID NOT NULL REFERENCES test_runs(id) ON DELETE CASCADE,
    test_case_id UUID NOT NULL REFERENCES test_cases(id) ON DELETE CASCADE,
    
    status VARCHAR(20) DEFAULT 'not_run' CHECK (status IN ('passed', 'failed', 'blocked', 'skipped', 'not_run')),
    comment TEXT DEFAULT '',
    defect_url VARCHAR(500) DEFAULT '',
    
    executed_by UUID REFERENCES users(id),
    executed_at TIMESTAMP WITH TIME ZONE,
    duration_seconds INTEGER DEFAULT 0,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(test_run_id, test_case_id)
);

-- ============================================
-- ИНДЕКСЫ (для скорости)
-- ============================================
CREATE INDEX idx_test_cases_workspace ON test_cases(workspace_id);
CREATE INDEX idx_test_cases_project ON test_cases(project_id);
CREATE INDEX idx_test_cases_suite ON test_cases(suite_id);
CREATE INDEX idx_test_runs_workspace ON test_runs(workspace_id);
CREATE INDEX idx_test_results_run ON test_results(test_run_id);
CREATE INDEX idx_workspace_members_user ON workspace_members(user_id);
CREATE INDEX idx_workspace_members_workspace ON workspace_members(workspace_id);

-- ============================================
-- ДЕМО-ДАННЫЕ
-- ============================================

-- Воркспейс
INSERT INTO workspaces (id, name, slug, description) VALUES
('a0000000-0000-0000-0000-000000000001', 'My QA Team', 'my-qa-team', 'Main workspace');

-- Проект
INSERT INTO projects (id, workspace_id, name, description) VALUES
('b0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'E-Commerce Platform', 'Testing e-commerce');

-- Сьюты
INSERT INTO suites (id, project_id, name, description, sort_order) VALUES
('c0000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-000000000001', 'Authentication', 'Login, registration', 1),
('c0000000-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000001', 'Checkout', 'Cart, payment', 2);

-- Тест-кейсы
INSERT INTO test_cases (id, suite_id, project_id, workspace_id, title, preconditions, steps, expected_result, priority, type, tags) VALUES
('d0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 
 'Login with valid credentials', 
 'User is registered', 
 '[{"step": 1, "action": "Open login page"}, {"step": 2, "action": "Enter email and password"}, {"step": 3, "action": "Click Login button"}]', 
 'User is redirected to dashboard', 
 'critical', 'smoke', '{auth, login}'),

('d0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 
 'Checkout with valid credit card', 
 'User is logged in, cart has items', 
 '[{"step": 1, "action": "Go to cart"}, {"step": 2, "action": "Click checkout"}, {"step": 3, "action": "Enter card details"}]', 
 'Order is created successfully', 
 'high', 'regression', '{checkout, payment}');
