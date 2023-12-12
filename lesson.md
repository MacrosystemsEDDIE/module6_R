# Macrosystems EDDIE Module 6: Understanding Uncertainty in Ecological Forecasts

## Summary
**Ecological forecasting** is a tool that can be used for understanding and predicting changes in populations, communities, and ecosystems. Ecological forecasting is an emerging approach which provides an estimate of the future state of an ecological system with uncertainty, allowing society to prepare for changes in important ecosystem services. Forecast **uncertainty** is derived from multiple sources, including model parameters and driver data, among others. Knowing the uncertainty associated with a forecast enables forecast users to evaluate the forecast and make more informed decisions. Ecological forecasters develop and update forecasts using the iterative forecasting cycle, in which they make a hypothesis of how an ecological system works; embed their hypothesis in a model; use the model to make a forecast of future conditions and quantify forecast uncertainty; and update the forecast when new data is available. There are a number of approaches that forecasters can use to reduce uncertainty, which will be explored in this module.  
  
This module will guide you through an exploration of the sources of uncertainty within an ecological forecast, how uncertainty can be quantified, and steps which can be taken to reduce the uncertainty in a forecast you develop for a lake ecosystem.  
  
## Learning Outcomes
1. Define ecological forecast uncertainty.  
2. Explore the contributions of different sources of uncertainty (e.g., model parameters, model driver data) to total forecast uncertainty. 
3. Understand how multiple sources of uncertainty are quantified. 
4. Identify ways in which uncertainty can be reduced within an ecological forecast. 
5. Describe how forecast horizon affects forecast uncertainty. 
6. Explain the importance of specifying uncertainty in ecological forecasts for forecast users and decision support. 
  
## Key Concepts

**What is ecological forecast uncertainty?**. 
  
Forecast uncertainty is the range of possible alternate future conditions predicted by a model. We generate multiple different predictions of the future because the future is inherently unknown.    
  
**Where does ecological forecast uncertainty come from?**
  
Uncertainty comes from natural variability in the environment, imperfect representation of an ecological system in a model, and error when measuring the system. When generating a forecast, uncertainty can come from the structure of the model used, the initial conditions of the model, the parameters of the model, and the data used to drive the model, among other sources. 
  
**Why is uncertainty important to quantify for an ecological forecast?**. 
  
Knowing the uncertainty in a forecast allows forecast users to make informed decisions based on the range of forecasted outcomes and prepare accordingly.  
  
## Overview
In this module, we will generate forecasts of lake water temperature for 1-7 days into the future. First, we will generate a **deterministic** forecast (with no uncertainty). This will involve the following steps:  
  
1. Read in and visualize data from Lake Barco, FL, USA. 
2. Read in and visualize an air temperature forecast for Lake Barco. 
3. Build a multiple linear regression forecast model. 
4. Generate a deterministic forecast (without uncertainty). 
  
Next, we will explore how to incorporate four different kinds of uncertainty that are commonly present in **probabilistic** forecasts: driver data uncertainty, parameter uncertainty, process uncertainty, and initial conditions uncertainty. We will generate forecasts that incorporate these sources of uncertainty one at a time to learn how each form of uncertainty is accounted for. This will involve the following steps:  
  
5. Generate a forecast with driver uncertainty. 
6. Generate a forecast with parameter uncertainty. 
7. Generate a forecast with process uncertainty. 
8. Generate a forecast with initial conditions uncertainty. 

Finally, we will put it all together to generate a forecast that incorporates all four sources of uncertainty. We will also explore the relative contributions of each source of uncertainty to total forecast uncertainty; this is known as **uncertainty partitioning**. This will involve the following steps:  
  
9. Generate a forecast incorporating all sources of uncertainty. 
10. Partition uncertainty.  
  
Example code is provided for steps 1-5, and you will be asked several short answer questions to interpret code output. Beginning in step 6, you will be guided to build on the module code by adjusting example code or developing your own code. The coding questions will build in difficulty and the amount of guidance provided will decrease as you progress from step 6 to step 10. Keep in mind that the example code is provided to help you, and use as much of it as you can in completing the questions embedded in steps 6-10. There are a total of 16 questions. Please see the module rubric for possible points per question and confirm with your instructor whether and how the module will be graded.  

## Feedback

<https://github.com/MacrosystemsEDDIE/module6_R/issues>


## Instructions
  - Attend the introductory PowerPoint lecture provided by your instructor; slides may be downloaded [here](https://d32ogoqmya1dw8.cloudfront.net/files/eddie/teaching_materials/modules/instructors_powerpoint_16626467611382673378.pptx)
  - Open the notebook `assignment/module6_assignment.Rmd` in RStudio
  - Work through the exercises described in the notebook.
  - `knit` + commit output files to GitHub

## Context

This module contains code to reproduce the basic functionality of "Macrosystems EDDIE Module 6: Understanding Uncertainty in Ecological Forecasts", found at https://serc.carleton.edu/eddie/teaching_materials/modules/module6.html. The code can be used by students to better understand what is happening "under the hood" of the Module 6 Shiny app, which can be found at the following link:  
https://macrosystemseddie.shinyapps.io/module6/. 
  
Alternatively, students can complete this version of the module instead of the Shiny app version.  

## Timeframe

2 75-minute class periods are allocated to this module

## Background Reading
  
Optional pre-class readings and videos:  
  
**Articles:**  
  
1. Silver, N. (2012) Chapter 6: How to drown in three feet of water. Pages 176-203 in The Signal and the Noise: Why so many Predictions Fail – but some Don't. Penguin Books.  
2. Dietze, M., & Lynch, H. (2019). Forecasting a bright future for ecology. Frontiers in Ecology and the Environment, 17(1), 3. https://doi.org/10.1002/fee.1994. 
3. Dietze, M. C., Fox, A., Beck-Johnson, L. M., Betancourt, J. L., Hooten, M. B., Jarnevich, C. S., Keitt, T. H., Kenney, M. A., Laney, C. M., Larsen, L. G., Loescher, H. W., Lunch, C. K., Pijanowski, B. C., Randerson, J. T., Read, E. K., Tredennick, A. T., Vargas, R., Weathers, K. C., & White, E. P. (2018). Iterative near-term ecological forecasting: Needs, opportunities, and challenges. Proceedings of the National Academy of Sciences, 115(7), 1424–1432. https://doi.org/10.1073/pnas.1710231115 
  
**Videos:**

1. NEON's [Ecological Forecast: The Science of Predicting Ecosystems](https://www.youtube.com/watch?v=Lgi_e7N-C8E&t=196s&pbjreload=101)  
2. Fundamentals of Ecological Forecasting Series
      - [Why Forecast?](https://www.youtube.com/watch?v=kq0DTcotpA0&list=PLLWiknuNGd50Lc3rft4kFPc_oxAhiQ-6s&index=1)
      - [Uncertainty Analysis](https://www.youtube.com/watch?v=rDCkjzVQNSw&list=PLLWiknuNGd50Lc3rft4kFPc_oxAhiQ-6s&index=12)
  
## References
  
This module is derived from Moore, T. N., Carey, C.C. and Thomas, R. Q. 13 October 2021. Macrosystems EDDIE: Understanding Uncertainty in Ecological Forecasts. Macrosystems EDDIE Module 6, Version 1. http://module6.macrosystemseddie.org. Module development was supported by NSF grants DEB-1926050 and DBI-1933016.  
  
-   author: Mary Lofton (@melofton)
-   contact: [melofton\@vt.edu](mailto:melofton@vt.edu)
-   url: https://serc.carleton.edu/eddie/teaching_materials/modules/module6.html
-   date: 2023-12-12
-   license: MIT, CC-BY
-   copyright: Mary Lofton

