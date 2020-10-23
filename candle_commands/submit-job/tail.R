# ASSUMPTIONS: None

# Above you must return a number named "candle_value_to_return"

# Store the number candle_value_to_return as the val_loss "key" in a data.frame object called temp
temp <- data.frame( val_loss = candle_value_to_return)

# append two copies of the temp value to the data.frame
# with a different name
temp$val_corr <- temp$val_loss
temp$val_dice_coef <- temp$val_loss

# convert the temp to a list
temp <- as.list(temp)

# write temp as a JSON object
# and save it as temp1
temp1 <- toJSON(temp)

# write temp1 (JSON object) to a file
write(temp1, file = "candle_value_to_return.json")
