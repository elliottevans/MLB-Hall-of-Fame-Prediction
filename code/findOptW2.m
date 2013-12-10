function [w] = findOptW2(data,numFolds,statArray,wInit,interval,threshold)
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

    % body   
    % num is number of instances
    [numPlayers,numAttributes] = size(data);
    
    if (numFolds==1)
        % initialize values
        w = wInit;
        modelErrorPrev=1;
        gradient=1;
        
        % if numFolds is 1 then the user does not want to use cross
        % validation
        [HoF, nonHoF] = divideset(data);
        gaussianHoF = creategaussian(HoF,statArray);          
        gaussianNonHoF = creategaussian(nonHoF,statArray);
        
        % perform gradient descent
        while (gradient > threshold)
            % get the errors of the models by moving in each direction
            numMisclassificationsPos=0;
            numMisclassificationsNeg=0;
            
            % classify all players for both decresing the weights
            % and increasing the weights
            for player=1:numPlayers
                playerStats=data(player,statArray);
                zHoF=pdf(gaussianHoF,playerStats);
                zNonHoF=pdf(gaussianNonHoF,playerStats);
                
                if (zHoF > zNonHoF+w+interval)
                    classificationPos = 1;
                else
                    classificationPos = 0;
                end
                if (zHoF > zNonHoF+w-interval)
                    classificationNeg = 1;
                else
                    classificationNeg = 0;
                end

                actualClassification=data(player,end);
                if (actualClassification~=classificationPos)
                    numMisclassificationsPos=numMisclassificationsPos+1;
                elseif (actualClassification~=classificationNeg)
                    numMisclassificationsNeg=numMisclassificationsNeg+1;  
                end                
            end
            
            modelErrorPos=numMisclassificationsPos/numPlayers;
            modelErrorNeg=numMisclassificationsNeg/numPlayers;

            % find the gradients
            gradientPos=modelErrorPrev-modelErrorPos;
            gradientNeg=modelErrorPrev-modelErrorNeg;

            % adjust w appropriately
            % we want the largest gradient
            if (gradientPos>gradientNeg)
                w=w+interval;
                modelErrorPrev=modelErrorPos;
                gradient=gradientPos;
            else
                w=w-interval;
                modelErrorPrev=modelErrorNeg;
                gradient=gradientNeg;
            end
        end
    else
        % the user does want to use cross validation    

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
        % initialize values
        w = wInit;
        modelErrorPrev=1;
        gradient=1;

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
            
            % create the gaussians
            [HoF, nonHoF] = divideset(trainingSet);
            gaussianHoF = creategaussian(HoF,statArray);          
            gaussianNonHoF = creategaussian(nonHoF,statArray);      

            while (gradient > threshold)
                % get the errors of the models by moving in each direction
                numMisclassificationsPos=0;
                numMisclassificationsNeg=0;

                % classify all players for both decresing the weights
                % and increasing the weights
                for player=1:numPlayers
                    playerStats=data(player,statArray);
                    zHoF=pdf(gaussianHoF,playerStats);
                    zNonHoF=pdf(gaussianNonHoF,playerStats);

                    if (zHoF > zNonHoF+w+interval)
                        classificationPos = 1;
                    else
                        classificationPos = 0;
                    end
                    if (zHoF > zNonHoF+w-interval)
                        classificationNeg = 1;
                    else
                        classificationNeg = 0;
                    end

                    actualClassification=data(player,end);
                    if (actualClassification~=classificationPos)
                        numMisclassificationsPos=numMisclassificationsPos+1;
                    elseif (actualClassification~=classificationNeg)
                        numMisclassificationsNeg=numMisclassificationsNeg+1;  
                    end                
                end

                modelErrorPos=numMisclassificationsPos/numPlayers;
                modelErrorNeg=numMisclassificationsNeg/numPlayers;

                % find the gradients
                gradientPos=modelErrorPrev-modelErrorPos;
                gradientNeg=modelErrorPrev-modelErrorNeg;

                % adjust w appropriately
                % we want the largest gradient
                if (gradientPos>gradientNeg)
                    w=w+interval;
                    modelErrorPrev=avgErrorPos;
                    gradient=gradientPos;
                else
                    w=w-interval;
                    modelErrorPrev=avgErrorNeg;
                    gradient=gradientNeg;
                end
            end
        end
    end
end