<script setup>
import { useCanister } from "@connect2ic/vue"
import { ref, watchEffect, onMounted} from "vue"

const props = defineProps({
  question: Object
})

let answers = ref([])
const currentAnswer = ref(answers[0])

let question_ids = ref([])
let number = ref(0)
let wachten = ref("Bewaar")
const [questions] = useCanister("questions", { mode: "anonymous" })

const saveAnswer = async (answer, questionId) => {
    let answerId = await questions.value.addAnswer(answer.answer, answer.score, questionId);
    return answerId;
}

</script>


<template>
  <div>
  <h2>{{props.question.name}}</h2>
  <h3>{{props.question.description}}</h3>
  <template v-for="answer in props.question.answers">
    <input type="radio"
      :id="answer.id"
      :value="answer.id"
      name="answer.description"
      v-model="currentAnswer">
    <label :for="answer.id">{{ answer.description }}</label>
  </template>

  <span>Picked: {{ currentAnswer }}</span>
  </div>
</template>

