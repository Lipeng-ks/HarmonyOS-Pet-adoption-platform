import { createRouter, createWebHistory, RouteRecordRaw } from 'vue-router'
import type { RouteLocationNormalized } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const Login = () => import('@/views/Login.vue')
const AdminLayout = () => import('@/layouts/AdminLayout.vue')
const AnimalsList = () => import('@/views/animals/AnimalsList.vue')
const UsersList = () => import('@/views/users/UsersList.vue')
const RealNameInfo = () => import('@/views/users/RealNameInfo.vue')
const AdoptionPage = () => import('@/views/adoption/AdoptionPage.vue')
const CitiesList = () => import('@/views/cities/CitiesList.vue')
const LostPetsList = () => import('@/views/lost/LostPetsList.vue')
const AdoptionOrders = () => import('@/views/orders/AdoptionOrders.vue')
const CheckinPage = () => import('@/views/checkin/CheckinPage.vue')

const routes: RouteRecordRaw[] = [
  { path: '/login', name: 'login', component: Login, meta: { public: true } },
  {
    path: '/',
    component: AdminLayout,
    children: [
      { path: '', redirect: { name: 'animals' } },
      { path: 'animals', name: 'animals', component: AnimalsList },
      { path: 'orders', name: 'orders', component: AdoptionOrders },
      { path: 'lost', name: 'lost', component: LostPetsList },
      { path: 'users', name: 'users', component: UsersList },
      {
        path: '/realname',
        name: 'RealNameInfo',
        component: RealNameInfo,
        meta: { title: '实名认证' }
      },
      {
        path: '/adoption',
        name: 'AdoptionPage',
        component: AdoptionPage,
        meta: { title: '宠物领养' }
      },
      { path: 'cities', name: 'cities', component: CitiesList },
      { path: 'checkin', name: 'checkin', component: CheckinPage }
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
