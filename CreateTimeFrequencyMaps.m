function CreateTimeFrequencyMaps(events_list, dataset_path, ...
                                 times_file_path, electrodes_list)

    % loads the relevant EEG data and times
    EEG = pop_loadset(dataset_path);
    load(times_file_path);
    
    % create destination folders
    [pathstr,name,~] = fileparts(dataset_path);
    epochs_folder = [pathstr '\components\epochs\'];
    spect_folder = [pathstr '\components\timef\'];
    mkdir(epochs_folder);
    mkdir(spect_folder);
    
    % go over all the events and product spectograms according to their
    % conditions
    for event = 1:size(conds_data_summary.EEG_data.cond_duration,1)
        
       % check if the condition of the event is relevant (part of the
       % events list)
       condition = conds_data_summary.EEG_data.cond_duration(event,2);
       if (~ismember(condition,events_list))
           continue;
       end
       
       % divide the continuous data to epochs according to the relevant
       % duration
       event_duration_threshold = conds_data_summary.EEG_data.cond_duration(event,3);
       disp(strcat('creating spectogram for condition: ', event));
       
       limit_start = -2;
       limit_end = event_duration_threshold;
       EEG_new = pop_epoch( EEG, { event }, [limit_start limit_end]);
       
       % saves the epochs in the relevant folder
       pop_saveset(EEG_new,'filename', [epochs_folder 'event_' num2str(event)]);
       EEG_new.chanlocs=pop_chanedit(EEG_new.chanlocs, 'load',{ 'D:\MC\Kinesemes\Data\EEGData\ChannelsLocation.locs', 'filetype', 'autodetect'});
       init  = 1;
       num_of_electrodes = length(electrodes_list);
       for elec = electrodes_list 
    
            %tmpsig = (EEG_new.icaweights(elec,:)*EEG_new.icasphere)*reshape(EEG_new.data(:,:,:), EEG_new.nbchan, size(EEG_new.data,2)*size(EEG_new.data,3));
            tmpsig = EEG_new.data(elec,:);
            [ersp,itc,powbase,times,freqs,erspboot,itcboot] = newtimef(tmpsig, ...
             size(EEG_new.data,2) , [limit_start EEG_new.xmax]*1000,EEG_new.srate, [3 0.5],  ...
             'topovec', elec, ...
             'elocs', EEG_new.chanlocs, ...
            'chaninfo', EEG_new.chaninfo, ...
             'alpha', 0.05, 'plotitc','off', 'plotersp','off', 'plotphase', 'off', ... 
             'baseline', [(limit_start*1000+500) 0], 'nfreqs', 80, 'freqs', [3 45], ...
             'trialbase', 'on',...
            'timesout', 200, ...
            'padratio', 16, ...
            'verbose', 'off');...'freqs', [1 45],

            if init == 1  % create empty arrays if first electrode
                allersp = zeros([ size(ersp) num_of_electrodes ]);
                allitc = zeros([ size(itc) num_of_electrodes ]);
                allpowbase = zeros([ size(powbase) num_of_electrodes ]);
                alltimes = zeros([ size(times) num_of_electrodes ]);
                allfreqs = zeros([ size(freqs) num_of_electrodes ]);
                allerspboot = zeros([ size(erspboot) num_of_electrodes ]);
                allitcboot = zeros([ size(itcboot) num_of_electrodes ]);
                init = 0;
                total_ersp = ersp;
            end;

            allersp (:,:,elec) = ersp;
            allitc (:,:,elec) = itc;
            allpowbase (:,:,elec) = powbase;
            alltimes (:,:,elec) = times;
            allfreqs (:,:,elec) = freqs;
            allerspboot (:,:,elec) = erspboot;
            allitcboot (:,:,elec) = itcboot;
            total_ersp = total_ersp + ersp;  
         
       end
   
       % check the maximal ersp value averages across electrodes to get the
       % scalp map at that time and frequency
       [maxVal, maxInd] = max(total_ersp(:,times>0));
       [minVal, minInd] = min(total_ersp(:,times>0));
       max_col = find(maxVal==max(maxVal));
       min_col = find(minVal==min(minVal));
       max_row = maxInd(max_col);
       min_row = minInd(min_col);
       max_time  = times(length(times(times<0))+max_col);
       min_time  = times(length(times(times<0))+min_col);
       max_freq = freqs(max_row);
       min_freq = freqs(min_row);
       
       % create whole brain figure and saves it
       eval([name '_event' num2str(event) '_timef_figure = figure;']);
       EEG_new.chanlocs=pop_chanedit(EEG_new.chanlocs, 'load',{ 'D:\MC\Kinesemes\Data\EEGData\ChannelsLocation.locs', 'filetype', 'autodetect'});
       tftopo(allersp,alltimes(:,:,1),allfreqs(:,:,1),'mode','rms',...
       'signifs', allerspboot, 'sigthresh', [6], 'smooth',8,...
       'timefreqs', [min_time min_freq ; max_time max_freq; ], ...
       'chanlocs', EEG_new.chanlocs, 'title', ['condition ' num2str(event)]);
   
       % save the figure for the specific trial
       mkdir([pathstr '\components\tftopos\' num2str(condition) '\']);
       eval(['saveas(' name '_event' num2str(event) '_timef_figure,''' pathstr '\components\tftopos\' num2str(condition) '\event_' num2str(event) '.jpg'')']);
   
       % closes the figure's window
       close all;
       
       % saves the spectogram in the relevant folder and file
        save([spect_folder 'event_' num2str(event) '.mat'],     ...
              'allersp', 'alltimes', 'allfreqs','allitc',       ...
              'allerspboot','allpowbase');

    end
end

