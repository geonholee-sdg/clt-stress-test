# How fast does normal happen?

Stress-testing the central limit theorem in R.

People say that once a sample has 30 values, the sample mean is close enough to normal. I wanted to see whether that is actually true, and for which populations. This is my Project 1 for Math 167R, fall 2026.

## What I did

For each population I picked a sample size n, drew a sample of that size, took its mean, and repeated that 10,000 times. Then I checked whether those 10,000 means look normal. I did this for 51 sample sizes: every n from 2 to 20, then 25 to 100 in steps of 5, then 125 to 500 in steps of 25. That grid is the one from the 9/14 class script. It is dense where n is small, which is where things change fastest, and spreads out after 100.

Two different numbers show up everywhere, so to be clear: n is how many values go into one mean. 10,000 is how many means I collect for each n. The 10,000 does not make the sample bigger. It just gives a clean picture of what the mean of n values does.

I used eight populations. Five from the assignment list (normal, six-sided die, exponential, binomial, Cauchy) and the three processes from the class handouts (life/death ages, basketball shots with fatigue, dependent machine failures).

Everything is base R (plus the `moments` package for skewness and kurtosis) and Quarto. The simulation loop lives in `clt_helpers.R`, and every file uses the same seed (the last four digits of my student ID), so the numbers below come back exactly if you render the files again.

## My rule for "normal enough"

There is no official cutoff, so I had to settle on one. I call the sample mean normal enough at n if:

- the skewness of the 10,000 means is within 0.3 of 0,
- their kurtosis is within 0.3 of 3,
- their sd is within 3% of the standard error, σ/√n (or the correct SE when σ/√n does not apply, see below),
- and all three keep holding for every bigger n I tried, up to 500. One lucky n does not count.

The 3% on the sd is there because the sd of 10,000 means wobbles on its own, by up to 2.9% in these files. It still catches a wrong SE formula, which it did twice.

Why 0.3: the number was Claude's suggestion (`ai_prompts.md` has that part). Here is the case for it. I ran Q-Q plots for the exponential at n = 16, 30, 45 and 100 (`choosing_cutoff.R`). At n = 30 the right tail bends clearly off the line. At n = 45 (skewness 0.29 in that run, 0.302 in the full exponential file) only the top end still lifts, and at n = 100 it is nearly gone. So a 0.3 cutoff lands between n = 30 and n = 45. The normal file gave me the other half of the argument. With 10,000 simulations, skewness and kurtosis wobble by about 0.05 to 0.1 even for a population that is exactly normal, and a cutoff of 0.05 would need n = 475 for a perfect normal. So 0.3 is a few times above the noise but still strict enough to catch the exponential at 30.

Every file except the Cauchy also shows the answer under cutoffs of 0.5, 0.2, 0.1 and 0.05, so you can see how much that choice matters.

What I looked at in every file: a histogram of the means with the normal curve on top, a Q-Q plot, skewness, kurtosis, Shapiro-Wilk W (as a trend only, since with 5,000 points the test flags everything), the simulated mean against the theoretical mean, and the simulated sd against σ/√n. Before running anything, each file except the Cauchy also predicts n from the population's skewness and kurtosis, using the fact that the skewness of the mean shrinks like skew/√n and the excess kurtosis like excess/n.

## Results

Smallest n that passes my rule, with the formula's prediction and a second seed for comparison:

| Population | Population skewness | Formula said | My n (seed 5146) | Seed 167 | Is 30 enough? |
|---|---|---|---|---|---|
| Normal(0, 1) | 0 | any n | 2 | 2 | yes, easily |
| Six-sided die | 0 | 5 (from kurtosis) | 5 | 5 | yes |
| Basketball shots | changes by shot | 9 if every shot were 70% | 6 | 8 | yes |
| Life/death ages | -0.86 | 9 | 11 | 11 | yes |
| Binomial(5, 0.1) | 1.19 | 16 | 25 | 16 | yes, but not under a 0.2 cutoff |
| Exponential(1) | 2 | 45 | 65 | 50 | no, skewness is still 0.38 at 30 |
| Dependent machine failures | 2.89 (long run) | 93 if the runs were independent | 300 | 150 | no, skewness is still 0.73 at 30 |
| Cauchy | undefined | no n | none | none | no, nothing works |

What the evidence looked like at the n I picked:

| Population | n | Mean of the means (theory) | SD of the means vs SE | Skewness | Kurtosis | Shapiro W | Key observation |
|---|---|---|---|---|---|---|---|
| Normal(0, 1) | 2 | -0.003 (0) | 1.5% off | 0.038 | 3.00 | 0.999 | already normal at n = 2; shows the noise floor (skewness up to 0.047) |
| Six-sided die | 5 | 3.498 (3.5) | 0.4% off | 0.004 | 2.76 | 0.993 | zero skew but flat; kurtosis 2.35 at n = 2 is what fails |
| Basketball shots | 6 | 0.698 (0.70) | 0.7% off, sum-of-variances SE | -0.298 | 2.79 | 0.916 | σ/√n with p = 0.7 is the wrong SE; the shape itself is fine by n = 6 |
| Life/death ages | 11 | 49.95 (49.98) | 0.5% off | -0.246 | 2.98 | 0.995 | strange shape but mild skew, so fast; three bumps at n = 2 |
| Binomial(5, 0.1) | 25 | 0.499 (0.5) | 0.4% off | 0.246 | 3.01 | 0.988 | skewness decides; a noisy n = 20 pushed the answer to 25 |
| Exponential(1) | 65 | 1.002 (1) | 0.1% off | 0.289 | 3.15 | 0.994 | histogram looks fine at 30, but skewness is 0.38 and the Q-Q tail bends |
| Dependent machine failures | 300 | 1.676 (1.67) | 0.9% off, dependence-adjusted SE | 0.202 | 3.11 | 0.997 | usual SE 12% to 19% too big; shape slower than independent runs |
| Cauchy | 500 | -3.2 (no mean exists) | no SE exists | -75.6 | 6,557 | 0.013 | mean of 500 values is as spread out as one; the median works by n = 100 |

The low W for the basketball shots is the ties: a 6-shot game can only land on 7 values. Full tables, plots and the reasoning for each number are in the files.

The seed 167 column is the reproducibility check from the project description. The exact n moved for four of the eight populations, by as much as a factor of two for the machine failures, because each answer sits where a noisy curve crosses a line. The conclusions did not move. And with the seed fixed, every file comes back with the same numbers each time, which is the point of setting one.

## Is the number 30?

Sometimes. For five of the eight populations it is enough, and for the normal and the die it is far more than needed. For the exponential it is not. The histogram at n = 30 looks fine, but the skewness is still 0.38 and the Q-Q plot still bends on the right. I needed 50 to 65 depending on the seed. For the dependent process, 30 is not close. I needed 150 to 300. For the Cauchy no n works. The theorem does not apply there, because the variance is infinite.

Fastest to slowest: normal (2), die (5), basketball (6), life/death (11), binomial (16 to 25), exponential (50 to 65), machine failures (150 to 300), Cauchy (never). What decided the speed was skewness, almost every time. Kurtosis shrinks like 1/n and skewness only like 1/√n, so kurtosis gets fixed early and skewness is what is left. The formula predicted the order and roughly the size: any n for the normal, 5 for the die (from kurtosis, since its skewness is 0), 9 for the life/death ages (I got 11), 16 for the binomial (16 to 25), 45 for the exponential (50 to 65). Under my cutoff, the skewness check passes at 30 whenever the population skewness is under about 1.6, because 30 × 0.3² = 2.7 and √2.7 ≈ 1.6. The exponential's skewness is 2, which is why 30 fails there.

So the answer I would give: 30 is a fine rule for mildly skewed populations with independent draws, and that is a fact about those populations more than a rule from the theorem.

## What surprised me or broke

**Cauchy.** No n works. The average of 500 Cauchy values has exactly the same Cauchy(0, 1) distribution as one value, and the simulation shows it: the middle 50% of the means runs from about -1 to 1 at n = 2 and still does at n = 500. One sample of 70 values had a mean of about -813,768 and moved the average of 10,000 means from 0.22 to -81. The median, on the same kind of data, is normal enough by n = 100.

**Dependent machine failures.** Each operating time depends on the one before it, and a long run is usually followed by a short one. The usual σ/√n was 12% to 19% too big at every n, because the long and short runs partly cancel out, so the mean is actually more precise than the formula says. At the same time the shape was slower than for independent runs: skewness at n = 100 was 0.42 where independent runs would give 0.29. With the dependence-adjusted SE my rule passes at n = 300 (150 with the other seed). The long-run mean is also 1.67, not 1, even though the baseline rate is 1.

**Basketball shots.** Each shot has its own probability, 0.90 for the first and dropping to 0.50 for the last. σ/√n with the average p = 0.7 is too big at every n, by 9.5% at n = 2 and still 2% to 5% from n = 10 on, so with that formula my rule never passes. With the SE that adds up each shot's own variance, it passes at n = 6, and it was actually a bit faster than a constant 70% shooter (n = 10). So the non-identical shots did not slow the CLT down, but they did make the usual SE formula wrong.

**Binomial(5, 0.1).** It looks worse than the exponential (six values, and 59% of draws are 0) but was faster, because its skewness is 1.19 instead of 2. One noisy n made the difference between the two seeds: at n = 20 the skewness came out 0.323 with my seed when the formula says 0.267, and the keep-passing rule pushed the answer to 25 (seed 167 gave the formula's 16).

**Six-sided die.** Its skewness is exactly 0, so if I had only checked skewness it would pass at n = 2. It does not. The population is flat, the kurtosis at n = 2 is 2.35, and that is what my rule caught. It is also why the histograms of the means look like combs: the mean of n rolls can only land on a few values.

**Life/death ages.** The strangest-looking population, a spike at age 0 and a hump at 65, was one of the fastest, because its skewness is only -0.86. At n = 2 the histogram has three bumps, one for each way two deaths can combine (both young, one of each, both old).

**Normal.** Even for a population that is exactly normal, skewness wobbles up to 0.047 and kurtosis up to 0.1 with 10,000 simulations. That is the noise behind every number in this project.

## What happened when the assumptions broke

- **Not independent** (machine failures): the mean still landed on the long-run mean and the shape still became normal, just slowly, at 5 to 10 times the 30 rule. The usual SE was off in the opposite direction from the one the project description warns about. This process goes back and forth, so n runs estimate the mean about as well as 1.36n independent runs would. The warning about the effective sample size being smaller fits positive dependence, where similar values come in streaks.
- **Not identically distributed** (basketball): the CLT worked fine, faster than the matching constant-p case, but σ/√n with one average p was the wrong SE.
- **Infinite variance** (Cauchy): no convergence at any n. The sd of the means never shrank.

## Files

| File | Contents | Rendered |
|---|---|---|
| `clt_helpers.R` | the simulation loop, my rule, and the two plot functions most files use | |
| `choosing_cutoff.R` | the exponential Q-Q plots I used to pick the 0.3 cutoff | |
| `normal.qmd` | the control case | [page](https://geonholee-sdg.github.io/clt-stress-test/normal.html) |
| `six_sided_die.qmd` | symmetric but flat and discrete | [page](https://geonholee-sdg.github.io/clt-stress-test/six_sided_die.html) |
| `exponential.qmd` | the main test of the 30 rule | [page](https://geonholee-sdg.github.io/clt-stress-test/exponential.html) |
| `binomial_small.qmd` | skewed and discrete | [page](https://geonholee-sdg.github.io/clt-stress-test/binomial_small.html) |
| `cauchy.qmd` | infinite variance, plus the median as a fix | [page](https://geonholee-sdg.github.io/clt-stress-test/cauchy.html) |
| `life_death.qmd` | two-hump age-at-death distribution | [page](https://geonholee-sdg.github.io/clt-stress-test/life_death.html) |
| `basketball.qmd` | not identically distributed | [page](https://geonholee-sdg.github.io/clt-stress-test/basketball.html) |
| `dependent_failure.qmd` | not independent | [page](https://geonholee-sdg.github.io/clt-stress-test/dependent_failure.html) |
| `ai_prompts.md` | what I asked the AI, what was wrong, and what I changed | |

Every file follows the same outline: the population, what to expect, the simulation, what happens as n grows, a closer look at a few n, my decision, the same data under other cutoffs (except the Cauchy, where nothing passes), a second seed, and what surprised me. A few files add a section for the part that was different (the median for the Cauchy, the SE formula for the basketball and machine files). The `.html` files next to the `.qmd` files are the rendered output.

## How to run it

You need R with the `moments`, `knitr` and `rmarkdown` packages (`install.packages(c("moments", "knitr", "rmarkdown"))`) and Quarto, which comes with RStudio. Put the `.qmd` files and `clt_helpers.R` in the same folder and render any file, either with the Render button in RStudio or with `quarto render exponential.qmd`. Each file takes a minute or two.

Every file sets `student_id <- 5146` and uses it as the seed, then runs once more with seed 167. Change `student_id` at the top of a file to try another seed.

## AI use

I ran and rendered everything here myself, and every number in the write-ups was checked against the rendered output before it went up. Claude wrote the code and drafted the write-ups, including this README and `ai_prompts.md`. `ai_prompts.md` has the prompts that mattered, the mistakes the drafts had, and what changed.
