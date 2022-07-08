<script setup lang="ts">
import { useCanister } from "@connect2ic/vue"
import { onMounted, ref, watchEffect } from "vue"

import { JsonForms, JsonFormsChangeEvent } from "@jsonforms/vue";
import { defaultStyles, mergeStyles, vanillaRenderers } from "@jsonforms/vue-vanilla";
import { isDescriptionHidden } from "@jsonforms/core";
// mergeStyles combines all classes from both styles definitions into one
const myStyles = mergeStyles(defaultStyles, { control: { label: "mylabel" } });

const schema = {
  properties: {
    qid: {
      type: "number",
      minLength: 1,
    },
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
          // aid: {
          //   type: "number",
          //   minLength: 1,
          // },
          answer: {
            type: "string",
            minLength: 1,
            title: "antwoord"
          },
          score: {
            title: "score",
            type: "integer",
          },
          correct: {
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
    type: "HorizontalLayout",
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
                  scope: "#/properties/correct",
                }
              ]
            }
          }
        }
      ]     
    },
  ]
};

const data = ref({qid: 0, name: "Dag1", description: "Vul de vraag", open: false, answers: [{aid: 0, answer: "Antwoord1", score: 3, correct: false}]})
const renderers = Object.freeze(vanillaRenderers)

let question = ref()
let question_objects = ref([])
let number = ref(0)
let wachten1 = ref("Nieuw")
let wachten2 = ref("Wijzig")

const [questions] = useCanister("questions", { mode: "anonymous" })

const getQuestions = async () => {
  let qqs = []
  const freshQuestions = await questions.value.list_questions()
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
  data.value = qqs[0]
  
}



const refreshQuestion = async () => {
  const freshQuestion = await questions.value.showQuestion(number.value)
  question.value = freshQuestion
}

const saveAnswer = async (answer, questionId) => {
    if(answer.correct == undefined) {
      answer.correct = false
    }
    let answerId = await questions.value.addAnswer(answer.answer, answer.score, answer.correct, questionId);
    return answerId;
}

const saveQuestion = async () => {
  wachten1.value = "Wachten..."
  const savedQuestionId = await questions.value.addQuestion(data.value.name, data.value.description)
  console.log("QuestionID: ", savedQuestionId)
  const answers = data.value.answers
  for (let i = 0; i < answers.length; i++) {
    let answerId = await saveAnswer(answers[i], savedQuestionId);
  }
  wachten1.value = "Nieuw"
  getQuestions()
}

const updateQuestion = async () => {
  wachten2.value = "Wachten..."
  const savedQuestionId = await questions.value.updateQuestion(data.value.qid, data.value.name, data.value.description, data.value.open)
  console.log("QuestionID: ", savedQuestionId)
  const answers = data.value.answers
  for (let i = 0; i < answers.length; i++) {
    let answerId = await saveAnswer(answers[i], savedQuestionId);
  }
  wachten2.value = "Wijzig"
}


function onChange(event: JsonFormsChangeEvent) {
  data.value = event.data
}

const increment = async () => {
  number.value++
  data.value = question_objects.value[number.value]
}

const decrement = async () => {
  number.value--
  data.value = question_objects.value[number.value]
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
  <div>
        <button class="connect-button" @click=decrement>-</button>
    <button class="connect-button" @click=increment>+</button>
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

