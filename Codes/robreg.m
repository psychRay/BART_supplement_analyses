%% Robust regression(trial数作为covariates):

path_canlabcore = 'D:\Canlab_codes\CanlabCore';
path_robregtool = 'D:\Canlab_codes\RobustToolbox-master';
addpath(genpath(path_canlabcore));
addpath(genpath(path_robregtool));

folder_fmrimg_1st_Adt = 'E:\ImportantDOCs\currentWKdir\work_postdoc\BART_supplement\Firstlv_Group_Sorted_2019\Adults';
folder_fmrimg_1st_Chd = 'E:\ImportantDOCs\currentWKdir\work_postdoc\BART_supplement\Firstlv_Group_Sorted_2019\Children';
folder_fmrimg_1st_ageGroup = 'E:\ImportantDOCs\currentWKdir\work_postdoc\BART_supplement\Firstlv_Group_Sorted_2019\Children_Age';
cons     = {'pump', 'cashout', 'explode'};
cons_new = {'inflation', 'win', 'loss'  };
tab_cov = 'E:\ImportantDOCs\currentWKdir\work_postdoc\BART_supplement\trial_numbers_BART.csv';

%%
    %% ====================================================================================================
    % for：成人和儿童在各条件下的激活
    for n_cons=1:numel(cons)

        img_set  = dir([folder_fmrimg_1st_Chd '\' cons{1,n_cons} '\*nii']);
        imgs_set = {img_set(:).name}';
        imgs_set = cellfun(@(x) [img_set(1).folder '\' x], imgs_set, 'UniformOutput', false);

        [~, ~, image_names] = load_image_set(imgs_set);
        EXPT.SNPM.P{n_cons} = char(image_names);

    end
    % ====================================================================================================

    % ====================================================================================================
    % for：成人和儿童在各条件下的比较
    for n_cons=1:numel(cons)

        img_set_A = dir([folder_fmrimg_1st_Adt '\' cons{1,n_cons} '\*nii']);
        img_set_C = dir([folder_fmrimg_1st_Chd '\' cons{1,n_cons} '\*nii']);

        imgs_set_A = {img_set_A(:).name}';
        imgs_set_A = cellfun(@(x) [img_set_A(1).folder '\' x], imgs_set_A, 'UniformOutput', false);
        imgs_set_C = {img_set_C(:).name}';
        imgs_set_C = cellfun(@(x) [img_set_C(1).folder '\' x], imgs_set_C, 'UniformOutput', false);

        [~, ~, image_names] = load_image_set([imgs_set_A; imgs_set_C]);
        EXPT.SNPM.P{n_cons} = char(image_names);

    end
    % ====================================================================================================

[~, subject_names, ~] = load_image_set([imgs_set_A; imgs_set_C]);
EXPT.subjects  = subject_names;

    % ====================================================================================================
    % 从covariates表格中提取与当前组被试匹配的covariates
    T = readtable(tab_cov);
    columnName = 'ID';
    elementsToFind = cellfun(@(x) x(1:end-9), subject_names, 'UniformOutput', false);

    indices_subs = cellfun(@(x) find(strcmp(T.(columnName), x)), elementsToFind, 'UniformOutput', false);
    indices_subs = cell2mat(indices_subs);
    cov_mat = table2array(T(indices_subs, [2:4 6]));    % 需要根据实际情况选择提取的columns    
    % ====================================================================================================

EXPT.SNPM.connums  = [1 2 3];
EXPT.SNPM.connames = ['ift_Adt'; 'win_Adt'; 'los_Adt'];
EXPT.cov = [cov_mat(:, end) cov_mat(:,1:3)];
EXPT.mask = which('gray_matter_mask.img');

folder_stats = 'E:\ImportantDOCs\currentWKdir\work_postdoc\BART_supplement\stats_2nd-level';
statdir = fullfile(folder_stats, '\Rob_reg_results\A-C');
mkdir(statdir)
cd(statdir)

res_EXPT = robfit(EXPT);


%%
    %% ====================================================================================================
    % for：各年龄组儿童在各条件下的激活
    age_groups = {'Age_6_7', 'Age_8', 'Age_9', 'Age_10', 'Age_11_12'};
    EXPT.SNPM.connums  = [1 2 3];
    EXPT.SNPM.connames = ['ift_Adt'; 'win_Adt'; 'los_Adt'];
    EXPT.mask = which('gray_matter_mask.img');
    T = readtable(tab_cov);
    
    for n_group=1:numel(age_groups)
        
        for n_cons=1:numel(cons)

        img_set  = dir([folder_fmrimg_1st_ageGroup '\' cons{1,n_cons} '\' age_groups{1, n_group} '\*nii']);
        imgs_set = {img_set(:).name}';
        imgs_set = cellfun(@(x) [img_set(1).folder '\' x], imgs_set, 'UniformOutput', false);

        [~, ~, image_names] = load_image_set(imgs_set);
        EXPT.SNPM.P{n_cons} = char(image_names);

        end
        
        [~, subject_names, ~] = load_image_set(imgs_set);
        EXPT.subjects  = subject_names;
        
        % ====================================================================================================
        % 从covariates表格中提取与当前组被试匹配的covariates
        columnName = 'ID';
        elementsToFind = cellfun(@(x) x(1:end-9), subject_names, 'UniformOutput', false);

        indices_subs = cellfun(@(x) find(strcmp(T.(columnName), x)), elementsToFind, 'UniformOutput', false);
        indices_subs = cell2mat(indices_subs);
        cov_mat = table2array(T(indices_subs, 2:4));    % 需要根据实际情况选择提取的columns    
        % ====================================================================================================
        
        EXPT.cov = cov_mat;
        
        folder_stats = 'E:\ImportantDOCs\currentWKdir\work_postdoc\BART_supplement\stats_2nd-level';
        statdir = fullfile(folder_stats, ['\Rob_reg_results\Children_ageG\' age_groups{1, n_group}]);
        mkdir(statdir)
        cd(statdir)
        
        res_EXPT = robfit(EXPT);
    
    end
    % ====================================================================================================