# changepoint_analysis

function [num_of_changepoint, loc_of_changepoint] = changepoint_bootstrap2(x)

% Created by Jamilah Foucher, 2017 following the instructions at http://www.variation.com/cpa/tech/changepoint.html .

% Purpose: detect significant changes points in a signal using a bootstrap statistical analysis (cumulative sum).

% Input VARIABLES:
% (1) x is the signal (that you would like to detect significant changes points)
% 
% Output VARIABLES:
% (1) number of changepoints
% 
% (2) location of changepoints

Medium blog (Practicing DatScy): https://medium.com/@j622amilah/
