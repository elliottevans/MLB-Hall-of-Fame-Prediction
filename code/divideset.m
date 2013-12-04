function [set_one, set_zero] = divideset(big_set)

numOfOnes = sum(big_set(:,17));

[numOfPlayers, numOfStats] = size(big_set);

numOfZeroes = numOfPlayers - numOfOnes;

set_one = zeros(numOfOnes, numOfStats);
set0 = zeros(numOfZeroes, numOfStats);

one_counter = 0;
zero_counter = 0;

for i=1:numOfPlayers
    if big_set(i,17)==1
        set_one(one_counter+1,:) = big_set(i,:);
        one_counter = one_counter+1;
    else
        set_zero(zero_counter+1,:) = big_set(i,:);
        zero_counter = zero_counter+1;
    end
end

end