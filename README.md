# Product-Basket
## Overview
This program calculates the total price of a basket of products and determines whether the delivery is free or not based on the basket's total value.
## Input Files
1- Basket List File (PANIER.txt):
- Contains the list of baskets.
- Each record includes a basket key.
2- Product List File (PANPRD.txt):
- Contains the list of products within each basket.
- Each record includes the basket key, product code, and product price.
## Output File
- Total per Basket File (SortiePanier.txt):
    - Contains the total price, number of products, and delivery status (free, paid, or canceled) for each basket.
## Delivery Conditions
- Delivery is free (G) for baskets with a total value exceeding 100€.
- For baskets with no products, delivery is canceled (A).
- For baskets with a total value less than 100€, delivery is paid (P), with a fixed delivery charge of 14.55€.
## Program Execution
1- Initialization:
- Open input and output files.
- Initialize variables, counters, and flags.
2- Processing:
- Read each basket and its associated products from the input files.
- Calculate the total price of each basket and determine the delivery status.
- Write the total price, number of products, and delivery status to the output file.
3- Completion:
- Close all files.
- Display summary information, including the number of input records, output records, and encountered errors.
- Terminate the program.
## File Handling
- Sequential file handling is used for input and output operations.
- File status codes (L-Fst-In1, L-Fst-In2, L-Fst-Out, L-Fst-Err) are used for error handling.
## Error Handling
- Errors encountered during file operations or processing are logged in the error file (SortieErreur.txt).
- Error messages include details of the erroneous records.
## Conclusion
This program provides a solution for calculating the total price of product baskets and determining delivery status based on predefined conditions. It efficiently processes input data, handles errors gracefully, and generates accurate output.
