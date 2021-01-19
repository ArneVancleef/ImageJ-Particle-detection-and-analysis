# ImageJ-Particle-detection-and-analysis
An automated imageJ macro which can be used to detect and measure the size of particles in images, maps of images or videos

This code will detect and measure particles in an image as long as they have a defined perimeter and do not touch too many other particles. 

Read me

In order to run the macro, copy the code (name: MacroU-Vxx) and go to imageJ -> plugin -> new -> Macro. Then paste the code here and press run.

After running the code a window will appear with analysis settings, here the settings have to be adjusted for the desired analysis. 
Once the desired settings are set press ok to process the images. An overview of all settings is given below:
Note that there are certain plugins this macro depends on in order to run, information on how to download these can be found in the first lines of the macro code itself.

1. Scale 
The scale in pixels/µm is necessary for pixel calibration! The correct scale can be found using an image of an object micrometer and going to Analyze ? Set scale

2. file type
This is the type of file that has to be analyzed, there are 4 options: 
- Preview: preview will analyze the open image (one image) in imageJ and shows the particle detection, ideal for setting up the analysis. Press ok in order to see the preview. 
- Map of videos: With this setting a map of videos will be anayzed after pressing ok. make sure map only contains videos. Only available video format is .avi. 
	Analysis will be performed in the background. Two maps will be made in the same map for each video analyzed. one with input images, this can be removed after analysis. 
	The other map will contain the output, which include the analyzed images, the results file, the summary file and settings of the analysis. 
	A window will appear after pressing ok to select the desired analysis map.  
- Single image: One open image is analyzed. note, D4.3, D3.2 and D1.0 will not be calculated in the summary for these measurements. 
- Map with maps of images. With this setting a map that contains maps of images will be analyzed, (not a map with images, a map with maps of images!) the output will be placed in the same maps as the original maps. works the same as the map of videos. 

3. background
This is the method that is used to subtract the background from the image. 3 methods exist for this: 
- Rolling ball background subtraction: with this method the computer generates a background from the original image
- Background image is open: A background image is open manually or by another way and is open in imageJ during the whole analysis. 
- Median method: a background image is constructed from multiple frames by taking the median of each pixel value. This method only works for map of videos or map with maps of images. This method also removes scratches or stuck aparticles on top of uneven lighting. 

4. Edge detection threshold
This is the high threshold for the edge detection, the most important threshold, the higher this threshold the sharper a particle must be before being detected. 3 is a good starting value for most images (with a edge detection smoothing of 2 and sharpening of 0.40). If not enough particles are detected: increase threshold, if too much particles are detected, reduce threshold. 

5. Low detection threshold
This is the low threshold for the canny edge detection, pixels between high and low are only seen as particles if they connect ends of pixels above the high threshold. A good starting value is 1/3 or 1/2 of the high threshold. 

6. Edge detection smoothing.
This is the amount of smoothing during the canny edge detection, this should be a whole number and there is little reason to change this value. 

7. Edge detection sharpening. 
This is the amount of sharpening with an unsharp mask before the edge detection, if there are particles touching each other that should not be touching eachothet it can help to increase this value and decrease the threshold values. 

8. frames for background:
Only when using the median background method is this important. This is the amount of images that are used to construct a background image, 30 is a nice starting point. 

9. Use additional intensity thresholding
With this method checked an additional segmentation will be done by also applying the imageJ default threshold method. This is useful for when there are partly out of focus particles and as a extra method to connect the outlines of particles. When there are a lot of particles out of focus, or when the particles are very transparant or have a brighter inside than the background than this method can cause difficulties. 

10. Use only additioanl intensity thresholding, 
For when the edge detection is not beneficial this method can be used, or for setting up the image analysis to see what the intensity thresholding measures. 

11. Gaussian blur
The gaussian blur can be used when the intensity thresholding causes a lot of single pixel noise, this are particles of which some pixels are not measured. 

12. Closing cycles after intensity thresholding
Not often used, only when there are very big agglomerates that have very unsharp edges it can help connect foreground zones of the intensity thresholding and the edge detection. 

13. Field of view correction factor
This is a correct factor that corrects for the chance a particle is removed at the edges. only for map of videos and map of maps of images. 

14. add scalebar to input
This functions adds a scalebar to the input after analysis. Output automatically has a scale bar. 

15. Show processing steps. 
This function is only for when analyzing a single image and shows the main processing steps and can be useful to find issues with the image

16. minimum size in pixels
This is the minimum size a particle can have, the size is defined as equivalent spherical diameter, but unit is in pixels.

17. maximum size in pixels
This is the maxmimum size a particle can have, the size is defined as equivalent spherical diameter, but unit is in pixels! 

18. Minimum particle circularity
This is the minimum circularity a particle can have to be detected.

19. maximum particle circularity
This is the maximum circularity a particle can have to be detected.

18. Watershed
checking this method will result in using the standard watershed (which watersheds everything)

19. Watershed for irregular particles
Checking this method will result in an advanced watershed based on the following input, note that if watershed is also checked then a normal watershed will be performed. 

20. Watershed IF erosion cycles: 
this is the amount of erosion cycles (in pixels) that are performed during a watershed, a seperator line cannot be longer than twice the erosion cycles

21. convexity threshold
If this value is above "0" the erosion cycles are ignored. Particles that have a convexity below this value are watershed, others are not. 
The convexity is the perimeter of the particle devided by the perimeter of the convex hull of the particle, which is the particle with the shortest perimeter that still contains the whole image.

22. Extended results: 
If this option is checked an additional summary file is added which gives for each measured image the amount of particles in a certain range (ex 10-20µm), works only with Field of view correction factor. 

Press ok then to perform the analysis. 

After running the code a summary file and a results file will be automatically saved (only when working with videos or maps of maps). 
The results file contains the data of each measured particles and can be pasted into the excel template in order to obtain the particle distribution and other parameters. 
The summary files gives the average values of particle counts, size etc. of each measured image. 

