function errors = runAllStats(data, numFolds)
%This calls MLBHallOfFamePrediction with each individual stat,
%outputting a matrix containing the error rates for each stat.
%Calculates error rate by running it 4 times on each stat,
%then averaging the 12 error rates.

run_this_many_times = 4;

currentErrors = zeros(17, 3);
errors = zeros(17,1);

for i = 2:16      
    
    for j = 1:run_this_many_times;
        currentErrors(i,:) = currentErrors(i,:) + MLBHallOfFamePrediction(data, numFolds, (i));
    end
    
    errors(i,1) = sum(currentErrors(i,:));   
end

errors = errors/(run_this_many_times * numFolds);

bar(errors(2:16,1));
set(gca,'XTickLabel',{'G', 'PA', 'HR', 'R', 'RBI', 'SB', 'ISO', 'BABIP', 'AVG', 'OBP', 'SLG', 'wOBA', 'wRC+', 'BsR', 'WAR'});
xlabel('Statistics');
ylabel('Error Rate');
title('Error Rates of Individual Statistics');
hold on;
x = plot(xlim,[.062 .062], 'r');
legend(x, 'Baseline Err Rt .062');

end
    
    
    