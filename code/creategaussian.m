function gaussian = creategaussian(training_set)

[numOfPlayers, numOfStats] = size(training_set);

a = zeros(numOfPlayers, numOfStats-2);
% Get specific stats here

%First column is wRC+
a(:,1:numOfStats-2) = training_set(:,2:numOfStats-1);

sigma = cov(a);

%Calculate the means
mu = zeros(1, numOfStats-2);

for i = 1:15
    mu(1,i) = mean(a(:,i));
end

gaussian = gmdistribution(mu, sigma);

end