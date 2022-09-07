//Go to imageJ → Plugin → New → Macro : Paste this code and press run to start the macro. 
//ImageJ can be downloaded: https://imagej.net/Fiji/Downloads
//Before macro usage: plugins have to be installed. 
//For installing: go to imageJ toolbar → help → update... after a short while the "imageJ updated" will appear, press the button "manage update sites" in the left bottom corner. 
//In the "manage update sites" select BioVoxxel, biomedgroup, ImageScience, and Morphology then close manage update site and then press apply changes. After updating restart imageJ. 
//Note: all default values can be changed by changing the defaultvalue after declaration of the variable: "var variable = defaultvalue".  
//Note: This macro only works for images with black particles on white backgrounds. For darkfield microscopy the images have to be inverted before usage. 
//Note: Make sure that there are no long lines (like the top and bottom edges of a flow cell) in the image that run from one end of the image to the other end, in this case everything between these lines will be detected, but will be removed as it touches the edges. Crop these edges of before analysis.

macro "Particle detection and analysis" {

setBatchMode(true);

var inNumberScale = 0.650;									//scale in pixel/µm: must be calculated from calibration image then go to ImageJ toolbar → Analyze → Set scale...
var ChoiceType = "Preview (press ok for preview)"; 			//This is the type of analysis that has to be done, either a preview of the analysis, a single image, a map with maps of images or a map with videos (avi).
var ChoiceSegmentation = "Edge detection + Intensity thresholding";
var ChoiceBackground = "Rolling ball from single image";	//Which method for background substraction, the rolling ball method generates a background image, background image can also be opened and called "background.tif" or can be generated from the median of pixel values if map of videos or map of map of images is selected.  
var ChoiceWatershed = "Irregular particles convexity threshold";
var inNumberEdgeHighThreshold = 3;							//High threshold value for the edge detection, typically between 2 or 15, depends on image/compute smoothing and unsharp mask, higher thresholds mean lower sensitivity
var inNumberEdgeLowThreshold = 1;							//Low threshold value for the edge detection, typically around 1, depends on image/compute smoothing and unsharp mask: high mean, higher thresholds mean lower sensitivity
var inNumberEdgeComputeSmoothing = 2;						//Smoothing before finding edge detection, typically 1, 2 or 3. Higher values mean lower sensitivity
var inNumberEdgeUnsharpMask = 0.40;							//Extra sharpening that can be done before edge detection, high: higher sensitivty, low: lower sensitivity
var FramesForBackground = 30;								//Amount of images used for calculating the background if median method is selected
var HistogramBinerization = true;							//Adds a second method for finding particles: intensity thresholding, if particles are dark enough they will be detected
var OnlyHistogramBinerization = false; 						//Discards edge detection
var GaussianBlurBeforeIntensityThresholding = 0; 			//GuassianBlur.
var ClosingCycles = 2;										
var RollingBall = 500;
var inNumberClosingCycles = 0;								//cycles (dilation + erosion) after putting together the intensity thresholding
var FOVcfYesOrNo = true;									//Boolean: use a field of view correction factor in the analysis
var AddScaleBar = false;										//Boolean: add scale bars to the original images after analysis
var ShowProcessingStepsBoolean = false;						//Boolean: Can be used to see all substeps in the image analysis when only analyzing a single imamge
var WatershedBoolean = false; 								//Boolean: Use a standard watershed: only recommended for circular particles
var WatershedIrregularFeaturesBoolean = true; 				//Boolean: use a watershed for irregular features, recommended for irregular particles
var SeperatorLength = 3;										//Erosion cycles for watershed irregular features: see biovoxxel toolbox wiki
var WatershedConvexity = 0.9800;									//Convexity threshold for watershed irregular features: see biovoxxel toolbox wiki
var minCircularity = 0.00;									//Minimum circularity of a particle to be analyzed
var maxCircularity = 1.00;									//Maximum circularity of a particle to be analyzed
var minSize2 = 1; 											//Minmum Size of a particle to be analyzed
var maxSize2 = 999999999999;
var RowsRemovedFromEdges = 3;
var ExtendedResults = true;
var WhiteParticles = false;

run("Set Measurements...", "area perimeter bounding shape feret's stack display redirect=None decimal=8");

while (ChoiceType == "Preview (press ok for preview)")
{
setBatchMode(true);
Dialog.create("Analysis settings");
Dialog.addNumber("scale in pixels/µm", inNumberScale); //1
Dialog.addChoice("file type:", newArray("Preview (press ok for preview)", "Map of videos (avi.)", "Single image", "Single image + show processing steps", "Map containing maps of images")); 

    if (ChoiceSegmentation == "Edge detection"){
		Dialog.addChoice("Segmentation Method:", newArray("Edge detection", "Edge detection + Intensity thresholding", "Intensity thresholding", "Intensity thresholding with edge seeding"));
	} else if (ChoiceSegmentation == "Intensity thresholding"){
		Dialog.addChoice("Segmentation Method:", newArray("Intensity thresholding" , "Edge detection + Intensity thresholding", "Edge detection", "Intensity thresholding with edge seeding"));
	} else if (ChoiceSegmentation == "Intensity thresholding with edge seeding"){
		Dialog.addChoice("Segmentation Method:", newArray("Intensity thresholding with edge seeding", "Edge detection + Intensity thresholding", "Intensity thresholding" , "Edge detection"));
	} else {
		Dialog.addChoice("Segmentation Method:", newArray( "Edge detection + Intensity thresholding", "Edge detection", "Intensity thresholding", "Intensity thresholding with edge seeding"));		
	}
Dialog.addChoice("Background image method:", newArray("Rolling ball from single image", "Median of multiple frames (videos/maps)", "Background is open and named background.tif")); 

	if (ChoiceWatershed == "None"){
		Dialog.addChoice("Watershed Method:", newArray("None", "Irregular particles convexity threshold", "Irregular particles separator line", "Normal (round particles)"));
	} else if (ChoiceWatershed == "Normal (round particles)"){
		Dialog.addChoice("Watershed Method:", newArray("Normal (round particles)", "Irregular particles convexity threshold", "Irregular particles separator line", "None"));
	} else if (ChoiceWatershed == "Irregular particles separator line"){
		Dialog.addChoice("Watershed Method:", newArray("Irregular particles separator line", "Irregular particles convexity threshold", "Normal (round particles)", "None"));
	} else {
		Dialog.addChoice("Watershed Method:", newArray("Irregular particles convexity threshold", "Irregular particles separator line", "Normal (round particles)", "None"));
	}
Dialog.addMessage("-------------------------------------------------  Advanced settings  -------------------------------------------------");
Dialog.addNumber("Edge detection High Threshold", inNumberEdgeHighThreshold); //2
Dialog.addNumber("Edge detection Low Threshold", inNumberEdgeLowThreshold); //3
Dialog.addNumber("Minimum particle size in µm", minSize2); //4
Dialog.addNumber("Maximum particle size in µm", maxSize2); //5
Dialog.addNumber("Minimum particle circularity (0-1)", minCircularity); //6
Dialog.addNumber("Maximum particle circularity (0-1)", maxCircularity); //7
Dialog.addSlider("Watershed IF convexity threshold", 0, 1, WatershedConvexity); //8
SeperatorLength = SeperatorLength*2;
Dialog.addSlider("Watershed IF seperator length", 1, 10000, SeperatorLength); //9
Dialog.addMessage("-------------------------------------------------  Additional settings  -------------------------------------------------");
Dialog.addNumber("Rolling ball size:", RollingBall);
Dialog.addNumber("Edge detection Smoothing", inNumberEdgeComputeSmoothing); //10
Dialog.addSlider("Edge detection Sharpening", 0, 0.9, inNumberEdgeUnsharpMask); //11
Dialog.addNumber("Frames for background (videos/maps)", FramesForBackground); //12
//Dialog.addCheckbox("Use additional intensity thresholding", HistogramBinerization);
//Dialog.addCheckbox("Use only intensity thresholding", OnlyHistogramBinerization);
Dialog.addSlider("Gaussian Blur radius (intensity threshold)", 0, 10, GaussianBlurBeforeIntensityThresholding); //13
Dialog.addSlider("Closing cycles after edge detection", 0, 10, ClosingCycles); //14
Dialog.addSlider("Closing cycles after intensity thresholding", 0, 10, inNumberClosingCycles); //15
Dialog.addCheckbox("Field of View correction factor", FOVcfYesOrNo); //16
Dialog.addCheckbox("Add scalebar to input", AddScaleBar); //adds scalebar to input images after analysis //17
//Dialog.addCheckbox("Show processing steps (single image)", ShowProcessingStepsBoolean);
//Dialog.addCheckbox("watershed", WatershedBoolean);
//Dialog.addCheckbox("watershed irregular features (IF)", WatershedIrregularFeaturesBoolean);
Dialog.addCheckbox("Extended results", ExtendedResults); //18
Dialog.addCheckbox("White particles on dark backround", WhiteParticles); //19
Dialog.show();

// Once the Dialog is OKed the rest of the code is executed
// values are recovered in order of appearance
inNumberScale = Dialog.getNumber(); //Check //1
ChoiceType  = Dialog.getChoice(); //Check
	if(ChoiceType ==  "Single image + show processing steps"){
		ShowProcessingStepsBoolean = true;	
	} else {
		ShowProcessingStepsBoolean = false;	
	}
ChoiceSegmentation = Dialog.getChoice();
	if(ChoiceSegmentation == "Edge detection + Intensity thresholding"){
		HistogramBinerization = true;
		OnlyHistogramBinerization = false;
	} else if (ChoiceSegmentation == "Edge detection"){
		HistogramBinerization = false;
		OnlyHistogramBinerization = false;
	} else if (ChoiceSegmentation == "Intensity thresholding"){
		OnlyHistogramBinerization = true;
		HistogramBinerization = true;
	} else if (ChoiceSegmentation == "Intensity thresholding with edge seeding"){
		OnlyHistogramBinerization = true;
		HistogramBinerization = true;
	}
ChoiceBackground  = Dialog.getChoice(); //Check
ChoiceWatershed = Dialog.getChoice(); // Check
inNumberEdgeHighThreshold = Dialog.getNumber(); //Check //2
inNumberEdgeLowThreshold = Dialog.getNumber(); //Check //3
minSize2 = Dialog.getNumber(); //4
minSize = 3.141*((minSize2*inNumberScale)*(minSize2*inNumberScale))/4;
maxSize2 = Dialog.getNumber(); //5
maxSize = 3.141*((maxSize2*inNumberScale)*(maxSize2*inNumberScale))/4;
minCircularity = Dialog.getNumber(); //6
maxCircularity = Dialog.getNumber(); //7
WatershedConvexity = Dialog.getNumber(); //8
SeperatorLength = round(Dialog.getNumber()/2); //9
//-----------------------------------------------Additional settings-----------------------------------------------
RollingBall = Dialog.getNumber();
inNumberEdgeComputeSmoothing = Dialog.getNumber(); //Check //10
inNumberEdgeUnsharpMask = Dialog.getNumber(); //Check //11
FramesForBackground = Dialog.getNumber();   //check //12
//HistogramBinerization = Dialog.getCheckbox(); //Check
//OnlyHistogramBinerization = Dialog.getCheckbox();
//if(OnlyHistogramBinerization == true) {
//	HistogramBinerization == true;
//	}
GaussianBlurBeforeIntensityThresholding = Dialog.getNumber(); //13
ClosingCycles = Dialog.getNumber(); //14
inNumberClosingCycles = Dialog.getNumber(); //Check //15
FOVcfYesOrNo = Dialog.getCheckbox(); // Check //16
AddScaleBar = Dialog.getCheckbox(); //16
//WatershedBoolean = Dialog.getCheckbox();
//WatershedIrregularFeaturesBoolean = Dialog.getCheckbox();
ExtendedResults = Dialog.getCheckbox(); //17
WhiteParticles = Dialog.getCheckbox(); //18


 	if (ChoiceWatershed == "None"){
		WatershedBoolean = false;
		WatershedIrregularFeaturesBoolean = false;
 	} else if (ChoiceWatershed == "Normal (round particles)"){
		WatershedBoolean = true;
		WatershedIrregularFeaturesBoolean = false; 		
	} else if (ChoiceWatershed == "Irregular particles convexity threshold"){
		WatershedBoolean = false;
		WatershedIrregularFeaturesBoolean = true; 		
	} else if (ChoiceWatershed == "Irregular particles separator line"){
		WatershedBoolean = false;
		WatershedIrregularFeaturesBoolean = true;
		WatershedConvexity = 0.00;		
	}

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Analysis of a single image
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


if (ChoiceType == "Single image" || ChoiceType == "Single image + show processing steps")
{
	if(ShowProcessingStepsBoolean == false){
		setBatchMode(true);
	} else {
		setBatchMode(false);
	}
roiManager("Reset");
OrigineleAfbeelding = getTitle(); 
	if(WhiteParticles == true){run("Invert");} 
	run("8-bit"); 
			//background substraction: Voor deze stap is het noodzakelijk dat een achtergrondafbeelding met de naam "background.tif" openstaat
			if(ChoiceBackground == "Rolling ball from single image")
			{
				makeRectangle(0, 0, getWidth(), getHeight());
				run("Duplicate...", "title=background.tif");     //Only used when also using histogram thresholding in combination with canny edge detection
				run("Subtract Background...", "rolling="+RollingBall+" light create sliding");
				rename("background.tif");
			} else {
				makeRectangle(0, 0, RowsRemovedFromEdges, RowsRemovedFromEdges); 
				run("Add...", "value=255 slice"); 
				makeRectangle(RowsRemovedFromEdges, 0, RowsRemovedFromEdges, RowsRemovedFromEdges); 
				run("Subtract...", "value=255 slice");		
			}
	imageCalculator("Subtract create 32-bit stack", OrigineleAfbeelding, "background.tif");
	run("8-bit");
	rename("AfterBackgroundSubstraction");		
	run("Duplicate...", "title=AfterHistogramBinerization");  
	run("Duplicate...", "title=BeforeCannyEdgeDetection");        
	run("Unsharp Mask...", "radius=1 mask=inNumberEdgeUnsharpMask");						
	run("FeatureJ Edges", "compute smoothing="+inNumberEdgeComputeSmoothing+" suppress lower="+inNumberEdgeLowThreshold+" higher="+inNumberEdgeHighThreshold);
	rename("AfterCannyEdgeDetection");	
	selectImage("BeforeCannyEdgeDetection");
	run("Close");
	selectImage("AfterCannyEdgeDetection");
	run("Duplicate...", "title=AfterCannyEdgeDetectionAndMorphologicalOperators");  
		run("8-bit");
		run("EDM Binary Operations", "iterations="+ClosingCycles+" operation=dilate");
			makeRectangle(0, 0, RowsRemovedFromEdges, getHeight);		
			run("Add...", "value=255 slice");
			makeRectangle(getWidth-RowsRemovedFromEdges,0, RowsRemovedFromEdges,getHeight);
			run("Add...", "value=255 slice");
			setOption("BlackBackground", true);
			run("Make Binary");	
			run("Fill Holes");
			makeRectangle(RowsRemovedFromEdges,0,getWidth-RowsRemovedFromEdges-RowsRemovedFromEdges,getHeight);
			run("Crop");
			makeRectangle(0, 0, getWidth, RowsRemovedFromEdges);
			run("Add...", "value=255 slice");
			makeRectangle(0,getHeight-RowsRemovedFromEdges,getWidth,RowsRemovedFromEdges);
			run("Add...", "value=255 slice");
			setOption("BlackBackground", true);
			run("Make Binary");	
			run("Fill Holes");
			makeRectangle(0,RowsRemovedFromEdges,getWidth,getHeight-RowsRemovedFromEdges-RowsRemovedFromEdges);
			run("Crop");
			run("EDM Binary Operations", "iterations="+ClosingCycles+" operation=erode");
			run("EDM Binary Operations", "iterations=1 operation=erode");
			run("EDM Binary Operations", "iterations=1 operation=dilate");
			//run("Watershed Irregular Features", "erosion=3 convexity_threshold=0 separator_size=0-8");				

			//Steps for also doing a histogram based binerization
			if(HistogramBinerization == true)
			{
				selectWindow("AfterHistogramBinerization");
				if(GaussianBlurBeforeIntensityThresholding>0){
				run("Gaussian Blur...", "sigma="+GaussianBlurBeforeIntensityThresholding);
				}
				setAutoThreshold("Default");
				run("Convert to Mask");	
				makeRectangle(0, 0, RowsRemovedFromEdges, getHeight);		
				run("Add...", "value=255 slice");
				makeRectangle(getWidth-RowsRemovedFromEdges,0, RowsRemovedFromEdges,getHeight);
				run("Add...", "value=255 slice");
				setOption("BlackBackground", true);
				run("Make Binary");	
				run("Fill Holes");
				makeRectangle(RowsRemovedFromEdges,0,getWidth-RowsRemovedFromEdges-RowsRemovedFromEdges,getHeight);
				run("Crop");
				makeRectangle(0, 0, getWidth, RowsRemovedFromEdges);
				run("Add...", "value=255 slice");
				makeRectangle(0,getHeight-RowsRemovedFromEdges,getWidth,RowsRemovedFromEdges);
				run("Add...", "value=255 slice");
				setOption("BlackBackground", true);
				run("Make Binary");
				run("Fill Holes");
				makeRectangle(0,RowsRemovedFromEdges,getWidth,getHeight-RowsRemovedFromEdges-RowsRemovedFromEdges);
				run("Crop");
				run("Duplicate...", "title=AfterHistogramBinerization2");  
				if(OnlyHistogramBinerization == false || ChoiceSegmentation == "Intensity thresholding with edge seeding"){
				run("BinaryReconstruct ", "mask=AfterHistogramBinerization2 seed=AfterCannyEdgeDetectionAndMorphologicalOperators create white");
					if (ChoiceSegmentation != "Intensity thresholding with edge seeding"){
						rename("toClose");
						run("Duplicate...", "title=AfterMerging");  
						selectImage("toClose");
						run("Close");
						selectImage("AfterMerging");
						imageCalculator("OR", "AfterMerging" , "AfterCannyEdgeDetectionAndMorphologicalOperators");
					}
				}
				run("EDM Binary Operations", "iterations=inNumberClosingCycles operation=dilate");
				run("EDM Binary Operations", "iterations=inNumberClosingCycles operation=erode");
				run("Fill Holes");
				run("Duplicate...", "title=AfterWatershed");  
				
			} else {
				selectImage("AfterHistogramBinerization");
				run("Close"); 
			}
			if (WatershedBoolean == true){
				run("Watershed");
			} else if(WatershedIrregularFeaturesBoolean == true){
				run("Watershed Irregular Features", "erosion="+SeperatorLength+" convexity_threshold="+WatershedConvexity+" separator_size=0-Infinity");
			} 

			run("Duplicate...", "title=BeforeAnalysis");  
			rename(OrigineleAfbeelding); //regel!!
			FinalHeightImage = getHeight();		//deze zou nog ergens anders komen te staan zodat hij niet iedere keer opnieuw moet worden bepaald
			FinalWidthImage = getWidth();		//deze zou nog ergens anders komen te staan zodat hij niet iedere keer opnieuw moet worden bepaald
			//Volgende stap bepaalt de schaal van de afbeelding, voeg hier de waarde in die opgegeven stonden bij de kalibratieafbeelding (Distance in pixel = distance; known distance = known)						
			run("Set Scale...", "distance="+inNumberScale+" known=1 pixel=1 unit=µm");
			FinalHeightImage = getHeight;		//deze zou nog ergens anders komen te staan zodat hij niet iedere keer opnieuw moet worden bepaald
			FinalWidthImage = getWidth;		//deze zou nog ergens anders komen te staan zodat hij niet iedere keer opnieuw moet worden bepaald
			run("Analyze Particles...", "size="+minSize+"-"+maxSize+" pixel circularity="+minCircularity+"-"+maxCircularity+" show=Nothing display include exclude summarize add");
		close();
		selectWindow(OrigineleAfbeelding);
		makeRectangle(RowsRemovedFromEdges, RowsRemovedFromEdges, (getWidth-RowsRemovedFromEdges-RowsRemovedFromEdges), (getHeight-RowsRemovedFromEdges-RowsRemovedFromEdges));
		run("Crop");
			if(WhiteParticles == true){run("Invert");} 
		run("ROI Manager...");
		roiManager("Show All without labels");
		//run("Flatten");			
		//roiManager("Reset");

		selectWindow("Results");
		Table.applyMacro("Diameter=sqrt(Area/3.14*4); Diameter3=Diameter*Diameter*Diameter; Diameter4=Diameter3*Diameter; FOVcf=("+FinalWidthImage+"*"+FinalHeightImage+")/(("+FinalHeightImage+"-Height)*("+FinalWidthImage+"-Width))");

		
		 if(AddScaleBar==true){
				run("Set Scale...", "distance="+inNumberScale+" known=1 pixel=1 unit=µm");
				run("Scale Bar...", "width=100 height=12 font=42 color=White background=Black location=[Lower Right] bold overlay label");
		 }	
		 if(ShowProcessingStepsBoolean == false){
			close("AfterWatershed");
			close("AfterCannyEdgeDetectionAndMorphologicalOperators");
			close("AfterHistogramBinerization");
			close("AfterBackgroundSubstraction");
			close("AfterCannyEdgeDetection");
			close("AfterMerging");
		 }
		 if(OnlyHistogramBinerization == true && ShowProcessingStepsBoolean == true){
		 	close("AfterCannyEdgeDetection");
		 	close("AfterCannyEdgeDetectionAndMorphologicalOperators");
		 }
		 	
}




//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Analysis of maps with videos
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


if (ChoiceType == "Map of videos (avi.)")
{
dir = getDirectory("Choose a folder");
// processing video (.avi) files
list = getFileList(dir);
for (i = 0; i < list.length; i++) 
	{
	name = list[i];
		if(matches(name, ".*.avi*."))						//only opening videofiles (in this case .avi files)
		{
			//Splitting the video (.avi) file
			open(list[i]);
				// vv Removing .avi from name
				unwantedPartOfName = ".avi"; 				
				len1=lengthOf(name);						
				len2=lengthOf(unwantedPartOfName); 			
				len3=indexOf(name,unwantedPartOfName);		
				string1=substring(name, len2+len3,len1);	
				string2=substring(name, 0,len3);			
				nameWithoutAvi=string2+string1;		
				// ^^ Removing .avi from name				
			NewDirInput= dir + nameWithoutAvi + " - Input"; 
			NewDirOutput= dir + nameWithoutAvi + " - Output";
			File.makeDirectory(NewDirInput);
			File.makeDirectory(NewDirOutput);
			//for (y = 1; y <= nSlices; y++) {
  				  //setSlice(y);
  					//  run("Duplicate...", "duplicate range=i use");
					//	saveAs(nameWithoutAvi+i, NewDirInput "nameWithoutAvi+i");
					//	saveAs("png", subdir2 + OrigineleAfbeelding);
					//list4 = getFileList(dir);
					//	saveAs("png", NewDirInput + i);
					//	saveAs("Results", subdir2 + videonaam2 + "Results.tsv");
  					//  run("Close");
				//}


		
			run("Image Sequence... ", "format=png dir=["+NewDirInput+"] start=1 digits=6");
			//run("Image Sequence... ", "dir="" format=PNG digits=5 use");
			//run("Image Sequence... ", "format=PNG start=1 digits=5 save=NewDirInput");
	
			//creating a background from videofile
			if(ChoiceBackground == "Median of multiple frames (videos/maps)"){
				run("Slice Keeper", "first=1 last=FramesForBackground increment=1");
				run("Z Project...", "projection=Median");
				rename("background.tif");
				saveAs("tif", NewDirOutput+"background");
				run("Close All");
			}
		}
	}


listTwo = getFileList(dir);
listTwo = Array.sort(listTwo);
    for (i = 0; i < listTwo.length; i++) 
    {
   	    showProgress(i+1, listTwo.length);
   	    mapname = listTwo[i];
        if(File.isDirectory(dir + File.separator + listTwo[i]) && matches(mapname,".*Input*."))
        {
        	subdir = dir + listTwo[i];
        	subdir2 = dir + listTwo[i+1];
     		listThree = getFileList(subdir);
			videonaam1 = listTwo[i];
			videonaam2 = replace(videonaam1,"Input/","");
			for (n = 0; n < listThree.length; n++) 
				{  		
					if(ChoiceBackground == "Median of multiple frames (videos/maps)"){
					open(videonaam2 +"Outputbackground.tif");
					rename("background.tif"); 
					}
					open(subdir+listThree[n]);


//-------------------------------
//Start of code that is actually used to process the image
//------------------------------			
			

OrigineleAfbeelding = getTitle(); 
	if(WhiteParticles == true){run("Invert");} 
	run("8-bit"); 
	makeRectangle(0, 0, RowsRemovedFromEdges, RowsRemovedFromEdges); 
		run("Add...", "value=255 slice"); 
		makeRectangle(RowsRemovedFromEdges, 0, RowsRemovedFromEdges, RowsRemovedFromEdges); 
		run("Subtract...", "value=255 slice");
		if(ChoiceBackground == "Rolling ball from single image")
		{
			makeRectangle(0, 0, getWidth(), getHeight());
			run("Duplicate...", "title=background.tif");     //Only used when also using histogram thresholding in combination with canny edge detection
			run("Subtract Background...", "rolling="+RollingBall+" light create sliding");
			rename("background.tif");
		}
	imageCalculator("Subtract create 32-bit stack", OrigineleAfbeelding, "background.tif");
	run("8-bit");
	if(HistogramBinerization == true)
			{
	rename("BackgroundSubstractedImage");							//Only used when also using histogram thresholding in combination with canny edge detection
	run("Duplicate...", "title=BackgroundSubstractedImage2");     //Only used when also using histogram thresholding in combination with canny edge detection
			}
			
	//Volgende stap bepaalt de gevoeligheid van de analyse, hoe hoger de mask waarde (van 0 tot 0.9) hoe gevoeliger de analyse
	run("Unsharp Mask...", "radius=1 mask="+inNumberEdgeUnsharpMask);
							

	run("FeatureJ Edges", "compute smoothing="+inNumberEdgeComputeSmoothing+" suppress lower="+inNumberEdgeLowThreshold+" higher="+inNumberEdgeHighThreshold);	
	
	rename("BackgroundSubstractedImage3");	
		run("8-bit");
		run("EDM Binary Operations", "iterations="+ClosingCycles+" operation=dilate");
			makeRectangle(0, 0, RowsRemovedFromEdges, getHeight);		
			run("Add...", "value=255 slice");
			makeRectangle(getWidth-RowsRemovedFromEdges,0, RowsRemovedFromEdges,getHeight);
			run("Add...", "value=255 slice");
			setOption("BlackBackground", true);
			run("Make Binary");	
			run("Fill Holes");
			makeRectangle(RowsRemovedFromEdges,0,getWidth-RowsRemovedFromEdges-RowsRemovedFromEdges,getHeight);
			run("Crop");
			makeRectangle(0, 0, getWidth, RowsRemovedFromEdges);
			run("Add...", "value=255 slice");
			makeRectangle(0,getHeight-RowsRemovedFromEdges,getWidth,RowsRemovedFromEdges);
			run("Add...", "value=255 slice");
			setOption("BlackBackground", true);
			run("Make Binary");	
			run("Fill Holes");
			makeRectangle(0,RowsRemovedFromEdges,getWidth,getHeight-RowsRemovedFromEdges-RowsRemovedFromEdges);
			run("Crop");
			run("EDM Binary Operations", "iterations="+ClosingCycles+" operation=erode");
			run("EDM Binary Operations", "iterations=1 operation=erode");
			run("EDM Binary Operations", "iterations=1 operation=dilate");
							

			//Steps for also doing a histogram based binerization
			if(HistogramBinerization == true)
			{
				selectWindow("BackgroundSubstractedImage");
				if(GaussianBlurBeforeIntensityThresholding>0){
				run("Gaussian Blur...", "sigma="+GaussianBlurBeforeIntensityThresholding);
				}
				setAutoThreshold("Default");
				run("Convert to Mask");	
				makeRectangle(0, 0, RowsRemovedFromEdges, getHeight);		
				run("Add...", "value=255 slice");
				makeRectangle(getWidth-RowsRemovedFromEdges,0, RowsRemovedFromEdges,getHeight);
				run("Add...", "value=255 slice");
				setOption("BlackBackground", true);
				run("Make Binary");	
				run("Fill Holes");
				makeRectangle(RowsRemovedFromEdges,0,getWidth-RowsRemovedFromEdges-RowsRemovedFromEdges,getHeight);
				run("Crop");
				makeRectangle(0, 0, getWidth, RowsRemovedFromEdges);
				run("Add...", "value=255 slice");
				makeRectangle(0,getHeight-RowsRemovedFromEdges,getWidth,RowsRemovedFromEdges);
				run("Add...", "value=255 slice");
				setOption("BlackBackground", true);
				run("Make Binary");	
				run("Fill Holes");
				makeRectangle(0,RowsRemovedFromEdges,getWidth,getHeight-RowsRemovedFromEdges-RowsRemovedFromEdges);
				run("Crop");
				if(OnlyHistogramBinerization == false || ChoiceSegmentation == "Intensity thresholding with edge seeding"){
				run("BinaryReconstruct ", "mask=BackgroundSubstractedImage seed=BackgroundSubstractedImage3 create white");
					if (ChoiceSegmentation != "Intensity thresholding with edge seeding"){
						rename("ReconstructedImage");
						imageCalculator("OR", "ReconstructedImage" , "BackgroundSubstractedImage3");
					}
				}
				run("EDM Binary Operations", "iterations=inNumberClosingCycles operation=dilate");
				run("EDM Binary Operations", "iterations=inNumberClosingCycles operation=erode");
				run("Fill Holes");
				
			}
			if (WatershedBoolean == true){
				run("Watershed");
			} else if(WatershedIrregularFeaturesBoolean == true){
				run("Watershed Irregular Features", "erosion="+SeperatorLength+" convexity_threshold="+WatershedConvexity+" separator_size=0-Infinity");
			} 

			rename(OrigineleAfbeelding);
			//Volgende stap bepaalt de schaal van de afbeelding, voeg hier de waarde in die opgegeven stonden bij de kalibratieafbeelding (Distance in pixel = distance; known distance = known)						
			run("Set Scale...", "distance="+inNumberScale+" known=1 pixel=1 unit=µm");
			FinalHeightImage = getHeight();		//deze zou nog ergens anders komen te staan zodat hij niet iedere keer opnieuw moet worden bepaald
			FinalWidthImage = getWidth();		//deze zou nog ergens anders komen te staan zodat hij niet iedere keer opnieuw moet worden bepaald
			run("Analyze Particles...", "size="+minSize+"-"+maxSize+" pixel circularity="+minCircularity+"-"+maxCircularity+" show=Nothing display include exclude summarize add");
		close();
		selectWindow(OrigineleAfbeelding);
		makeRectangle(RowsRemovedFromEdges, RowsRemovedFromEdges, (getWidth-RowsRemovedFromEdges-RowsRemovedFromEdges), (getHeight-RowsRemovedFromEdges-RowsRemovedFromEdges));
		run("Crop");
			if(WhiteParticles == true){run("Invert");} 
										

//-------------------------------
//end of code that is used to actually process the image
//------------------------------			

						roiManager("Show All without labels");
						run("Flatten");			
						run("Set Scale...", "distance="+inNumberScale+" known=1 pixel=1 unit=µm");
						run("Scale Bar...", "width=100 height=12 font=42 color=White background=Black location=[Lower Right] bold overlay label");
						roiManager("Reset");
					close("\\Others"); //sluit alle andere afbeeldingen: memory
					saveAs("png", subdir2 + OrigineleAfbeelding);		
					close();				
				}
 			selectWindow("Results");  //activate results table



			//Getting necessary information out of results
				if(FOVcfYesOrNo == false) 
				{
					Table.applyMacro("Diameter=sqrt(Area/3.14*4); Diameter3=Diameter*Diameter*Diameter; Diameter4=Diameter3*Diameter");
					FOVcfMeasurements = newArray(nResults);
					diameterMeasurements = newArray(nResults);
					diameter3Measurements = newArray(nResults);
					diameter4Measurements = newArray(nResults);
					for(k=0; k<nResults; k++) 
					{
						FOVcfMeasurements[k] = 1;
						diameterMeasurements[k] = getResult("Diameter", k);
						diameter3Measurements[k] = getResult("Diameter3", k);
					    diameter4Measurements[k] = getResult("Diameter4", k);  
					}
				}
				else if (FOVcfYesOrNo == true)
				{
					Table.applyMacro("Diameter=sqrt(Area/3.14*4); Diameter3=Diameter*Diameter*Diameter; Diameter4=Diameter3*Diameter; FOVcf=("+FinalWidthImage+"*"+FinalHeightImage+")/(("+FinalHeightImage+"-Height)*("+FinalWidthImage+"-Width))");
					FOVcfMeasurements = newArray(nResults);
					diameterMeasurements = newArray(nResults);
					diameter3Measurements = newArray(nResults);
					diameter4Measurements = newArray(nResults);
					for(k=0; k<nResults; k++) 
					{
						FOVcfMeasurements[k] = getResult("FOVcf", k);		
						diameterMeasurements[k] = getResult("Diameter", k);
						diameter3Measurements[k] = getResult("Diameter3", k);
					    diameter4Measurements[k] = getResult("Diameter4", k);			    
					}

				}
			saveAs("Results", subdir2 + videonaam2 + "Results.tsv");
			run("Close");

			//Verwerken van summary data
			selectWindow("Summary");  //activate summary table
			IJ.renameResults("Results");
			totalCount = 0;
			if(FOVcfYesOrNo == true)
			{
				for(m=0; m<nResults; m++) 
					{
						D1som = 0;
						D4som = 0;
						D3som = 0;
						FOVcfsom = 0;
						SphericalVolume = 0;
						
						for(h=totalCount; h<totalCount+getResult("Count",m);h++)
    						{
								D1som = D1som + (diameterMeasurements[h]*FOVcfMeasurements[h]);
								D4som = D4som + (diameter4Measurements[h]*FOVcfMeasurements[h]);
								D3som = D3som + (diameter3Measurements[h]*FOVcfMeasurements[h]);
								FOVcfsom += FOVcfMeasurements[h];
								SphericalVolume += FOVcfMeasurements[h]*4*3.141*(diameterMeasurements[h]*diameterMeasurements[h]*diameterMeasurements[h])/(8*3);
    						}
    					totalCount += getResult("Count", m);
						setResult("D4.3", m, D4som/D3som);
						setResult("D1.0", m, D1som/getResult("Count" ,m)); 						
						setResult("FOV corrected counts", m, FOVcfsom); 
						setResult("Spherical Volume", m, SphericalVolume); 
   				 	}
			} 
			else 
			{
				for(m=0; m<nResults; m++) 
					{
						D1som = 0;
						D4som = 0;
						D3som = 0;
						for(h=totalCount; h<totalCount+getResult("Count",m);h++)
    						{
								D1som += diameterMeasurements[h];
								D4som += diameter4Measurements[h];
								D3som += diameter3Measurements[h];
    						}
    					totalCount += getResult("Count", m);
						setResult("D4.3", m, D4som/D3som);
						setResult("D1.0", m, D1som/getResult("Count" ,m)); 

   				 	}
			}
			saveAs("Results", subdir2 + videonaam2 + "Summary.tsv");

			//
			// Extended results
			//
					
					if(FOVcfYesOrNo == true && ExtendedResults == true)
						totalCount = 0;
						{
							for(m=0; m<nResults; m++) 
							{
								f010 = 0;
								f1020 = 0;
								f2030 = 0;
								f3040 = 0; 
								f4050 = 0;
								f5060 = 0; 
								f6070 = 0;
								f7080 = 0;
								f8090 = 0;
								f90100 = 0; 
								f100110 = 0;
								f110120 = 0;
								f120130 = 0; 
								f130140 = 0;
								f140150 = 0;
								f150160 = 0;
								f160170 = 0;
								f170180 = 0;
								f180190 = 0;
								f190200 = 0;
								f200225 = 0;
								f225250 = 0;
								f250275 = 0;
								f275300 = 0;
								f300325 = 0;
								f325350 = 0;
								f350375 = 0;
								f375400 = 0;
								f400450 = 0;
								f450500 = 0;
									for(h=totalCount; h<totalCount+getResult("Count",m);h++)
				    						{
												if(diameterMeasurements[h]<10){
													f010 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<20){
													f1020 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<30){
													f2030 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<40){
													f3040 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<50){
													f4050 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<60){
													f5060 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<70){
													f6070 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<80){
													f7080 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<90){
													f8090 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<100){
													f90100 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<110){
													f100110 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<120){
													f110120 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<130){
													f120130 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<140){
													f130140 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<150){
													f140150 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<160){
													f150160 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<170){
													f160170 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<180){
													f170180 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<190){
													f180190 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<200){
													f190200 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<225){
													f200225 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<250){
													f225250 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<275){
													f250275 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<300){
													f275300 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<325){
													f300325 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<350){
													f325350 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<375){
													f350375 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<400){
													f375400 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<450){
													f400450 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<500){
													f450500 += FOVcfMeasurements[h];
												}
				    						}
			    				totalCount += getResult("Count", m);
								setResult("0-10", m, f010);
								setResult("10-20", m, f1020);
								setResult("20-30", m, f2030);
								setResult("30-40", m, f3040);
								setResult("40-50", m, f4050);
								setResult("50-60", m, f5060);
								setResult("60-70", m, f6070);
								setResult("70-80", m, f7080);
								setResult("80-90", m, f8090);
								setResult("90-100", m, f90100);
								setResult("100-110", m, f100110);
								setResult("110-120", m, f110120);
								setResult("120-130", m, f120130);
								setResult("130-140", m, f130140);
								setResult("140-150", m, f140150);
								setResult("150-160", m, f150160);
								setResult("160-170", m, f160170);
								setResult("170-180", m, f170180);
								setResult("180-190", m, f180190);
								setResult("190-200", m, f190200);
								setResult("200-225", m, f200225);
								setResult("225-250", m, f225250);
								setResult("250-275", m, f250275);
								setResult("275-300", m, f275300);
								setResult("300-325", m, f300325);
								setResult("325-350", m, f325350);
								setResult("350-375", m, f350375);
								setResult("375-400", m, f375400);
								setResult("400-450", m, f400450);
								setResult("450-500", m, f450500);
							}
							saveAs("Results", subdir2 + videonaam2 + "ExtendedSummary.tsv");
						}	
			run("Close");
			print("Scale in scale in pixels/µm: "+inNumberScale);
			print(ChoiceType); 
			print("Segmentation method: "+ChoiceSegmentation);
			print("Background image method: "+ChoiceBackground);
			print("Watershed method: "+ChoiceWatershed);
			print("Edge detection High Threshold: "+inNumberEdgeHighThreshold);
			print("Edge detection Low Threshold: "+inNumberEdgeLowThreshold);
			print("minimum size: " +minSize2);
			print("maximum size: " +maxSize2);
			print("minimum circularity: " +minCircularity);
			print("maximum circularity: " +maxCircularity);
			print("Edge detection Smoothing: "+inNumberEdgeComputeSmoothing);
			print("Edge detection Sharpening: "+inNumberEdgeUnsharpMask);
			print("Seperator length: "+ (SeperatorLength*2));
			print("Convexity threshold: "+ WatershedConvexity);
			print("Frames for background substraction: "+FramesForBackground);
			print("Use additional histogram based binerization (1 = true, 0 = false): "+HistogramBinerization);
			print("Closing cycles when using histogram binerization: "+inNumberClosingCycles);
			print("Field of View correction factor (1 = true, 0 = false): "+FOVcfYesOrNo);
			print("Add scalebar to input (1 = true, 0 = false): " + AddScaleBar);
			print("Show processing steps (single image)(1 = true, 0 = false): " +ShowProcessingStepsBoolean);
			saveAs("Text", subdir2 + videonaam2 + "Settings");
			run("Close");
					
		}
    }
 if(AddScaleBar==true){
	for (t = 0; t < listThree.length; t++){
		open(subdir+listThree[t]);
		run("Set Scale...", "distance="+inNumberScale+" known=1 pixel=1 unit=µm");
		run("Scale Bar...", "width=100 height=12 font=42 color=White background=Black location=[Lower Right] bold overlay label");
		saveAs("png", subdir);	
		run("Close");
	}
}   
}


//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Analysis of maps with maps of images
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


if (ChoiceType == "Map containing maps of images" )
{
setBatchMode(true);
dir = getDirectory("Choose a folder");
listTwo = getFileList(dir);
listTwo = Array.sort(listTwo);
    for (i = 0; i < listTwo.length; i++) 
    {
   	    showProgress(i+1, listTwo.length);
        if(File.isDirectory(dir + File.separator + listTwo[i]))
        {
        	subdir = dir + listTwo[i];
     		listThree = getFileList(subdir);
     		NewDirOutput= subdir +"Output - ";
     		
			if(ChoiceBackground == "Median of multiple frames (videos/maps)"){
				for(y = 0; y<(minOf(FramesForBackground,listThree.length)) ; y++){
				open(subdir+listThree[y]);
				}
			run("Images to Stack", "name=background.tif title=[] use");
			run("Z Project...", "projection=Median");
			saveAs("tif", NewDirOutput+"background");
			close("\\Others");
			run("Close");
				
        	}

			
			
			for (n = 0; n < listThree.length; n++) 
				{  	
					if(ChoiceBackground == "Median of multiple frames (videos/maps)"){
					open(subdir + "Output - background.tif");	
					rename("background.tif");
					}
					open(subdir+listThree[n]);

//-------------------------------
//Start of code that is actually used to process the image
//------------------------------	
			
				if(WhiteParticles == true){run("Invert");} 
OrigineleAfbeelding = getTitle(); 
	run("8-bit"); 
	makeRectangle(0, 0, RowsRemovedFromEdges, RowsRemovedFromEdges); 
		run("Add...", "value=255 slice"); 
		makeRectangle(RowsRemovedFromEdges, 0, RowsRemovedFromEdges, RowsRemovedFromEdges); 
		run("Subtract...", "value=255 slice");
		if(ChoiceBackground == "Rolling ball from single image")
		{
			makeRectangle(0, 0, getWidth(), getHeight());
			run("Duplicate...", "title=background.tif");     //Only used when also using histogram thresholding in combination with canny edge detection
			run("Subtract Background...", "rolling="+RollingBall+" light create sliding");
			rename("background.tif");
		}
	imageCalculator("Subtract create 32-bit stack", OrigineleAfbeelding, "background.tif");
	run("8-bit");
	if(HistogramBinerization == true)
			{
	rename("BackgroundSubstractedImage");							//Only used when also using histogram thresholding in combination with canny edge detection
	run("Duplicate...", "title=BackgroundSubstractedImage2");     //Only used when also using histogram thresholding in combination with canny edge detection
			}
			
	//Volgende stap bepaalt de gevoeligheid van de analyse, hoe hoger de mask waarde (van 0 tot 0.9) hoe gevoeliger de analyse
	run("Unsharp Mask...", "radius=1 mask=inNumberEdgeUnsharpMask");
							

	run("FeatureJ Edges", "compute smoothing="+inNumberEdgeComputeSmoothing+" suppress lower="+inNumberEdgeLowThreshold+" higher="+inNumberEdgeHighThreshold);	
	
	rename("BackgroundSubstractedImage3");	
		run("8-bit");
		run("EDM Binary Operations", "iterations="+ClosingCycles+" operation=dilate");
			makeRectangle(0, 0, RowsRemovedFromEdges, getHeight);		
			run("Add...", "value=255 slice");
			makeRectangle(getWidth-RowsRemovedFromEdges,0, RowsRemovedFromEdges,getHeight);
			run("Add...", "value=255 slice");
			setOption("BlackBackground", true);
			run("Make Binary");	
			run("Fill Holes");
			makeRectangle(RowsRemovedFromEdges,0,getWidth-RowsRemovedFromEdges-RowsRemovedFromEdges,getHeight);
			run("Crop");
			makeRectangle(0, 0, getWidth, RowsRemovedFromEdges);
			run("Add...", "value=255 slice");
			makeRectangle(0,getHeight-RowsRemovedFromEdges,getWidth,RowsRemovedFromEdges);
			run("Add...", "value=255 slice");
			setOption("BlackBackground", true);
			run("Make Binary");	
			run("Fill Holes");
			makeRectangle(0,RowsRemovedFromEdges,getWidth,getHeight-RowsRemovedFromEdges-RowsRemovedFromEdges);
			run("Crop");
			run("EDM Binary Operations", "iterations="+ClosingCycles+" operation=erode");
			run("EDM Binary Operations", "iterations=1 operation=erode");
			run("EDM Binary Operations", "iterations=1 operation=dilate");
							

			//Steps for also doing a histogram based binerization
			if(HistogramBinerization == true)
			{
				selectWindow("BackgroundSubstractedImage");
				if(GaussianBlurBeforeIntensityThresholding>0){
				run("Gaussian Blur...", "sigma="+GaussianBlurBeforeIntensityThresholding);
				}
				setAutoThreshold("Default");
				run("Convert to Mask");	
				makeRectangle(0, 0, RowsRemovedFromEdges, getHeight);		
				run("Add...", "value=255 slice");
				makeRectangle(getWidth-RowsRemovedFromEdges,0, RowsRemovedFromEdges,getHeight);
				run("Add...", "value=255 slice");
				setOption("BlackBackground", true);
				run("Make Binary");	
				run("Fill Holes");
				makeRectangle(RowsRemovedFromEdges,0,getWidth-RowsRemovedFromEdges-RowsRemovedFromEdges,getHeight);
				run("Crop");
				makeRectangle(0, 0, getWidth, RowsRemovedFromEdges);
				run("Add...", "value=255 slice");
				makeRectangle(0,getHeight-RowsRemovedFromEdges,getWidth,RowsRemovedFromEdges);
				run("Add...", "value=255 slice");
				setOption("BlackBackground", true);
				run("Make Binary");	
				run("Fill Holes");
				makeRectangle(0,RowsRemovedFromEdges,getWidth,getHeight-RowsRemovedFromEdges-RowsRemovedFromEdges);
				run("Crop");
				if(OnlyHistogramBinerization == false || ChoiceSegmentation == "Intensity thresholding with edge seeding"){
				run("BinaryReconstruct ", "mask=BackgroundSubstractedImage seed=BackgroundSubstractedImage3 create white");
					if (ChoiceSegmentation != "Intensity thresholding with edge seeding"){
						rename("ReconstructedImage");
						imageCalculator("OR", "ReconstructedImage" , "BackgroundSubstractedImage3");
					}
				}
				run("EDM Binary Operations", "iterations=inNumberClosingCycles operation=dilate");
				run("EDM Binary Operations", "iterations=inNumberClosingCycles operation=erode");
				run("Fill Holes");
			}
			if (WatershedBoolean == true){
				run("Watershed");
			} else if(WatershedIrregularFeaturesBoolean == true){
				run("Watershed Irregular Features", "erosion="+SeperatorLength+" convexity_threshold="+WatershedConvexity+" separator_size=0-Infinity");
			} 

			rename(OrigineleAfbeelding);
			//Volgende stap bepaalt de schaal van de afbeelding, voeg hier de waarde in die opgegeven stonden bij de kalibratieafbeelding (Distance in pixel = distance; known distance = known)						
			run("Set Scale...", "distance="+inNumberScale+" known=1 pixel=1 unit=µm");
			FinalHeightImage = getHeight();		//deze zou nog ergens anders komen te staan zodat hij niet iedere keer opnieuw moet worden bepaald
			FinalWidthImage = getWidth();		//deze zou nog ergens anders komen te staan zodat hij niet iedere keer opnieuw moet worden bepaald
			run("Analyze Particles...", "size="+minSize+"-"+maxSize+" pixel circularity="+minCircularity+"-"+maxCircularity+" show=Nothing display include exclude summarize add");
		close();
		selectWindow(OrigineleAfbeelding);
		makeRectangle(RowsRemovedFromEdges, RowsRemovedFromEdges, (getWidth-RowsRemovedFromEdges-RowsRemovedFromEdges), (getHeight-RowsRemovedFromEdges-RowsRemovedFromEdges));
		run("Crop");
			if(WhiteParticles == true){run("Invert");} 
										

//-------------------------------
//End of code that is actually used to process the image
//------------------------------	


						roiManager("Show All without labels");
						run("Flatten");			
						run("Set Scale...", "distance="+inNumberScale+" known=1 pixel=1 unit=µm");
						run("Scale Bar...", "width=100 height=12 font=42 color=White background=Black location=[Lower Right] bold overlay label");
						roiManager("Reset");
					if(ChoiceBackground == "Background is open and named background.tif"){
					saveAs("png", NewDirOutput + OrigineleAfbeelding);	
					selectImage("background.tif");
					close("\\Others"); //sluit alle andere afbeeldingen: memory			
					} else {
					close("\\Others"); //sluit alle andere afbeeldingen: memory
					saveAs("png", NewDirOutput + OrigineleAfbeelding);	
					close();			
					}	
				}
 			selectWindow("Results");  //activate results table



			//Getting necessary information out of results
				if(FOVcfYesOrNo == false) 
				{
					Table.applyMacro("Diameter=sqrt(Area/3.14*4); Diameter3=Diameter*Diameter*Diameter; Diameter4=Diameter3*Diameter");
					FOVcfMeasurements = newArray(nResults);
					diameterMeasurements = newArray(nResults);
					diameter3Measurements = newArray(nResults);
					diameter4Measurements = newArray(nResults);
					for(k=0; k<nResults; k++) 
					{
						FOVcfMeasurements[k] = 1;
						diameterMeasurements[k] = getResult("Diameter", k);
						diameter3Measurements[k] = getResult("Diameter3", k);
					    diameter4Measurements[k] = getResult("Diameter4", k);  
					}
				}
				else if (FOVcfYesOrNo == true)
				{
					Table.applyMacro("Diameter=sqrt(Area/3.14*4); Diameter3=Diameter*Diameter*Diameter; Diameter4=Diameter3*Diameter; FOVcf=("+FinalWidthImage+"*"+FinalHeightImage+")/(("+FinalHeightImage+"-Height)*("+FinalWidthImage+"-Width))");
					FOVcfMeasurements = newArray(nResults);
					diameterMeasurements = newArray(nResults);
					diameter3Measurements = newArray(nResults);
					diameter4Measurements = newArray(nResults);
					for(k=0; k<nResults; k++) 
					{
						FOVcfMeasurements[k] = getResult("FOVcf", k);		
						diameterMeasurements[k] = getResult("Diameter", k);
						diameter3Measurements[k] = getResult("Diameter3", k);
					    diameter4Measurements[k] = getResult("Diameter4", k);			    
					}

				}
			saveAs("Results", NewDirOutput + "Results.tsv");
			run("Close");

			//Verwerken van summary data
			selectWindow("Summary");  //activate summary table
			IJ.renameResults("Results");
			totalCount = 0;
			if(FOVcfYesOrNo == true)
			{
				for(m=0; m<nResults; m++) 
					{
						D1som = 0;
						D4som = 0;
						D3som = 0;
						FOVcfsom = 0;
						SphericalVolume = 0;
						for(h=totalCount; h<totalCount+getResult("Count",m);h++)
    						{
								D1som = D1som + (diameterMeasurements[h]*FOVcfMeasurements[h]);
								D4som = D4som + (diameter4Measurements[h]*FOVcfMeasurements[h]);
								D3som = D3som + (diameter3Measurements[h]*FOVcfMeasurements[h]);
								FOVcfsom += FOVcfMeasurements[h];
								SphericalVolume += FOVcfMeasurements[h]*4*3.141*(diameterMeasurements[h]*diameterMeasurements[h]*diameterMeasurements[h])/(8*3);
    						}
    					totalCount += getResult("Count", m);
						setResult("D4.3", m, D4som/D3som);
						setResult("D1.0", m, D1som/getResult("Count" ,m)); 						
						setResult("FOV corrected counts", m, FOVcfsom); 
						setResult("Spherical Volume", m, SphericalVolume); 
   				 	}
			} 
			else 
			{
				for(m=0; m<nResults; m++) 
					{
						D1som = 0;
						D4som = 0;
						D3som = 0;
						for(h=totalCount; h<totalCount+getResult("Count",m);h++)
    						{
								D1som += diameterMeasurements[h];
								D4som += diameter4Measurements[h];
								D3som += diameter3Measurements[h];
    						}
    					totalCount += getResult("Count", m);
						setResult("D4.3", m, D4som/D3som);
						setResult("D1.0", m, D1som/getResult("Count" ,m)); 

   				 	}
			}
			saveAs("Results", NewDirOutput + "Summary.tsv");
					if(FOVcfYesOrNo == true && ExtendedResults == true)
						totalCount = 0;
						{
							for(m=0; m<nResults; m++) 
							{
								f010 = 0;
								f1020 = 0;
								f2030 = 0;
								f3040 = 0; 
								f4050 = 0;
								f5060 = 0; 
								f6070 = 0;
								f7080 = 0;
								f8090 = 0;
								f90100 = 0; 
								f100110 = 0;
								f110120 = 0;
								f120130 = 0; 
								f130140 = 0;
								f140150 = 0;
								f150160 = 0;
								f160170 = 0;
								f170180 = 0;
								f180190 = 0;
								f190200 = 0;
								f200225 = 0;
								f225250 = 0;
								f250275 = 0;
								f275300 = 0;
								f300325 = 0;
								f325350 = 0;
								f350375 = 0;
								f375400 = 0;
								f400450 = 0;
								f450500 = 0;
									for(h=totalCount; h<totalCount+getResult("Count",m);h++)
				    						{
												if(diameterMeasurements[h]<10){
													f010 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<20){
													f1020 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<30){
													f2030 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<40){
													f3040 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<50){
													f4050 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<60){
													f5060 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<70){
													f6070 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<80){
													f7080 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<90){
													f8090 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<100){
													f90100 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<110){
													f100110 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<120){
													f110120 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<130){
													f120130 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<140){
													f130140 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<150){
													f140150 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<160){
													f150160 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<170){
													f160170 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<180){
													f170180 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<190){
													f180190 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<200){
													f190200 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<225){
													f200225 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<250){
													f225250 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<275){
													f250275 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<300){
													f275300 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<325){
													f300325 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<350){
													f325350 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<375){
													f350375 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<400){
													f375400 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<450){
													f400450 += FOVcfMeasurements[h];
												} else if (diameterMeasurements[h]<500){
													f450500 += FOVcfMeasurements[h];
												}
				    						}
			    				totalCount += getResult("Count", m);
								setResult("0-10", m, f010);
								setResult("10-20", m, f1020);
								setResult("20-30", m, f2030);
								setResult("30-40", m, f3040);
								setResult("40-50", m, f4050);
								setResult("50-60", m, f5060);
								setResult("60-70", m, f6070);
								setResult("70-80", m, f7080);
								setResult("80-90", m, f8090);
								setResult("90-100", m, f90100);
								setResult("100-110", m, f100110);
								setResult("110-120", m, f110120);
								setResult("120-130", m, f120130);
								setResult("130-140", m, f130140);
								setResult("140-150", m, f140150);
								setResult("150-160", m, f150160);
								setResult("160-170", m, f160170);
								setResult("170-180", m, f170180);
								setResult("180-190", m, f180190);
								setResult("190-200", m, f190200);
								setResult("200-225", m, f200225);
								setResult("225-250", m, f225250);
								setResult("250-275", m, f250275);
								setResult("275-300", m, f275300);
								setResult("300-325", m, f300325);
								setResult("325-350", m, f325350);
								setResult("350-375", m, f350375);
								setResult("375-400", m, f375400);
								setResult("400-450", m, f400450);
								setResult("450-500", m, f450500);
							}
							saveAs("Results", NewDirOutput + "Extended Summary.tsv");
						}
			run("Close");
			print("Scale in scale in pixels/µm: "+inNumberScale);
			print(ChoiceType); 
			print("Background image method: "+ChoiceBackground);
			print("Edge detection High Threshold: "+inNumberEdgeHighThreshold);
			print("Edge detection Low Threshold: "+inNumberEdgeLowThreshold);
			print("Edge detection Smoothing: "+inNumberEdgeComputeSmoothing);
			print("Edge detection Sharpening: "+inNumberEdgeUnsharpMask);
			print("Frames for background substraction: "+FramesForBackground);
			print("Use additional histogram based binerization (1 = true, 0 = false): "+HistogramBinerization);
			print("Closing cycles when using histogram binerization: "+inNumberClosingCycles);
			print("Field of View correction factor (1 = true, 0 = false): "+FOVcfYesOrNo);
			print("Add scalebar to input (1 = true, 0 = false): " + AddScaleBar);
			print("Show processing steps (single image)(1 = true, 0 = false): " +ShowProcessingStepsBoolean);
			print("minimum size: " +minSize2);
			print("maximum size: "+maxSize2);
			print("minimum circularity: " +minCircularity);
			print("maximum circularity: " +maxCircularity);
			print("watershed(1 = true, 0 = false): " +WatershedBoolean); 
			print("watershed irregular features (1 = true, 0 = false): " +WatershedIrregularFeaturesBoolean); 
			print("Seperator length: "+ (SeperatorLength*2));
			print("Convexity threshold: "+ WatershedConvexity);
			saveAs("Text", NewDirOutput + " Analysis Settings");
			run("Close");
					
		}
    }
}


//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//Preview 
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


if (ChoiceType == "Preview (press ok for preview)")
{
	setBatchMode(false);
	OrigineleAfbeelding = getTitle(); 
	selectImage(OrigineleAfbeelding);
	setBatchMode(true);
	if(WhiteParticles == true){run("Invert");} 
	OriginalHeight = getHeight();
	OriginalWidth = getWidth();
	
	run("Duplicate...", "title=previewProcessing"); 
	run("8-bit"); 
			//background substraction: Voor deze stap is het noodzakelijk dat een achtergrondafbeelding met de naam "background.tif" openstaat
			if(ChoiceBackground == "Rolling ball from single image")
			{
				makeRectangle(0, 0, getWidth(), getHeight());
				run("Duplicate...", "title=background.tif");     //Only used when also using histogram thresholding in combination with canny edge detection
				run("Subtract Background...", "rolling="+RollingBall+" light create sliding");
				rename("background.tif");
			} else {
				makeRectangle(0, 0, RowsRemovedFromEdges, RowsRemovedFromEdges); 
				run("Add...", "value=255 slice"); 
				makeRectangle(RowsRemovedFromEdges, 0, RowsRemovedFromEdges, RowsRemovedFromEdges); 
				run("Subtract...", "value=255 slice");		
			}
	imageCalculator("Subtract create 32-bit stack", "previewProcessing", "background.tif");
	run("8-bit");
	rename("AfterBackgroundSubstraction");		
	run("Duplicate...", "title=AfterHistogramBinerization");  
	run("Duplicate...", "title=BeforeCannyEdgeDetection");        
	run("Unsharp Mask...", "radius=1 mask=inNumberEdgeUnsharpMask");						
	run("FeatureJ Edges", "compute smoothing="+inNumberEdgeComputeSmoothing+" suppress lower="+inNumberEdgeLowThreshold+" higher="+inNumberEdgeHighThreshold);	
	rename("AfterCannyEdgeDetection");	
	selectImage("BeforeCannyEdgeDetection");
	run("Close");
	selectImage("AfterCannyEdgeDetection");
	run("Duplicate...", "title=AfterCannyEdgeDetectionAndMorphologicalOperators");  
		run("8-bit");
		run("EDM Binary Operations", "iterations="+ClosingCycles+" operation=dilate");
			makeRectangle(0, 0, RowsRemovedFromEdges, getHeight);		
			run("Add...", "value=255 slice");
			makeRectangle(getWidth-RowsRemovedFromEdges,0, RowsRemovedFromEdges,getHeight);
			run("Add...", "value=255 slice");
			setOption("BlackBackground", true);
			run("Make Binary");	
			run("Fill Holes");
			makeRectangle(RowsRemovedFromEdges,0,getWidth-RowsRemovedFromEdges-RowsRemovedFromEdges,getHeight);
			run("Crop");
			makeRectangle(0, 0, getWidth, RowsRemovedFromEdges);
			run("Add...", "value=255 slice");
			makeRectangle(0,getHeight-RowsRemovedFromEdges,getWidth,RowsRemovedFromEdges);
			run("Add...", "value=255 slice");
			setOption("BlackBackground", true);
			run("Make Binary");	
			run("Fill Holes");
			makeRectangle(0,RowsRemovedFromEdges,getWidth,getHeight-RowsRemovedFromEdges-RowsRemovedFromEdges);
			run("Crop");
			run("EDM Binary Operations", "iterations="+ClosingCycles+" operation=erode");
			run("EDM Binary Operations", "iterations=1 operation=erode");
			run("EDM Binary Operations", "iterations=1 operation=dilate");
			//run("Watershed Irregular Features", "erosion=3 convexity_threshold=0 separator_size=0-8");				

			//Steps for also doing a histogram based binerization
			if(HistogramBinerization == true)
			{
				selectWindow("AfterHistogramBinerization");
				if(GaussianBlurBeforeIntensityThresholding>0){
				run("Gaussian Blur...", "sigma="+GaussianBlurBeforeIntensityThresholding);
				}
				setAutoThreshold("Default");
				run("Convert to Mask");	
				makeRectangle(0, 0, RowsRemovedFromEdges, getHeight);		
				run("Add...", "value=255 slice");
				makeRectangle(getWidth-RowsRemovedFromEdges,0, RowsRemovedFromEdges,getHeight);
				run("Add...", "value=255 slice");
				setOption("BlackBackground", true);
				run("Make Binary");	
				run("Fill Holes");
				makeRectangle(RowsRemovedFromEdges,0,getWidth-RowsRemovedFromEdges-RowsRemovedFromEdges,getHeight);
				run("Crop");
				makeRectangle(0, 0, getWidth, RowsRemovedFromEdges);
				run("Add...", "value=255 slice");
				makeRectangle(0,getHeight-RowsRemovedFromEdges,getWidth,RowsRemovedFromEdges);
				run("Add...", "value=255 slice");
				setOption("BlackBackground", true);
				run("Make Binary");
				run("Fill Holes");
				makeRectangle(0,RowsRemovedFromEdges,getWidth,getHeight-RowsRemovedFromEdges-RowsRemovedFromEdges);
				run("Crop");
				run("Duplicate...", "title=AfterHistogramBinerization2");
				if(OnlyHistogramBinerization == false || ChoiceSegmentation == "Intensity thresholding with edge seeding"){ 
				run("BinaryReconstruct ", "mask=AfterHistogramBinerization2 seed=AfterCannyEdgeDetectionAndMorphologicalOperators create white");
					if (ChoiceSegmentation != "Intensity thresholding with edge seeding"){
					rename("toClose");
					run("Duplicate...", "title=AfterMerging");  
					selectImage("toClose");
					run("Close");
					selectImage("AfterMerging");
					imageCalculator("OR", "AfterMerging" , "AfterCannyEdgeDetectionAndMorphologicalOperators");
					}
				}
				run("EDM Binary Operations", "iterations=inNumberClosingCycles operation=dilate");
				run("EDM Binary Operations", "iterations=inNumberClosingCycles operation=erode");
				run("Duplicate...", "title=AfterWatershed");  
			} else {
				selectImage("AfterHistogramBinerization");
				run("Close"); 
			}
			if (WatershedBoolean == true){
				run("Watershed");
			} else if(WatershedIrregularFeaturesBoolean == true){
				run("Watershed Irregular Features", "erosion="+SeperatorLength+" convexity_threshold="+WatershedConvexity+" separator_size=0-Infinity");
			} 

			run("Duplicate...", "title=BeforePreview");
			//  
			//run("BinaryKillBorders ", "top right bottom left white");
			//
			run("Analyze Particles...", "size="+minSize+"-"+maxSize+" pixel circularity="+minCircularity+"-"+maxCircularity+" show=Masks include exclude");
			selectImage("Mask of BeforePreview");
			run("Invert");
			run("Canvas Size...", "width="+OriginalWidth+" height="+OriginalHeight+" position=Center");
			run("Create Selection");
			roiManager("Reset");
			setBatchMode(false);
			run("ROI Manager...");
			roiManager("Add");
			close("Mask of BeforePreview");
			selectWindow(OrigineleAfbeelding);
			if(WhiteParticles == true){run("Invert");} 
			roiManager("Show All without labels");
	}
}
}

//Copyright (c) 2020 Arne Vancleef -- full license can be found on Github
//Publication in process - please refer to this in the future
//We would like to thank several developers for their plugins: (copyright belongs to them and can be found in the following links)
//J. Brocher for the boivoxxel plugin https://www.biovoxxel.de & https://imagej.net/BioVoxxel_Toolbox.
//E. Meijering for the imageScience plugin. http://sites.imageJ.net/ImageScience/ 
//G. Landini for the Morphology plugin https://blog.bham.ac.uk/intellimic/g-landini-software/ & http://sites.imageJ.net/Landini/. 