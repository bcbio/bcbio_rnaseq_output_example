context("Reports")
library(rmarkdown)
library(bcbioRNASeq)

unlink("report", recursive = TRUE)

uploadDir <- tools::file_path_as_absolute(file.path("."))
print(uploadDir)
library(bcbioRNASeq)
bcb <- loadRNASeq(
    uploadDir,
    interestingGroups = c("group"),
    organism = "Homo sapiens"
)

dir.create("report")
setwd("report")

saveData(bcb, dir = "data")

outputDir <- tools::file_path_as_absolute(file.path("."))

extraDir <- system.file("extra", package = "bcbioRNASeq")
miscDir <- file.path("..",  "..", "bcbioRNASeq",
                     "inst", "rmarkdown", "shared")

print(list.files(miscDir, full.names = TRUE))
file.copy(list.files(miscDir, full.names = TRUE), ".",
          overwrite = TRUE, recursive = TRUE)

test_that("qc", {
    reportDir <- file.path("..", "..", "bcbioRNASeq",
                           "inst", "rmarkdown",
                           "templates", "quality_control",
                           "skeleton")
    file.copy(file.path(reportDir, "skeleton.Rmd"), "qc.Rmd", overwrite = TRUE)
    render("qc.Rmd", params = list(bcb_file = "data/bcb.rda",
                                   results_dir = outputDir))
})

test_that("de", {
    reportDir <- file.path("..",  "..", "bcbioRNASeq",
                           "inst", "rmarkdown",
                           "templates", "differential_expression",
                           "skeleton")
    file.copy(file.path(reportDir, "skeleton.Rmd"), "de.Rmd", overwrite = TRUE)
    render("de.Rmd", params = list(bcb_file = "data/bcb.rda",
                                   design = formula(~group),
                                   contrast = c("group", "ctrl", "ko"),
                                   results_dir = outputDir))
})

# test_that("fa", {
#     reportDir <- file.path("..",  "..", "bcbioRNASeq",
#                            "inst", "rmarkdown",
#                            "templates", "functional_analysis",
#                            "skeleton")
#     file.copy(file.path(reportDir, "skeleton.Rmd"), "fa.Rmd", overwrite = TRUE)
#     render("fa.Rmd", params = list(bcbFile = "data/bcb.rda",
#                                    outputDir = outputDir))
#
# })


load("data/bcb.rda")
print(bcb)

setwd("..")
