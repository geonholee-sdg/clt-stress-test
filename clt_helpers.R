# helper functions I reuse in every distribution file
# (the loop is the same idea as the 9/14 class notes, just wrapped up so I don't have to paste it into 8 files)

library(moments)

# for every n: draw a sample of size n, take the mean, repeat 10,000 times
# generator is a function(n) that returns n random values from the population
run_simulation <- function(generator, pop_sd, seed,
                           n_values = c(2:20, seq(25, 100, by = 5), seq(125, 500, by = 25)),
                           number_of_samples = 10000) {
  set.seed(seed)
  results <- data.frame()
  all_means <- list()

  for (n in n_values) {
    sample_means <- replicate(number_of_samples, mean(generator(n)))
    all_means[[as.character(n)]] <- sample_means

    results <- rbind(results, data.frame(
      n         = n,
      mean      = mean(sample_means),
      sd        = sd(sample_means),
      theory_se = pop_sd / sqrt(n),
      skewness  = skewness(sample_means),
      kurtosis  = kurtosis(sample_means),
      shapiro_w = unname(shapiro.test(sample(sample_means, min(5000, number_of_samples)))$statistic)
    ))
  }

  # how far off the simulated sd is from sigma / sqrt(n), as a fraction
  results$sd_error <- abs(results$sd - results$theory_se) / results$theory_se

  list(results = results, means = all_means)
}

# my "normal enough" rule:
# |skewness| < cutoff, |kurtosis - 3| < cutoff, sd within 3% of theory,
# and it has to KEEP passing for every bigger n (one lucky pass doesn't count)
smallest_n <- function(results, cutoff = 0.3, sd_tolerance = 0.03) {
  passes <- abs(results$skewness) < cutoff &
            abs(results$kurtosis - 3) < cutoff &
            results$sd_error < sd_tolerance
  passes[is.na(passes)] <- FALSE

  for (i in seq_along(passes)) {
    if (all(passes[i:length(passes)])) {
      return(results$n[i])
    }
  }
  NA
}

# 4 plots: sd, skewness, kurtosis, shapiro W as n grows (x axis is log scale so small n is readable)
# red dashed = what theory says, gray dotted = my cutoff
plot_trends <- function(results, pop_skew = NA, pop_exkurt = NA, cutoff = 0.3) {
  old_par <- par(mfrow = c(2, 2))

  plot(results$n, results$sd, type = "b", pch = 16, cex = 0.6, log = "x",
       xlab = "n", ylab = "SD of sample means", main = "Spread")
  lines(results$n, results$theory_se, col = "firebrick", lty = 2, lwd = 2)

  plot(results$n, results$skewness, type = "b", pch = 16, cex = 0.6, log = "x",
       xlab = "n", ylab = "Skewness", main = "Skewness")
  abline(h = c(-cutoff, cutoff), col = "gray50", lty = 3)
  if (!is.na(pop_skew)) {
    lines(results$n, pop_skew / sqrt(results$n), col = "firebrick", lty = 2, lwd = 2)
  }

  plot(results$n, results$kurtosis, type = "b", pch = 16, cex = 0.6, log = "x",
       xlab = "n", ylab = "Kurtosis (normal = 3)", main = "Kurtosis")
  abline(h = 3 + c(-cutoff, cutoff), col = "gray50", lty = 3)
  if (!is.na(pop_exkurt)) {
    lines(results$n, 3 + pop_exkurt / results$n, col = "firebrick", lty = 2, lwd = 2)
  }

  plot(results$n, results$shapiro_w, type = "b", pch = 16, cex = 0.6, log = "x",
       xlab = "n", ylab = "W", main = "Shapiro-Wilk W")
  abline(h = 1, col = "gray50", lty = 3)

  par(old_par)
}

# top row: histograms (red = normal curve the CLT predicts)
# bottom row: Q-Q plots
plot_means <- function(sim, show_n, pop_mean = NA, pop_sd = NA) {
  old_par <- par(mfrow = c(2, length(show_n)))

  for (n in show_n) {
    m <- sim$means[[as.character(n)]]
    hist(m, breaks = 40, probability = TRUE, col = "steelblue", border = "white",
         main = paste("n =", n), xlab = "Sample mean")
    if (!is.na(pop_sd)) {
      curve(dnorm(x, mean = pop_mean, sd = pop_sd / sqrt(n)),
            add = TRUE, col = "firebrick", lwd = 2)
    }
  }

  for (n in show_n) {
    m <- sim$means[[as.character(n)]]
    qqnorm(m, main = paste("Q-Q, n =", n), pch = 16, cex = 0.3, col = "steelblue")
    qqline(m, col = "firebrick", lwd = 2)
  }

  par(old_par)
}
