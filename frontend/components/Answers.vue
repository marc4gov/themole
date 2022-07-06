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
  for (var id in freshQuestions) {
    const qs = await questions.value.getQuestion(Number(id))
    console.log(qs.ok)
    // const qq = {id: Number(id), name: qs.ok.name, description: qs.ok.description, answerIds: qs.ok.answer_ids.map(a => Number(a) )}
    qqs.push(qs.ok)
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



watchEffect(() => {

})

onMounted(() => {
  getQuestions()
})
</script>


<template>
{{principal}}
      <QuestionItem
        v-for="q_obj in question_objects"
        :question="q_obj">
      </QuestionItem>  
</template>

