<script setup>
import { useCanister } from "@connect2ic/vue"

import { useWallet, useBalance, useConnect } from "@connect2ic/vue"
import {ref} from "vue"

const name = ref('Vul naam in')
const wachten = ref('Bewaar')
const [questions] = useCanister("questions", { mode: "anonymous" })

const saveAccount = async () => {
  wachten.value = "Wachten..."
  const res = await questions.value.createAccountName(name.value)
  console.log("Result: ", res)
  wachten.value = "Bewaar"
}

const { isConnected, principal, activeProvider } = useConnect({
  onConnect: () => {
    console.log("Principal connected: ", principal)
    // Signed in
  },
  onDisconnect: () => {
    // Signed out
  }

})

</script>
<template>
  <div class="example">
    <template v-if="isConnected">
      <!-- <p>Wallet address: <span style="font-size: 0.7em">{{ wallet.principal }}</span></p> -->
      <table>
        <tbody>
          <tr>
            <td>
              {{principal}}
            </td>
            <td>
              <input v-model="name"> {{ name }}
            </td>
            <td>
              <button class="connect-button" @click="saveAccount">{{wachten}}</button>
            </td>
          </tr>
        </tbody>
      </table>
    </template>
    <template v-else>
      <p class="example-disabled">Connect with a wallet to access this example</p>
    </template>
  </div>
</template>
