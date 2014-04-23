function [ full_theta_1 ] = moment_match_training( subject_type,subject_num )
%moment_match_training training
%   Detailed explanation goes here

    eta = 0.5;
    epsilon = 1e-5;
    max_t = 50;
    d_object_theta = 100;
    d_attribute_theta = 9;
    d_low_theta = 5;
    object_theta = zeros(d_object_theta, 1);
    attribute_theta = zeros(d_attribute_theta, 1);
    low_theta = zeros(d_low_theta, 1);
    ll_0 = log_likelihood(object_theta, attribute_theta, low_theta);
    full_theta_0 = [object_theta(:); attribute_theta(:); low_theta(:)];
    
    
    %% main part
    for t = 1 : max_t
        [phi_emp_sum, phi_theo_sum, derivation, Hessian, num_points] = get_subject_clip_training_info(...
            subject_type,subject_num,object_theta,attribute_theta,low_theta);
        
%         update
        full_theta_1 = full_theta_0 + eta * (Hessian \ derivation);
        
        full_theta_0 = full_theta_1;
        object_theta_1 = full_theta_1(1: d_object_theta);
        attribute_theta_1 = full_theta_1(d_object_theta+1, d_object_theta+d_attribute_theta);
        low_theta_1 = full_theta_1(d_object_theta+d_attribute_theta+1, end);
        
        ll_1 = log_likelihood(object_theta_1, attribute_theta_1, low_theta_1);
        
        sub_t = 1;
        sub_max_t = 10;
        while(ll_1 < ll_0 && sub_t < sub_max_t) % worse
            eta = eta * 0.5;
            full_theta_1 = full_theta_0 + eta * (Hessian \ derivation);
        
            full_theta_0 = full_theta_1;
            object_theta_1 = full_theta_1(1: d_object_theta);
            attribute_theta_1 = full_theta_1(d_object_theta+1, d_object_theta+d_attribute_theta);
            low_theta_1 = full_theta_1(d_object_theta+d_attribute_theta+1, end);
        
            ll_1 = log_likelihood(object_theta_1, attribute_theta_1, low_theta_1);
        end
        if(ll_1 > ll_0)
            eta = eta * 1.01;
        end
        ll_0 = ll_1;
        
        if(abs(ll_1-ll_0) / ll_0 < epsilon)
            return;
        end
    end
      
end

