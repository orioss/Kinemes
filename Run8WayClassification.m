function [results] = Run8WayClassification(classification_data_path,  ...
                                           classification_type,       ...
                                           output_folder,             ...
                                           iteration_num,             ...
                                           labels_to_classify)

% loads the classification data
load(classification_data_path);

% calculate the minimum number of trials used for classification (might be
% more bad trials in one label than the other)
train_sizes = [];
for label=1:length(labels_to_classify)
    eval(['train_sizes = [train_sizes; size(class_data.power.cond_' num2str(labels_to_classify(label)) ',1)]; ']);
end    
min_size = min(train_sizes);

% initialize results data structure
results = struct;
power_total_acc = 0;
power_shuffle_total_acc = 0;
power_prob_estimates = {};

% make X itrations for classification
for i=1:iteration_num
    ['iteration: ' num2str(i)]
    
    % construct the train and test information
    power_test_data = [];
    power_train_data = [];
    test_labels = [];
    train_labels = [];
    
    % go over all the labels and make leave-one-out
    for label=1:length(labels_to_classify)
        
        % gets the matrix from the classification data (rows are the
        % trials, columns - features)
        eval(['iter_data = class_data.power.cond_' num2str(labels_to_classify(label)) ';']);
        
        % choose random trial as test for this label and adds it to the test data
        test_ind = ceil(rand(1)*(size(iter_data,1)-1));
        power_test_data = [power_test_data; iter_data(test_ind,:)]; 
       
        % adds other trials of this label (remove the one in the test
        % index) to the training data). also takes number of trials
        % according to the minimum size.
        iter_data(test_ind,:) = [];
        power_train_data = [power_train_data; iter_data(1:min_size-1,:)];
        
        % update the labels arrays with this label
        test_labels = [test_labels; labels_to_classify(label)];
        train_labels = [train_labels; repmat(labels_to_classify(label), size(power_train_data_cur,1),1)];
    end    
    
       % classify power and adds to the accuracy
       model = svmtrain(train_labels,double(power_train_data));
       [predicted_label, accuracy, prob_estimates] = svmpredict(test_labels, double(power_test_data), model);
       power_total_acc = power_total_acc + accuracy(1);
       power_prob_estimates{i} = prob_estimates;
       
       % classify power shuffle and add to the accuracy
       model = svmtrain(train_labels(randperm(length(train_labels))),double(power_train_data));
       [predicted_label, accuracy, prob_estimates] = svmpredict(test_labels, double(power_test_data), model);
       power_shuffle_total_acc = power_shuffle_total_acc + accuracy(1);
       power_shuffle_prob_estimates{i} = prob_estimates;     
              
end

% update the results with the averaged accuracy and saves it in the output
% folder
results.power_accuracy = power_total_acc/iteration_num;
results.power_shuffle_accuracy = power_shuffle_total_acc/iteration_num;
results.power_prob_estimates = power_prob_estimates;
results.power_shuffle_prob_estimates = power_shuffle_prob_estimates;
save([output_folder classification_type '_results.mat'],'results');

end

