% This demo script will extract the following visual statistics 
% for the sample image based on the sample bounding box:
%   visual size (area in pixels^2)
%   distance from center
%   contrast (weighted sum of LAB)
%   amount of edges
%   and proportion of edges 
% see separate document for how we measured number of objects

% Change this to your image name 
im = samplefull;

% Change this to your bounding box vertices
%   Note: Input must be two columns (x,y) reflecitng consecutive points on 
%   the continuous line / edge
%   See export script for getting this input from image labeller
b = boundingbox;

% Calculate visual size
placeholder;

% Calculate distance from center
placeholder;

% Export cropped photo centered on bounding box
placeholder;

% Calculate amount of edges
placeholder;

% Calculate proportion of edges
placeholder;

% Calculate contrast
placeholder;