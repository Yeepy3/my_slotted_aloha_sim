clear; clc;

% Parameters
numNodes = 5;
numSlots = 20;
init_transmission_prob = 0.1;
iteration = 10;

% test_initialization
transmission_prob = zeros(1,iteration) + init_transmission_prob;
Efficiency_array = zeros(1,iteration);

for i = 1:iteration
    Efficiency_array(i) = test_slotted_aloha(numNodes, numSlots, transmission_prob(i));
    if i < iteration
        transmission_prob(i+1) = transmission_prob(i) + 0.01;
    else
        transmission_prob(i) = transmission_prob(i);
    end
end

figure;
plot(transmission_prob, Efficiency_array);
ylim([0 100]);
xlabel('Transmission Probability');
ylabel('Efficiency');
grid on;
title('Efficiency vs. Transmission Probability');