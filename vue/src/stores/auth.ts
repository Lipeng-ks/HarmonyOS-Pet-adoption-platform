import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { loginApi } from '@/services/auth'

export interface UserInfo {
  id: number
  username: string
  avatar?: string
  gender?: boolean | null
  phone?: string | null
  email?: string | null
  address?: string | null
  birthday?: string | null
}

export const useAuthStore = defineStore('auth', () => {
  const user = ref<UserInfo | null>(null)
  const isAuthed = computed(() => !!user.value)

  async function login(username: string, password: string) {
    const res = await loginApi({ username, password })
    if (res.success) {
      user.value = res.data as UserInfo
    }
    return res
  }

  function logout() {
    user.value = null
  }

  return { user, isAuthed, login, logout }
})
