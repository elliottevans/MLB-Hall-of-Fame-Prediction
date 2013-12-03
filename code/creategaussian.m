function gaussian = creategaussian(training_set)

[numOfPlayers, numOfStats] = size(training_set);

% Get specific stats here
a = zeros(numOfPlayers, 2);
%First column is wRC+
a(:,1) = training_set(:,14);
%Second column is WAR
a(:,2) = training_set(:,16);

sigma = cov(a);
disp(sigma);

mu_one = mean(a(:,1));
mu_two = mean(a(:,2));

disp(mu_one);
disp(mu_two);

p = ones(1,1)/2;

gaussian = gmdistribution([mu_one mu_two], sigma, p);

%ezsurf(@(x,y)pdf(obj,[x y]),[0 200],[-5 150])

disp(gaussian);



end