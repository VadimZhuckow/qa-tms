<template>
  <div class="page">
    <div class="page-header">
      <h1>📋 Test Cases</h1>
      <button class="btn-primary" @click="openCreateModal">+ New Test Case</button>
    </div>

    <div class="filters">
      <input 
        v-model="searchQuery" 
        type="text" 
        placeholder="🔍 Search test cases..." 
        class="search-input"
      />
      <select v-model="filterPriority" class="filter-select">
        <option value="">All priorities</option>
        <option value="critical">Critical</option>
        <option value="high">High</option>
        <option value="medium">Medium</option>
        <option value="low">Low</option>
      </select>
    </div>

    <div class="table-container">
      <table v-if="testCases.length > 0" class="test-table">
        <thead>
          <tr>
            <th>ID</th>
            <th>Title</th>
            <th>Priority</th>
            <th>Type</th>
            <th>Status</th>
            <th>Updated</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="tc in filteredTestCases" :key="tc.id" @click="viewTestCase(tc.id)" class="clickable-row">
            <td class="id-cell">{{ tc.custom_id }}</td>
            <td class="title-cell">{{ tc.title }}</td>
            <td>
              <span :class="['priority-badge', tc.priority]">
                {{ tc.priority }}
              </span>
            </td>
            <td>{{ tc.type }}</td>
            <td>
              <span class="status-badge">{{ tc.automation_status }}</span>
            </td>
            <td>{{ formatDate(tc.updated_at) }}</td>
            <td class="actions" @click.stop>
              <button class="btn-icon" title="View" @click="viewTestCase(tc.id)">👁️</button>
              <button class="btn-icon" title="Edit" @click="editTestCase(tc.id)">✏️</button>
              <button class="btn-icon" title="Delete" @click="confirmDelete(tc.id)">🗑️</button>
            </td>
          </tr>
        </tbody>
      </table>
      <div v-else class="empty-state">
        <p>📭 No test cases yet</p>
      </div>
    <!-- Модальное окно подтверждения удаления -->
<div v-if="showDeleteModal" class="modal-overlay" @click.self="cancelDelete">
  <div class="modal delete-modal">
    <div class="modal-icon">
      <span class="icon-warning">️</span>
    </div>
    <h3>Delete Test Case?</h3>
    <p class="modal-description">
      Are you sure you want to delete this test case? This action cannot be undone.
    </p>
    <div class="modal-actions">
      <button class="btn-secondary" @click="cancelDelete">Cancel</button>
      <button class="btn-danger" @click="deleteTestCase">Delete</button>
    </div>
  </div>
</div>
    </div>

    <!-- Модальное окно ПРОСМОТРА -->
    <div v-if="showViewModal" class="modal-overlay" @click.self="closeViewModal">
      <div class="modal view-modal">
        <div class="modal-header">
          <h2>📋 Test Case Details</h2>
          <button class="close-btn" @click="closeViewModal">✕</button>
        </div>
        <div class="modal-content" v-if="viewingTest">
          <div class="detail-section">
            <div class="detail-header">
              <h3>{{ viewingTest.title }}</h3>
              <div class="badges">
                <span :class="['priority-badge', viewingTest.priority]">{{ viewingTest.priority }}</span>
                <span class="type-badge">{{ viewingTest.type }}</span>
              </div>
            </div>
          </div>

          <div class="detail-section" v-if="viewingTest.description">
            <h4>Description</h4>
            <p class="detail-text">{{ viewingTest.description }}</p>
          </div>

          <div class="detail-section" v-if="viewingTest.preconditions">
            <h4>Preconditions</h4>
            <p class="detail-text">{{ viewingTest.preconditions }}</p>
          </div>

          <div class="detail-section" v-if="viewingTest.steps && viewingTest.steps.length > 0">
            <h4>Test Steps</h4>
            <div class="steps-list">
              <div v-for="(step, index) in viewingTest.steps" :key="index" class="step-item">
                <span class="step-number">{{ index + 1 }}</span>
                <span class="step-text">{{ step }}</span>
              </div>
            </div>
          </div>

          <div class="detail-section" v-if="viewingTest.expected_result">
            <h4>Expected Result</h4>
            <p class="detail-text">{{ viewingTest.expected_result }}</p>
          </div>

          <div class="detail-section" v-if="viewingTest.test_data && Object.keys(viewingTest.test_data).length > 0">
            <h4>Test Data</h4>
            <pre class="json-data">{{ JSON.stringify(viewingTest.test_data, null, 2) }}</pre>
          </div>

          <div class="detail-footer">
            <div class="meta-info">
               <span><strong>Created:</strong> {{ formatDate(viewingTest.created_at) }}</span>
               <span><strong>Updated:</strong> {{ formatDate(viewingTest.updated_at) }}</span>
              <span><strong>Created:</strong> {{ formatDate(viewingTest.created_at) }}</span>
              <span><strong>Updated:</strong> {{ formatDate(viewingTest.updated_at) }}</span>
            </div>
          </div>
        </div>
        <div class="modal-actions">
          <button class="btn-secondary" @click="closeViewModal">Close</button>
          <button class="btn-primary" @click="editFromView">✏️ Edit</button>
        </div>
      </div>
    </div>

    <!-- Модальное окно создания/редактирования -->
    <div v-if="showCreateModal" class="modal-overlay" @click.self="closeModal">
      <div class="modal">
        <div class="modal-header">
          <h2>{{ editingId ? 'Edit Test Case' : 'Create Test Case' }}</h2>
          <button class="close-btn" @click="closeModal">✕</button>
        </div>
        <form @submit.prevent="saveTestCase">
          <div class="form-group">
            <label>Title *</label>
            <input v-model="newTest.title" type="text" required placeholder="e.g. Login with valid credentials" />
          </div>
          <div class="form-group">
            <label>Description</label>
            <textarea v-model="newTest.description" rows="3" placeholder="Describe what this test verifies..."></textarea>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label>Priority</label>
              <select v-model="newTest.priority">
                <option value="critical">Critical</option>
                <option value="high">High</option>
                <option value="medium">Medium</option>
                <option value="low">Low</option>
              </select>
            </div>
            <div class="form-group">
              <label>Type</label>
              <select v-model="newTest.type">
                <option value="functional">Functional</option>
                <option value="smoke">Smoke</option>
                <option value="regression">Regression</option>
                <option value="ui">UI</option>
                <option value="api">API</option>
                <option value="performance">Performance</option>
                <option value="security">Security</option>
              </select>
            </div>
          </div>
          <div class="form-group">
            <label>Preconditions</label>
            <textarea v-model="newTest.preconditions" rows="2" placeholder="What needs to be set up before the test..."></textarea>
          </div>
          <div class="form-group">
            <label>Expected Result</label>
            <textarea v-model="newTest.expected_result" rows="2" placeholder="What should happen..."></textarea>
          </div>
          <div class="modal-actions">
            <button type="button" class="btn-secondary" @click="closeModal">Cancel</button>
            <button type="submit" class="btn-primary">{{ editingId ? 'Update' : 'Create' }}</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'

const testCases = ref([])
const searchQuery = ref('')
const filterPriority = ref('')
const showCreateModal = ref(false)
const showViewModal = ref(false)
const showDeleteModal = ref(false)
const deletingId = ref(null)
const editingId = ref(null)
const viewingTest = ref(null)

const newTest = ref({
  custom_id: '', 
  title: '',
  description: '',
  preconditions: '',
  expected_result: '',
  priority: 'medium',
  type: 'functional',
  project_id: '00000000-0000-0000-0000-000000000001',
  workspace_id: '00000000-0000-0000-0000-000000000001'
})

const filteredTestCases = computed(() => {
  return testCases.value.filter(tc => {
    const matchesSearch = tc.title.toLowerCase().includes(searchQuery.value.toLowerCase())
    const matchesPriority = !filterPriority.value || tc.priority === filterPriority.value
    return matchesSearch && matchesPriority
  })
})

const loadTestCases = async () => {
  try {
    const res = await axios.get('/api/test-cases')
    testCases.value = res.data
  } catch (error) {
    console.error('Failed to load test cases:', error)
  }
}

const formatDate = (dateStr) => {
  if (!dateStr) return '-'
  return new Date(dateStr).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const confirmDelete = (id) => {
  deletingId.value = id
  showDeleteModal.value = true
}

const deleteTestCase = async () => {
  if (!deletingId.value) return
  
  try {
    await axios.delete(`/api/test-cases/${deletingId.value}`)
    showDeleteModal.value = false
    deletingId.value = null
    await loadTestCases()
  } catch (error) {
    console.error('Failed to delete:', error)
    alert('Error deleting test case')
  }
}

const cancelDelete = () => {
  showDeleteModal.value = false
  deletingId.value = null
}

const viewTestCase = async (id) => {
  try {
    const res = await axios.get(`/api/test-cases/${id}`)
    viewingTest.value = res.data
    showViewModal.value = true
  } catch (error) {
    console.error('Failed to load test case:', error)
    alert('Error loading test case details')
  }
}

const closeViewModal = () => {
  showViewModal.value = false
  viewingTest.value = null
}

const editFromView = () => {
  const id = viewingTest.value.id 
  closeViewModal()
  editTestCase(id)
}

const openCreateModal = () => {
  editingId.value = null
  newTest.value = {
    title: '',
    description: '',
    preconditions: '',
    expected_result: '',
    priority: 'medium',
    type: 'functional',
    project_id: '00000000-0000-0000-0000-000000000001',
    workspace_id: '00000000-0000-0000-0000-000000000001'
  }
  showCreateModal.value = true
}

const editTestCase = (id) => {
  const tc = testCases.value.find(t => t.id === id)
  if (!tc) return
  
  editingId.value = id
  newTest.value = {
    title: tc.title,
    description: tc.description || '',
    preconditions: tc.preconditions || '',
    expected_result: tc.expected_result || '',
    priority: tc.priority,
    type: tc.type,
    project_id: tc.project_id,
    workspace_id: tc.workspace_id
  }
  
  showCreateModal.value = true
}

const saveTestCase = async () => {
  try {
    if (editingId.value) {
      await axios.put(`/api/test-cases/${editingId.value}`, newTest.value)
    } else {
      await axios.post('/api/test-cases', newTest.value)
    }
    
    closeModal()
    await loadTestCases()
  } catch (error) {
    console.error('Failed to save test case:', error)
    alert('Error saving test case')
  }
}

const closeModal = () => {
  showCreateModal.value = false
  editingId.value = null
  newTest.value = {
    title: '',
    description: '',
    preconditions: '',
    expected_result: '',
    priority: 'medium',
    type: 'functional',
    project_id: '00000000-0000-0000-0000-000000000001',
    workspace_id: '00000000-0000-0000-0000-000000000001'
  }
}

onMounted(() => {
  loadTestCases()
})
</script>

<style scoped>
.page {
  padding: 20px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.page-header h1 {
  margin: 0;
  font-size: 28px;
  color: #1e293b;
}

.filters {
  display: flex;
  gap: 12px;
  margin-bottom: 20px;
}

.search-input {
  flex: 1;
  padding: 10px 14px;
  border: 1px solid #e2e8f0;
  border-radius: 6px;
  font-size: 14px;
}

.filter-select {
  padding: 10px 14px;
  border: 1px solid #e2e8f0;
  border-radius: 6px;
  font-size: 14px;
  background: white;
}

.table-container {
  background: white;
  border-radius: 8px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
  overflow: hidden;
}

.test-table {
  width: 100%;
  border-collapse: collapse;
}

.test-table th {
  background: #f8fafc;
  padding: 12px 16px;
  text-align: left;
  font-size: 12px;
  font-weight: 600;
  color: #64748b;
  text-transform: uppercase;
  border-bottom: 1px solid #e2e8f0;
}

.test-table td {
  padding: 14px 16px;
  border-bottom: 1px solid #f1f5f9;
  font-size: 14px;
}

.test-table tr {
  cursor: pointer;
}

.test-table tr:hover {
  background: #f8fafc;
}

.clickable-row:hover {
  background: #eff6ff;
}

.id-cell {
  font-family: monospace;
  color: #94a3b8;
  font-size: 12px;
}

.title-cell {
  font-weight: 500;
  color: #1e293b;
}

.priority-badge {
  padding: 4px 10px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 500;
  text-transform: capitalize;
}

.priority-badge.high {
  background: #fee2e2;
  color: #dc2626;
}

.priority-badge.medium {
  background: #fef3c7;
  color: #d97706;
}

.priority-badge.low {
  background: #dbeafe;
  color: #2563eb;
}

.priority-badge.critical {
  background: #fce7f3;
  color: #be185d;
  font-weight: 700;
}

.status-badge {
  padding: 4px 10px;
  background: #f1f5f9;
  border-radius: 12px;
  font-size: 12px;
  color: #64748b;
}

.actions {
  display: flex;
  gap: 8px;
}

.btn-icon {
  background: none;
  border: none;
  cursor: pointer;
  font-size: 16px;
  padding: 4px;
  border-radius: 4px;
}

.btn-icon:hover {
  background: #f1f5f9;
}

.empty-state {
  padding: 60px 20px;
  text-align: center;
  color: #94a3b8;
}

.btn-primary {
  background: #3b82f6;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 6px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
}

.btn-primary:hover {
  background: #2563eb;
}

.btn-secondary {
  background: #f1f5f9;
  color: #475569;
  border: none;
  padding: 10px 20px;
  border-radius: 6px;
  font-size: 14px;
  cursor: pointer;
}

.btn-secondary:hover {
  background: #e2e8f0;
}

/* Modal */
.modal-overlay {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0,0,0,0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal {
  background: white;
  border-radius: 12px;
  padding: 24px;
  width: 90%;
  max-width: 600px;
  max-height: 90vh;
  overflow-y: auto;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.modal-header h2 { margin: 0; font-size: 20px; }

.close-btn {
  background: none;
  border: none;
  font-size: 20px;
  cursor: pointer;
  color: #64748b;
}

.form-group { margin-bottom: 16px; }

.form-group label {
  display: block;
  margin-bottom: 6px;
  font-size: 14px;
  font-weight: 500;
  color: #475569;
}

.form-group input,
.form-group textarea,
.form-group select {
  width: 100%;
  padding: 10px 12px;
  border: 1px solid #e2e8f0;
  border-radius: 6px;
  font-size: 14px;
  font-family: inherit;
}

.form-group textarea { resize: vertical; }

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
}

.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  margin-top: 20px;
}

/* View Modal Styles */
.view-modal {
  max-width: 700px;
}

.modal-content {
  margin-bottom: 20px;
}

.detail-section {
  margin-bottom: 24px;
  padding-bottom: 24px;
  border-bottom: 1px solid #e2e8f0;
}

.detail-section:last-child {
  border-bottom: none;
}

.detail-section h4 {
  margin: 0 0 8px 0;
  font-size: 14px;
  color: #64748b;
  text-transform: uppercase;
  font-weight: 600;
}

.detail-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 16px;
}

.detail-header h3 {
  margin: 0;
  font-size: 20px;
  color: #1e293b;
  flex: 1;
}

.badges {
  display: flex;
  gap: 8px;
  flex-shrink: 0;
}

.type-badge {
  padding: 4px 10px;
  background: #e0e7ff;
  color: #4f46e5;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 500;
  text-transform: capitalize;
}

.detail-text {
  margin: 0;
  padding: 12px;
  background: #f8fafc;
  border-radius: 6px;
  color: #334155;
  line-height: 1.6;
  white-space: pre-wrap;
}

.steps-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.step-item {
  display: flex;
  gap: 12px;
  padding: 12px;
  background: #f8fafc;
  border-radius: 6px;
  align-items: flex-start;
}

.step-number {
  background: #3b82f6;
  color: white;
  width: 24px;
  height: 24px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 600;
  font-size: 12px;
  flex-shrink: 0;
}

.step-text {
  color: #334155;
  line-height: 1.6;
}

.json-data {
  background: #1e293b;
  color: #e2e8f0;
  padding: 12px;
  border-radius: 6px;
  font-family: 'Courier New', monospace;
  font-size: 13px;
  overflow-x: auto;
  margin: 0;
}

.detail-footer {
  margin-top: 20px;
  padding-top: 20px;
  border-top: 1px solid #e2e8f0;
}

.meta-info {
  display: flex;
  flex-direction: column;
  gap: 8px;
  font-size: 13px;
  color: #64748b;
}

.meta-info span {
  display: flex;
  gap: 8px;
}
/* Delete Modal */
.delete-modal {
  max-width: 400px;
  text-align: center;
  padding: 32px 24px;
}

.modal-icon {
  margin-bottom: 16px;
}

.icon-warning {
  font-size: 48px;
  display: inline-block;
  padding: 16px;
  background: #fee2e2;
  border-radius: 50%;
}

.delete-modal h3 {
  margin: 0 0 12px 0;
  font-size: 20px;
  color: #1e293b;
}

.modal-description {
  margin: 0 0 24px 0;
  color: #64748b;
  font-size: 14px;
  line-height: 1.6;
}

.btn-danger {
  background: #ef4444;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 6px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
}

.btn-danger:hover {
  background: #dc2626;
}

.delete-modal .modal-actions {
  display: flex;
  justify-content: center;
  gap: 12px;
  margin-top: 0;
}
</style>