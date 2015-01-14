function [conds_data_summary, non_relevant_trials_RT] = ...
                            CreateCondDurationFiles(subject, matlab_folder)

conditions = 1:13;
non_relevant_trials_duration = []
non_relevant_trials_RT = []
current_folder = pwd;
subject_files_path = [matlab_folder subject '\'];
load([subject_files_path 'TimeData.mat']);

eval(['cd ' subject_files_path]); 

cond_duration = [];
files = dir('*.mat');
for file = files'
    if (~strcmp(file.name,'TimeData.mat') & ~strcmp(file.name,'cond_duration.mat'))
        name = file.name;
        [traceWord rest] = strtok(name,'_');
        [traceNumber rest] = strtok(rest, 'Cond_');
        [CondWord rest] = strtok(rest, 'Cond_');
        [condNumber rest] = strtok(CondWord, '.mat');
        trace_num = str2num(traceNumber);
        cond_duration = [cond_duration ; str2num(traceNumber)      ...
                         str2num(condNumber) timeData(trace_num,4) ...
                         timeData(trace_num,5)];
    end
end 
cond_duration = sortrows(cond_duration,1);
conds_data_summary = struct;
conds_data_summary.durations = [];
conds_data_summary.RT = [];
conds_data_summary.EEG_data.durations = [];
conds_data_summary.EEG_data.cond_duration = cond_duration;

for cond=1:size(conditions,2)
    cond_data_durations = cond_duration(cond_duration(:,2)==cond,3);
    cond_data_RT = cond_duration(cond_duration(:,2)==cond,4);
    conds_data_summary.durations = [conds_data_summary.durations; ...
                                    mean(cond_data_durations) ...
                                    max(cond_data_durations) ...
                                    min(cond_data_durations) ...
                                    std(cond_data_durations)];

    conds_data_summary.EEG_data.durations = [conds_data_summary.EEG_data.durations; ...
              ceil(mean(cond_data_durations)+std(cond_data_durations))];
    conds_data_summary.RT = [conds_data_summary.RT; ...
                             mean(cond_data_RT) ...
                             max(cond_data_RT) ...
                             min(cond_data_RT) ...
                             std(cond_data_RT)];


end

save('cond_duration.mat','cond_duration','conds_data_summary');

% removes non-relevant trials
for trial=1:size(cond_duration,1)
   cond = cond_duration(trial,2);
   
   % check durations
    if %((cond_duration(trial,3)<conds_data_summary.durations(cond,1)- ...
        %    (conds_data_summary.durations(cond,4))) || ... 
        %(cond_duration(trial,3)> ...
        %    conds_data_summary.durations(cond,1) + (conds_data_summary.durations(cond,4)))) ...
           (cond_duration(trial,3)<0.8)
               non_relevant_trials_duration = [non_relevant_trials_duration; trial cond_duration(trial,2)];
            non_relevant_trials_RT = [non_relevant_trials_RT; trial cond_duration(trial,2)];
%       
%    % check RT
%    elseif (cond_duration(trial,4)> ...
%            conds_data_summary.RT(cond,1) + (conds_data_summary.RT(cond,4))*1.5) ...
%            
%         non_relevant_trials_RT = [non_relevant_trials_RT; trial cond_duration(trial,2)];
   end
   
end


eval(['cd ' current_folder]); 


end