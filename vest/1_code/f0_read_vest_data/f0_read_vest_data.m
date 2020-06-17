% Project setup
global epoch_duration; 
epoch_duration = 60; % seconds

global fs; % sampling frequency
fs = 1000; % Hz

global nb_electrodes;
nb_electrodes = 252;
% End project setup

read_data_folder = './0_data/external/';
read_data_files = dir(strcat(read_data_folder,'*.dat'));
write_data_folder = './2_pipeline/f0_read_vest_data/out/';

nb_patients = length(read_data_files);
for pnb = 1:nb_patients
    ecg_brut = medtronic_read_vest_data(read_data_files(pnb).name);
    nb_ecg_samples = length(ecg_brut);
    epoch_nb_samples = epoch_duration*fs;
    nb_epochs = floor(nb_ecg_samples / epoch_nb_samples);
    last_sample = 1;    
    for epoch_nb = 1:nb_epochs
        end_sample = last_sample + epoch_nb_samples - 1;
        ep_samples = last_sample:end_sample;
        raw_ecg = ecg_brut(ep_samples,:);
        if (epoch_nb > 9)
            epoch_nb_char = num2str(epoch_nb);
        else
            epoch_nb_char = strcat('0',num2str(epoch_nb));
        end
        split_filename = split(read_data_files(pnb).name,'.');
        filename = split_filename{1}; extension = '.mat';
        write_data_filename = strcat(filename,'_',epoch_nb_char,extension);
        save(strcat(write_data_folder,write_data_filename),'raw_ecg');
    end
end



