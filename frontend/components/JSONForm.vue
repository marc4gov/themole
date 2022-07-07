<script setup lang="ts">
import { useCanister } from "@connect2ic/vue"
import { onMounted, ref, watchEffect } from "vue"

import { JsonForms, JsonFormsChangeEvent } from "@jsonforms/vue";
import { defaultStyles, mergeStyles, vanillaRenderers } from "@jsonforms/vue-vanilla";
// mergeStyles combines all classes from both styles definitions into one
const myStyles = mergeStyles(defaultStyles, { control: { label: "mylabel" } });

const schema = {
  properties: {
    name: {
      type: "string",
      minLength: 1,
      title: "Naam"
    },
    description: {
      title: "Omschrijving van de vraag",
      type: "string",
    },
    open: {
      type: "boolean",
      title: "Vraag staat open"
    },
    answers: {
      "type": "array",
      "title": "Antwoorden",
      "items": {
        "type": "object",
        "properties": {
          answer: {
            type: "string",
            minLength: 1,
            title: "antwoord"
          },
          score: {
            title: "score",
            type: "integer",
          },
          correctAnswer: {
            title: "Correct",
            type: "boolean",
          },
        }
      }
    },
  },
};

const uischema = {
  type: "VerticalLayout",
  elements: [
    {
      type: "Control",
      scope: "#/properties/name"
    },
    {
      type: "Control",
      scope: "#/properties/description"
    },
    {
      type: "Control",
      scope: "#/properties/open",
    },
    {
    type: "VerticalLayout",
    elements: [
        {
          type: "Control",
          scope: "#/properties/answers",
          options: {
            elementLabelProp: "Antwoord",
            detail: {
              type: "HorizontalLayout",
              elements: [
                {
                  type: "Control",
                  scope: "#/properties/answer"
                },
                {
                  type: "Control",
                  scope: "#/properties/score"
                },
                {
                  type: "Control",
                  scope: "#/properties/correctAnswer",
                }
              ]
            }
          }
        }
      ]     
    },
  ]
};

const data = ref({id: 0, name: "Dag1", description: "Vul de vraag", answers: [{id: 0, answer: "Antwoord1", score: 3, correctAnswer: false}]})
const renderers = Object.freeze(vanillaRenderers)

let question = ref()
let question_objects = ref([])
let number = ref(0)
let wachten1 = ref("Nieuw")
let wachten2 = ref("Wijzig")

const [questions] = useCanister("questions", { mode: "anonymous" })

const getQuestions = async () => {
  let qqs = []
  const freshQuestions = await questions.value.list_closed_questions()
  for (var id in freshQuestions) {
    const qs = await questions.value.getQuestion(Number(id))
    console.log(qs.ok)
    const qq = {id: Number(id), name: qs.ok.name, description: qs.ok.description, answers: qs.ok.answers}
    qqs.push(qq)
  }
  data.value = qqs[0]

  // const questions = freshQuestions.map(q => Number(q))

}


const refreshQuestion = async () => {
  const freshQuestion = await questions.value.showQuestion(number.value)
  question.value = freshQuestion
}

const saveAnswer = async (answer, questionId) => {
    let answerId = await questions.value.addAnswer(answer.answer, answer.score, questionId);
    return answerId;
}

const updateAnswer = async (answer, questionId) => {
    let answerId = await questions.value.updateAnswer(answer.answer, answer.score, questionId);
    return answerId;
}

const saveQuestion = async () => {
  wachten1.value = "Wachten..."
  const savedQuestionId = await questions.value.addQuestion(data.value.name, data.value.description)
  console.log("QuestionID: ", savedQuestionId)
  const answers = data.value.answers
  for (let i = 0; i < answers.length; i++) {
    let answerId = await saveAnswer(answers[i], savedQuestionId);
    if (answers[i].correctAnswer) {
      console.log("AnswerId: ", answerId)
      await questions.value.setCorrectAnswer(savedQuestionId, answerId, answers[i].score)
    } 
  }
  wachten1.value = "Nieuw"
}

const updateQuestion = async () => {
  wachten2.value = "Wachten..."
  const savedQuestionId = await questions.value.updateQuestion(data.value.name, data.value.description)
  console.log("QuestionID: ", savedQuestionId)
  const answers = data.value.answers
  for (let i = 0; i < answers.length; i++) {
    let answerId = await saveAnswer(answers[i], savedQuestionId);
    if (answers[i].correctAnswer) {
      console.log("AnswerId: ", answerId)
      await questions.value.setCorrectAnswer(savedQuestionId, answerId, answers[i].score)
    } 
  }
  wachten2.value = "Wijzig"
}


function onChange(event: JsonFormsChangeEvent) {
  data.value = event.data
}

onMounted(() => {
  getQuestions()
})

watchEffect(() => {
  if (data.value) {
    console.log(data.value)  
  }
})

</script>


<template>
  <div className="myform">
  <JsonForms
    :data="data"
    :schema="schema"
    :uischema="uischema"
    :renderers="renderers"
    @change="onChange"
  />
  <button class="connect-button" @click=saveQuestion>{{wachten1}}</button>
  <button class="connect-button" @click=updateQuestion>{{wachten2}}</button>
  </div>
</template>

