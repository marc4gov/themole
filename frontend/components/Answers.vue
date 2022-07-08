<script setup>
import { useCanister, useConnect } from "@connect2ic/vue"
import { ref, watchEffect, onMounted} from "vue"
import QuestionItem from "./QuestionItem.vue";

  const { isConnected, principal, activeProvider } = useConnect({
    onConnect: () => {
      // Signed in
    },
    onDisconnect: () => {
      // Signed out
    }
  })

const picked = ref('One')


let answers = ref([])
const currentAnswer = ref(answers[0])

let question_objects = ref([])
let number = ref(0)
let wachten = ref("Bewaar")
const [questions] = useCanister("questions", { mode: "anonymous" })

const getQuestions = async () => {
  let qqs = []
  const freshQuestions = await questions.value.list_closed_questions()
  for (var qid in freshQuestions) {
    const qs = await questions.value.getQuestion(Number(qid))
    // console.log("QS: ", qs.ok)
    const ans = qs.ok.answers
    const as = await ans.map(a => { return {aid : Number(a.id), answer: a.description, score: Number(a.score), correct: a.correct}})
    // console.log("AS: ", as)
    const qq = {qid: Number(qid), name: qs.ok.name, description: qs.ok.description, open: false, answers: as}
    // console.log("QQ: ", as)
    qqs.push(qq)
  }
  question_objects.value = qqs

  // const questions = freshQuestions.map(q => Number(q))

}

const saveAnswer = async (answer, questionId) => {
    let answerId = await questions.value.addAnswer(answer.answer, answer.score, questionId);
    return answerId;
}

// const getQuestion = async (id) => {
//   wachten.value = "Wachten..."
//   console.log("QuestionID: ", savedQuestionId)
//   const answers = data.value.answers
//   for (let i = 0; i < answers.length; i++) {
//     let answerId = await saveAnswer(answers[i], savedQuestionId);
//     if (answers[i].correctAnswer) {
//       console.log("AnswerId: ", answerId)
//       await questions.value.setCorrectAnswer(savedQuestionId, answerId, answers[i].score)
//     } 
//   }
//   wachten.value = "Bewaar"
// }

const handleInput = (answer, qua) => {
  console.log("Input answer: ", answer)
  console.log("Input question: ", qua)
  
}

watchEffect(() => {

})

onMounted(() => {
  getQuestions()
})
</script>
<template>
  <div class="example">
    <template v-if="isConnected">
      {{principal}}
      <QuestionItem
        v-for="q_obj in question_objects"
        :question="q_obj"
        :prince="principal">
      </QuestionItem>  
</template>
    <template v-else>
      <p class="example-disabled">Connect om vragen te zien </p>
    </template>
  </div>
</template>