# Bacterial Genome Size Analysis
#
# Research question:
# Is there a relationship between bacterial genome size
# and the number of protein-coding genes?
#
# Dataset:
# 200 complete bacterial genomes from BV-BRC
#
# Analysis:
# - Data acquisition and preprocessing
# - Exploratory data analysis
# - Correlation analysis
# - Linear regression
# - Model diagnostics
# - Outlier/influential observation analysis
#
# Author: Ali Moubed

library(httr2)
library(dplyr)
library(ggplot2)
library(plotly)
# ---------------------------------------------------------
# 1. Data acquisition
# ---------------------------------------------------------

url <- "https://www.bv-brc.org/api/genome/?eq(superkingdom,Bacteria)&eq(genome_status,Complete)&limit(200)&http_accept=text/csv"

response <- request(url) |>
  req_perform()

data <- read.csv(
  text = resp_body_string(response)
)

# ---------------------------------------------------------
# 2. Data preprocessing
# ---------------------------------------------------------
data$Genome_Mb <- data$Size / 1000000

mean_gc <- mean(data$GC.Content)

data <- data %>%
  mutate(Gc_label = ifelse(GC.Content >= mean_gc, "High" , "Low"))

data <- data %>%
  mutate(row_id = 1:nrow(data))

# ---------------------------------------------------------
# 3. Data visualization
# ---------------------------------------------------------

p <- ggplot(data, aes(x = Genome_Mb,
                     y = CDS,
                     col = Gc_label,
                     text = paste("Row:", row_id,
                                  "<br>Genome:", Genome.Name,
                                  "<br>Genome Size:", round(Genome_Mb, 2), "Mb",
                                  "<br>CDS:", CDS,
                                  "<br>GC Content:", round(GC.Content, 2), "%"))) +
  geom_point(size = 1.5) +
  theme_bw() +
  labs(
    title = "Genome Size and the Number of Protein-Coding Genes",
    x = "Genome Size (Mb)",
    y = "Number of CDS",
    col = "GC Content"
  )

ggplotly(p, tooltip = "text")

# ---------------------------------------------------------
# 4. Correlation analysis
# ---------------------------------------------------------
cor.test(data$Genome_Mb, data$CDS)

cor(data$Genome_Mb, data$CDS)

# ---------------------------------------------------------
# 5. Linear regression
# ---------------------------------------------------------
model <- lm(CDS ~ Genome_Mb, data = data)
summary(model)

plot(model)

# ---------------------------------------------------------
# 6. Influential observations
# ---------------------------------------------------------
sort(cooks.distance(model),decreasing = TRUE)[1:10]
