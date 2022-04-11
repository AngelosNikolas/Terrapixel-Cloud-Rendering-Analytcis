# Performance evaluation of Terapixel rendering in Cloud (Super)computing

## The Project is utilizing the ProjectTemplate framework within R Studio see documentation here: http://projecttemplate.net/getting_started.html.

## Angelos Nikolas

### Background 
Terapixel images offer an intuitive, accessible way to present information sets to stakeholders, allowing viewers to interactively browse big data across multiple scales. The challenge we addressed here is how to deliver the supercomputer scale resources needed to compute a realistic terapixel visualization of the city of Newcastle upon Tyne and its environmental data as captured by the Newcastle Urban Observatory.

### Problems Explored
1. Which event types dominate task runtimes?
2. What is the interplay between GPU temperature and performance?
3. What is the interplay between increased power draw and render time?
4. Can we quantify the variation in computation requirements for particular tiles?
5. Can we identify particular GPU cards (based on their serial numbers) whose performance differs to other cards? (i.e. perpetually slow cards).
6. What can we learn about the efficiency of the task scheduling process?

### Basic instructions
1. Download the data https://newcastle-my.sharepoint.com/personal/nmf47_newcastle_ac_uk/_layouts/15/onedrive.aspx?id=%2Fpersonal%2Fnmf47%5Fnewcastle%5Fac%5Fuk%2FDocuments%2FTeraScope
2. Load the data into the data folder of project template.
3. Set the project template folder as working directory
4. Navigate to src open the analysis file and run the first 2 lines everything should be loaded in the environment.
5.The munge folder contains all the pre-processing, the reports folder have all the reports both markdown and pdf.


