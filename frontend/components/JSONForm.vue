<script setup lang="ts">
import { useCanister } from "@connect2ic/vue"
import { ref, watchEffect } from "vue"

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
    dueDate: {
      type: "string",
      format: "date",
      title: "Welke dag komt deze vraag?"
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
      scope: "#/properties/dueDate",
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

const data = ref({name: "Dag1", description: "Vul de vraag", answers: [{answer: "Antwoord1", score: 3, correctAnswer: false}]})
const renderers = Object.freeze(vanillaRenderers)

let question = ref()
let number = ref(0)
let wachten = ref("Bewaar")
const [questions] = useCanister("questions", { mode: "anonymous" })

const refreshQuestion = async () => {
  const freshQuestion = await questions.value.showQuestion(number.value)
  question.value = freshQuestion
}

const saveAnswer = async (answer, questionId) => {
    let answerId = await questions.value.addAnswer(answer.answer, answer.score, questionId);
    return answerId;
}

const saveQuestion = async () => {
  wachten.value = "Wachten..."
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
  wachten.value = "Bewaar"
}

function onChange(event: JsonFormsChangeEvent) {
  data.value = event.data
}

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
  <button class="connect-button" @click=saveQuestion>{{wachten}}</button>
  </div>
</template>

