library(moments)

student_id <- 5146
set.seed(student_id)

number_of_samples <- 10000
sample_sizes <- c(16, 30, 45, 100)

old_par <- par(mfrow = c(2, 2))

for (n in sample_sizes) {
  sample_means <- replicate(number_of_samples, mean(rexp(n, rate = 1)))
  
  qqnorm(sample_means,
         main = paste("n =", n, "  skew =", round(skewness(sample_means), 2)),
         pch = 16, cex = 0.3, col = "steelblue")
  qqline(sample_means, col = "firebrick", lwd = 2)
}

par(old_par)