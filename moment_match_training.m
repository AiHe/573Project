function [ full_theta_1 ] = moment_match_training( subject_type, subject_num )
%moment_match_training training
%   Detailed explanation goes here

    eta = 1;
    epsilon = 1e-5;
    max_t = 50;
    d_object_theta = 10;
    d_attribute_theta = 9;
    d_low_theta = 5;
    
    object_theta = rand(d_object_theta, d_object_theta);
    attribute_theta = rand(d_attribute_theta, 1);
    low_theta = rand(d_low_theta, 1);

    
    full_theta_0 = [object_theta(:); attribute_theta(:); low_theta(:)];
    [phi_emp_sum, phi_theo_sum, ll_0, sum_Hessian, num_points] = get_subject_clip_training_info(...
        subject_type,subject_num,object_theta,attribute_theta,low_theta);
    derivation = phi_emp_sum - phi_theo_sum;

%     load state_1_1.mat;
    
    %% main part
    for t = 1 : max_t
        
        %% update
        full_theta_1 = full_theta_0 + 1e-3 * derivation;

%         full_theta_1 = full_theta_0 + (1e-7*eye(size(sum_Hessian,1)) + sum_Hessian) \ derivation;
        
        object_theta = reshape(full_theta_1(1: d_object_theta^2), d_object_theta, d_object_theta);
        attribute_theta = full_theta_1(d_object_theta^2+1: d_object_theta^2+d_attribute_theta);
        low_theta = full_theta_1(d_object_theta^2+d_attribute_theta+1: end);
        
        [phi_emp_sum, phi_theo_sum, ll_1, sum_Hessian, num_points] = get_subject_clip_training_info(...
            subject_type,subject_num,object_theta,attribute_theta,low_theta,true);
        
        derivation = phi_emp_sum - phi_theo_sum;
        
        
        %% sub-update
%         sub_t = 1;
%         sub_max_t = 10;
%         while(ll_1 < ll_0 && sub_t < sub_max_t) % worse
%             
%             eta = eta * 0.5;
%             full_theta_1 = full_theta_0 + eta * (sum_Hessian \ derivation);
%         
%             full_theta_0 = full_theta_1;
%             object_theta_1 = full_theta_1(1: d_object_theta);
%             attribute_theta_1 = full_theta_1(d_object_theta+1, d_object_theta+d_attribute_theta);
%             low_theta_1 = full_theta_1(d_object_theta+d_attribute_theta+1, end);
%         
%             ll_1 = log_likelihood(object_theta_1, attribute_theta_1, low_theta_1);
%         end
%         if(ll_1 > ll_0)
%             eta = eta * 1.01;
%         end

        
        %% check termination
        fprintf('[ll_1: %e, ll_0: %e]\n', ll_1, ll_0);
        if(abs((ll_1-ll_0) / ll_0) < epsilon)
            return;
        end

        %% replacement
        full_theta_0 = full_theta_1;
        ll_0 = ll_1;
    end
    
end

