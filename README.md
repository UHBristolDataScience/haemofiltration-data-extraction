# haemofiltration_data_extraction
Data extraction and processing scripts. There are two scripts:

*haemofiltration_data_extraction_cjm.sql*
  * This is an exploratory script that was used to locate and then extract the required variables in the back end of ICCA. Some output of the exploratory queries are included as comments in the script.
  * Queries should be run individually in MSQL server by selecting to relevant text and pressing F5.
  * The main three select statements produce output that were saved to file for further processing in python (see below). To save to file right-click and select "Results to->File". (Also under options set the text delimiter to tab since some valueString outputs contain commas).
  
*Processing haemofiltration data.ipynb*
  * This is a Jupyter notebook (python script) for processing the data extracted from ICCA.
  * This notebook uses the powerful Pandas library to manipulate the data.
  * The notebook should render online in github allowing you to view the script in your browser (you may sometimes get a message "Sorry, something went wrong. Reload?" when github is having a bad time).
  * Comments inline explain the main functions of the script.
  
  
Questions and comments to: chris.mcwilliams@bristol.ac.uk
