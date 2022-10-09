package main

import (
	"fmt"
	"github.com/aws/aws-lambda-go/lambda"
)

type Event struct {
	Name string `json: "What is your name?"`
	Age  int    `json: "What is your age?"`
}

type Response struct {
	Message string `json: "Answer"`
}

func HandleLambdaEvent(event Event) (Response, error) {
	return Response{
		Message: fmt.Sprintf("%s is %v years old", event.Name, event.Age),
	}, nil
}

func main() {
	lambda.Start(HandleLambdaEvent)
}
