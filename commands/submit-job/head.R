# ASSUMPTIONS: In directory where params.json resides

# Call in code like 'candle_params[["k"]]'

# load jsonlite library
library(jsonlite)

# append $SUPP_R_LIBS to the R path
.libPaths( c( .libPaths(), Sys.getenv("CANDLE_SUPP_R_LIBS")) )

# load the parameters from the "params.json" file
candle_params <- fromJSON("params.json")
