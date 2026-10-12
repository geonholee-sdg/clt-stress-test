# AI prompts

I used Claude (Anthropic's chat assistant) a lot on this project. I wrote my prompts in Korean, so the ones below are translated and shortened. This is not every message. These are the ones where something changed. Claude also drafted this file and the README from the chat history, and they went through the same review as the other files.

## Who did what

- Claude wrote the R code (`clt_helpers.R` and the code in each .qmd file) and drafted the written parts of each file. For most files it ran the code itself with my seed first and wrote from those numbers, then checked them against my rendered output. The numbers were identical.
- I ran and rendered every file myself in RStudio and sent the output back to be checked. I asked for a full review before every upload, and I decided what went on GitHub.
- The seed 5146 is the last 4 digits of my student ID, like the instructions say. Claude suggested 167 as the second seed.
- For the "normal enough" rule, I ran the Q-Q comparison, but the final numbers were Claude's suggestion (details below).

## 1. Understanding the assignment

**Prompt:** "I am going to keep adding project files. Read all of them and analyze them properly."

Claude summarized the three versions of the assignment and what the 9/29 announcement says is graded. It also pointed out that the 2/√n and 6/n lines in the 9/14 class script are the general rule, skewness / √n and excess kurtosis / n, which is what every file uses for its prediction.

**Follow-up:** "What is the professor actually asking us to do? I do not get it."

It explained the project again with a dice example and suggested an order: define the rule first, write one function that runs the simulation, then go population by population. That is the order I followed.

## 2. Matching the class code

**Prompt:** "I want to match the professor's coding style as much as possible."

I gave it the for loops notes, the 9/14 class R script and the Class 05 qmd. The code uses the same things as class: a for loop with `replicate()` and `rbind()`, `hist()` with `curve(dnorm())`, `qqnorm()` / `qqline()`, and the same colors.

Claude noticed that Class 05 treats the kurtosis of a normal as 0, but the `moments` package gives 3. The files use 3, and the plots say "normal = 3" so there is no mix-up.

## 3. Picking the cutoff

Claude brought this one up. It listed options (skewness under 0.2, 0.3 or 0.5) and asked which I wanted.

**My answer:** "I am not sure. What would the professor want?"

It suggested deciding by looking at Q-Q plots, which became `choosing_cutoff.R`.

I ran it for the exponential at n = 16, 30, 45 and 100 and checked the skewness against 2/√n:

| n | simulated | 2/√n |
|---|---|---|
| 16 | 0.57 | 0.50 |
| 30 | 0.37 | 0.37 |
| 45 | 0.29 | 0.30 |
| 100 | 0.21 | 0.20 |

(These are from that four-n run. The full exponential file lands at 0.302 for n = 45.)

I could not decide where to draw the line from the plots, so I asked Claude to pick.

**The rule it proposed:** skewness and kurtosis within 0.3 of a normal, simulated sd within 2% of theory, and it has to keep passing for every bigger n.

**Change:** it later loosened the sd check to 3%, because with 10,000 simulations the sd itself moves by about 1%, and 2% could fail an n that is actually fine.

**Later check:** the Normal file backed up 0.3. For a population that is exactly normal, skewness still moved up to 0.047 and kurtosis by up to 0.1 just from noise, and a 0.05 cutoff would have needed n = 475. So the small cutoffs are mostly measuring noise.

## 4. Review rounds on the first file (exponential)

**Prompt:** "Check every word and every number again."

This is where most of the problems showed up:

- The draft said the sd was within about 1% of σ/√n. The worst gap was actually 2.9%, at n = 4.
- It said the sd matching σ/√n showed the CLT working at small n. That is wrong, since σ/√n is true for any n whatever the shape. It was changed to say this is a check that the simulation works.
- There was no sentence comparing the simulated mean with the theoretical mean (question 4 in the guidance), so one was added.
- It gave the wrong reason the answer was 65. The draft blamed n = 45 (0.302). The actual reason was that n = 50 and 55 passed but n = 60 came back at 0.303, and the keep-passing rule moved the answer to 65.

**Follow-up:** "Are you actually following the 9/22 guidance document? Go through it line by line."

One thing was missing: a statement about the three CLT assumptions (independent, identically distributed, finite variance). It was added to every file after that.

## 5. Making the checks systematic

Errors kept showing up one at a time, so I asked: "Why do you keep getting one thing wrong? From now on, finish the review yourself before you bring anything to me."

From the die file on, every number in the text was recalculated from the simulation output before I got the file. Once I rendered, the numbers and paragraphs in my HTML were compared against the .qmd. Some things this caught:

- **Die:** the kurtosis at n = 2 was written as 2.36. It is 2.35.
- **Die:** the n = 5 Q-Q plot was described as following the line the whole way. The last few points at each end bend off.
- **Cauchy:** the Q-Q ends were described as "in the thousands". At n = 30 the lowest point is about -862, so it became "hundreds or thousands".
- **Basketball:** the draft said skewness was negative from n = 200 on. It is slightly positive at n = 250.
- **Dependent:** the n = 300 Q-Q plot was described as only a few points off at the ends. The ends are still visibly above the line, so that was too strong.
- **Exponential:** the text said the mean column "sits at 1.00 the whole way", but the table shows 0.993 at n = 5. It now says within about 0.01 of 1.
- **Cauchy:** the file said W was above 0.84 at n = 2 "for every other population". That was true when only the first four were done. The basketball and machine files came in lower, so it now names the four.
- **Surprise sections:** the die, life/death and Cauchy files called something a surprise that their own prediction section had already said. Reworded.
- **Prediction sentences:** a few drafts said I "expected" something before running the simulation when the chat history showed the opposite had already come up. Those were rewritten as what the formulas or the project description predict.

Most of the mistakes were sentences that claimed more than the numbers showed. The code itself was usually fine.

## 6. When the usual formula is wrong

The guidance says not to apply the usual formula automatically when an assumption does not hold. Claude pointed out early that this matters for the basketball shots and the dependent machine failures.

**Basketball:** there is no single σ. σ/√n with p = 0.7 is too big at every n (9.5% at n = 2, still 2% to 5% from n = 10 on), so my rule never passes with it. The sum of each shot's p(1 - p) gives an SE within about 1.6%. Both versions are in the file so you can see the difference.

**Dependent failures:**

- The usual SE was too big by 12% to 19%. An SE that adds in the correlations between runs is within 2.4%.
- Simulating one machine at a time, with a loop inside every sample, would have been very slow, so the code runs all 10,000 machines side by side.
- Each machine runs 50 failures first so the starting value does not matter.

## 7. Things I caught

- **A quote:** Claude quoted the professor. I asked when he said that. It turned out to be a paraphrase, so we went back to the actual text.
- **Repo name:** the first suggestion was a name Claude made up, and I asked whether other students using AI would get the same one. The final name, `clt-stress-test`, comes from the project's title, which calls it stress-testing the central limit theorem.
- **A commit message:** one started with "cauchy:", which did not match any of my earlier commits, so I changed it.

## 8. How I checked the results

- The first check was `choosing_cutoff.R`: the skewness in the plot titles matched 2/√n within noise, so the simulation loop was doing the right thing before anything was built on it.
- Each file except the Cauchy has a prediction from the formulas before the simulation runs, and then compares it with the result.
- The trend plots have the theory lines on them, so it is easy to see where the simulation leaves theory.
- Every file was run again with seed 167. The exact n moved for some populations:

  | Population | Seed 5146 | Seed 167 |
  |---|---|---|
  | Exponential | 65 | 50 |
  | Binomial | 25 | 16 |
  | Basketball | 6 | 8 |
  | Dependent | 300 | 150 |

  The conclusions did not change.
- The Normal file works as a control. It should pass right away, and it does at n = 2.
- I rendered every file myself. The numbers matched Claude's separate run with the same seed exactly, so the code runs the same way on two machines.
