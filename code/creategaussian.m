function gaussian = creategaussian(class_set, stat_array)

%stat_array is 1xn
%Don't use 1 or 17 in the stat array...plz.

[numOfPlayers, x] = size(class_set);

numOfStats = length(stat_array(1,:));

a = zeros(numOfPlayers, numOfStats);
% Get specific stats here

for i = 1:numOfStats
    a(:,i) = class_set(:,stat_array(i));
end

sigma = cov(a);

%Calculate the means
mu = zeros(1, numOfStats);
sig = zeros(1, numOfStats);

for i = 1:numOfStats
    mu(1,i) = mean(a(:,i));
    sig(1,i) = std(a(:,i));
end
   
gaussian = gmdistribution(mu, sigma);

if numOfStats == 2
    ezsurf(@(x,y)pdf(gaussian, [x y]), [mu(1,1)-3*sig(1,1) mu(1,1) + 3*sig(1,1)], [mu(1,2)-3*sig(1,2) mu(1,2) + 3*sig(1,2)]);
end
    
end