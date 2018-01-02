This code was made by Rohan Doshi
email: rdoshi@caltech.edu

This the code used to run the thermal camera/HD camera experiment for recording Bumblebee temperatures. 

The Cameras used were:

Thermal Camera: FLIR C2
HDCamera: DMK24uj003 (3856 x 2764 pixels, 10.7 MP)
http://www.theimagingsource.com/products/industrial-cameras/usb-3.0-monochrome/dmk24uj003/


The Code for Tracking can bee found in the BEEtag package Made by James Crall
email: 	james.crall@gmail.com
It can be found here: https://github.com/jamescrall/BEEtag
It is necessary for running the included programs

-Matlab (needs to be at least 2014b I believe) with Image Acquisition Toolbox

-HD Camera drivers (http://www.theimagingsource.com/support/downloads-for-windows/device-drivers/icwdmuvccamtis/)

-Matlab driver (http://www.theimagingsource.com/support/downloads-for-windows/extensions/icmatlabr2013b/)

You must get the Atlas SDK for MATLAB compatability with the FLIR C2 camera. You can find it here: https://flir.app.box.com/v/atlasSDK 

Read through ImageFusion.m first. Then read through GetSnaps.m. 