#' Diagnostical Statistics
#' 
#' Functions to access diagnostical statics in a \code{"seas"} object. More 
#' statistics can be calculated with standard R functions (see examples). For 
#' accessing the complete output of X-13ARIMA-SEATS, use the \code{\link{out}} 
#' function. For diagnostical plots, see \code{\link{plot.seas}}.
#' 
#' @param x  object of class \code{"seas"}
#'   
#' @return  \code{qs} returns the QS statistics for seasonality of input and
#'   output series and the corresponding p-values.
#'   
#' @return \code{spc} returns the content of the \code{.spc} file, i.e. the 
#'   specification as it is sent to X-13ARIMA-SEATS. Analyzing the \code{spc} 
#'   output is useful for debugging.
#'   
#' @return \code{fivebestmdl} returns the five best models as chosen by the BIC 
#'   criterion. It needs the \code{automdl} spec to be activated (default). If it is not 
#'   activated, the function tries to reevaluate the model with 
#'   the \code{automdl} spec activated.
#'   
#' @return \code{arimamodel} retrurs the structure of a the ARIMA model, a 
#'   numerical vector of the form \code{(p d q)(P D Q)}, containing the 
#'   non-seasonal and seasonal part of the ARIMA model.
#'   
#' @seealso \code{\link{seas}} for the main function.
#' @seealso \code{\link{plot.seas}}, for diagnostical plots.
#' @seealso \code{\link{out}}, for accessing the full output of X-13ARIMA-SEATS.
#' 
#' @references Vignette with a more detailed description: 
#'   \url{http://cran.r-project.org/web/packages/seasonal/vignettes/seas.pdf}
#'   
#'   Wiki page with a comprehensive list of R examples from the X-13ARIMA-SEATS 
#'   manual: 
#'   \url{https://github.com/christophsax/seasonal/wiki/Examples-of-X-13ARIMA-SEATS-in-R}
#'   
#'   Official X-13ARIMA-SEATS manual: 
#'   \url{http://www.census.gov/ts/x13as/docX13AS.pdf}
#'   
#' @examples
#' \dontrun{
#' 
#' m <- seas(AirPassengers)
#' 
#' qs(m)
#' spc(m)
#' fivebestmdl(m)
#' arimamodel(m)
#' 
#' # if no automdl spec is present, the model is re-evaluated
#' m2 <- seas(AirPassengers, arima.model = "(0 1 1)(0 1 1)")
#' spc(m2)           # arima overwrites the automdl spec
#' fivebestmdl(m2)   # re-evaluation with automdl
#' 
#' # more diagnostical statistics with R functions
#' shapiro.test(resid(m))  # no rejection of normality
#' Box.test(resid(m), lag = 24, type = "Ljung-Box")  # no auto-correlation
#' 
#' # accessing the full output (see ?out)
#' out(m)
#' out(m, search = "Ljung-Box")
#' }
#' @export
qs <- function(x){
  x$qs
}


#' @rdname qs
#' @export
spc <- function(x){
  x$spc
}


#' @rdname qs
#' @export
fivebestmdl <- function(x){
  if (!is.null(x$fivebestmdl)){
    txt <- x$fivebestmdl[3:7]
    arima <- substr(txt, start = 19, stop = 32)
    bic <- as.numeric(substr(txt, start = 51, stop = 56))
    z <- data.frame(arima, bic, stringsAsFactors = FALSE)
  } else if (is.null(x$reeval)) {
    # if no fivebestmdl, try reevaluating with automdl
    lc <- as.list(x$call)
    lc$automdl <- list()
    lc$arima.model <- NULL
    rx <- eval(as.call(lc), envir = globalenv())
    rx$reeval <- TRUE  # avoid infinite looping
    z <- fivebestmdl(rx)
  } else {
    z <- NULL
  }
  z
}





#' @rdname qs
#' @export
arimamodel <- function(x){
  stopifnot(inherits(x, "seas"))
  str <- x$model$arima$model
  str <- gsub("[ \\(\\)]", "", str)
  z <- c(substr(str, 1, 1),
         substr(str, 2, 2),
         substr(str, 3, 3),
         substr(str, 4, 4),
         substr(str, 5, 5),
         substr(str, 6, 6)
  )
  as.numeric(z)
}

