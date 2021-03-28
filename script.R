library(jsonlite)

tmp <- list(
    id = "$FILE",
    title = "$TITLE",
    author = structure(list(name = "$AUTHOR"), class = "data.frame", row.names = 1L),
    type = "article",
    year = "$YEAR",
    journal = list(
        name = "Soosiana",
        shortcode = "Soosiana",
        id = "soosiana",
        identifier = structure(list(
            id = "0133-7971", type = "ISSN"), class = "data.frame", row.names = 1L),
        volume = "$VOLUME",
        pages = "$START--$END"),
    link = structure(list(
        url = "https://soosiana.github.io/content/$VOLUME/$FILE"),
        class = "data.frame", row.names = 1L),
    identifier = structure(list(type = "DOI", id = "$DOI",
                                url = "https://doi.org/$DOI"),
                           class = "data.frame", row.names = 1L),
    license = structure(list(type = "CC BY 4.0",
                             url = "https://creativecommons.org/licenses/by/4.0/",
                             description = "Attribution 4.0 International",
                             jurisdiction = "universal"),
                        class = "data.frame", row.names = 1L))

x1 <- read.csv("soosiana1.csv")
x2 <- read.csv("soosiana2.csv")
x12 <- rbind(x1, x2)
write.csv(x12,row.names=FALSE,file="soosiana.csv")
x <- x2

z <- x[!duplicated(x$Volume), c("Journal", "Volume", "Year")]
rownames(z) <- NULL
colnames(z) <- c("journal", "volume", "year")
z$url <- paste0("https://soosiana.github.io/volume-", z$volume, "/")
toJSON(z, pretty=TRUE)
writeLines(toJSON(z, pretty = FALSE, auto_unbox = TRUE), "docs/index.json")

rm <- ""
for (i in 1:nrow(z)) {
    nv <- paste0("[Soosiana Volume ", z$volume[i], ", ",
                 z$year[i], "](", z$url[i], ")\n")
    rm <- c(rm, nv)
}
writeLines(rm, "docs/README.md")


vols <- unique(as.character(x$Volume))
names(vols) <- vols
vals <- as.integer(sapply(strsplit(vols, "-"), "[[", 1L))
vols <- vols[order(vals)]
#vols <- rev(vols)

for (vol in vols) {
    cat(vol, "\n")
    xx <- droplevels(as.data.frame(x[x$Volume==vol,]))
    out <- list()
    f <- file.path("docs", vol, paste0(xx$File, ".pdf"))
    OK <- file.exists(f)
    if (!all(OK))
        stop("Files not found:\n", paste(f[!OK], "\n"))

    toc <- ""
    for (i in 1:nrow(xx)) {
        p <- tmp
        p$year <- as.character(xx[i,"Year"])
        p$id <- as.character(xx[i,"File"])
        p$title <- as.character(xx[i,"Title"])

        p$journal$volume <- as.character(xx[i,"Volume"])
        p$journal$pages <- paste0(xx[i,"Start"], "--", xx[i,"End"])
        if (is.na(xx[i,"DOI"])) {
            p$identifier$id <- ""
            p$identifier$url <- ""
        }
        a <- xx[i,"Authors"]
        if (is.na(a) || a == "") {
            a <- ""
        } else {
            a <- strsplit(as.character(xx[i,"Authors"]), ";")[[1L]]
        }
        a0 <- a
        a <- data.frame(name=a)
        rownames(a) <- NULL
        p$author <- a
        p$link <- paste0("https://soosiana.github.io/volume-",
                         as.character(xx[i,"Volume"]), "/",
                         as.character(xx[i,"File"]), ".pdf")
        out[[i]] <- p

        n <- if (any(a0 == "")) {
            paste0(
                p$title,
                ". _", p$journal$name, "_, **",
                p$journal$volume, "**: ",
                p$journal$pages, ". [PDF](",
                p$link, ")\n\n"
            )
        } else {
            paste0(
                paste0(a0, collapse=", "),
                ", ", p$year, ". ",
                p$title,
                ". _", p$journal$name, "_, **",
                p$journal$volume, "**: ",
                p$journal$pages, ". [PDF](",
                p$link, ")\n\n"
            )

        }
        toc <- c(toc, n)
    }


    u <- c(paste0("# Soosiana Volume ", vol, ".\n\n",
                "> Hungarian Malacological Journal\n\n",
                "## Contents\n\n"),
                toc, "\n")

    writeLines(toJSON(out, pretty = FALSE, auto_unbox = TRUE),
               paste0("docs/", vol, "/index.json"))
    writeLines(u, paste0("docs/", vol, "/README.md"))
}

if (FALSE) {

## splitting vol 32
library(pdftools)

xx <- droplevels(as.data.frame(x[x$Volume=="32",]))
xx$Start <- as.integer(as.character(xx$Start))
xx$End <- as.integer(as.character(xx$End))

pdf_subset("soos.pdf", 1:8, "docs/32/01_Soosiana_2013_32_1-6.pdf")
for (i in 2:nrow(xx)) {
    pdf_subset("soos.pdf", (xx$Start[i]:xx$End[i])+2L,
               paste0("docs/32/", as.character(xx$File[i]), ".pdf"))
}

}


## OCR

library(tesseract)

library(tesseract)
hun <- tesseract("hun")
toc <- "~/Documents/soosiana/26/toc.png"
text <- tesseract::ocr(toc, engine = hun)
cat(text)

