# RP-cone-count
Matlab code to count the number of labeled cone photoreceptor nuclei in a flat-mount degenerating retina.

# Authorship & Publications
This set of Matlab code was created in Harvard Medical School originally by Marcelo Cicconet with updates from Connie Cepko Lab members: 
Emma West, David Wu and Yunlu "Sawyer" Xue.
This set of code was first used for publication in (Wu DM et al., 2021, JCI Insight; PMID: 33491671).
This set of code was updated, described, and deposited to Github by Yunlu Xue for a separate publication (Xue Y et al., 2021, eLife).

This set of code is released to public for non-profit research purpose only, thus prohibited to be used for any commercial purposes.
Harvard Uniersity and the Authors retains all the right associated with this set of code.

# User guide of sawyer.m
1. Download the (Spot Detection Code) folder
2. Setup the correct directory folder.
3. Make sure the MATLAB program installed appropriate APPs.
4. A sample Commond for (Xue Y et al. 2021) image analysis looks like this.
     >> [im,spots,n]=sawyer('/Users/xue/Desktop/for Matlab/20191029_TxCS_C4.tif',794.1,1636,1620,1.3,13);
5. Inside () in order: Image, radius (r), X of center (cx), Y of center (cy), sigma of spot distribution (sigma), detection threshold (logThr). 
6. [n] in workspace will be the number of counted cells within the radius of circle.
7. A sample image (20191029_TxCS_C4.tif) is available in (sample image) folder with following parameters. Result [n] = 3908:
     >> % r = 794.1, cx =	1636, cy = 1620, signma = 1.3, logThr = 13
8. Please use the "sawyer_MS.m" script to get a brighter sample image with magenta recogonition dots, e.g. Figure 1-figure supplement 1C in (Xue Y et al. 2021)
9. The image for analysis must be similar to the format/resolution/size of the sample image.
