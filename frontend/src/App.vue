<template>
  <div style="padding: 40px; background: #f5f7fa; min-height: 100vh;">
    <h1>🧪 QA TMS</h1>
    <p>Test Management System</p>
    <div v-if="status" style="padding: 12px; background: #d4edda; border-radius: 4px;">
      ✅ {{ status }}
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'

const status = ref(null)

onMounted(async () => {
  try {
    const res = await axios.get('/api/health')
    status.value = `API: ${res.data.status}`
  } catch (e) {
    status.value = 'Backend not available'
  }
})
</script>