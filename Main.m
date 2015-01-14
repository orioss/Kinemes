clear;
base_folder = 'D:\MC\Kinesemes\Data\';
eeg_data_folder = [base_folder 'EEGData\'];
matlab_data_folder = [base_folder 'MatlabData\']; 
subjects = {'anastasia';'Judeh';'noga';'karin';'guycarmi';'guy';'shachart'; 'ronel';'itzik'; 'shacharaloni'}; 
%freq_bands = {[1 4] [4 12] [15 30] [30 45]};
freq_band = [30 45];
num_of_bins = 5;
num_of_freqs = 10;
relevant_events = 1:13;
ref_electrodes = [69 70];
electrodes_list = 1:64;
elec = 13;
iteration_num = 500;
shuffle_num = 200;

for subj=1:size(subjects,1)
    
    

    % make EEG preprocessing - filtering, rereferencing, removing
    % non-relevant events
    dataset_path = EEGPreprocessing(relevant_events, [eeg_data_folder subjects{subj} '\' subjects{subj} '.bdf'], ref_electrodes)
    
    dataset_path = [eeg_data_folder subjects{subj} '\' subjects{subj} '.set'];
    
    % create Time-Freuqency maps according to the pre-processed data
    CreateTimeFrequencyMaps(relevant_events, dataset_path, [matlab_data_folder subjects{subj} '\' 'cond_duration.mat'], electrodes_list); 
    
end