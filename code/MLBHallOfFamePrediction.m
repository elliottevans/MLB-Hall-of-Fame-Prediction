function [modelErrors] = MLBHallOfFamePrediction(data,numFolds,statArray,w)
% MLBHallOfFamePrediction
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
% AUTHORS: Elliott Evans, Jon Ford, Corey McMahon

    % body   
    % num is number of instances
    [numPlayers,numAttributes] = size(data);

    % construct the n sets
    instances=1:numPlayers;
    samples=datasample(instances,numPlayers,'Replace',false);
    
    % size of validation sets
    validationSetSize=floor(numPlayers/numFolds);
    
    % each row of validationSets is one validation set
    % each number in each row represents one player
    validationSets=zeros(numFolds,validationSetSize);
    for i=1:numFolds
        validationSets(i,:)=samples((i*validationSetSize-(validationSetSize-1)):(i*validationSetSize));
    end
    
    trainingSetSize=(numFolds-1)*validationSetSize;
    modelErrors=zeros(1,numFolds);
    baselineErrors=zeros(1,numFolds);
    
    for i=1:numFolds
        % i corresponds to the current row of validationSets that we will
        % test on. Players in this row are the testingSet
        testingSetRows=validationSets(i,:);
        testingSet=zeros(validationSetSize,numAttributes);
        
        % create the testing set
        currentRow=1;
        for player=testingSetRows
            testingSet(currentRow,:)=data(player,:);
            currentRow=currentRow+1;
        end
        
        trainingSet=zeros(trainingSetSize,numAttributes);
        currentRow=1;
        for j=1:numFolds
            if (j ~= i)
                % then this row is part of the training set
                trainingSetRows=validationSets(j,:);
                for player=trainingSetRows
                    trainingSet(currentRow,:)=data(player,:);
                    currentRow=currentRow+1;
                end
            end
        end
        [HoF, nonHoF] = divideset(trainingSet);
        gaussianHoF = creategaussian(HoF,statArray);          
        gaussianNonHoF = creategaussian(nonHoF,statArray);      
        
        % classify as HoF or not
        numMisclassifications=0;
        numBaselineMisclassifications=0;
        for player=1:validationSetSize
            playerStats=testingSet(player,statArray);
            zHoF=pdf(gaussianHoF,playerStats);
            zNonHoF=pdf(gaussianNonHoF,playerStats);
            if (zHoF > zNonHoF+w)
                classification = 1;
            else
                classification = 0;
            end
            
            actualClassification=testingSet(player,end);
            if (actualClassification~=classification)
                numMisclassifications=numMisclassifications+1;
            elseif (actualClassification==1)
                numBaselineMisclassifications=numBaselineMisclassifications+1;
            end
            
%            if(actualClassification==1 && classification==1)
%                disp('CORRECTLY GOT A HOFer');
%            end
%            if(actualClassification==0 && classification==0)
%                disp('CORRECTLY GOT A SCRUB');
%            end
%            if(actualClassification==1 && classification==0)
%                disp('ACCIDENTALLY CALLED A HALL OF FAMER A SCRUB*********');
%            end
%            if(actualClassification==0 && classification==1)
%                disp('ACCIDENTALLY CALLED A SCRUB A HALL OF FAMER*********');
%            end
        end
        modelError=numMisclassifications/validationSetSize;
        baselineError=numBaselineMisclassifications/validationSetSize;
        modelErrors(i)=modelError;
        baselineErrors(i)=baselineError;
    end

end