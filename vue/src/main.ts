import { createApp } from 'vue'
import { createPinia } from 'pinia'
import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'
import * as ElIcons from '@element-plus/icons-vue'

import App from './App.vue'
import router from './router'

const app = createApp(App)

// 注册所有图标（简便起见）
Object.entries(ElIcons).forEach(([name, component]) => {
  app.component(name, component as any)
})

app.use(createPinia())
app.use(ElementPlus)
app.use(router)

app.mount('#app')
