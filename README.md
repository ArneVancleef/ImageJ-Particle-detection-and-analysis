# ImageJ-Particle-detection-and-analysis
An automated ImageJ algorithm that can be used to detect and measure the size of particles in images. The macro can be used to analyze single images, maps of images, and videos.

This code will detect and measure particles in an image as long as they have a defined perimeter and are not interconnected with too many other particles. 

Read me:

If you don't have ImageJ, go to https://imagej.net/Fiji/Downloads to download it.
Before the macro can be used, a few plugins have to be installed. To install these, do the following:
go to imageJ toolbar → help → update... after a short while the "imageJ updated" will appear, press the button "manage update sites" in the left bottom corner. 
In the "manage update sites" select BioVoxxel, biomedgroup, ImageScience, and Morphology then close manage update site and then press apply changes. After updating restart imageJ. 

Now the code can be run by going to imageJ -> plugin -> new -> Macro. Paste the code here (Name MacroU-Vxx, take the latest version). 
Run the code:
After running the code a window will appear with analysis settings, the default settings will generally suffice to analyze particles, but settings can be changed based on the application. 
There are 5 important settings that have to be adjusted for each analysis, and these are the first 5, more information about all these settings can be found below:
Once the desired settings are set press ok to process the images.

In order to test the macro on a new kind of image first open a single image (with particles) to test the macro on: 
To open an image go to File → open..., in case a video needs to be analyzed go to file and open the video, then press ctrl + shift + d to duplicate on image of this video.
In order to test (preview) the macro, run the code ( imageJ -> plugin -> new -> Macro, paste the macro -> press run) 
The analysis settings will appear, for the preview all standard settings are okay, including the first 5 (as the scale doesn't matter for the preview, the second setting is the preview mode, and the third setting is the background method, the rolling ball method is perfect for new images). 
Press ok to do the preview. A couple of seconds later an outline will be drawn on the particles.
If the ouline is okay the analysis can be done using these settings (only the first two and the fourth might need to change). If the outline is not okay, settings need to be adjusted.
close the macro in order to zoom on the image. 


--------------------------------- Analysis settings ------------------------------

1. Scale 
The scale in pixels/µm is necessary for pixel calibration! The correct scale can be found using an image of an object micrometer and going to Analyze -> Set scale. This value needs to be correct in order to measure the actual size of particles. 

2. file type
This is the type of file that has to be analyzed, there are 5 options: 
- Preview: preview will analyze the open image (one image) in imageJ and shows the particle detection, ideal for setting up the analysis. Press ok in order to see the preview. 
- Map of videos: With this setting a map of videos will be anayzed after pressing ok. make sure map only contains videos. Only available video format is .avi. 
	Analysis will be performed in the background. Two maps will be made in the same map for each video analyzed. one with input images, this can be removed after analysis. 
	The other map will contain the output, which include the analyzed images, the results file, the summary file and settings of the analysis. 
	A window will appear after pressing ok to select the desired analysis map.  
- Single image: One open image is analyzed. note, D4.3, D3.2 and D1.0 will not be calculated in the summary for these measurements. 
- Single imaage + show processing steps: In this case one image is analyzed while also showing all subimages, this can be used to find it in which step of the analysis an error is made. 
- Map with maps of images. With this setting a map that contains maps of images will be analyzed, (not a map with images, a map with maps of images!) the output will be placed in the same maps as the original maps. works the same as the map of videos. 

3. Segmentation method: this is the method used to detect the particles, there are 4 options: 
- Edge detectoion + Intensity thresholding: Now both the sharpness of edges and the darkness(or lightness) of pixels are  used to find particles.
- Edge detectoion : Only use the sharpness of edges to find particles.
- Intensity thresholding : Only use the darkness of pixels to find particles.
This is useful for when there are partly out of focus particles and as a extra method to connect the outlines of particles. When there are a lot of particles out of focus, or when the particles are very transparant or have a brighter inside than the background than this method can cause difficulties. Note, that with this setting particles will be detected in nearly each image.
- Intensity thresholding with edge seeding: Use the outline of the intensity thresholding for the sizing but only measure the particle if the edge is sharper than the defined value (which is done below)

4. background subtraction
This is the method that is used to subtract the background from the image. 3 methods exist for this: 
- Rolling ball background subtraction: with this method the computer generates a background from the original image. Can be used on a single image and is the easiest method when working with only one image. 
- Background image is open: A background image is open manually or by another way and is open in imageJ during the whole analysis. Rather unconvenient method. 
- Median method: a background image is constructed from multiple frames by taking the median of each pixel value. This method only works for map of videos or map with maps of images. This method also removes scratches or stuck aparticles on top of uneven lighting. Prefered method when working with more than 20 images. 

5. Watershed method: This method will split up overlapping particles, there are the following options:
- No watershed
- Watershed for round particles, which is just the standard watershed and will split up round particles
- Irregular particles seperator line: which is a watershed that limits the maximum length of the seperator line
- Irregular particles convexity threshold: Will only watershed particles that have a convexity below a certain value


--------------------------------- Advanced settings ------------------------------

6. Edge detection threshold
This is the high threshold for the edge detection, the most important threshold, the higher this threshold the sharper a particle must be before being detected. 3 is a good starting value for most images (with a edge detection smoothing of 2 and sharpening of 0.40). If not enough particles are detected: increase threshold, if too much particles are detected, reduce threshold. 

7. Low detection threshold
This is the low threshold for the canny edge detection, pixels between high and low are only seen as particles if they connect ends of pixels above the high threshold. A good starting value is 1/3 or 1/2 of the high threshold. 

8. minimum size in µm:
This is the minimum size a particle can have, the size is defined as equivalent spherical diameter

9. maximum size in µm: 
This is the maxmimum size a particle can have, the size is defined as equivalent spherical diameter

10. Minimum particle circularity
This is the minimum circularity a particle can have to be detected.

11. maximum particle circularity
This is the maximum circularity a particle can have to be detected.

12. watershed irregular features convexity threshold
If this "Irregular particles convexity threshold" is selected this parameter is used. Particles that have a convexity below this value are watershed, others are not. 
The convexity is the perimeter of the particle devided by the perimeter of the convex hull of the particle, which is the particle with the shortest perimeter that still contains the whole image.

13. Watershed irregular features erosion cycles: 
If this "Irregular particles seperator line" is selected this parameter is used. 


--------------------------------- Additional settings ------------------------------

14. Rolling ball size: 
The size of the rolling ball that is used during the background subtraction (when using the rolling ball method). Quick rule: Ball must be larger than the particle size

15. Edge detection smoothing.
This is the amount of smoothing during the canny edge detection, this should be a whole number and there is little reason to change this value

16. Edge detection sharpening. 
This is the amount of sharpening with an unsharp mask before the edge detection, if there are particles touching each other that should not be touching eachother it can help to increase this value and decrease the threshold values. 

17. frames for background:
Only when using the median background method is this important. This is the amount of images that are used to construct a background image, 30 is a nice starting point. 

18. Gaussian blur
The gaussian blur can be used when the intensity thresholding causes a lot of single pixel noise. 

19. Closing cycles after edge detection
After the closing cycles a morphological closing is done, the higher this value the more times it is repeated. Note that in dense images it is better to keep this value low. The standard value of 2 is generally the ideal value. 

20. Closing cycles after intensity thresholding
Not often used, only when there are very big agglomerates that have very unsharp edges it can help connect foreground zones of the intensity thresholding and the edge detection. 

21. Field of view correction factor
This is a correct factor that corrects for the chance a particle is removed at the edges. only for map of videos and map of maps of images. 

22. add scalebar to input
This functions adds a scalebar to the input after analysis. Output automatically has a scale bar. 

23. Extended results: 
If this option is checked an additional summary file is added which gives for each measured image the amount of particles in a certain range (ex 10-20µm), works only with Field of view correction factor.

24. Whith particle on dark background:
Use when the background is dark.

---------------------------------------------------------------------------------------

Press ok then to perform the analysis. 

After running the code a summary file and a results file will be automatically saved (only when working with videos or maps of maps). 
The results file contains the data of each measured particles and can be pasted into the excel template in order to obtain the particle distribution and other parameters. 
The summary files gives the average values of particle counts, size etc. of each measured image. 

