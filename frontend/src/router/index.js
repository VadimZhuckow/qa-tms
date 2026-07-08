import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  {
    path: '/',
    name: 'Dashboard',
    component: () => import('../views/Dashboard.vue')
  },
  {
    path: '/test-cases',
    name: 'TestCases',
    component: () => import('../views/TestCases.vue')
  },
  {
    path: '/test-runs',
    name: 'TestRuns',
    component: () => import('../views/TestRuns.vue')
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
