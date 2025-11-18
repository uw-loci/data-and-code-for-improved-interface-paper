from ij import IJ
from ij.plugin import ZProjector
from ij.process import ImageConverter
import os
from ij import WindowManager


folder = 'C:\\Users\\jonat\\OneDrive - UW-Madison\\LOCI\\Jonathan\\tendonnew'
subfolders = [f for f in os.listdir(folder) if os.path.isdir(os.path.join(folder,f))]

output_folder = os.path.join(folder, 'bit8')
if not os.path.exists(output_folder):
    os.makedirs(output_folder)	

for subfolder in subfolders:
	subpath = os.path.join(folder,subfolder)
	files = os.listdir(subpath)
	ims = [f for f in files if f.lower().endswith('.tif')]
	
	for im in ims:
		
		fullfile = os.path.join(subpath,im)
		
#		imp = IJ.openImage(fullfile);
		IJ.run("Bio-Formats", "open=[" + fullfile+ "] autoscale color_mode=Default open_files rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		imp = WindowManager.getCurrentImage()
		imp = ZProjector.run(imp,"sum");
		ImageConverter.setDoScaling(True);
		IJ.run(imp, "8-bit", "");
		IJ.saveAs(imp, "Tiff", os.path.join(output_folder,'sum8bit' + im));
		IJ.run("Close All", "");
		
		
		