function [ data_path ] = Run8WayClassificationDataConstruction(dataset_path,      ...
                                                               cond_time_data,    ...
                                                               timef_source_path, ...
                                                               labels,            ...
                                                               num_of_bins,       ...
                                                               freq_band)

% loads the EEG and the cond_time information
EEG = pop_loadset(dataset_path);
load(cond_time_data);

% Constructing the folders and files for classification
[pathstr,name,~] = fileparts(dataset_path);
data_path = [data_folder '\components\classification\'];
mkdir(data_path);

% construct the classification data structure
class_data = struct;
class_data.labels = labels;
for i=1:labels
    label = labels(i);
    eval(['class_data.label_' num2str(label) ' = [];']);
end
    
for i = 1:size(conds_data_summary.EEG_data.cond_duration,1)
      
    % check what is the condition of the specific trial
    cond = conds_data_summary.EEG_data.cond_duration(i,2);
    if (~ismember(cond,labels))
        continue;
    end
    
    % load the trial's timef file
    new_timef_file_path = [timef_source_path '\event_' num2str(i)];
    load(new_timef_file_path);
   
    % filter the to the relevant band
    relevant_ersp = ersp(freqs>freq_band(1) & freqs<freq_band(2),times>0);
    
    % average the time axis according to the time bins
    time_step_size = floor(size(relevant_ersp,2)/num_of_bins);
    bin_ave_relevant_ersp = []
    
    % go over all the bins and average bin by bin
    for y=1:num_of_bins
        
        % in case it's the final bin - average to end
        if ((y+1)*time_step_size > size(relevant_ersp,2))
            bin_ave_relevant_ersp = [bin_ave_relevant_ersp; ...
                      (mean(relevant_ersp(:,y*time_step_size:size(relevant_ersp,2)),2))];                       
            break;
        end
        
        % average the bin
        bin_ave_relevant_ersp = [bin_ave_relevant_ersp; ...
                 (mean(relevant_ersp(:,y*time_step_size:(y+1)*time_step_size),2))];
    end
    
    % saves to the full structure
    eval(['class_data.power.cond_' num2str(cond) ' = [class_data.power.cond_' num2str(cond) '; bin_ave_relevant_ersp'']']);
    save([data_path 'data_for_classification.mat'],'class_data');

end
end

