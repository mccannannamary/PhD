read_data_folder = './2_pipeline/f0_read_vest_data/out/';
read_data_files = dir(strcat(read_data_folder,'*.mat'));
write_data_folder = './2_pipeline/f1_measure_electrode_quality/out/';

nb_data_files = length(read_data_files);
epoch_nb_samples = epoch_duration*fs;
time_vec = [0:epoch_nb_samples-1]/fs; lcf = 0.1; hcf = []; aff = 0;
for data_file_nb = 1:nb_data_files
   raw_ecg = load(strcat(read_data_folder,read_data_files(data_file_nb).name));
   raw_ecg = raw_ecg.raw_ecg;
   % check each stream's quality
   for electrode_number = 1:nb_electrodes
       [~,~,mean_quality(electrode_number)] = ...
           Get_Quality(raw_ecg(:,electrode_number),time_vec,fs,lcf,hcf,aff);
   end
   high_quality_electrodes = find(mean_quality > 0.75);
   write_data_filename = read_data_files(data_file_nb).name;
   save(strcat(write_data_folder,write_data_filename),'high_quality_electrodes');
end


