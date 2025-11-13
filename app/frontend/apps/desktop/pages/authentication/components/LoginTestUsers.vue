<!-- Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/ -->

<script setup lang="ts">
import { ref, computed } from 'vue'

import CommonIcon from '#shared/components/CommonIcon/CommonIcon.vue'
import { NotificationTypes } from '#shared/components/CommonNotifications/types.ts'
import { useNotifications } from '#shared/components/CommonNotifications/useNotifications.ts'

interface TestUser {
  name: string
  email: string
  password: string
  role: 'ADMIN' | 'AGENT' | 'CUSTOMER'
  department: string
}

const emit = defineEmits<{
  'fill-credentials': [{ login: string; password: string }]
}>()

const { notify } = useNotifications()

const TEST_USERS: TestUser[] = [
  {
    name: __('Usuário Emissor de Tickets'),
    email: 'prefeitura@suporte.com',
    password: 'PrefeituraSuporte123',
    role: 'CUSTOMER',
    department: __('Prefeitura'),
  },
  {
    name: __('Usuário do Suporte Técnico'),
    email: 'suportetecnico@email.com',
    password: 'SuporteTecnico123',
    role: 'ADMIN',
    department: __('Suporte Técnico'),
  },
]

const isExpanded = ref(true)
const showAllUsers = ref(false)
const visiblePasswords = ref<Set<string>>(new Set())

const displayedUsers = computed(() => {
  return showAllUsers.value ? TEST_USERS : TEST_USERS.slice(0, 4)
})

const hasMoreUsers = computed(() => TEST_USERS.length > 4)

const toggleExpanded = () => {
  isExpanded.value = !isExpanded.value
}

const toggleShowAll = () => {
  showAllUsers.value = !showAllUsers.value
}

const togglePasswordVisibility = (email: string, event: Event) => {
  event.stopPropagation()
  const newSet = new Set(visiblePasswords.value)
  if (newSet.has(email)) {
    newSet.delete(email)
  } else {
    newSet.add(email)
  }
  visiblePasswords.value = newSet
}

const isPasswordVisible = (email: string) => {
  return visiblePasswords.value.has(email)
}

const copyToClipboard = async (text: string, type: 'email' | 'password', event: Event) => {
  event.stopPropagation()

  try {
    await navigator.clipboard.writeText(text)
    notify({
      type: NotificationTypes.Success,
      message: type === 'email' ? __('Email copied!') : __('Password copied!'),
      durationMS: 2000,
    })
  } catch {
    notify({
      type: NotificationTypes.Error,
      message: __('Failed to copy to clipboard'),
      durationMS: 2000,
    })
  }
}

const fillCredentials = (user: TestUser) => {
  emit('fill-credentials', {
    login: user.email,
    password: user.password,
  })

  notify({
    type: NotificationTypes.Success,
    message: __('Credentials for %s filled!', user.name),
    durationMS: 2000,
  })
}

const getRoleBadgeClass = (role: TestUser['role']) => {
  const baseClass = 'rounded px-2 py-0.5 text-xs font-medium'
  switch (role) {
    case 'ADMIN':
      return `${baseClass} bg-purple-100 text-purple-800 dark:bg-purple-900 dark:text-purple-200`
    case 'AGENT':
      return `${baseClass} bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200`
    case 'CUSTOMER':
      return `${baseClass} bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200`
    default:
      return `${baseClass} bg-gray-100 text-gray-800 dark:bg-gray-900 dark:text-gray-200`
  }
}
</script>

<template>
  <div class="w-full rounded-3xl bg-white shadow-sm dark:bg-gray-500">
    <!-- Header (Collapsible Toggle) -->
    <button
      type="button"
      class="flex w-full items-center justify-between rounded-t-3xl bg-gradient-to-r from-orange-500 to-yellow-500 p-4 text-white transition-all hover:from-orange-600 hover:to-yellow-600 focus:outline-none focus:ring-2 focus:ring-orange-400 focus:ring-offset-2"
      :class="{ 'rounded-b-3xl': !isExpanded }"
      @click="toggleExpanded"
    >
      <div class="flex items-center gap-2">
        <CommonIcon name="person" size="small" decorative />
        <span class="font-semibold">{{ $t('Test Users') }}</span>
      </div>
      <CommonIcon :name="isExpanded ? 'chevron-up' : 'chevron-down'" size="small" decorative />
    </button>

    <!-- Users List -->
    <div v-if="isExpanded" class="max-h-[600px] overflow-y-auto p-4">
      <div class="space-y-3">
        <button
          v-for="user in displayedUsers"
          :key="user.email"
          type="button"
          class="group w-full cursor-pointer rounded-lg border border-gray-200 p-3 text-left transition-all hover:border-blue-400 hover:bg-blue-50 dark:border-gray-600 dark:hover:border-blue-500 dark:hover:bg-blue-900/20"
          @click="fillCredentials(user)"
        >
          <!-- User Info Header -->
          <div class="mb-2 flex items-start justify-between">
            <div class="flex-1">
              <h3 class="font-bold text-gray-900 dark:text-white">
                {{ user.name }}
              </h3>
              <p class="text-xs text-gray-500 dark:text-gray-400">
                {{ user.department }}
              </p>
            </div>
            <span :class="getRoleBadgeClass(user.role)">
              {{ $t(user.role) }}
            </span>
          </div>

          <!-- Email -->
          <div class="mb-2 flex items-center justify-between gap-2">
            <code class="flex-1 text-xs text-gray-700 dark:text-gray-300">
              {{ user.email }}
            </code>
            <button
              type="button"
              class="rounded p-1 opacity-0 transition-all hover:bg-gray-200 group-hover:opacity-100 dark:hover:bg-gray-600"
              :aria-label="$t('Copy email')"
              @click="copyToClipboard(user.email, 'email', $event)"
            >
              <CommonIcon name="duplicate" size="xs" decorative />
            </button>
          </div>

          <!-- Password -->
          <div class="flex items-center justify-between gap-2">
            <code class="flex-1 text-xs text-gray-700 dark:text-gray-300">
              {{ isPasswordVisible(user.email) ? user.password : '••••••••' }}
            </code>
            <div class="flex gap-1 opacity-0 transition-all group-hover:opacity-100">
              <button
                type="button"
                class="rounded p-1 transition-all hover:bg-gray-200 dark:hover:bg-gray-600"
                :aria-label="$t(isPasswordVisible(user.email) ? 'Hide password' : 'Show password')"
                @click="togglePasswordVisibility(user.email, $event)"
              >
                <CommonIcon
                  :name="isPasswordVisible(user.email) ? 'eye-slash' : 'eye'"
                  size="xs"
                  decorative
                />
              </button>
              <button
                type="button"
                class="rounded p-1 transition-all hover:bg-gray-200 dark:hover:bg-gray-600"
                :aria-label="$t('Copy password')"
                @click="copyToClipboard(user.password, 'password', $event)"
              >
                <CommonIcon name="duplicate" size="xs" decorative />
              </button>
            </div>
          </div>
        </button>
      </div>

      <!-- Show More Button -->
      <button
        v-if="hasMoreUsers"
        type="button"
        class="mt-3 w-full rounded-lg border border-gray-300 bg-white px-4 py-2 text-sm font-medium text-gray-700 transition-all hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 dark:border-gray-600 dark:bg-gray-700 dark:text-gray-200 dark:hover:bg-gray-600"
        @click="toggleShowAll"
      >
        {{ showAllUsers ? $t('Show Less') : $t('Show All (%s)', TEST_USERS.length) }}
      </button>
    </div>
  </div>
</template>
