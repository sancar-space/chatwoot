<script setup>
import { ref } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { useStore } from 'vuex';
import Input from 'dashboard/components-next/input/Input.vue';
import Button from 'dashboard/components-next/button/Button.vue';

const store = useStore();
const router = useRouter();
const route = useRoute();

const phoneNumber = ref('');
const inboxName = ref('');
const providerUrl = ref('');
const apiKey = ref('');
const isCreating = ref(false);
const errorMessage = ref('');

const handleSubmit = async () => {
  if (!phoneNumber.value) {
    errorMessage.value = 'O número de telefone é obrigatório.';
    return;
  }

  isCreating.value = true;
  errorMessage.value = '';

  const normalizedPhone = phoneNumber.value.replace(/\D/g, '');
  const name = inboxName.value.trim() || `WhatsApp ${normalizedPhone}`;

  const providerConfig = {};
  if (providerUrl.value.trim()) providerConfig.provider_url = providerUrl.value.trim();
  if (apiKey.value.trim()) providerConfig.api_key = apiKey.value.trim();

  try {
    const inbox = await store.dispatch('inboxes/createChannel', {
      name,
      channel: {
        type: 'whatsapp',
        phone_number: normalizedPhone,
        provider: 'baileys',
        provider_config: providerConfig,
      },
    });

    router.push({
      name: 'settings_inboxes_add_agents',
      params: { page: 'agents', inbox_id: inbox.id },
    });
  } catch (error) {
    errorMessage.value =
      error?.message || 'Erro ao criar a caixa de entrada. Tente novamente.';
  } finally {
    isCreating.value = false;
  }
};
</script>

<template>
  <form class="flex flex-col gap-5" @submit.prevent="handleSubmit">
    <div>
      <h3 class="mb-1 text-sm font-medium text-n-slate-12">
        WhatsApp via Baileys (QR Code)
      </h3>
      <p class="text-sm text-n-slate-11">
        Conecte um número de WhatsApp escaneando um QR Code. Não requer
        conta Meta Business.
      </p>
    </div>

    <Input
      v-model="phoneNumber"
      label="Número de telefone"
      placeholder="5511999999999 (somente dígitos, com DDI)"
      type="tel"
      :error="errorMessage && !phoneNumber ? 'Campo obrigatório' : ''"
      required
    />

    <Input
      v-model="inboxName"
      label="Nome da caixa de entrada (opcional)"
      placeholder="WhatsApp Sancar"
    />

    <details class="text-sm text-n-slate-11">
      <summary class="cursor-pointer select-none font-medium text-n-slate-12">
        Configurações avançadas (opcional)
      </summary>
      <div class="mt-3 flex flex-col gap-3">
        <Input
          v-model="providerUrl"
          label="URL da Baileys API"
          placeholder="http://baileys-api:3025"
          helper-text="Deixe em branco para usar o valor padrão configurado no servidor."
        />
        <Input
          v-model="apiKey"
          label="API Key da Baileys API"
          placeholder="••••••••"
          type="password"
          helper-text="Deixe em branco para usar a chave padrão do servidor."
        />
      </div>
    </details>

    <div
      v-if="errorMessage"
      class="p-3 text-sm text-red-700 bg-red-50 rounded-lg border border-red-200"
    >
      {{ errorMessage }}
    </div>

    <div class="flex justify-end">
      <Button
        type="submit"
        solid
        blue
        :disabled="isCreating"
        :label="isCreating ? 'Criando...' : 'Criar caixa de entrada'"
      />
    </div>
  </form>
</template>