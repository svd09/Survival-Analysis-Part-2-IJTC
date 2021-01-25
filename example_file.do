/* Survival Analysis - part 2. The Cox Proportional Hazards model.
Salil V Deo MD, Vaishali S Deo DCP DNB MPH, Varun Sundaram MD */





/* This is a do file to run a simple Cox model (CPH) using STATA
and present this as a supplement for the paper on CPH in the 
Indian Journal of Cardiothoracic Surgery.
The data = lung which contains 228 patients who underwent surgery 
for stage III lung cancer. The covariates of interest are age at surgery
and female sex. */

use "E:\\ICTVS_review_biostatistics\\surv2\\revision\\lung.dta", replace 

univar age

. univar age
                                        -------------- Quantiles --------------
Variable       n     Mean     S.D.      Min      .25      Mdn      .75      Max
-------------------------------------------------------------------------------
     age     228    62.45     9.07    39.00    56.00    63.00    69.00    82.00
-------------------------------------------------------------------------------

/* This provides the distribution of age in our data */



tab female


     female |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |        138       60.53       60.53
          1 |         90       39.47      100.00
------------+-----------------------------------
      Total |        228      100.00


/* Now that we have the variables that we are interested in entering into the model,
let now look at our survival information. For running the Cox model, we need the time period that 
each patient is followed-up for and their status (0 = censored, 1 = died). */

tab died

       died |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |         63       27.63       27.63
          1 |        165       72.37      100.00
------------+-----------------------------------
      Total |        228      100.00

/* As we can see, 165 patients died during the study period */

univar time


                                        -------------- Quantiles --------------
Variable       n     Mean     S.D.      Min      .25      Mdn      .75      Max
-------------------------------------------------------------------------------
    time     228   305.23   210.65     5.00   166.50   255.50   399.00  1022.00
-------------------------------------------------------------------------------

/* As the time is presented in days, we will convert that value into years, which is 
easier to understand */

gen time_years = time/365.24

univar time_years

                                        -------------- Quantiles --------------
Variable       n     Mean     S.D.      Min      .25      Mdn      .75      Max
-------------------------------------------------------------------------------
time_years     228     0.84     0.58     0.01     0.46     0.70     1.09     2.80
-------------------------------------------------------------------------------

/* Now that we have all the variables need to run the CPH model, in STATA we first need to stset
the data and declare it as survival data */

stset time_years, failure(died == 1)

   failure event:  died == 1
obs. time interval:  (0, time_years]
 exit on or before:  failure

------------------------------------------------------------------------------
        228  total observations
          0  exclusions
------------------------------------------------------------------------------
        228  observations remaining, representing
        165  failures in single-record/single-failure data
     190.54  total analysis time at risk and under observation
                                                at risk from t =         0
                                     earliest observed entry t =         0
                                          last observed exit t =   2.79816


/* As can be seen, all is set now for the CPH model. We will use age and female as the 
covariates in the model */

stcox age female, hr 

         failure _d:  died == 1
   analysis time _t:  time_years

Iteration 0:   log likelihood = -750.12202
Iteration 1:   log likelihood = -743.09465
Iteration 2:   log likelihood = -743.07965
Iteration 3:   log likelihood = -743.07965
Refining estimates:
Iteration 0:   log likelihood = -743.07965

Cox regression -- Breslow method for ties

No. of subjects =          228                  Number of obs    =         228
No. of failures =          165
Time at risk    =  190.5404664
                                                LR chi2(2)       =       14.08
Log likelihood  =   -743.07965                  Prob > chi2      =      0.0009

------------------------------------------------------------------------------
          _t | Haz. Ratio   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
         age |   1.017158   .0093802     1.84   0.065     .9989388     1.03571
      female |   .5989574   .1003026    -3.06   0.002      .431372    .8316487
------------------------------------------------------------------------------

/* Let us now consider the results and understand what the important terms here mean.
As we know, we have 228 subjects in the model out of which 165 died during the study period.
The total time included in the model is 190.54 years. This can be interpreted as the person-years
included in the model. 
The p-value for the entire model is provided above the regression results table. It is 0.0009.
Hence, we can conclude that our model is statistically significant at the 95% confidence level.
Now, lets look at the regression table.
The table provides the (1) name of the covariate (2) the hazard ratio (3) the standard error of the hazard ratio
(4) the z-score (5) the p-value for that covariate and (6) the confidence interval for the calculated hazard ratio.
From our table, we can conclude that both variables in our model significantly affect patient survival independent of each other. 
While a unit increase in age increases the risk of death,compared to males, female sex is associated with a lower risk for mortality.
While the presentation of results depends upon the statistical software used, all routine analytical programs will provide these
estimates. We may expect some minor changes between statistical packages; however, these are generally observed at the 3rd of 4th decimal
place and unlikely to meaningfully alter overall results. */

/* testing the proportional hazards assumption. */
/* testing the proportonal (PH) assumptions can be done in the following manner: */

estat phtest, detail


      Test of proportional-hazards assumption

      Time:  Time
      ----------------------------------------------------------------
                  |       rho            chi2       df       Prob>chi2
      ------------+---------------------------------------------------
      age         |     -0.02090         0.07        1         0.7851
      female      |      0.12535         2.52        1         0.1125
      ------------+---------------------------------------------------
      global test |                      2.65        2         0.2659
      ----------------------------------------------------------------

/* Using this command, we can get the test for PH assumptions. Here both p-values > 0.05 and global test p > 0.05.
Hence, we can assume that the PH assumption is met. More detailed graphical methods are available, however, they are 
beyond the scope of this presentation. We will discuss in a later paper what options are available when the PH assumption fails. */