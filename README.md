# Data and Code for improved interfaces paper

## Name
Data and Code for the paper title "Improved imaging interfaces on a co-registered ultrasound and optical microscopy multiscale system". This paper can be found here: TBD

## Description
This code and data is everything one would need to reproduce all analysis and figures done in the paper listed above. 


## Installation
The code can be dowloaded directly from the GitLab page. The repository can also be cloned using Git by running (in command line) 
git clone https://github.com/uw-loci/data-and-code-for-improved-interface-paper.git

The data is stored separately in Box and needs to be downloaded and placed in the same cloned repository. The link to the data is here: https://uwmadison.box.com/s/gyyfsvak3el7qf8usazbsvdqspx0dwb9
Download the folder "Data" and place it in the same github repo folder. The only folders in the github repo should then be called "Code" and "Data". 

The code is written in Matlab, so an installation of Matlab is required to run the code. Matlab version >= 2020a is recommended. Each matlab live script is intended to be run when the 'current folder' is the folder where the live script is found. If there are issues with running the live script, I would check if the current folder is set to the right folder.

The FieldII simulations have a dependency that will need to be installed manually. Navigate to https://field-ii.dk// and go to the downloads page and download the FieldII release for your system. Place the unzipped FieldII code into the folder data-and-code-for-improved-interfaces-paper/Code/US_clutter_code/Utility_functions. This should allow the FieldII simulations found in 'field_ii_l22_14 normal.mlx' and 'field_ii_l22_14 - one-third-pitch.mlx' to run. 

## Usage
Most of the code is matlab live scripts. You should be able to open the scripts and run the cells in the live script. Again, make sure the matlab current folder is the folder where the matlab live script is found. 

## Support
Any questions can be directed to Jonathan Hale at jhhale@wisc.edu

## Authors and acknowledgment
FieldII was used in this project. 

[1] J.A. Jensen: Field: A Program for Simulating Ultrasound Systems, Paper presented at the 10th Nordic-Baltic Conference on Biomedical Imaging Published in Medical & Biological Engineering & Computing, pp. 351-353, Volume 34, Supplement 1, Part 1, 1996.

[2] J.A. Jensen and N. B. Svendsen: Calculation of pressure fields from arbitrarily shaped, apodized, and excited ultrasound transducers, IEEE Trans. Ultrason., Ferroelec., Freq. Contr., 39, pp. 262-267, 1992.


