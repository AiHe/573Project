function [ full_theta_1 ] = moment_match_training()
%moment_match_training training
%   Detailed explanation goes here

% %Load the appropriate clip IDS
% if train
%     load('train_IDS');
% else
%     lost('test_IDS');
% end


semantic = 1;


num_s_clips = 95;

%     eta = 1;
%     epsilon = 1e-5;
%     max_t = 50;
    d_object_theta = 10;
    d_attribute_theta = 9;
    d_low_theta = 5;
    
    object_theta = rand(d_object_theta, d_object_theta);
    attribute_theta = rand(d_attribute_theta, 1);
    low_theta = rand(d_low_theta, 1);


%     load state_1_1.mat;
    
    
    %% use package to opt(l-bfgs)
    options = [];
    options.display = 'none';
    options.maxFunEvals = 1e4;
    options.Method = 'lbfgs';
%         options.LS_multi = 2;
%         options.LS_type = 0;
%         options.LS_interp = 1;
    options.useMex = 1;
    options.MaxIters = 25;
%         options.DERIVATIVECHECK = 1;
    if semantic
        full_theta_0 = [object_theta(:); attribute_theta(:); low_theta(:)];
%         load('reg_1_full__control_theta.mat');
%         full_theta_0 = reg_full_theta;
    else
        full_theta_0 = low_theta(:)/200;
    end
    full_theta_1 = minFunc(@(theta) gradient_wrapper(theta,num_s_clips,semantic),full_theta_0,options);
    
    %% previous method
%         
%     full_theta_0 = [object_theta(:); attribute_theta(:); low_theta(:)];
%     [phi_emp_sum, phi_theo_sum, ll_0, sum_Hessian, num_points] = get_subject_clip_training_info(...
%         subject_type,subject_num,object_theta,attribute_theta,low_theta);
%     derivation = phi_emp_sum - phi_theo_sum;
%     %% main loop
%     for t = 1 : max_t
%         
%         %% update
% %         full_theta_1 = full_theta_0 + 1e-3 * derivation;
% %         full_theta_1 = full_theta_0 + (1e-7*eye(size(sum_Hessian,1)) + sum_Hessian) \ derivation;
% 
% 
%         object_theta = reshape(full_theta_1(1: d_object_theta^2), d_object_theta, d_object_theta);
%         attribute_theta = full_theta_1(d_object_theta^2+1: d_object_theta^2+d_attribute_theta);
%         low_theta = full_theta_1(d_object_theta^2+d_attribute_theta+1: end);
%         
%         [phi_emp_sum, phi_theo_sum, ll_1, ~, num_points] = get_subject_clip_training_info(...
%             subject_type,subject_num,object_theta,attribute_theta,low_theta,true);
%         
%         derivation = phi_emp_sum - phi_theo_sum;
%         
%         
%         %% sub-update
% %         sub_t = 1;
% %         sub_max_t = 10;
% %         while(ll_1 < ll_0 && sub_t < sub_max_t) % worse
% %             
% %             eta = eta * 0.5;
% %             full_theta_1 = full_theta_0 + eta * (sum_Hessian \ derivation);
% %         
% %             full_theta_0 = full_theta_1;
% %             object_theta_1 = full_theta_1(1: d_object_theta);
% %             attribute_theta_1 = full_theta_1(d_object_theta+1, d_object_theta+d_attribute_theta);
% %             low_theta_1 = full_theta_1(d_object_theta+d_attribute_theta+1, end);
% %         
% %             ll_1 = log_likelihood(object_theta_1, attribute_theta_1, low_theta_1);
% %         end
% %         if(ll_1 > ll_0)
% %             eta = eta * 1.01;
% %         end
% 
%         
%         %% check termination
%         fprintf('[ll_1: %e, ll_0: %e]\n', ll_1, ll_0);
%         if(abs((ll_1-ll_0) / ll_0) < epsilon)
%             return;
%         end
% 
%         %% replacement
%         full_theta_0 = full_theta_1;
%         ll_0 = ll_1;
%     end
    
end

