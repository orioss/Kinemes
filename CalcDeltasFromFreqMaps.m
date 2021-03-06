function CalcDeltasFromFreqMaps(events_list, dataset_path,                ...
                                electrodes_list, calc_energies_MFCC_like, ...
                                times_file_path)
                            

load(times_file_path);

%% settings
windowSize_delta = 9; % Odd number
windowSize_delta_delta = 5; % Odd number

%% create destination folders
[pathstr, ~, ~] = fileparts(dataset_path);

if calc_energies_MFCC_like
    % Calc deltas from filttered spectograms into energy coefficients
    spect_deltas_folder = [pathstr '\components\timef_deltas\'];
    spect_deltas_deltas_folder = [pathstr '\components\timef_deltas_deltas\'];
    mkdir(spect_deltas_folder);

    spect_folder = [pathstr '\components\timef_energies\'];
else
    % Calc detlas from orignial spectograms
    spect_deltas_folder = [pathstr '\components\timef_deltas\'];
    spect_deltas_deltas_folder = [pathstr '\components\timef_deltas_deltas\'];
    mkdir(spect_deltas_folder);
    mkdir(spect_deltas_deltas_folder);

    spect_folder = [pathstr '\components\timef\'];
end

%% Calc Deltas and save in new array
for event = 1:size(conds_data_summary.EEG_data.cond_duration,1)
    
    % check if the condition of the event is relevant (part of the
    % events list)
    condition = conds_data_summary.EEG_data.cond_duration(event,2);
    if (~ismember(condition,events_list))
       continue;
    end
      
    % loads the relevant spectograms
    load([spect_folder 'event_' num2str(event) '.mat'], 'allersp')
    init = true;
    
    % Calc delta
    for elec = electrodes_list
        % create empty arrays if first electrode
        if init  
            allersp_deltas        = zeros(size(allersp));
            allersp_deltas_deltas = zeros(size(allersp));
            init = false;
        end
        
        % Calc deltas and delta-deltas
        allersp_deltas(:, :, elec)        = calcDeltas(allersp(:,:, elec), windowSize_delta); % Data, window-size
        allersp_deltas_deltas(:, :, elec) = calcDeltas(calcDeltas(allersp_deltas,5), windowSize_delta_delta);
    end
    
    % save deltas and delta-deltas in new folder
    allersp = allersp_deltas;
    save([spect_deltas_folder 'event_' num2str(event) '.mat'], 'allersp')
    allersp = allersp_deltas_deltas;
    save([spect_deltas_deltas_folder 'event_' num2str(event) '.mat'], 'allersp')
    
    % Clear from memory
    clear 'allersp' 'allersp_deltas' 'allersp_deltas_deltas'
    
end
    
end