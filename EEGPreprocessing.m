function [dataset_path] = EEGPreprocessing(relevant_events, ...
                                           bdfFileLocation, ...
                                           ref_electrodes)

    % initialize all the EEG files paths
    EEG = pop_biosig(bdfFileLocation);
    [pathstr,name,~] = fileparts(bdfFileLocation);
    dataset_path = [pathstr '\' name '.set'];
    pop_saveset(EEG,'filename',dataset_path);
    EEG = pop_loadset(dataset_path);
    
    % find all non-relevant events according to relevant events
    non_relevant_events = [];
    for k=1:size(EEG.event,2)
        if (~ismember(EEG.event(k).type,relevant_events))
            non_relevant_events = [non_relevant_events k];
        end
    end
    
    % removes the non-relevant events
    EEG = pop_editeventvals( EEG, 'delete', non_relevant_events);
    
    for i=1:size(EEG.event,2)
        EEG.event(i).type = i;
    end
    
    
    % saves the data set again
    pop_saveset(EEG,'filename',dataset_path)
    

    % filtering
    EEG = pop_eegfilt( EEG, 0.5, 40, [], [0], 0, 0, 'fir1', 0);
    
    
    % re-ref the data
    EEG = pop_reref(EEG, ref_electrodes);
    
    % run ICA
    %EEG = pop_runica(EEG,'Extended',1,'interupt','on')
    
    % saves the data set again
    pop_saveset(EEG,'filename',dataset_path)
    
end

