[![CRAN\_Status\_Badge](https://www.r-pkg.org/badges/version/d3Tree)](https://cran.r-project.org/package=d3Tree)
[![Project Status: Active - The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/0.1.0/active.svg)](https://www.repostatus.org/#active) 
![downloads](http://cranlogs.r-pkg.org/badges/grand-total/d3Tree)

# Reactive shiny filters through collapsible d3js trees

## Overview

D3js is a great tool to visualize complex data in a dynamic way. But how can the visualization be part of the natural workflow? 

Creating new reactive elements through the integration of Shiny with d3js objects allows us to solve this problem.

Through Shiny we let the server observe the d3 <a href="https://bl.ocks.org/mbostock/4339083" target="_blank">collapsible tree library</a>  and its real-time layout. 

The data transferred back to Shiny can be mapped to a series of logial expressions to create reactive filters. 

This allows for complex data structures, such as heirarchal simulations, complex design of clinical trials and results from polycompartmental structural models to be visually represented and *filtered in a reactive manner* through an intuitive and simple tool.

