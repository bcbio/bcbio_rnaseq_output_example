context("Reports")

library(rmarkdown)
library(bcbioRNASeq)

# R Markdown source templates from package
templates_dir <- system.file("rmarkdown/templates", package = "bcbioRNASeq")

bcb <- bcbioRNASeq(
    uploadDir = ".",
    interestingGroups = "group",
    organism = "Mus musculus"
)
print(bcb)

unlink("report", recursive = TRUE)
dir.create("report")
setwd("report")

prepareRNASeqTemplate(overwrite = TRUE)

data_dir <- normalizePath("data")
results_dir <- normalizePath(".")

bcb_file <- saveData(bcb, dir = data_dir)
res_file <- file.path(data_dir, "res.rda")

test_that("Quality Control", {
    file.copy(
        from = file.path(
            templates_dir,
            "quality_control",
            "skeleton",
            "skeleton.Rmd"
        ),
        to = "qc.Rmd",
        overwrite = TRUE
    )
    x <- render(
        input = "qc.Rmd",
        params = list(
            bcb_file = bcb_file,
            data_dir = data_dir,
            results_dir = results_dir
        )
    )
    expect_identical(basename(x), "qc.html")
})

test_that("Differential Expression", {
    file.copy(
        from = file.path(
            templates_dir,
            "differential_expression",
            "skeleton",
            "skeleton.Rmd"
        ),
        to = "de.Rmd",
        overwrite = TRUE
    )
    x <- render(
        input = "de.Rmd",
        params = list(
            bcb_file = bcb_file,
            design = formula("~group"),
            contrast = c("group", "ctrl", "ko"),
            data_dir = data_dir,
            results_dir = results_dir
        )
    )
    expect_identical(basename(x), "de.html")
})

test_that("Functional Analysis", {
    file.copy(
        from = file.path(
            templates_dir,
            "functional_analysis",
            "skeleton",
            "skeleton.Rmd"
        ),
        to = "fa.Rmd",
        overwrite = TRUE
    )
    x <- render(
        input = "fa.Rmd",
        params = list(
            bcb_file = bcb_file,
            res_file = res_file,
            organism = "Mm",
            gspecies = "mmu",
            species = "mouse",
            data_dir = data_dir,
            results_dir = results_dir
        )
    )
    expect_identical(basename(x), "fa.html")
})

setwd("..")
