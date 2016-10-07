[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.154536.svg)](https://doi.org/10.5281/zenodo.154536)


## GeoDataMATLAB
![alt text](https://raw.github.com/jswoboda/GeoDataMATLAB/master/logo/logo1.png "GeoDataMATLAB")
#Overview
This is the repository for the MATLAB version of GeoData to plot and analyze data from geophysics sources such as radar and optical systems.

#Installation
To install first clone repository:

	$ git clone https://github.com/jswoboda/GeoDataMATLAB.git
	
The user should then start MATLAB	 and go to the folder containing the code. 

The software package can be installed in MATLAB by running setup.m, which will add the tools to the MATLAB path. The user can specify they’re developing the toolbox further by adding the string “develop” as the second argument. This will create a directory Test that will be added within the main GeoData directory. This folder will not be added to the path to allow the user to test new functions. There is also an option to create a new path file that can be saved where ever the user wants. It is suggested that this is saved in the MATLAB folder in the user's Documents directory.

~~~matlab
cd GeoData 
setup('permanent','develop'); % perminately saves path and creates test directory.
setup('permanent','develop',' ~/Documents/MATLAB'); % perminately saves path and creates test directory.

~~~

#Software Structure

The code is broken up into three main directories: Main, Utilities and Reading. Main holds code related to the GeoData class such as the class def file and any other functions that directly use or impact the class. The folder Utilities holds code related to functions that would be used to support the class such as coordinate transforms. Lastly the Reading directory is to be used to store functions that will be used to read in data from new data types.

#Style Guide
This style guide will cover conventions and elements specific to this codebase. For more general tips on proper MATLAB style guidelines see The Elements of MATLAB Style by Richard K. Johnson.


The code to read in data will be within functions and output the class data variables in an order shown in the code. These read functions will be placed in the Reading folder and be within a specific file. The names of the functions will start with read_ and then followed by a descriptive name.

Code to impact the class will be placed in the class def file. For example if it is desired to interpolate the data to a different set of coordinates this should be implemented as a method in the class. The code for doing this can be written outside of the class def file if needed but this should only be done to keep the code neat.

The properties names will be all lower case. While all function names will be lower case with _ to separate words. The classes will be have capitalized words with no spaces. Directories will be capitalized with _ to separate words.

If the user would like to create test code please do this in the Test folder. Also this code is not be uploaded to the main code base on GitHub. 

#Workflow
The GeoData take advantage of a standardized structure of data to give the user access to the avalible tools. It's built off of container class where each instances is a specfic data set. In all cases the user needs to put their data in this structure. This first task will require a line of code similar to the following to start the process,

~~~matlab
Geo = GeoData(@readfunction,input1,input2 ...)
~~~
The @readfunction is a function handle, a MATLAB pointer to a function, that can read the data from its previous format to the one specified by GeoData. The terms input1, input2 are what ever inputs are required by the read function to work. 

Once the data set is now in the proper format the user can go about augmenting it in a number of ways. The user can augment the values and labeling of the data sets by using the changedata method built into the class. Interpolation methods are avalible in the class to change the coordinate system or simply regrid it in the current system. The size of the data set can be reduced by applying methods to filter out specfic time and data points. A time registration method is also avalible where it will take as input a second instance of the class and determine what measurements overlap in time with the original instance.

At this point the user can plot their results. Each of the plotting tools are set up in different functions in the Plotting folder. These plotting tools will output handles to figures that we plotted along with handles to colorbars if included. 

Examples
--------
To run these examples, you need the data files in the Google Drive [GeoDataTest folder](https://drive.google.com/drive/folders/0B37DfeCiFYMgaWlObkhpOHFSRXM?usp=sharing). 
Ask the authors for access to these files, which have not been included in the repo to save space.
