provider "aws" {
  region = "eu-central-1"
}

data "aws_iam_policy_document" "lambda" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com"
      ]
    }
  }
}

resource "aws_lambda_function" "lambda-function" {
  filename = "target/function.zip"
  role = "${aws_iam_role.this.arn}"
  function_name = "my-function"
  handler = "not.used"
  runtime = "provided"
}

resource "aws_iam_role" "this" {
  name = "lambda-role"
  assume_role_policy = "${data.aws_iam_policy_document.lambda.json}"
}

variable "lambda_role_iams" {
  type = list(string)
  default = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
             "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"]
}

resource "aws_iam_role_policy_attachment" "lambda-all-iams" {
  role       = "${aws_iam_role.this.name}"
  count      = "${length(var.lambda_role_iams)}"
  policy_arn = "${var.lambda_role_iams[count.index]}"
}
