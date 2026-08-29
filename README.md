# ohw26_model_downsampling

This project is exploring the CANESM2 model performance relative to observations made in the region around St. Mary's Bay (Digby County) in Eastern Canada.

**Folder Structure**

* `contributor_folders` (optional) Each contributor can make a folder here and 
push their work here during the week. This will allow everyone to see each others work but prevent any merge conflicts. It is good if participants are new to collaborative coding.
* `final_notebooks` When the team develops shared final notebooks, they 
can be shared here. Make sure to communicate so that you limit merge conflicts.
* `scripts` Shared scripts or functions can be added here.
* `data` Shared dataset can be shared here. Note, do not put large datasets on GitHub. Speak to the organizers if you 
need to share large datasets. Each team member can have a version of the dataset locally in the same folder to 
preserve relative paths, but the dataset does not need to be added to git/GitHub (you can use `.gitignore`).

## Collaborators

| Name                | Role/tasks of interest | GH Handle |
|---------------------|---------------------|-----------|
| Danielle Dempsey     | ADCP vs FVCOM | @dempsey-CMAR |
| Falzan Hague      | Gridding and EDA | @FaizanHaque |
| Aaron Mau       | Historical obs. vs CMAR | @klankers |
| Rachel Woodside       | Extract FVCOM w/ overlapping variables | @rachelwoodside |


## Planning

* Initial idea: "we have a model run, what does it look like against the various observations made there? If we were to rerun the model with fewer or more data points, what would happen?"
* Ideation Slide: [Link](https://docs.google.com/presentation/d/1_KLEDpLLvtKpH3awDlZRAiOKuHzbEti4CWmhEykuCG8/edit?slide=id.g3f85357d4e2_7_0#slide=id.g3f85357d4e2_7_0)
* Slack channel: ohw26_model_downsampling
* Final presentation: [Link](https://docs.google.com/presentation/d/1AWgq7BNeF90E--sdQYpEGv6aMrgwxQDI6shM-3RuwSM/edit?usp=sharing)

## Background

A circulation model was run for data from 2017-2018 in the Bay of Fundy. A nice aspect of the model is how high the resolution is. However, it also creates challenges when collaborating, as the data size can be a little overwhelming. When narrowing down a focus area, namely [St. Mary's Bay](https://en.wikipedia.org/wiki/St._Marys_Bay,_Nova_Scotia), it's clear that we want to trim out the majority of the model's geographic extent and simplify to a single variable: Temperature.

Contrast this with the [relatively sparse observations in the area](https://explore.cioos.ca/?lat=44.354407178115565&lon=-66.14962611228577&zoom=9.234117507629128&lang=en). St. Mary's Bay and the Bay of Fundy are relatively undersampled when compared to the Gulf of St. Lawrence to the north. Of these observations, some of the most consistent are the [moorings set up by CMAR](https://cmar.ca/coastal-monitoring-program/). Some reasons could be related to:

1. Some of the most intense tides in the world
2. Active shipping lanes coming from St. John
3. Seasonal trawling, which requires sensor movement

This puts St. Mary's Bay at risk of being underrepresented in the regional model. After all, if there are no observations, how do we know if the model is getting it right?

## Goals

Our initial goals were as follows:
* Assess the performance of the model by comparison with in-situ observations
* Refine the performance of the model by integrating in-situ observations
  * Interpolation methods?
  * Statistical versus dynamic downscaling?

However, time constraints limited our work to just the first bullet point. Could we reduce the size of our model product down to something that is easily shared amongst one another, and could we then overlay the observations in such a way that they are comparable to our modeled output?

## Datasets

* CMAR week-averaged mooring observations
* FVCOM model run for the Bay of Fundy and St. Mary's Bay

Other datasets were explored/considered from CIOOS, but they weren't collected by CMAR and therefore were less familiar to our group.
* BIO/DFO CTDs (2009)
* Fisheries and Oceans Canada Coastal rosette casts (2009)
* Fisheries and Oceans Canada Moored timeseries (1994, 2013)
* Historical DFO/MEDS buoy data (1977-1979)
* Canadian Atlantic Shelf Temperature-Salinity (CASTS) (1912-2024)

## Workflow/Roadmap

## Results/Findings

## Lessons Learned

## References

