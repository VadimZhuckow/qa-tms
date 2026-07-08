<template>
  <div class="page">
    <h1>📊 Dashboard</h1>
    <div class="stats">
      <div class="stat-card">
        <h3>Test Cases</h3>
        <div class="number">124</div>
      </div>
      <div class="stat-card">
        <h3>Test Runs</h3>
        <div class="number">8</div>
      </div>
      <div class="stat-card">
        <h3>Coverage</h3>
        <div class="number">75%</div>
      </div>
    </div>
  </div>
</template>

<script setup>
</script>

<style scoped>
.page {
  padding: 20px;
}

.stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 20px;
  margin-top: 20px;
}

.stat-card {
  background: white;
  padding: 24px;
  border-radius: 8px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
}

.stat-card h3 {
  margin: 0 0 12px 0;
  color: #586069;
  font-size: 14px;
}

.stat-card .number {
  font-size: 32px;
  font-weight: bold;
  color: #1976d2;
}
</style>
