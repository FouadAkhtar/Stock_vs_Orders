# Install and load the required libraries
if (!requireNamespace("sendmailR", quietly = TRUE)) {
  install.packages("sendmailR")
}

library(sendmailR)

# Data frame with shop information
shop_info <- data.frame(
  shop_name = c("Shop1", "Shop2", "Shop3"),
  manager_name = c("John Doe", "Jane Doe", "Alice"),
  mobile_number = c("1234567890", "9876543210", "5555555555"),
  email = c("john@example.com", "jane@example.com", "alice@example.com"),
  image_name = c("ZUE.png", "XYZ.png", "ABC.png")
)

# Loop through each row in the data frame
for (i in seq_len(nrow(shop_info))) {
  # Shop information
  shop_name <- shop_info$shop_name[i]
  manager_name <- shop_info$manager_name[i]
  mobile_number <- shop_info$mobile_number[i]
  email_address <- shop_info$email[i]
  image_name <- shop_info$image_name[i]
  
  # Generate PDF as in the previous example
  rmd_file <- "monthly_stockVsorders_master.rmd"
  rmd_content <- readLines(rmd_file, warn = FALSE)
  rmd_content <- gsub("Partner", shop_name, rmd_content)
  rmd_content <- gsub("<!--IMAGE_PLACEHOLDER-->", paste0("![](`r file.path(getwd(), '", image_name, "')`)"), rmd_content)
  
  temp_rmd_file <- tempfile(fileext = ".rmd")
  writeLines(rmd_content, temp_rmd_file)
  
  rmarkdown::render(temp_rmd_file, output_format = "html_document")
  
  output_pdf <- paste0(tools::file_path_sans_ext(temp_rmd_file), ".pdf")
  pagedown::chrome_print(paste0(tools::file_path_sans_ext(temp_rmd_file), ".html"), output = output_pdf)
  
  unlink(temp_rmd_file)
  
  # Send Email
  subject <- paste("Monthly Report for", shop_name)
  body <- paste("Dear", manager_name, ",\n\nPlease find the attached monthly report for", shop_name, ".\n\nRegards,\nYour Company")
  
  sendmail(
    from = "myemail@example.com",
    to = email_address,
    subject = subject,
    body = body,
    smtp = list(
      host.name = "smtp.email-provider.com",
      user.name = "email@email.com",
      passwd = "password",
      port = 465,
      ssl = TRUE
    ),
    attach.files = output_pdf
  )
  
  # Send WhatsApp Message
  # You would need to use a third-party API service for WhatsApp messaging
  # (Please note: WhatsApp has policies on automated messaging, and you need to comply with them)
  
  # Sleep for a short duration between messages to avoid rate limits
  Sys.sleep(5)
}