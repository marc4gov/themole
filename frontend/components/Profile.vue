<script setup>
import { useCanister } from "@connect2ic/vue"

import { useConnect } from "@connect2ic/vue"
import {ref, onMounted} from "vue"

import { Principal } from "@dfinity/principal";

import sound from '../widm.mp3'

const name = ref('Vul naam in')
const wachten = ref('Bewaar')

const [questions] = useCanister("questions", { mode: "anonymous" })
const [accounts] = useCanister("accounts", { mode: "anonymous" })
var s = new Audio(sound)


const saveAccount = async () => {
  wachten.value = "Wachten..."
  play()
  const res = await questions.value.createAccountName(principal.value, name.value)
  console.log("Result: ", res)
  wachten.value = "Bewaar"
}

const getAccount = async () => {
    console.log("Principal connected: ", principal)
    const p = Principal.fromText(principal.value)
    console.log("Dit is p: ", p)
    const res = await accounts.value.get_role2(p)
    console.log("Role: ", res)
}

const play = () => {
  s.play()
}

const { isConnected, principal, activeProvider } = useConnect({
  onConnect: () => {

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
              <button class="connect-button" @click="play">Geluid</button>

            </td>
          </tr>
        </tbody>
      </table>
    </template>
    <template v-else>
      <p class="example-disabled">Connect om vragen te zien </p>
    </template>
  </div>
</template>
