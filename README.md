# ImageJ-Particle-detection-and-analysis
An automated imageJ macro which can be used to detect and measure the size of particles in images. The macro can be used to analyze single images, maps of images and videos.

This code will detect and measure particles in an image as long as they have a defined perimeter and do not touch too many other particles. 

Read me:

If you don't have imageJ, go to https://imagej.net/Fiji/Downloads to download it. 
Before the macro can be used a few plugins have to be installed, in order to instal these do the following: 
go to imageJ toolbar → help → update... after a short while the "imageJ updated" will appear, press the button "manage update sites" in the left bottom corner. 
In the "manage update sites" select BioVoxxel, biomedgroup, ImageScience, and Morphology then close manage update site and then press apply changes. After updating restart imageJ. 

Now the code can be run by going to imageJ -> plugin -> new -> Macro. Paste the code here (Name MacroU-Vxx, take the latest version). 
After running the code a window will appear with analysis settings, the default settings will generally suffice to analyze particles, but settings can be changed based on the application. 
There are 3 settings that have to be adjusted for each analysis, and these are the first 3, more information about all these settings can be found below:
Once the desired settings are set press ok to process the images.

In order to test the macro on a new kind of image first open a single image (with particles) to test the macro on: 
To open an image go to File → open..., in case a video needs to be analyzed go to file and open the video, then press ctrl + shift + d to duplicate on image of this video.
In order to test (preview) the macro, run the code ( imageJ -> plugin -> new -> Macro, paste the macro -> press run) 
The analysis settings will appear, for the preview all standard settings are okay, including the first three (as the scale doesn't matter for the preview, the second setting is the preview mode, and the third setting is the background method, the rolling ball method is perfect for new images). 
Press ok to do the preview. A couple of seconds later an outline will be drawn on the particles.
If the ouline is okay the analysis can be done using these settings (only the first three might need to change). If the outline is not okay, settings need to be adjusted.
close the macro in order to zoom on the image. 

note: the minimimum size setting needs to be changes after each run of the preview mode. Make sure to change it back to the original value. 
note: make sure the particles are black and the background white, if this is not the case go to edit -> invert

Information on the settings:
1. Scale 
The scale in pixels/µm is necessary for pixel calibration! The correct scale can be found using an image of an object micrometer and going to Analyze -> Set scale. This value needs to be correct in order to measure the actual size of particles. 

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
- Rolling ball background subtraction: with this method the computer generates a background from the original image. Can be used on a single image and is the easiest method when working with only one image. 
- Background image is open: A background image is open manually or by another way and is open in imageJ during the whole analysis. Rather unconvenient method. 
- Median method: a background image is constructed from multiple frames by taking the median of each pixel value. This method only works for map of videos or map with maps of images. This method also removes scratches or stuck aparticles on top of uneven lighting. Prefered method when working with more than 20 images. 

---

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

