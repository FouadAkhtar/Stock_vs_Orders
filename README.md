# Stock Vs Orders

# Project Documentation: Analyzing Monthly Sales and Stock Updates for Multiple Shops

## Introduction:
This project involved a comprehensive analysis of monthly sales data for numerous shops, focusing on the relationship between stock Stock updates and the number of orders. The objective was to provide actionable insights to shop managers, utilizing a combination of data processing, visualization, and automated reporting.

## Data Collection and Preparation:
Data was sourced from multiple APIs, each representing different tables. The data was combined using join methods, cleaned for quality, and underwent transformations to ensure compatibility for analysis.

## Data Processing:
R and loops were employed to process each shop's data, generating over 100 unique ggplots that showcased sales and Stock trends.

## Automated Report Generation:
Personalized PDF reports were created for each shop, incorporating details such as shop name, manager names, title, contact details, emails, and mobile numbers. The reports were stored in a designated folder, and their paths were converted using loops for direct referencing.

## R Markdown Document Creation:
A markdown document was utilized to compile a detailed analysis report. Information from the Excel sheet, including shop names, manager names, and contact details, was dynamically retrieved. The document included a full description of the analysis, statistical measures, and insights gained.

## Communication Channels:

### 1. Email Communication:
   - **Email Address Import:**
     - Utilized Excel sheet data for accurate extraction of shop managers' email addresses.
   - **Loop Method for Sending Emails:**
     - Employed loops to send personalized emails to shop managers sequentially.
     - Each email included a personalized subject, content, and attachment of the respective PDF report.
   - **Attachment of PDF Reports:**
     - Dynamically attached the corresponding PDF report to each email, ensuring individualized communication.

### 2. WhatsApp Communication:
   - **Mobile Number Retrieval:**
     - Extracted mobile numbers from the Excel sheet for each shop manager.
   - **Loop Method for Sending WhatsApp Messages:**
     - Utilized loops to send personalized messages to shop managers via WhatsApp sequentially.
     - Messages included a brief description of the analysis along with a link or attachment to the PDF report.
   - **Enhanced Personalization:**
     - Tailored each WhatsApp message to the individual shop manager for enhanced personalization.

### 3. Efficiency and Sequencing:
   - **Sequential Sending:**
     - Ensured a sequential and systematic approach in both email and WhatsApp communication.
     - Prevented simultaneous sending for efficiency and to avoid potential issues.
   - **Feedback Mechanism:**
     - Implemented a feedback mechanism to track the success of each communication.
     - Verified successful email deliveries and received WhatsApp messages to ensure effective communication.

### 4. Scalability and Robustness:
   - **Handling Large Datasets:**
     - Demonstrated scalability by efficiently handling a large dataset of shop information.
     - Ensured robust communication channels capable of handling over 100 shops seamlessly.
   - **Error Handling:**
     - Incorporated error-handling mechanisms in the loops for both email and WhatsApp communication.
     - Addressed potential issues to maintain the reliability of the communication process.

## Conclusion:
This project showcases the integration of data analysis, visualization, and automated reporting, providing actionable insights to shop managers. The use of email and WhatsApp for communication enhances the project's impact, making it a valuable addition to my portfolio.

## Appendix:

[Stock Update vs Order Report (Updated).pdf](https://github.com/FouadAkhtar/OrdersVsInventory/files/13998705/Stock.Update.vs.Order.Report.Updated.pdf)

