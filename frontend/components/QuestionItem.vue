i<script setup>
import { useCanister } from "@connect2ic/vue"
import { ref, watchEffect, onMounted} from "vue"

const props = defineProps({
  question: Object,
  prince: Text
})


let answered = ref(false)
let answers = ref([])
const currentAnswer = ref(0)

let question_ids = ref([])
let number = ref(0)
let wachten = ref("Bewaar")
const [questions] = useCanister("questions", { mode: "anonymous" })

const saveAnswer = async () => {
  wachten.value = "Wachten.."
  console.log("Current answer: ", currentAnswer.value)
  console.log("Principal: ", props.prince)
  console.log("Question ID: ", props.question.qid)
  

    let res = await questions.value.vote2(currentAnswer.value, props.question.qid, props.prince);
    console.log("Result: ", res)
    wachten.value = "Bewaar"

        answered.value = true
}


</script>

<template>
  <h2>{{props.question.name}}</h2>
  <h3>{{props.question.description}}</h3>
    <div>
    <template v-for="answer in props.question.answers">
        <label for="answer.aid">
          <input type="radio"
            :id="answer.aid"
            :value="answer.aid"
            name="answer.answer"
            v-model="currentAnswer"
         >
          {{ answer.answer }}
        </label>
    </template>
            <button class="connect-button" @click=saveAnswer>{{wachten}}</button>
</div>
</template>