import { createRouter, createWebHistory, RouteRecordRaw } from 'vue-router'
import type { RouteLocationNormalized } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const Login = () => import('@/views/Login.vue')
const AdminLayout = () => import('@/layouts/AdminLayout.vue')
const Dashboard = () => import('@/views/Dashboard.vue')
const AnimalsList = () => import('@/views/animals/AnimalsList.vue')
const UsersList = () => import('@/views/users/UsersList.vue')
const RealNameInfo = () => import('@/views/users/RealNameInfo.vue')
const AdoptionPage = () => import('@/views/adoption/AdoptionPage.vue')
const CitiesList = () => import('@/views/cities/CitiesList.vue')
const LostPetsList = () => import('@/views/lost/LostPetsList.vue')
const AdoptionOrders = () => import('@/views/orders/AdoptionOrders.vue')
const CheckinPage = () => import('@/views/checkin/CheckinPage.vue')
const AnalyticsPage = () => import('@/views/analytics/AnalyticsPage.vue')
const SettingsPage = () => import('@/views/system/SettingsPage.vue')
const PermissionsPage = () => import('@/views/system/PermissionsPage.vue')


const routes: RouteRecordRaw[] = [
  { path: '/login', name: 'login', component: Login, meta: { public: true } },
  {
    path: '/',
    component: AdminLayout,
    children: [
      { path: '', redirect: { name: 'dashboard' } },
      { path: 'dashboard', name: 'dashboard', component: Dashboard, meta: { title: '仪表板' } },
      { path: 'animals', name: 'animals', component: AnimalsList, meta: { title: '动物管理' } },
      { path: 'orders', name: 'orders', component: AdoptionOrders, meta: { title: '订单管理' } },
      { path: 'lost', name: 'lost', component: LostPetsList, meta: { title: '寻宠管理' } },
      { path: 'users', name: 'users', component: UsersList, meta: { title: '用户管理' } },
      { path: 'realname', name: 'realname', component: RealNameInfo, meta: { title: '实名认证' } },
      { path: 'adoption', name: 'adoption', component: AdoptionPage, meta: { title: '宠物领养' } },
      { path: 'cities', name: 'cities', component: CitiesList, meta: { title: '城市管理' } },
      { path: 'checkin', name: 'checkin', component: CheckinPage, meta: { title: '签到管理' } },
      { path: 'analytics', name: 'analytics', component: AnalyticsPage, meta: { title: '数据分析' } },

      { path: 'settings', name: 'settings', component: SettingsPage, meta: { title: '系统设置' } },
      { path: 'permissions', name: 'permissions', component: PermissionsPage, meta: { title: '权限管理' } }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach((to: RouteLocationNormalized) => {
  const auth = useAuthStore()
  if (!to.meta.public && !auth.isAuthed) {
    return { name: 'login', query: { redirect: to.fullPath } }
  }
})

export default router
