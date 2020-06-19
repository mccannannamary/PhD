% Read atrial activity ecg files one at a time. Calculate instantaneous
% frequency (IF) over time separately for the signal on each electrode.

% script setup
read_data_folder = './2_pipeline/s3_get_atrial_activity/out/';
write_data_folder = './2_pipeline/s4_get_inst_frequency/out/';

read_data_files = dir(strcat(read_data_folder,'*.mat'));
nb_data_files = length(read_data_files);

% parameter definitions
aff = 0; fs_resample = 50; beta = 0.95; delta = 0.95; df_init = 'auto';
oi_mode = 'pwelch'; fenetre = get_PD_fenetre(epoch_duration);
cut_duration_sec = 1; 
for data_file_nb = 1:nb_data_files
   atrial_act_ecg = load(strcat(read_data_folder,read_data_files(data_file_nb).name)); 
   atrial_act_ecg = atrial_act_ecg.atrial_act_ecg;
   atrial_act_ecg = filtre(atrial_act_ecg);
   nb_electrodes = size(atrial_act_ecg,1); 
   % pre-allocate vectors/matrices to store data
   [inst_frequency, slope_phase_diff, adaptive_phase_diff, adaptive_org_index] = ...
    deal(zeros(nb_electrodes,fs_resample*epoch_duration));
   [avg_inst_frequency, avg_adaptive_oi] = deal(zeros(1,nb_electrodes));
   for k = 1:nb_electrodes
      % CHECK ORIENTATION OF ATRIAL_ACT_ECG
      aa_ecg_one_elec = atrial_act_ecg(k,:);
      aa_ecg_one_elec_resampled = resample(aa_ecg_one_elec,...
          fs_resample,fs);
      % get initial frequency estimate to give to IF tracker
      df_estimate = get_ECG_dominant_frequency(df_init,true,oi_mode,...
          aa_ecg_one_elec_resampled,aa_ecg_one_elec_resampled,...
          fs_resample,data_file_nb,k);
      % CHECK THAT ORIENTATION BELOW MAKES SENSE, check value for
      % df_estimate
      [inst_frequency(k,:), avg_inst_frequency(k), slope_phase_diff(k,:),...
          adaptive_phase_diff(k,:),adaptive_org_index(k,:), avg_adaptive_oi(k)] = ...
          hft(aa_ecg_one_elec_resampled', df_estimate,beta,delta,fenetre);
      % do actual frequency tracking
   end
   save(strcat(write_data_folder,read_data_files(data_file_nb).name),...
       'inst_frequency','avg_inst_frequency','slope_phase_diff',...
       'adaptive_phase_diff','adaptive_org_index','avg_adaptive_oi');
end