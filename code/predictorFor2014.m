function [] = predictorFor2014(training_set, statArray)
%This predicts who from the 2014 ballot will make the HOF

%1. playerid
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

players2014 = csvread('2014_HOF_Ballot_Players.csv');
playerStats = zeros(14, length(statArray));


for i = 1:14
    for j = 1:length(statArray)
        playerStats(i,j) = players2014(i, statArray(j));
    end
end

w = findOptW2(training_set, 1, statArray, 0, .000001,0);

[HoF,nonHoF] = divideset(training_set);

gaussianHoF = creategaussian(HoF, statArray);
gaussianNonHoF = creategaussian(nonHoF, statArray);

disp(playerStats);

for i = 1:14
    zHoF = pdf(gaussianHoF, playerStats(i,:));
    
    zNonHoF = pdf(gaussianNonHoF,playerStats(i,:));
    
    if(zHoF > zNonHoF+w)
        disp('HOF');
    else
        disp('SCRUB');
    end
end


   




end

