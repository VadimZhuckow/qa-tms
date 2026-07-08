<template>
  <div class="sidebar">
    <div class="sidebar-header">
      <h2>🧪 QA TMS</h2>
    </div>
    <nav class="sidebar-nav">
      <router-link to="/" class="nav-item" active-class="active">
        <span class="icon">📊</span>
        <span>Dashboard</span>
      </router-link>
      <router-link to="/test-cases" class="nav-item" active-class="active">
        <span class="icon">📋</span>
        <span>Test Cases</span>
      </router-link>
      <router-link to="/test-runs" class="nav-item" active-class="active">
        <span class="icon">▶️</span>
        <span>Test Runs</span>
      </router-link>
    </nav>
  </div>
</template>

<script setup>
</script>

<style scoped>
.sidebar {
  width: 240px;
  background: #1e293b;
  color: white;
  min-height: 100vh;
  padding: 20px 0;
  position: fixed;
  left: 0;
  top: 0;
}

.sidebar-header {
  padding: 0 20px 20px;
  border-bottom: 1px solid #334155;
  margin-bottom: 20px;
}

.sidebar-header h2 {
  margin: 0;
  font-size: 20px;
}

.sidebar-nav {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.nav-item {
  display: flex;
  align-items: center;
  padding: 12px 20px;
  color: #cbd5e1;
  text-decoration: none;
  transition: all 0.2s;
  gap: 12px;
}

.nav-item:hover {
  background: #334155;
  color: white;
}

.nav-item.active {
  background: #3b82f6;
  color: white;
}

.icon {
  font-size: 18px;
}
</style>
