# how-to-code-simple-data-assignments

My Solved Assignments of [How to Code - Simple Data](https://www.edx.org/course/how-to-code-simple-data) course on Edx.

## 🎾 About the course

How to Code - Simple Data is the first course of the [UBCx Software Development MicroMasters](https://www.edx.org/micromasters/ubcx-software-development) and the first course of the [Core CS section](https://github.com/ossu/computer-science#core-cs) in the [OSSU CS curriculum](https://github.com/ossu/computer-science) targeted to self-taught developers.

## 🎾 Relection on the course

I was first intrigued by the logic behind the HtDF (How to design functions) recipe and how well-structured it is for designing functions. Each step helps in producing the subsequent step in the design process, even if a step seems useless.

For example, when Professor Kiczales introduced the stub method, I thought it was just an extra step that wasn't much necessary but later on, I found how this step is very important in testing how well-formed the test examples are.

Some function design patterns such as recursion, which dont seem very trivial in function design, were very trivial following the HtDf recipe.

At the end of the course, I came to appreciate every step in the design process. Overall, Professor Kiczales delivered the course exceptionally well, and I learned so much from this course.

## 🎾 What I learned

- A systematic approach to solve complex problems by breaking them into simpler problems following the [HtDF](https://cs.berry.edu/webdocs-common/csc120/docs/recipes/htdf.html) and [HtDD](https://cs.berry.edu/webdocs-common/csc120/docs/recipes/htdd.html) recipes.

- Test driven development: Writing tests first can serve as examples of the function output in addition to being tests aiding in the function design process.

- How to covert real world information to data in a way that makes interpretting them back to information easy.

## 🎾 Final Project

In my final project, I implemented a fully-tested fully-modular version of space invaders.

First, I conducted a thorough domain analysis of the program.

![domain analysis according to type of information_page-0001.jpg](https://i.imgur.com/fTMC4Ct.jpg)

![domain analysis according to type of information_page-0002.jpg](https://i.imgur.com/6ntqsp9.jpg)

![domain analysis according to type of information_page-0003.jpg](https://i.imgur.com/n8uSol8.jpg)

Then, I started the implementation conforming to the course recipes.

![](https://i.imgur.com/gzcETy7.png)

<small> Part of Space Invaders Implementation. </small>

And here's the final result.

<img src="https://i.imgur.com/817QbYT.gif" title="" alt="2024-01-02 16-41-10.gif" width="215">

## 🎾 Reflection on the project

Few areas that could be further enhanced for an improved gaming experience:

1. Limit rate of missile fire so it would require some accuracy hitting invaders.
2. Add a pause of 3 seconds when the invader reaches the base and make the tank blink (indicating death) so the user can look at his failure better 😈.
3. Increase invade rate as time goes by. Display a level number with each invade rate increment. Start the gameplay with 'Level 1'.

## 🎾 How to view the files?

1. Install racket from [here](https://download.racket-lang.org/).
2. Open the _.rkt_ files

## 🎾 How to play the game?

1. Install DrRacket from [here](https://download.racket-lang.org/).
2. Go to the final project repo by clicking on `space-invaders-htcsd @ fa38ed4` in the current repo files.
3. Clone the final project repo or download the `starter.rkt` file
4. Open the `starter.rkt` in DrRacket.
5. Press Run
   ![Imgur](https://i.imgur.com/lDFHgRD.png)
6. Start the game by typing `(main GAME-START)` in the DrRacket console and press `Enter`
   ![Imgur](https://i.imgur.com/jmp7ENz.png)

If you need any additional info for installation you could check the docs from [here](https://docs.racket-lang.org/pollen/Installation.html).
