
%% extract number of trials of each condition
folder_1st = 'E:\ImportantDOCs\currentWKdir\work_postdoc\BART_supplement\stats_1st-level';
file_behv  = 'E:\ImportantDOCs\currentWKdir\work_postdoc\BART_supplement\BART_Behavior_Analyses_298.xlsx';
behv_bart  = readtable(file_behv);
subIDs = behv_bart.ID;

trial_num = struct;
for i=1:numel(subIDs)
    
    fpath_sub_tDesign = [folder_1st '\' subIDs{i,1} '\task_design.mat'];
    onsets = load(fpath_sub_tDesign, 'onsets');
    
    trial_num.ID{i,1} = subIDs{i,1};
    trial_num.inflation{i,1} = numel(onsets.onsets{1,1});
    trial_num.win{i,1} = numel(onsets.onsets{1,2});
    trial_num.loss{i,1} = numel(onsets.onsets{1,3});
    
end

table_trialNum = struct2table(trial_num);
fpath_save = [folder_1st '\..\trial_numbers_BART.csv'];
writetable(table_trialNum, fpath_save);
