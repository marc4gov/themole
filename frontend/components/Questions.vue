<script setup>
import { useCanister } from "@connect2ic/vue"
import { ref, watchEffect } from "vue"

let question = ref()
let questionlist = ref([])
let number = ref(0)
const [questions] = useCanister("questions", { mode: "anonymous" })

const refreshQuestion = async () => {
  const freshQuestion = await questions.value.showQuestion(number.value)
  question.value = freshQuestion
}

const increment = async () => {
  number.value++
  await refreshQuestion()
}

const decrement = async () => {
  number.value--
  await refreshQuestion()
}

const list_questions = async () => {
    const qs = await questions.value.list_closed_questions();
    const qq = qs.map(q => Number(q))
    questionlist.value = qq

}

watchEffect(() => {
  if (questions.value) {
    refreshQuestion()
  }
})

</script>
<template>
  <div class="example">
    <p style="font-size: 2.5em">{{ question?.toString()  }}</p>
    <button class="connect-button" @click=decrement>-</button>
    <button class="connect-button" @click=increment>+</button>
        <button class="connect-button" @click=list_questions>list</button>
        {{questionlist}}

  </div>
</template>
