function [log_likelihood, derivative] = gradient_wrapper(full_theta,num_use)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here

train = 1;

%Load the appropriate clip IDS
if train
    load('train_IDS');
else
    lost('test_IDS');
end

%set the number of clips to use on each cycle
%num_use = 35;


%select random sample of the IDS
IDS = IDS(randsample(1:size(IDS,1),num_use,'false'),:);

log_likelihood = 0;
derivative = 0;

for row = 1:size(IDS,1)
    [log_likelihood_piece, derivative_piece] = ...
        get_subject_clip_training_info_4opt(full_theta,IDS(row,1),IDS(row,2));

    
    log_likelihood = log_likelihood + log_likelihood_piece;
    derivative = derivative + derivative_piece;
    
end

fprintf('log-likelihood value: %e\n', log_likelihood);



end

