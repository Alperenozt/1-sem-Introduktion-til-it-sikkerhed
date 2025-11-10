from flask import Flask, request, jsonify
import random

app = Flask(__name__)

# ---------- Exercise 1: Hello World ----------
@app.route("/")
def home():
    return "Velkommen til min Python server – den kører!"

# ---------- Exercise 2: Add two numbers ----------
@app.route("/add/<int:a>/<int:b>")
def add(a, b):
    return jsonify({
        "a": a,
        "b": b,
        "result": a + b
    })

# ---------- Exercise 3: Reverse a string ----------
@app.route("/reverse")
def reverse():
    text = request.args.get("text", "")
    return jsonify({
        "original": text,
        "reversed": text[::-1]
    })

# ---------- Exercise 4: FizzBuzz ----------
@app.route("/fizzbuzz/<int:n>")
def fizzbuzz(n):
    if n % 15 == 0:
        result = "FizzBuzz"
    elif n % 3 == 0:
        result = "Fizz"
    elif n % 5 == 0:
        result = "Buzz"
    else:
        result = str(n)
    return jsonify({
        "input": n,
        "result": result
    })

# ---------- Exercise 5: Guess the number ----------
secret_number = random.randint(1, 100)

@app.route("/guess/<int:guess>")
def guess_number(guess):
    if guess < secret_number:
        return jsonify({"guess": guess, "result": "For lavt!"})
    elif guess > secret_number:
        return jsonify({"guess": guess, "result": "For højt!"})
    else:
        return jsonify({"guess": guess, "result": "Korrekt! Du har gættet tallet."})

# ---------- Run server ----------
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
