function [w] = findOptW(data,numFolds,statArray,wInit,interval,threshold)
% findOptW finds the optimum weight to use in our gaussian classifier by
% using gradient descent.
%
% data is a matrix where rows are players
% and there are 17 columns described below
% For batting_all_careers.csv, the columns represent the following, in order:
% 1. playerid
% 2. G
% 3. PA
% 4. HR
% 5. R
% 6. RBI
% 7. SB
% 8. ISO
% 9. BABIP
% 10. AVG
% 11. OBP
% 12. SLG
% 13. wOBA
% 14. wRC+
% 15. BsR
% 16. WAR
% 17. HoF classification (1 if in, 0 if not)
%
% numFolds is the number of folds to use in cross validation
%
% statArray is an array containing any numbers 1,..,17 corresponding to the
% columns of data that will be used to create the gaussian. For example, if
% statArray=[4,5,6] then HR, R, and RBI will be the statistics used to the
% create the gaussian model
%
% w is the weight adjuster used when comparing the probability densities of
% the gaussian created for Hall of Famers vs Non Hall of Famers. The
% specific equation used is:
% if (pdf(HoF)>pdf(nonHoF)+w) then classify example as Hall of Famer
%
% interval is the amount to adjust w by at each step
%
% threshold defines the stopping point of the algorithm, the function
% returns w when gradient is less than this threshold
%
% AUTHORS: Elliott Evans, Jon Ford, Corey McMahon

w = wInit;
initialErrors=MLBHallOfFamePrediction(data,numFolds,statArray,w);
avgErrorPrev=mean(initialErrors);
gradient=1;
while (gradient > threshold)
    % get the errors of the models by moving in each direction
    errorsNeg=MLBHallOfFamePrediction(data,numFolds,statArray,w-interval);
    avgErrorNeg=mean(errorsNeg);
    errorsPos=MLBHallOfFamePrediction(data,numFolds,statArray,w+interval);
    avgErrorPos=mean(errorsPos);
    
    % find the gradients
    gradientPos=avgErrorPrev-avgErrorPos;
    gradientNeg=avgErrorPrev-avgErrorNeg;
    
    % adjust w appropriately
    % we want the largest gradient
    if (gradientPos>gradientNeg)
        w=w+interval;
        avgErrorPrev=avgErrorPos;
        gradient = gradientPos;
    else
        w=w-interval;
        avgErrorPrev=avgErrorNeg;
        gradient = gradientNeg;
    end
end