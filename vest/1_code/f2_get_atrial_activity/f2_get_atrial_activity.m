% Read data one at a time, remove baseline wander for high quality
% electrodes, ignore data from electrodes that isn't high quality.

read_data_folder = './2_pipeline/f0_read_vest_data/out/';
read_high_quality_electrodes_folder = ...
    './2_pipeline/f1_measure_electrode_quality/out/';
write_data_folder = './2_pipeline/f2_get_atrial_activity/out/';

read_data_files = dir(strcat(read_data_folder,'*.mat'));
read_high_quality_electrodes_files = ...
    dir(strcat(read_high_quality_electrodes_folder,'*.mat'));

nb_data_files = length(read_data_files);
aff = 0;

for data_file_nb = 1:nb_data_files
   filename = read_data_files(data_file_nb).name;
   raw_ecg = load(strcat(read_data_folder,filename));
   raw_ecg = raw_ecg.raw_ecg;
   high_quality_electrodes = load(strcat(read_high_quality_electrodes_folder,...
       read_high_quality_electrodes_files(data_file_nb).name));
   high_quality_electrodes = high_quality_electrodes.high_quality_electrodes;
   [baseline_ecg,atrial_act_ecg,~,~] = ...
       main_cancellation_CHUV(raw_ecg(:,high_quality_electrodes),filename,fs,aff);
   write_data_filename = filename;
   save(strcat(write_data_folder,write_data_filename),'baseline_ecg','atrial_act_ecg');
end

