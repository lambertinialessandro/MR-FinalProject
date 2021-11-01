### DESCRIPTION OF THE FILES ###

=> c3dExport.m (Function File)
	Description:
		Convert a *.c3d file into *.trc and *.mot file.


=> CenterOfMass.m (Code File)
	Description:
		Eval the center of mass.
	
	You will be asked to:
		- Select the folder from which to load the file;
		- Select the input file.


=> compute_gravity.m (Function File)
	Description:
		Compute the gravity component of the dynamic model.


=> compute_roc.m (Function File)
	Description:
		Compute the roc vector of the i-th component of the robot.


=> computeDynamicModel3R.m (Function File)
	Description:
		Compute the dynamic model of the 3R leg with the Moving Frames method.


=> connect2.m (Function File)
	Description:
		Plot the connection between 2 markers.


=> connect3.m (Function File)
	Description:
		Plot the connection between 3 markers.


=> connect4.m (Function File)
	Description:
		Plot the connection between 4 markers.


=> dataProcessing.m (Code File) ------ IMPORTANT!!
	Description:
		File used to prepare the data.
		In this file there are all the steps to convert a file from *.c3d to
		the final product, so the file *.trc and *.mot filtered.
		
		STEPS:
			- converting from c3d
				1. Reading *.c3d file;
				2. Converting in *.trc and *.mot;
				3. Saveing *.trc and *.mot file.
			- trc file
				1. Reading *.trc file;
				2. Gap Filling of the data;
				3. Saving data Filled;
				4. Filtering Data;
				5. Saving data Filtered.
			- mot file
				1. Reading *.mot file;
				2. Gap Filling of the data;
				3. Saving data Filled;
				4. Filtering Data;
				5. Saving data Filtered.
	
	You will be asked to:
		- Select the folder from which to load the files;
		- Select the folder from which to save the files;
		- Insert if you want to process all the files inside the folder;
		- Insert if they are all already converted to *.trc and *.mot;
			- If you do not want to process all the files, you will be
				asked to select the files.
		- Finally, Insert:
			- If you want to process only the *.trc;
			- Only the *.mot
			- Or both.


=> drawBody.m (Function File)
	Description:
		Plot one instance of the body.


=> findDHParameters.m (Code File) ------ IMPORTANT!!
	Description:
		File used to find the parameters for the Kinematic and
		Dynamic model of Sirine and Lina.
	
	You will be asked to:
		- Select the folder from which to load the file;
		- Select the input file.


=> findMarkersAndGenerateBody.m (Function File)
	Description:
		Construct the body and the index of the markers.
		The body is a structure containing the markers of each body-part
		and indexMarkers is the relation between marker name and number.


=> GapFiller.m (Class File)
	Description:
		This class manage the filling phase of the data.
		it find the better grade for the polinomial to fit the data.


=> getMarkerValsI.m (Function File)
	Description:
		Return the x, y and z value of a marker at time i.


=> KD_model.m (Code File) ------ IMPORTANT!!
	Description:
		File used to:
			- Build the Kinematic model of the humanoid
			- Show the evolution of the Kinematic model over time
			- Build the Dynamic model of the humanoid
	
	You will be asked to:
		- select the folder from which to load the file;
		- select the input file;
		- Insert if the model should use the Siline or Lina parameters.
		- Insert if you want to show the video or just 1 frame;
			- if you choose only 1 frame you will be asked to:
				- insert the desired one.


=> KD_model_complex.m (Code File) ------ IMPORTANT!!
	Description:
		This file is the same as KD_model.m, but in this case we have
		a more complex model, and more complex formulas (no humanoid plot)
		(computation time consuming)
	
	You will be asked to:
		- select the folder from which to load the file;
		- select the input file;
		- Insert if the model should use the Siline or Lina parameters.


=> loadDataFromMOT.m (Function File)
	Description:
		Load the data from the file following the MOT format.


=> loadDataFromTRC.m (Function File)
	Description:
		Load the data from the file following the TRC format.


=> mot_analisisi.m (Code File) ------ IMPORTANT!!
	Description:
		In this file we work on the *.mot file.
		We load and subdivide the data in steps.
		We plot the steps to check the values.
		(if we load a FILLED_*.mot file the final plot will show also the filtered and unfiltered signal, for comparison).
	
	You will be asked to:
		- select the folder from which to load the file;
		- select the input file;
		- Insert the step to plot.


=> motData.m (Class File)
	Description:
		This class manage the steps in the *.mot file.
		This class can filter and plot the force, point of pressure and moment of a step


=> plotGaitCycle.m (Function File)
	Description:
		Plot the gait circle of a marche


=> plotModel.m (Code File) ------ IMPORTANT!!
	Description:
		File that plot a marche.
		It can show also the marker not used and the trail for the markers.
	
	You will be asked to:
		- select the folder from which to load the file;
		- select the input file;
		- Insert if you want to plot all the markers;
		- Insert if you want to plot the trail of the markers;
		- Insert if you want to show the video or just 1 frame;
			- if you choose only 1 frame you will be asked to:
				- insert the desired one.


=> saveDataOnFileMOT.m (Function File)
	Description:
		Save the data inside the file following the MOT format.


=> saveDataOnFileTRC.m (Function File)
	Description:
		Save the data inside the file following the TRC format.


=> stability.m (Code File) ------ IMPORTANT!!
	Description:
		In this File we analize the stability of the subject.
		To do this we do:
			1. ;
			2. Build the Kinematic and Dynamic model;
			3. Evaluating Dcom;
			4. Filtering Dcom;
			5. Plotting stability with gait cycle.
	
	You will be asked to:
		- select the folder from which to load the file;
		- select the input file;
		- Insert if the model should use the Siline or Lina parameters.

